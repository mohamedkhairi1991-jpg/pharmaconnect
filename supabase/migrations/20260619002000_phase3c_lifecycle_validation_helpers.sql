drop trigger products_validate_draft on public.products;

create or replace function private.product_validation_errors(
  target_product_id uuid,
  validation_stage text
)
returns text[]
language plpgsql
stable
security definer
set search_path = ''
as $$
declare
  target_product public.products;
  errors text[] := array[]::text[];
  iraq_market public.product_markets;
begin
  if validation_stage not in ('submission', 'publication') then
    raise exception using
      errcode = '22023',
      message = 'Validation stage must be submission or publication.';
  end if;

  select * into target_product
  from public.products
  where id = target_product_id;

  if not found then
    return array['product_not_found'];
  end if;

  if not private.is_verified_company(target_product.company_id) then
    errors := array_append(errors, 'company_not_verified');
  end if;

  if not exists (
    select 1 from public.drug_classes
    where id = target_product.drug_class_id and is_active
  ) then
    errors := array_append(errors, 'drug_class_not_active');
  end if;

  if target_product.category in ('prescription_drug', 'otc_drug') then
    if target_product.generic_drug_id is null or not exists (
      select 1 from public.generic_drugs
      where id = target_product.generic_drug_id and is_active
    ) then
      errors := array_append(errors, 'generic_drug_not_active');
    elsif not exists (
      select 1
      from public.generic_drug_ingredients as composition
      join public.active_ingredients as ingredient
        on ingredient.id = composition.active_ingredient_id
      where composition.generic_drug_id = target_product.generic_drug_id
        and ingredient.is_active
    ) then
      errors := array_append(errors, 'generic_composition_invalid');
    end if;
  end if;

  if not exists (
    select 1 from public.product_translations
    where product_id = target_product_id and locale = 'en'
      and btrim(brand_name) <> ''
  ) then
    errors := array_append(errors, 'english_product_translation_missing');
  end if;

  select market.* into iraq_market
  from public.product_markets as market
  join public.countries as country on country.id = market.country_id
  where market.product_id = target_product_id
    and country.iso_code = 'IQ'
    and country.is_active
  limit 1;

  if not found then
    errors := array_append(errors, 'iraq_market_missing');
  else
    if not exists (
      select 1 from public.product_market_translations
      where product_market_id = iraq_market.id and locale = 'en'
        and btrim(storage_conditions) <> ''
        and btrim(approved_indications) <> ''
        and btrim(usual_adult_dose) <> ''
        and btrim(contraindications) <> ''
        and btrim(common_adverse_effects) <> ''
    ) then
      errors := array_append(errors, 'english_iraq_content_missing');
    end if;

    if validation_stage = 'publication'
      and iraq_market.market_status <> 'marketed_in_iraq' then
      errors := array_append(errors, 'not_marketed_in_iraq');
    end if;
  end if;

  if not exists (
    select 1
    from public.product_specialties as product_specialty
    join public.specialties as specialty
      on specialty.id = product_specialty.specialty_id
    where product_specialty.product_id = target_product_id
      and specialty.is_active
  ) then
    errors := array_append(errors, 'active_specialty_missing');
  end if;

  if target_product.presentation_fingerprint is null then
    errors := array_append(errors, 'presentation_fingerprint_missing');
  end if;

  if target_product.presentation_fingerprint is not null and exists (
    select 1
    from public.products as duplicate
    where duplicate.company_id = target_product.company_id
      and duplicate.presentation_fingerprint =
        target_product.presentation_fingerprint
      and duplicate.id <> target_product_id
  ) then
    errors := array_append(errors, 'duplicate_presentation');
  end if;

  return errors;
end;
$$;

create or replace function private.is_product_submission_ready(
  target_product_id uuid
)
returns boolean
language sql
stable
security definer
set search_path = ''
as $$
  select cardinality(
    private.product_validation_errors(target_product_id, 'submission')
  ) = 0;
$$;

create or replace function private.is_product_publishable(
  target_product_id uuid
)
returns boolean
language sql
stable
security definer
set search_path = ''
as $$
  select coalesce(
    exists (
      select 1
      from public.products as product
      where product.id = target_product_id
        and product.status = 'submitted'
        and product.submitted_by is not null
        and product.submitted_at is not null
    ),
    false
  )
  and cardinality(
    private.product_validation_errors(target_product_id, 'publication')
  ) = 0;
$$;

create or replace function private.can_manage_official_product_content(
  target_product_id uuid
)
returns boolean
language sql
stable
security definer
set search_path = ''
as $$
  select coalesce(
    exists (
      select 1
      from public.products as product
      where product.id = target_product_id
        and product.status in ('draft', 'changes_requested')
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

create or replace function private.can_read_company_product_record(
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

create or replace function private.is_official_catalog_product_visible(
  target_product_id uuid
)
returns boolean
language sql
stable
security definer
set search_path = ''
as $$
  select coalesce(
    exists (
      select 1
      from public.products as product
      join public.companies as company on company.id = product.company_id
      join public.product_markets as market on market.product_id = product.id
      join public.countries as country on country.id = market.country_id
      where product.id = target_product_id
        and product.status = 'published'
        and product.submitted_by is not null
        and product.submitted_at is not null
        and product.reviewed_by is not null
        and product.reviewed_at is not null
        and product.published_by is not null
        and product.published_at is not null
        and company.status = 'verified'
        and country.iso_code = 'IQ'
        and country.is_active
        and market.market_status = 'marketed_in_iraq'
    ),
    false
  );
$$;

create or replace function private.can_read_official_catalog_product(
  target_product_id uuid
)
returns boolean
language sql
stable
security definer
set search_path = ''
as $$
  select private.is_approved_doctor()
    and private.is_official_catalog_product_visible(target_product_id);
$$;

create or replace function private.validate_product_catalog_record()
returns trigger
language plpgsql
security definer
set search_path = ''
as $$
begin
  if tg_op = 'INSERT'
    or new.company_id is distinct from old.company_id
    or new.drug_class_id is distinct from old.drug_class_id
    or new.generic_drug_id is distinct from old.generic_drug_id
    or new.category is distinct from old.category then
    if not private.is_verified_company(new.company_id) then
      raise exception using
        errcode = '23514',
        message = 'Official catalog products require a verified company.';
    end if;

    if not exists (
      select 1 from public.drug_classes
      where id = new.drug_class_id and is_active
    ) then
      raise exception using
        errcode = '23514',
        message = 'Official catalog products require an active drug class.';
    end if;

    if new.category in ('prescription_drug', 'otc_drug')
      and not exists (
        select 1 from public.generic_drugs
        where id = new.generic_drug_id and is_active
      ) then
      raise exception using
        errcode = '23514',
        message = 'Prescription and OTC products require an active generic drug.';
    end if;
  end if;

  if new.status = 'draft' and (
    new.submitted_by is not null or new.submitted_at is not null
    or new.reviewed_by is not null or new.reviewed_at is not null
    or new.review_reason is not null
    or new.published_by is not null or new.published_at is not null
    or new.hidden_by is not null or new.hidden_at is not null
    or new.hidden_reason is not null
    or new.archived_by is not null or new.archived_at is not null
    or new.archive_reason is not null
  ) then
    raise exception using errcode = '23514',
      message = 'Draft lifecycle metadata is invalid.';
  elsif new.status = 'submitted' and (
    new.submitted_by is null or new.submitted_at is null
    or new.reviewed_by is not null or new.reviewed_at is not null
    or new.review_reason is not null
    or new.published_by is not null or new.published_at is not null
    or new.hidden_by is not null or new.hidden_at is not null
    or new.hidden_reason is not null
    or new.archived_by is not null or new.archived_at is not null
    or new.archive_reason is not null
  ) then
    raise exception using errcode = '23514',
      message = 'Submitted lifecycle metadata is invalid.';
  elsif new.status = 'changes_requested' and (
    new.submitted_by is null or new.submitted_at is null
    or new.reviewed_by is null or new.reviewed_at is null
    or new.review_reason is null
    or new.published_by is not null or new.published_at is not null
    or new.hidden_by is not null or new.hidden_at is not null
    or new.hidden_reason is not null
    or new.archived_by is not null or new.archived_at is not null
    or new.archive_reason is not null
  ) then
    raise exception using errcode = '23514',
      message = 'Changes-requested lifecycle metadata is invalid.';
  elsif new.status = 'published' and (
    new.submitted_by is null or new.submitted_at is null
    or new.reviewed_by is null or new.reviewed_at is null
    or new.review_reason is not null
    or new.published_by is null or new.published_at is null
    or new.hidden_by is not null or new.hidden_at is not null
    or new.hidden_reason is not null
    or new.archived_by is not null or new.archived_at is not null
    or new.archive_reason is not null
  ) then
    raise exception using errcode = '23514',
      message = 'Published lifecycle metadata is invalid.';
  elsif new.status = 'hidden' and (
    new.hidden_by is null or new.hidden_at is null
    or new.hidden_reason is null
    or new.archived_by is not null or new.archived_at is not null
    or new.archive_reason is not null
  ) then
    raise exception using errcode = '23514',
      message = 'Hidden lifecycle metadata is invalid.';
  elsif new.status = 'archived' and (
    new.archived_by is null or new.archived_at is null
    or new.archive_reason is null
  ) then
    raise exception using errcode = '23514',
      message = 'Archived lifecycle metadata is invalid.';
  end if;

  return new;
end;
$$;

create or replace function private.validate_product_lifecycle_transition()
returns trigger
language plpgsql
set search_path = ''
as $$
begin
  if new.status = old.status then
    return new;
  end if;

  if not (
    (old.status = 'draft' and new.status in ('submitted', 'hidden', 'archived'))
    or (
      old.status = 'submitted'
      and new.status in ('draft', 'changes_requested', 'published', 'archived')
    )
    or (
      old.status = 'changes_requested'
      and new.status in ('draft', 'submitted', 'archived')
    )
    or (
      old.status = 'published'
      and new.status in ('hidden', 'archived')
    )
    or (
      old.status = 'hidden'
      and new.status in ('published', 'changes_requested', 'archived')
    )
  ) then
    raise exception using
      errcode = '23514',
      message = 'The requested official catalog lifecycle transition is invalid.';
  end if;

  return new;
end;
$$;

create trigger products_validate_catalog_record
before insert or update on public.products
for each row execute function private.validate_product_catalog_record();

create trigger products_validate_lifecycle_transition
before update of status on public.products
for each row execute function private.validate_product_lifecycle_transition();

revoke all on function private.product_validation_errors(uuid, text)
  from public;
revoke all on function private.is_product_submission_ready(uuid)
  from public;
revoke all on function private.is_product_publishable(uuid)
  from public;
revoke all on function private.can_manage_official_product_content(uuid)
  from public;
revoke all on function private.can_read_company_product_record(uuid)
  from public;
revoke all on function private.is_official_catalog_product_visible(uuid)
  from public;
revoke all on function private.can_read_official_catalog_product(uuid)
  from public;
revoke all on function private.validate_product_catalog_record()
  from public;
revoke all on function private.validate_product_lifecycle_transition()
  from public;
