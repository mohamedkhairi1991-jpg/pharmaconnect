create or replace function public.admin_create_drug_class(
  p_code text,
  p_parent_drug_class_id uuid
)
returns public.drug_classes
language plpgsql
security definer
set search_path = ''
as $$
declare
  actor_id uuid;
  created_row public.drug_classes;
begin
  if not private.is_admin_or_super_admin() then
    raise exception using errcode = '42501',
      message = 'Administrator access is required.';
  end if;
  actor_id := private.current_profile_id();
  insert into public.drug_classes (
    code, parent_drug_class_id, created_by, updated_by
  ) values (
    lower(btrim(p_code)), p_parent_drug_class_id, actor_id, actor_id
  ) returning * into created_row;
  perform private.write_audit_log(
    actor_id, 'drug_class_created', 'drug_class', created_row.id, null,
    jsonb_build_object('code', created_row.code)
  );
  return created_row;
end;
$$;

create or replace function public.admin_update_drug_class(
  p_drug_class_id uuid,
  p_code text,
  p_parent_drug_class_id uuid
)
returns public.drug_classes
language plpgsql
security definer
set search_path = ''
as $$
declare
  actor_id uuid;
  old_row public.drug_classes;
  updated_row public.drug_classes;
begin
  if not private.is_admin_or_super_admin() then
    raise exception using errcode = '42501',
      message = 'Administrator access is required.';
  end if;
  actor_id := private.current_profile_id();
  select * into old_row from public.drug_classes
  where id = p_drug_class_id for update;
  if not found then
    raise exception using errcode = 'P0002',
      message = 'The drug class does not exist.';
  end if;
  update public.drug_classes set
    code = lower(btrim(p_code)),
    parent_drug_class_id = p_parent_drug_class_id,
    updated_by = actor_id
  where id = p_drug_class_id returning * into updated_row;
  perform private.write_audit_log(
    actor_id, 'drug_class_updated', 'drug_class', p_drug_class_id,
    jsonb_build_object(
      'code', old_row.code,
      'parent_drug_class_id', old_row.parent_drug_class_id
    ),
    jsonb_build_object(
      'code', updated_row.code,
      'parent_drug_class_id', updated_row.parent_drug_class_id
    )
  );
  return updated_row;
end;
$$;

create or replace function public.admin_set_drug_class_active(
  p_drug_class_id uuid,
  p_is_active boolean
)
returns public.drug_classes
language plpgsql
security definer
set search_path = ''
as $$
declare
  actor_id uuid;
  old_active boolean;
  updated_row public.drug_classes;
begin
  if not private.is_admin_or_super_admin() then
    raise exception using errcode = '42501',
      message = 'Administrator access is required.';
  end if;
  actor_id := private.current_profile_id();
  select is_active into old_active from public.drug_classes
  where id = p_drug_class_id for update;
  if not found then
    raise exception using errcode = 'P0002',
      message = 'The drug class does not exist.';
  end if;
  update public.drug_classes set
    is_active = p_is_active,
    updated_by = actor_id
  where id = p_drug_class_id returning * into updated_row;
  perform private.write_audit_log(
    actor_id,
    case when p_is_active then 'drug_class_activated'
      else 'drug_class_deactivated' end,
    'drug_class', p_drug_class_id,
    jsonb_build_object('is_active', old_active),
    jsonb_build_object('is_active', updated_row.is_active)
  );
  return updated_row;
end;
$$;

create or replace function public.admin_upsert_drug_class_translation(
  p_drug_class_id uuid,
  p_locale public.content_locale,
  p_name text,
  p_description text
)
returns public.drug_class_translations
language plpgsql
security definer
set search_path = ''
as $$
declare
  actor_id uuid;
  updated_row public.drug_class_translations;
begin
  if not private.is_admin_or_super_admin() then
    raise exception using errcode = '42501',
      message = 'Administrator access is required.';
  end if;
  actor_id := private.current_profile_id();
  insert into public.drug_class_translations (
    drug_class_id, locale, name, description
  ) values (
    p_drug_class_id, p_locale, btrim(p_name),
    case when p_description is null then null else btrim(p_description) end
  )
  on conflict (drug_class_id, locale) do update set
    name = excluded.name,
    description = excluded.description
  returning * into updated_row;
  perform private.write_audit_log(
    actor_id, 'drug_class_translation_changed', 'drug_class',
    p_drug_class_id, null,
    jsonb_build_object('locale', p_locale, 'name', updated_row.name)
  );
  return updated_row;
end;
$$;

create or replace function public.admin_create_active_ingredient(p_code text)
returns public.active_ingredients
language plpgsql
security definer
set search_path = ''
as $$
declare
  actor_id uuid;
  created_row public.active_ingredients;
begin
  if not private.is_admin_or_super_admin() then
    raise exception using errcode = '42501',
      message = 'Administrator access is required.';
  end if;
  actor_id := private.current_profile_id();
  insert into public.active_ingredients (code, created_by, updated_by)
  values (lower(btrim(p_code)), actor_id, actor_id)
  returning * into created_row;
  perform private.write_audit_log(
    actor_id, 'active_ingredient_created', 'active_ingredient',
    created_row.id, null, jsonb_build_object('code', created_row.code)
  );
  return created_row;
end;
$$;

create or replace function public.admin_update_active_ingredient(
  p_active_ingredient_id uuid,
  p_code text
)
returns public.active_ingredients
language plpgsql
security definer
set search_path = ''
as $$
declare
  actor_id uuid;
  old_code text;
  updated_row public.active_ingredients;
begin
  if not private.is_admin_or_super_admin() then
    raise exception using errcode = '42501',
      message = 'Administrator access is required.';
  end if;
  actor_id := private.current_profile_id();
  select code into old_code from public.active_ingredients
  where id = p_active_ingredient_id for update;
  if not found then
    raise exception using errcode = 'P0002',
      message = 'The active ingredient does not exist.';
  end if;
  update public.active_ingredients set
    code = lower(btrim(p_code)),
    updated_by = actor_id
  where id = p_active_ingredient_id returning * into updated_row;
  perform private.write_audit_log(
    actor_id, 'active_ingredient_updated', 'active_ingredient',
    p_active_ingredient_id,
    jsonb_build_object('code', old_code),
    jsonb_build_object('code', updated_row.code)
  );
  return updated_row;
end;
$$;

create or replace function public.admin_set_active_ingredient_active(
  p_active_ingredient_id uuid,
  p_is_active boolean
)
returns public.active_ingredients
language plpgsql
security definer
set search_path = ''
as $$
declare
  actor_id uuid;
  old_active boolean;
  updated_row public.active_ingredients;
begin
  if not private.is_admin_or_super_admin() then
    raise exception using errcode = '42501',
      message = 'Administrator access is required.';
  end if;
  actor_id := private.current_profile_id();
  select is_active into old_active from public.active_ingredients
  where id = p_active_ingredient_id for update;
  if not found then
    raise exception using errcode = 'P0002',
      message = 'The active ingredient does not exist.';
  end if;
  update public.active_ingredients set
    is_active = p_is_active,
    updated_by = actor_id
  where id = p_active_ingredient_id returning * into updated_row;
  perform private.write_audit_log(
    actor_id,
    case when p_is_active then 'active_ingredient_activated'
      else 'active_ingredient_deactivated' end,
    'active_ingredient', p_active_ingredient_id,
    jsonb_build_object('is_active', old_active),
    jsonb_build_object('is_active', updated_row.is_active)
  );
  return updated_row;
end;
$$;

create or replace function public.admin_upsert_active_ingredient_translation(
  p_active_ingredient_id uuid,
  p_locale public.content_locale,
  p_name text,
  p_description text
)
returns public.active_ingredient_translations
language plpgsql
security definer
set search_path = ''
as $$
declare
  actor_id uuid;
  updated_row public.active_ingredient_translations;
begin
  if not private.is_admin_or_super_admin() then
    raise exception using errcode = '42501',
      message = 'Administrator access is required.';
  end if;
  actor_id := private.current_profile_id();
  insert into public.active_ingredient_translations (
    active_ingredient_id, locale, name, description
  ) values (
    p_active_ingredient_id, p_locale, btrim(p_name),
    case when p_description is null then null else btrim(p_description) end
  )
  on conflict (active_ingredient_id, locale) do update set
    name = excluded.name,
    description = excluded.description
  returning * into updated_row;
  perform private.write_audit_log(
    actor_id, 'active_ingredient_translation_changed',
    'active_ingredient', p_active_ingredient_id, null,
    jsonb_build_object('locale', p_locale, 'name', updated_row.name)
  );
  return updated_row;
end;
$$;

create or replace function public.admin_create_generic_drug(
  p_code text,
  p_drug_class_id uuid
)
returns public.generic_drugs
language plpgsql
security definer
set search_path = ''
as $$
declare
  actor_id uuid;
  created_row public.generic_drugs;
begin
  if not private.is_admin_or_super_admin() then
    raise exception using errcode = '42501',
      message = 'Administrator access is required.';
  end if;
  actor_id := private.current_profile_id();
  insert into public.generic_drugs (
    code, drug_class_id, created_by, updated_by
  ) values (
    lower(btrim(p_code)), p_drug_class_id, actor_id, actor_id
  ) returning * into created_row;
  perform private.write_audit_log(
    actor_id, 'generic_drug_created', 'generic_drug', created_row.id,
    null, jsonb_build_object(
      'code', created_row.code,
      'drug_class_id', created_row.drug_class_id
    )
  );
  return created_row;
end;
$$;

create or replace function public.admin_update_generic_drug(
  p_generic_drug_id uuid,
  p_code text,
  p_drug_class_id uuid
)
returns public.generic_drugs
language plpgsql
security definer
set search_path = ''
as $$
declare
  actor_id uuid;
  old_row public.generic_drugs;
  updated_row public.generic_drugs;
begin
  if not private.is_admin_or_super_admin() then
    raise exception using errcode = '42501',
      message = 'Administrator access is required.';
  end if;
  actor_id := private.current_profile_id();
  select * into old_row from public.generic_drugs
  where id = p_generic_drug_id for update;
  if not found then
    raise exception using errcode = 'P0002',
      message = 'The generic drug does not exist.';
  end if;
  update public.generic_drugs set
    code = lower(btrim(p_code)),
    drug_class_id = p_drug_class_id,
    updated_by = actor_id
  where id = p_generic_drug_id returning * into updated_row;
  perform private.write_audit_log(
    actor_id, 'generic_drug_updated', 'generic_drug', p_generic_drug_id,
    jsonb_build_object(
      'code', old_row.code,
      'drug_class_id', old_row.drug_class_id
    ),
    jsonb_build_object(
      'code', updated_row.code,
      'drug_class_id', updated_row.drug_class_id
    )
  );
  return updated_row;
end;
$$;

create or replace function public.admin_upsert_generic_drug_translation(
  p_generic_drug_id uuid,
  p_locale public.content_locale,
  p_name text,
  p_description text
)
returns public.generic_drug_translations
language plpgsql
security definer
set search_path = ''
as $$
declare
  actor_id uuid;
  updated_row public.generic_drug_translations;
begin
  if not private.is_admin_or_super_admin() then
    raise exception using errcode = '42501',
      message = 'Administrator access is required.';
  end if;
  actor_id := private.current_profile_id();
  insert into public.generic_drug_translations (
    generic_drug_id, locale, name, description
  ) values (
    p_generic_drug_id, p_locale, btrim(p_name),
    case when p_description is null then null else btrim(p_description) end
  )
  on conflict (generic_drug_id, locale) do update set
    name = excluded.name,
    description = excluded.description
  returning * into updated_row;
  perform private.write_audit_log(
    actor_id, 'generic_drug_translation_changed', 'generic_drug',
    p_generic_drug_id, null,
    jsonb_build_object('locale', p_locale, 'name', updated_row.name)
  );
  return updated_row;
end;
$$;

create or replace function public.admin_set_generic_drug_ingredients(
  p_generic_drug_id uuid,
  p_active_ingredient_ids uuid[]
)
returns setof public.generic_drug_ingredients
language plpgsql
security definer
set search_path = ''
as $$
declare
  actor_id uuid;
begin
  if not private.is_admin_or_super_admin() then
    raise exception using errcode = '42501',
      message = 'Administrator access is required.';
  end if;
  if p_active_ingredient_ids is null
    or cardinality(p_active_ingredient_ids) = 0
    or cardinality(p_active_ingredient_ids)
      <> (select count(distinct value) from unnest(p_active_ingredient_ids) value)
    or exists (
      select 1 from unnest(p_active_ingredient_ids) value
      where not exists (
        select 1 from public.active_ingredients
        where id = value and is_active
      )
    ) then
    raise exception using errcode = '23514',
      message = 'Generic composition requires unique active ingredients.';
  end if;
  actor_id := private.current_profile_id();
  delete from public.generic_drug_ingredients
  where generic_drug_id = p_generic_drug_id;
  insert into public.generic_drug_ingredients (
    generic_drug_id, active_ingredient_id, sort_order, created_by
  )
  select p_generic_drug_id, value, ordinality::integer, actor_id
  from unnest(p_active_ingredient_ids) with ordinality as ingredient(value, ordinality);
  perform private.write_audit_log(
    actor_id, 'generic_drug_composition_changed', 'generic_drug',
    p_generic_drug_id, null,
    jsonb_build_object(
      'ingredient_ids', to_jsonb(p_active_ingredient_ids)
    )
  );
  return query
  select * from public.generic_drug_ingredients
  where generic_drug_id = p_generic_drug_id
  order by sort_order;
end;
$$;

create or replace function public.admin_set_generic_drug_active(
  p_generic_drug_id uuid,
  p_is_active boolean
)
returns public.generic_drugs
language plpgsql
security definer
set search_path = ''
as $$
declare
  actor_id uuid;
  old_active boolean;
  updated_row public.generic_drugs;
begin
  if not private.is_admin_or_super_admin() then
    raise exception using errcode = '42501',
      message = 'Administrator access is required.';
  end if;
  actor_id := private.current_profile_id();
  select is_active into old_active from public.generic_drugs
  where id = p_generic_drug_id for update;
  if not found then
    raise exception using errcode = 'P0002',
      message = 'The generic drug does not exist.';
  end if;
  update public.generic_drugs set
    is_active = p_is_active,
    updated_by = actor_id
  where id = p_generic_drug_id returning * into updated_row;
  perform private.write_audit_log(
    actor_id,
    case when p_is_active then 'generic_drug_activated'
      else 'generic_drug_deactivated' end,
    'generic_drug', p_generic_drug_id,
    jsonb_build_object('is_active', old_active),
    jsonb_build_object('is_active', updated_row.is_active)
  );
  return updated_row;
end;
$$;

create or replace function public.create_product_draft(
  p_company_id uuid,
  p_category public.product_category,
  p_generic_drug_id uuid,
  p_drug_class_id uuid,
  p_english_brand_name text
)
returns public.products
language plpgsql
security definer
set search_path = ''
as $$
declare
  actor_id uuid;
  created_row public.products;
begin
  actor_id := private.current_profile_id();
  if actor_id is null or not private.has_company_role(
    p_company_id,
    array['company_admin', 'product_manager']::public.company_role[]
  ) then
    raise exception using errcode = '42501',
      message = 'Product draft management access is required.';
  end if;
  insert into public.products (
    company_id, generic_drug_id, drug_class_id, category,
    created_by, updated_by
  ) values (
    p_company_id, p_generic_drug_id, p_drug_class_id, p_category,
    actor_id, actor_id
  ) returning * into created_row;
  insert into public.product_translations (
    product_id, locale, brand_name
  ) values (
    created_row.id, 'en', btrim(p_english_brand_name)
  );
  perform private.refresh_product_search_keywords(created_row.id);
  perform private.write_audit_log(
    actor_id, 'product_draft_created', 'product', created_row.id, null,
    jsonb_build_object(
      'company_id', created_row.company_id,
      'category', created_row.category,
      'generic_drug_id', created_row.generic_drug_id,
      'drug_class_id', created_row.drug_class_id
    )
  );
  return created_row;
end;
$$;

create or replace function public.update_product_draft(
  p_product_id uuid,
  p_category public.product_category,
  p_generic_drug_id uuid,
  p_drug_class_id uuid
)
returns public.products
language plpgsql
security definer
set search_path = ''
as $$
declare
  actor_id uuid;
  old_row public.products;
  updated_row public.products;
begin
  if not private.can_manage_product_draft(p_product_id) then
    raise exception using errcode = '42501',
      message = 'Product draft management access is required.';
  end if;
  actor_id := private.current_profile_id();
  select * into old_row from public.products
  where id = p_product_id for update;
  update public.products set
    category = p_category,
    generic_drug_id = p_generic_drug_id,
    drug_class_id = p_drug_class_id,
    updated_by = actor_id
  where id = p_product_id returning * into updated_row;
  perform private.refresh_product_presentation_fingerprint(p_product_id);
  perform private.refresh_product_search_keywords(p_product_id);
  perform private.write_audit_log(
    actor_id, 'product_draft_updated', 'product', p_product_id,
    jsonb_build_object(
      'category', old_row.category,
      'generic_drug_id', old_row.generic_drug_id,
      'drug_class_id', old_row.drug_class_id
    ),
    jsonb_build_object(
      'category', updated_row.category,
      'generic_drug_id', updated_row.generic_drug_id,
      'drug_class_id', updated_row.drug_class_id
    )
  );
  return updated_row;
end;
$$;

create or replace function public.upsert_product_translation(
  p_product_id uuid,
  p_locale public.content_locale,
  p_brand_name text
)
returns public.product_translations
language plpgsql
security definer
set search_path = ''
as $$
declare
  actor_id uuid;
  updated_row public.product_translations;
begin
  if not private.can_manage_product_draft(p_product_id) then
    raise exception using errcode = '42501',
      message = 'Product draft management access is required.';
  end if;
  actor_id := private.current_profile_id();
  insert into public.product_translations (
    product_id, locale, brand_name
  ) values (
    p_product_id, p_locale, btrim(p_brand_name)
  )
  on conflict (product_id, locale) do update set
    brand_name = excluded.brand_name
  returning * into updated_row;
  perform private.refresh_product_presentation_fingerprint(p_product_id);
  perform private.refresh_product_search_keywords(p_product_id);
  perform private.write_audit_log(
    actor_id, 'product_translation_changed', 'product', p_product_id,
    null, jsonb_build_object(
      'locale', p_locale,
      'brand_name', updated_row.brand_name
    )
  );
  return updated_row;
end;
$$;

create or replace function public.upsert_product_market(
  p_product_id uuid,
  p_strength text,
  p_dosage_form text,
  p_route text,
  p_pack_size text,
  p_market_status public.iraq_market_status,
  p_registration_status public.product_registration_status,
  p_registration_number text,
  p_registration_authority text,
  p_registration_expires_on date
)
returns public.product_markets
language plpgsql
security definer
set search_path = ''
as $$
declare
  actor_id uuid;
  iraq_id uuid;
  updated_row public.product_markets;
begin
  if not private.can_manage_product_draft(p_product_id) then
    raise exception using errcode = '42501',
      message = 'Product draft management access is required.';
  end if;
  actor_id := private.current_profile_id();
  select id into iraq_id from public.countries
  where iso_code = 'IQ' and is_active;
  if iraq_id is null then
    raise exception using errcode = '23514',
      message = 'The active Iraq country record is required.';
  end if;
  insert into public.product_markets (
    product_id, country_id, strength, dosage_form, route, pack_size,
    market_status, registration_status, registration_number,
    registration_authority, registration_expires_on
  ) values (
    p_product_id, iraq_id, btrim(p_strength), btrim(p_dosage_form),
    btrim(p_route), btrim(p_pack_size), p_market_status,
    p_registration_status,
    case when p_registration_number is null then null
      else btrim(p_registration_number) end,
    case when p_registration_authority is null then null
      else btrim(p_registration_authority) end,
    p_registration_expires_on
  )
  on conflict (product_id, country_id) do update set
    strength = excluded.strength,
    dosage_form = excluded.dosage_form,
    route = excluded.route,
    pack_size = excluded.pack_size,
    market_status = excluded.market_status,
    registration_status = excluded.registration_status,
    registration_number = excluded.registration_number,
    registration_authority = excluded.registration_authority,
    registration_expires_on = excluded.registration_expires_on
  returning * into updated_row;
  perform private.refresh_product_presentation_fingerprint(p_product_id);
  perform private.write_audit_log(
    actor_id, 'product_market_changed', 'product', p_product_id, null,
    jsonb_build_object(
      'market_status', updated_row.market_status,
      'registration_status', updated_row.registration_status,
      'strength', updated_row.strength,
      'dosage_form', updated_row.dosage_form,
      'route', updated_row.route,
      'pack_size', updated_row.pack_size
    )
  );
  return updated_row;
end;
$$;

create or replace function public.upsert_product_market_translation(
  p_product_id uuid,
  p_locale public.content_locale,
  p_storage_conditions text,
  p_approved_indications text,
  p_usual_adult_dose text,
  p_contraindications text,
  p_common_adverse_effects text
)
returns public.product_market_translations
language plpgsql
security definer
set search_path = ''
as $$
declare
  actor_id uuid;
  market_id uuid;
  updated_row public.product_market_translations;
begin
  if not private.can_manage_product_draft(p_product_id) then
    raise exception using errcode = '42501',
      message = 'Product draft management access is required.';
  end if;
  actor_id := private.current_profile_id();
  select id into market_id from public.product_markets
  where product_id = p_product_id;
  if market_id is null then
    raise exception using errcode = 'P0002',
      message = 'The Iraq product market record does not exist.';
  end if;
  insert into public.product_market_translations (
    product_market_id, locale, storage_conditions, approved_indications,
    usual_adult_dose, contraindications, common_adverse_effects
  ) values (
    market_id, p_locale, btrim(p_storage_conditions),
    btrim(p_approved_indications), btrim(p_usual_adult_dose),
    btrim(p_contraindications), btrim(p_common_adverse_effects)
  )
  on conflict (product_market_id, locale) do update set
    storage_conditions = excluded.storage_conditions,
    approved_indications = excluded.approved_indications,
    usual_adult_dose = excluded.usual_adult_dose,
    contraindications = excluded.contraindications,
    common_adverse_effects = excluded.common_adverse_effects
  returning * into updated_row;
  perform private.write_audit_log(
    actor_id, 'product_market_translation_changed', 'product',
    p_product_id, null,
    jsonb_build_object('locale', p_locale, 'content_changed', true)
  );
  return updated_row;
end;
$$;

create or replace function public.set_product_specialties(
  p_product_id uuid,
  p_specialty_ids uuid[]
)
returns setof public.product_specialties
language plpgsql
security definer
set search_path = ''
as $$
declare
  actor_id uuid;
begin
  if not private.can_manage_product_draft(p_product_id) then
    raise exception using errcode = '42501',
      message = 'Product draft management access is required.';
  end if;
  if p_specialty_ids is null
    or cardinality(p_specialty_ids)
      <> (select count(distinct value) from unnest(p_specialty_ids) value)
    or exists (
      select 1 from unnest(p_specialty_ids) value
      where not exists (
        select 1 from public.specialties
        where id = value and is_active
      )
    ) then
    raise exception using errcode = '23514',
      message = 'Specialty assignments must be unique and active.';
  end if;
  actor_id := private.current_profile_id();
  delete from public.product_specialties where product_id = p_product_id;
  insert into public.product_specialties (
    product_id, specialty_id, created_by
  )
  select p_product_id, value, actor_id
  from unnest(p_specialty_ids) value;
  perform private.write_audit_log(
    actor_id, 'product_specialties_changed', 'product', p_product_id,
    null, jsonb_build_object('specialty_ids', to_jsonb(p_specialty_ids))
  );
  return query select * from public.product_specialties
    where product_id = p_product_id order by specialty_id;
end;
$$;

create or replace function public.upsert_product_media_metadata(
  p_media_id uuid,
  p_product_id uuid,
  p_media_type public.product_media_type,
  p_storage_path text,
  p_mime_type text,
  p_file_size_bytes bigint,
  p_sort_order integer,
  p_is_primary boolean
)
returns public.product_media
language plpgsql
security definer
set search_path = ''
as $$
declare
  actor_id uuid;
  updated_row public.product_media;
begin
  if not private.can_manage_product_draft(p_product_id) then
    raise exception using errcode = '42501',
      message = 'Product draft management access is required.';
  end if;
  actor_id := private.current_profile_id();
  if p_is_primary then
    update public.product_media set is_primary = false
    where product_id = p_product_id and media_type = p_media_type
      and (p_media_id is null or id <> p_media_id);
  end if;
  insert into public.product_media (
    id, product_id, media_type, storage_path, mime_type,
    file_size_bytes, sort_order, is_primary, uploaded_by
  ) values (
    coalesce(p_media_id, gen_random_uuid()), p_product_id, p_media_type,
    btrim(p_storage_path), lower(btrim(p_mime_type)), p_file_size_bytes,
    p_sort_order, p_is_primary, actor_id
  )
  on conflict (id) do update set
    media_type = excluded.media_type,
    storage_path = excluded.storage_path,
    mime_type = excluded.mime_type,
    file_size_bytes = excluded.file_size_bytes,
    sort_order = excluded.sort_order,
    is_primary = excluded.is_primary
  where public.product_media.product_id = p_product_id
  returning * into updated_row;
  if updated_row.id is null then
    raise exception using errcode = '42501',
      message = 'Media metadata belongs to another product.';
  end if;
  perform private.write_audit_log(
    actor_id, 'product_media_metadata_changed', 'product', p_product_id,
    null, jsonb_build_object(
      'media_id', updated_row.id,
      'media_type', updated_row.media_type,
      'is_primary', updated_row.is_primary
    )
  );
  return updated_row;
end;
$$;

create or replace function public.upsert_product_brochure_metadata(
  p_brochure_id uuid,
  p_product_id uuid,
  p_locale public.content_locale,
  p_title text,
  p_storage_path text,
  p_file_size_bytes bigint,
  p_version integer,
  p_is_current boolean
)
returns public.product_brochures
language plpgsql
security definer
set search_path = ''
as $$
declare
  actor_id uuid;
  market_id uuid;
  updated_row public.product_brochures;
begin
  if not private.can_manage_product_draft(p_product_id) then
    raise exception using errcode = '42501',
      message = 'Product draft management access is required.';
  end if;
  actor_id := private.current_profile_id();
  select id into market_id from public.product_markets
  where product_id = p_product_id;
  if market_id is null then
    raise exception using errcode = 'P0002',
      message = 'The Iraq product market record does not exist.';
  end if;
  if p_is_current then
    update public.product_brochures set is_current = false
    where product_market_id = market_id and locale = p_locale
      and (p_brochure_id is null or id <> p_brochure_id);
  end if;
  insert into public.product_brochures (
    id, product_market_id, locale, title, storage_path, mime_type,
    file_size_bytes, version, is_current, uploaded_by
  ) values (
    coalesce(p_brochure_id, gen_random_uuid()), market_id, p_locale,
    btrim(p_title), btrim(p_storage_path), 'application/pdf',
    p_file_size_bytes, p_version, p_is_current, actor_id
  )
  on conflict (id) do update set
    title = excluded.title,
    storage_path = excluded.storage_path,
    file_size_bytes = excluded.file_size_bytes,
    version = excluded.version,
    is_current = excluded.is_current
  where public.product_brochures.product_market_id = market_id
  returning * into updated_row;
  if updated_row.id is null then
    raise exception using errcode = '42501',
      message = 'Brochure metadata belongs to another product.';
  end if;
  perform private.write_audit_log(
    actor_id, 'product_brochure_metadata_changed', 'product',
    p_product_id, null,
    jsonb_build_object(
      'brochure_id', updated_row.id,
      'locale', updated_row.locale,
      'version', updated_row.version,
      'is_current', updated_row.is_current
    )
  );
  return updated_row;
end;
$$;

create or replace function public.upsert_product_keyword_alias(
  p_product_id uuid,
  p_locale public.keyword_locale,
  p_keyword text,
  p_keyword_type public.product_keyword_type
)
returns public.product_search_keywords
language plpgsql
security definer
set search_path = ''
as $$
declare
  actor_id uuid;
  normalized_value text;
  updated_row public.product_search_keywords;
begin
  if not private.can_manage_product_draft(p_product_id)
    or p_keyword_type not in ('alias', 'transliteration') then
    raise exception using errcode = '42501',
      message = 'Trusted alias management access is required.';
  end if;
  actor_id := private.current_profile_id();
  normalized_value := private.normalize_search_text(p_keyword, p_locale);
  insert into public.product_search_keywords (
    product_id, locale, keyword, normalized_keyword, keyword_type,
    source_reference
  ) values (
    p_product_id, p_locale, btrim(p_keyword), normalized_value,
    p_keyword_type, 'manual'
  )
  on conflict (
    product_id, locale, normalized_keyword, keyword_type
  ) do update set keyword = excluded.keyword
  returning * into updated_row;
  perform private.write_audit_log(
    actor_id, 'product_keywords_refreshed', 'product', p_product_id,
    null, jsonb_build_object(
      'keyword_type', p_keyword_type,
      'locale', p_locale,
      'normalized_keyword', normalized_value
    )
  );
  return updated_row;
end;
$$;

revoke all on function public.admin_create_drug_class(text, uuid) from public;
revoke all on function public.admin_update_drug_class(uuid, text, uuid) from public;
revoke all on function public.admin_set_drug_class_active(uuid, boolean) from public;
revoke all on function public.admin_upsert_drug_class_translation(
  uuid, public.content_locale, text, text
) from public;
revoke all on function public.admin_create_active_ingredient(text) from public;
revoke all on function public.admin_update_active_ingredient(uuid, text) from public;
revoke all on function public.admin_set_active_ingredient_active(uuid, boolean) from public;
revoke all on function public.admin_upsert_active_ingredient_translation(
  uuid, public.content_locale, text, text
) from public;
revoke all on function public.admin_create_generic_drug(text, uuid) from public;
revoke all on function public.admin_update_generic_drug(uuid, text, uuid) from public;
revoke all on function public.admin_upsert_generic_drug_translation(
  uuid, public.content_locale, text, text
) from public;
revoke all on function public.admin_set_generic_drug_ingredients(uuid, uuid[]) from public;
revoke all on function public.admin_set_generic_drug_active(uuid, boolean) from public;
revoke all on function public.create_product_draft(
  uuid, public.product_category, uuid, uuid, text
) from public;
revoke all on function public.update_product_draft(
  uuid, public.product_category, uuid, uuid
) from public;
revoke all on function public.upsert_product_translation(
  uuid, public.content_locale, text
) from public;
revoke all on function public.upsert_product_market(
  uuid, text, text, text, text, public.iraq_market_status,
  public.product_registration_status, text, text, date
) from public;
revoke all on function public.upsert_product_market_translation(
  uuid, public.content_locale, text, text, text, text, text
) from public;
revoke all on function public.set_product_specialties(uuid, uuid[]) from public;
revoke all on function public.upsert_product_media_metadata(
  uuid, uuid, public.product_media_type, text, text, bigint,
  integer, boolean
) from public;
revoke all on function public.upsert_product_brochure_metadata(
  uuid, uuid, public.content_locale, text, text, bigint, integer, boolean
) from public;
revoke all on function public.upsert_product_keyword_alias(
  uuid, public.keyword_locale, text, public.product_keyword_type
) from public;
