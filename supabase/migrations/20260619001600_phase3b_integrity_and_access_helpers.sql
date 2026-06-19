create or replace function private.is_catalog_taxonomy_reader()
returns boolean
language sql
stable
security definer
set search_path = ''
as $$
  select private.is_admin_or_super_admin()
    or (
      private.current_company_id() is not null
      and private.current_company_role() in (
        'company_admin',
        'product_manager'
      )
    );
$$;

create or replace function private.can_read_product_draft(
  target_product_id uuid
)
returns boolean
language sql
stable
security definer
set search_path = ''
as $$
  select private.is_admin_or_super_admin()
    or coalesce(
      exists (
        select 1
        from public.products as product
        where product.id = target_product_id
          and product.status = 'draft'
          and private.is_active_company_member(product.company_id)
          and private.current_company_role() in (
            'company_admin',
            'marketing_manager',
            'product_manager'
          )
      ),
      false
    );
$$;

create or replace function private.can_manage_product_draft(
  target_product_id uuid
)
returns boolean
language sql
stable
security definer
set search_path = ''
as $$
  select private.is_admin_or_super_admin()
    or coalesce(
      exists (
        select 1
        from public.products as product
        where product.id = target_product_id
          and product.status = 'draft'
          and private.has_company_role(
            product.company_id,
            array[
              'company_admin',
              'product_manager'
            ]::public.company_role[]
          )
      ),
      false
    );
$$;

create or replace function private.validate_drug_class_hierarchy()
returns trigger
language plpgsql
security definer
set search_path = ''
as $$
begin
  if new.parent_drug_class_id is null then
    return new;
  end if;

  if new.parent_drug_class_id = new.id
    or exists (
      with recursive descendants as (
        select child.id, child.parent_drug_class_id
        from public.drug_classes as child
        where child.id = new.parent_drug_class_id
        union all
        select child.id, child.parent_drug_class_id
        from public.drug_classes as child
        join descendants on child.id = descendants.parent_drug_class_id
      )
      select 1 from descendants where id = new.id
    ) then
    raise exception using
      errcode = '23514',
      message = 'Drug class hierarchy cycles are not allowed.';
  end if;

  return new;
end;
$$;

create or replace function private.validate_taxonomy_activation()
returns trigger
language plpgsql
security definer
set search_path = ''
as $$
begin
  if not new.is_active then
    return new;
  end if;

  if tg_table_name = 'drug_classes' then
    if not exists (
      select 1 from public.drug_class_translations
      where drug_class_id = new.id and locale = 'en'
    ) then
      raise exception using
        errcode = '23514',
        message = 'An English translation is required before activation.';
    end if;
    if new.parent_drug_class_id is not null
      and not exists (
        select 1 from public.drug_classes
        where id = new.parent_drug_class_id and is_active
      ) then
      raise exception using
        errcode = '23514',
        message = 'The parent drug class must be active.';
    end if;
  elsif tg_table_name = 'active_ingredients' then
    if not exists (
      select 1 from public.active_ingredient_translations
      where active_ingredient_id = new.id and locale = 'en'
    ) then
      raise exception using
        errcode = '23514',
        message = 'An English translation is required before activation.';
    end if;
  elsif tg_table_name = 'generic_drugs' then
    if not exists (
      select 1 from public.generic_drug_translations
      where generic_drug_id = new.id and locale = 'en'
    ) or not exists (
      select 1
      from public.generic_drug_ingredients as composition
      join public.active_ingredients as ingredient
        on ingredient.id = composition.active_ingredient_id
      where composition.generic_drug_id = new.id
        and ingredient.is_active
    ) or not exists (
      select 1 from public.drug_classes
      where id = new.drug_class_id and is_active
    ) then
      raise exception using
        errcode = '23514',
        message = 'An active class, active ingredient, and English translation are required before activation.';
    end if;
  end if;

  return new;
end;
$$;

create or replace function private.validate_product_draft()
returns trigger
language plpgsql
security definer
set search_path = ''
as $$
begin
  if new.status <> 'draft' then
    raise exception using
      errcode = '23514',
      message = 'Phase 3B products must remain draft.';
  end if;

  if not private.is_verified_company(new.company_id) then
    raise exception using
      errcode = '23514',
      message = 'Product drafts require a verified company.';
  end if;

  if not exists (
    select 1 from public.drug_classes
    where id = new.drug_class_id and is_active
  ) then
    raise exception using
      errcode = '23514',
      message = 'Product drafts require an active drug class.';
  end if;

  if new.category in ('prescription_drug', 'otc_drug')
    and not exists (
      select 1 from public.generic_drugs
      where id = new.generic_drug_id and is_active
    ) then
    raise exception using
      errcode = '23514',
      message = 'Prescription and OTC drafts require an active generic drug.';
  end if;

  return new;
end;
$$;

create or replace function private.prevent_product_ownership_change()
returns trigger
language plpgsql
set search_path = ''
as $$
begin
  if new.company_id is distinct from old.company_id then
    raise exception using
      errcode = '55000',
      message = 'Product company ownership is immutable.';
  end if;
  return new;
end;
$$;

create or replace function private.validate_product_market()
returns trigger
language plpgsql
security definer
set search_path = ''
as $$
begin
  if not exists (
    select 1 from public.countries
    where id = new.country_id and iso_code = 'IQ' and is_active
  ) then
    raise exception using
      errcode = '23514',
      message = 'Phase 3B supports Iraq market records only.';
  end if;
  return new;
end;
$$;

create or replace function private.validate_product_specialty()
returns trigger
language plpgsql
security definer
set search_path = ''
as $$
begin
  if not exists (
    select 1 from public.specialties
    where id = new.specialty_id and is_active
  ) then
    raise exception using
      errcode = '23514',
      message = 'Only active specialties may be assigned.';
  end if;
  return new;
end;
$$;

create or replace function private.refresh_product_presentation_fingerprint(
  target_product_id uuid
)
returns text
language plpgsql
security definer
set search_path = ''
as $$
declare
  fingerprint_value text;
begin
  select encode(
    extensions.digest(
      concat_ws(
        '|',
        product.company_id::text,
        private.normalize_english_text(translation.brand_name),
        product.category::text,
        coalesce(product.generic_drug_id::text, ''),
        product.drug_class_id::text,
        market.country_id::text,
        private.normalize_english_text(market.strength),
        private.normalize_english_text(market.dosage_form),
        private.normalize_english_text(market.route),
        private.normalize_english_text(market.pack_size)
      ),
      'sha256'
    ),
    'hex'
  )
  into fingerprint_value
  from public.products as product
  join public.product_translations as translation
    on translation.product_id = product.id and translation.locale = 'en'
  join public.product_markets as market
    on market.product_id = product.id
  where product.id = target_product_id;

  update public.products
  set presentation_fingerprint = fingerprint_value
  where id = target_product_id;

  return fingerprint_value;
end;
$$;

create trigger drug_classes_set_updated_at
before update on public.drug_classes
for each row execute function private.set_updated_at();
create trigger drug_class_translations_set_updated_at
before update on public.drug_class_translations
for each row execute function private.set_updated_at();
create trigger active_ingredients_set_updated_at
before update on public.active_ingredients
for each row execute function private.set_updated_at();
create trigger active_ingredient_translations_set_updated_at
before update on public.active_ingredient_translations
for each row execute function private.set_updated_at();
create trigger generic_drugs_set_updated_at
before update on public.generic_drugs
for each row execute function private.set_updated_at();
create trigger generic_drug_translations_set_updated_at
before update on public.generic_drug_translations
for each row execute function private.set_updated_at();
create trigger products_set_updated_at
before update on public.products
for each row execute function private.set_updated_at();
create trigger product_translations_set_updated_at
before update on public.product_translations
for each row execute function private.set_updated_at();
create trigger product_markets_set_updated_at
before update on public.product_markets
for each row execute function private.set_updated_at();
create trigger product_market_translations_set_updated_at
before update on public.product_market_translations
for each row execute function private.set_updated_at();
create trigger product_media_set_updated_at
before update on public.product_media
for each row execute function private.set_updated_at();
create trigger product_brochures_set_updated_at
before update on public.product_brochures
for each row execute function private.set_updated_at();

create trigger drug_classes_validate_hierarchy
before insert or update of parent_drug_class_id on public.drug_classes
for each row execute function private.validate_drug_class_hierarchy();
create trigger drug_classes_validate_activation
before insert or update of is_active on public.drug_classes
for each row execute function private.validate_taxonomy_activation();
create trigger active_ingredients_validate_activation
before insert or update of is_active on public.active_ingredients
for each row execute function private.validate_taxonomy_activation();
create trigger generic_drugs_validate_activation
before insert or update of is_active on public.generic_drugs
for each row execute function private.validate_taxonomy_activation();
create trigger products_validate_draft
before insert or update on public.products
for each row execute function private.validate_product_draft();
create trigger products_immutable_company
before update on public.products
for each row execute function private.prevent_product_ownership_change();
create trigger product_markets_validate_country
before insert or update of country_id on public.product_markets
for each row execute function private.validate_product_market();
create trigger product_specialties_validate_active
before insert or update of specialty_id on public.product_specialties
for each row execute function private.validate_product_specialty();

revoke all on function private.is_catalog_taxonomy_reader() from public;
revoke all on function private.can_read_product_draft(uuid) from public;
revoke all on function private.can_manage_product_draft(uuid) from public;
revoke all on function private.validate_drug_class_hierarchy() from public;
revoke all on function private.validate_taxonomy_activation() from public;
revoke all on function private.validate_product_draft() from public;
revoke all on function private.prevent_product_ownership_change() from public;
revoke all on function private.validate_product_market() from public;
revoke all on function private.validate_product_specialty() from public;
revoke all on function private.refresh_product_presentation_fingerprint(uuid)
  from public;
