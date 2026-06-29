-- PharmaConnect MVP demo catalog seed.
--
-- NON-PRODUCTION ONLY.
-- This file is intentionally not a migration. It prepares fake, local/demo
-- public-table data for the MVP walkthrough after the required Supabase Auth
-- users have already been created.
--
-- Required Auth users, looked up by email:
--   doctor.demo@pharmaconnect.local
--   company.admin.demo@pharmaconnect.local
--   admin.demo@pharmaconnect.local
--
-- Suggested local/manual password for those Auth users: DemoPass!2026
-- Do not use production credentials with this seed.
-- Do not use real patient data or real doctor/company personal data.

do $$
declare
  demo_timestamp constant timestamptz := '2026-06-29 09:00:00+00';

  doctor_email constant text := 'doctor.demo@pharmaconnect.local';
  company_admin_email constant text := 'company.admin.demo@pharmaconnect.local';
  admin_email constant text := 'admin.demo@pharmaconnect.local';

  doctor_auth_id uuid;
  company_admin_auth_id uuid;
  admin_auth_id uuid;

  doctor_profile_id uuid;
  company_admin_profile_id uuid;
  admin_profile_id uuid;
  iraq_country_id uuid;

  demo_company_id uuid;
  company_membership_id uuid;

  cardiology_specialty_id uuid;
  respiratory_specialty_id uuid;
  beta_blockers_class_id uuid;
  bronchodilators_class_id uuid;
  bisoprolol_ingredient_id uuid;
  salbutamol_ingredient_id uuid;
  bisoprolol_generic_id uuid;
  salbutamol_generic_id uuid;

  product_a_id constant uuid := '71000000-0000-4000-8000-000000000001';
  product_b_id constant uuid := '71000000-0000-4000-8000-000000000002';
  product_a_market_id constant uuid := '72000000-0000-4000-8000-000000000001';
  product_b_market_id constant uuid := '72000000-0000-4000-8000-000000000002';
begin
  select id into doctor_auth_id
  from auth.users
  where lower(email) = doctor_email;

  select id into company_admin_auth_id
  from auth.users
  where lower(email) = company_admin_email;

  select id into admin_auth_id
  from auth.users
  where lower(email) = admin_email;

  if doctor_auth_id is null then
    raise exception
      'Missing required demo Auth user: %',
      doctor_email
      using hint = 'Create the local demo Auth users before running this non-production public-table seed.';
  end if;

  if company_admin_auth_id is null then
    raise exception
      'Missing required demo Auth user: %',
      company_admin_email
      using hint = 'Create the local demo Auth users before running this non-production public-table seed.';
  end if;

  if admin_auth_id is null then
    raise exception
      'Missing required demo Auth user: %',
      admin_email
      using hint = 'Create the local demo Auth users before running this non-production public-table seed.';
  end if;

  select id into iraq_country_id
  from public.countries
  where iso_code = 'IQ'
    and is_active;

  if iraq_country_id is null then
    raise exception
      'Missing active Iraq country reference row.'
      using hint = 'Run the baseline migrations/reference data before running this demo seed.';
  end if;

  insert into public.profiles (
    id,
    auth_user_id,
    full_name,
    email,
    phone,
    role,
    country_id,
    city_id,
    status
  ) values (
    '70000000-0000-4000-8000-000000000001',
    doctor_auth_id,
    'Demo Doctor',
    doctor_email,
    '+9647000000001',
    'healthcare_professional',
    iraq_country_id,
    null,
    'active'
  )
  on conflict (auth_user_id) do update set
    full_name = excluded.full_name,
    email = excluded.email,
    phone = excluded.phone,
    role = excluded.role,
    country_id = excluded.country_id,
    city_id = null,
    status = excluded.status
  returning id into doctor_profile_id;

  insert into public.profiles (
    id,
    auth_user_id,
    full_name,
    email,
    phone,
    role,
    country_id,
    city_id,
    status
  ) values (
    '70000000-0000-4000-8000-000000000002',
    company_admin_auth_id,
    'Demo Company Admin',
    company_admin_email,
    '+9647000000002',
    'company_user',
    iraq_country_id,
    null,
    'active'
  )
  on conflict (auth_user_id) do update set
    full_name = excluded.full_name,
    email = excluded.email,
    phone = excluded.phone,
    role = excluded.role,
    country_id = excluded.country_id,
    city_id = null,
    status = excluded.status
  returning id into company_admin_profile_id;

  insert into public.profiles (
    id,
    auth_user_id,
    full_name,
    email,
    phone,
    role,
    country_id,
    city_id,
    status
  ) values (
    '70000000-0000-4000-8000-000000000003',
    admin_auth_id,
    'Demo Admin Reviewer',
    admin_email,
    '+9647000000003',
    'admin',
    iraq_country_id,
    null,
    'active'
  )
  on conflict (auth_user_id) do update set
    full_name = excluded.full_name,
    email = excluded.email,
    phone = excluded.phone,
    role = excluded.role,
    country_id = excluded.country_id,
    city_id = null,
    status = excluded.status
  returning id into admin_profile_id;

  insert into public.specialties (
    id,
    code,
    profession_type,
    is_active,
    created_by,
    updated_by
  ) values
    (
      '73000000-0000-4000-8000-000000000001',
      'cardiology',
      'physician',
      false,
      admin_profile_id,
      admin_profile_id
    ),
    (
      '73000000-0000-4000-8000-000000000002',
      'respiratory_medicine',
      'physician',
      false,
      admin_profile_id,
      admin_profile_id
    )
  on conflict (lower(code)) do update set
    profession_type = excluded.profession_type,
    updated_by = admin_profile_id;

  select id into cardiology_specialty_id
  from public.specialties
  where lower(code) = 'cardiology';

  select id into respiratory_specialty_id
  from public.specialties
  where lower(code) = 'respiratory_medicine';

  insert into public.specialty_translations (
    specialty_id,
    locale,
    name,
    description
  ) values
    (
      cardiology_specialty_id,
      'en',
      'Cardiology',
      'Demo physician specialty for cardiovascular catalog examples.'
    ),
    (
      respiratory_specialty_id,
      'en',
      'Respiratory Medicine',
      'Demo physician specialty for respiratory catalog examples.'
    )
  on conflict (specialty_id, locale) do update set
    name = excluded.name,
    description = excluded.description;

  update public.specialties
  set is_active = true,
      updated_by = admin_profile_id
  where id in (cardiology_specialty_id, respiratory_specialty_id);

  insert into public.healthcare_professionals (
    id,
    profile_id,
    profession_type,
    specialty_id,
    workplace,
    license_number,
    verification_status,
    reviewed_by,
    reviewed_at,
    review_reason
  ) values (
    '74000000-0000-4000-8000-000000000001',
    doctor_profile_id,
    'physician',
    cardiology_specialty_id,
    'Demo Medical Center',
    'DEMO-PHY-0001',
    'approved',
    admin_profile_id,
    demo_timestamp,
    null
  )
  on conflict (profile_id) do update set
    profession_type = excluded.profession_type,
    specialty_id = excluded.specialty_id,
    workplace = excluded.workplace,
    license_number = excluded.license_number,
    verification_status = excluded.verification_status,
    reviewed_by = excluded.reviewed_by,
    reviewed_at = excluded.reviewed_at,
    review_reason = null;

  insert into public.companies (
    id,
    applicant_profile_id,
    country_id,
    city_id,
    company_name,
    legal_name,
    description,
    website_url,
    contact_email,
    contact_phone,
    status,
    verified_by,
    verified_at,
    suspended_by,
    suspended_at,
    suspension_reason,
    archived_by,
    archived_at,
    archive_reason
  ) values (
    '75000000-0000-4000-8000-000000000001',
    company_admin_profile_id,
    iraq_country_id,
    null,
    'Tigris Pharma',
    'Tigris Pharma Demo LLC',
    'Demo pharmaceutical company for PharmaConnect MVP catalog workflow.',
    'https://demo.tigris-pharma.local',
    'catalog@tigris-pharma.local',
    '+9647000000000',
    'verified',
    admin_profile_id,
    demo_timestamp,
    null,
    null,
    null,
    null,
    null,
    null
  )
  on conflict (applicant_profile_id) do update set
    country_id = excluded.country_id,
    city_id = null,
    company_name = excluded.company_name,
    legal_name = excluded.legal_name,
    description = excluded.description,
    website_url = excluded.website_url,
    contact_email = excluded.contact_email,
    contact_phone = excluded.contact_phone,
    status = excluded.status,
    verified_by = excluded.verified_by,
    verified_at = excluded.verified_at,
    suspended_by = null,
    suspended_at = null,
    suspension_reason = null,
    archived_by = null,
    archived_at = null,
    archive_reason = null
  returning id into demo_company_id;

  select id into company_membership_id
  from public.company_users
  where profile_id = company_admin_profile_id;

  if company_membership_id is not null
    and not exists (
      select 1
      from public.company_users
      where id = company_membership_id
        and company_id = demo_company_id
    ) then
    raise exception
      'Demo company admin profile already belongs to another company.'
      using hint = 'Use a clean local demo Auth user or remove the conflicting non-demo membership before running this seed.';
  end if;

  insert into public.company_users (
    id,
    company_id,
    profile_id,
    company_role,
    is_active,
    created_by,
    deactivated_by,
    deactivated_at,
    deactivation_reason
  ) values (
    '76000000-0000-4000-8000-000000000001',
    demo_company_id,
    company_admin_profile_id,
    'company_admin',
    true,
    admin_profile_id,
    null,
    null,
    null
  )
  on conflict (profile_id) do update set
    company_role = excluded.company_role,
    is_active = true,
    deactivated_by = null,
    deactivated_at = null,
    deactivation_reason = null
  returning id into company_membership_id;

  insert into public.drug_classes (
    id,
    code,
    parent_drug_class_id,
    is_active,
    created_by,
    updated_by
  ) values
    (
      '77000000-0000-4000-8000-000000000001',
      'beta_blockers',
      null,
      false,
      admin_profile_id,
      admin_profile_id
    ),
    (
      '77000000-0000-4000-8000-000000000002',
      'bronchodilators',
      null,
      false,
      admin_profile_id,
      admin_profile_id
    )
  on conflict (lower(code)) do update set
    parent_drug_class_id = excluded.parent_drug_class_id,
    updated_by = admin_profile_id;

  select id into beta_blockers_class_id
  from public.drug_classes
  where lower(code) = 'beta_blockers';

  select id into bronchodilators_class_id
  from public.drug_classes
  where lower(code) = 'bronchodilators';

  insert into public.drug_class_translations (
    drug_class_id,
    locale,
    name,
    description
  ) values
    (
      beta_blockers_class_id,
      'en',
      'Beta Blockers',
      'Demo cardiovascular drug class.'
    ),
    (
      bronchodilators_class_id,
      'en',
      'Bronchodilators',
      'Demo respiratory drug class.'
    )
  on conflict (drug_class_id, locale) do update set
    name = excluded.name,
    description = excluded.description;

  update public.drug_classes
  set is_active = true,
      updated_by = admin_profile_id
  where id in (beta_blockers_class_id, bronchodilators_class_id);

  insert into public.active_ingredients (
    id,
    code,
    is_active,
    created_by,
    updated_by
  ) values
    (
      '78000000-0000-4000-8000-000000000001',
      'bisoprolol',
      false,
      admin_profile_id,
      admin_profile_id
    ),
    (
      '78000000-0000-4000-8000-000000000002',
      'salbutamol',
      false,
      admin_profile_id,
      admin_profile_id
    )
  on conflict (lower(code)) do update set
    updated_by = admin_profile_id;

  select id into bisoprolol_ingredient_id
  from public.active_ingredients
  where lower(code) = 'bisoprolol';

  select id into salbutamol_ingredient_id
  from public.active_ingredients
  where lower(code) = 'salbutamol';

  insert into public.active_ingredient_translations (
    active_ingredient_id,
    locale,
    name,
    description
  ) values
    (
      bisoprolol_ingredient_id,
      'en',
      'Bisoprolol',
      'Demo active ingredient.'
    ),
    (
      salbutamol_ingredient_id,
      'en',
      'Salbutamol',
      'Demo active ingredient.'
    )
  on conflict (active_ingredient_id, locale) do update set
    name = excluded.name,
    description = excluded.description;

  update public.active_ingredients
  set is_active = true,
      updated_by = admin_profile_id
  where id in (bisoprolol_ingredient_id, salbutamol_ingredient_id);

  insert into public.generic_drugs (
    id,
    code,
    drug_class_id,
    is_active,
    created_by,
    updated_by
  ) values
    (
      '79000000-0000-4000-8000-000000000001',
      'bisoprolol',
      beta_blockers_class_id,
      false,
      admin_profile_id,
      admin_profile_id
    ),
    (
      '79000000-0000-4000-8000-000000000002',
      'salbutamol',
      bronchodilators_class_id,
      false,
      admin_profile_id,
      admin_profile_id
    )
  on conflict (lower(code)) do update set
    drug_class_id = excluded.drug_class_id,
    updated_by = admin_profile_id;

  select id into bisoprolol_generic_id
  from public.generic_drugs
  where lower(code) = 'bisoprolol';

  select id into salbutamol_generic_id
  from public.generic_drugs
  where lower(code) = 'salbutamol';

  insert into public.generic_drug_translations (
    generic_drug_id,
    locale,
    name,
    description
  ) values
    (
      bisoprolol_generic_id,
      'en',
      'Bisoprolol',
      'Demo generic/scientific product.'
    ),
    (
      salbutamol_generic_id,
      'en',
      'Salbutamol',
      'Demo generic/scientific product.'
    )
  on conflict (generic_drug_id, locale) do update set
    name = excluded.name,
    description = excluded.description;

  insert into public.generic_drug_ingredients (
    generic_drug_id,
    active_ingredient_id,
    sort_order,
    created_by
  ) values
    (
      bisoprolol_generic_id,
      bisoprolol_ingredient_id,
      1,
      admin_profile_id
    ),
    (
      salbutamol_generic_id,
      salbutamol_ingredient_id,
      1,
      admin_profile_id
    )
  on conflict (generic_drug_id, active_ingredient_id) do update set
    sort_order = excluded.sort_order;

  update public.generic_drugs
  set is_active = true,
      updated_by = admin_profile_id
  where id in (bisoprolol_generic_id, salbutamol_generic_id);

  delete from public.product_search_keywords
  where product_id in (product_a_id, product_b_id);

  delete from public.product_media
  where product_id in (product_a_id, product_b_id);

  delete from public.product_specialties
  where product_id in (product_a_id, product_b_id);

  delete from public.product_brochures as brochure
  using public.product_markets as market
  where brochure.product_market_id = market.id
    and market.product_id in (product_a_id, product_b_id);

  delete from public.product_market_translations as translation
  using public.product_markets as market
  where translation.product_market_id = market.id
    and market.product_id in (product_a_id, product_b_id);

  delete from public.product_markets
  where product_id in (product_a_id, product_b_id);

  delete from public.product_translations
  where product_id in (product_a_id, product_b_id);

  delete from public.products
  where id in (product_a_id, product_b_id);

  insert into public.products (
    id,
    company_id,
    generic_drug_id,
    drug_class_id,
    category,
    status,
    presentation_fingerprint,
    created_by,
    updated_by,
    submitted_by,
    submitted_at,
    reviewed_by,
    reviewed_at,
    review_reason,
    published_by,
    published_at,
    hidden_by,
    hidden_at,
    hidden_reason,
    archived_by,
    archived_at,
    archive_reason
  ) values
    (
      product_a_id,
      demo_company_id,
      bisoprolol_generic_id,
      beta_blockers_class_id,
      'prescription_drug',
      'published',
      null,
      company_admin_profile_id,
      company_admin_profile_id,
      company_admin_profile_id,
      demo_timestamp - interval '4 days',
      admin_profile_id,
      demo_timestamp - interval '3 days',
      null,
      admin_profile_id,
      demo_timestamp - interval '3 days',
      null,
      null,
      null,
      null,
      null,
      null
    ),
    (
      product_b_id,
      demo_company_id,
      salbutamol_generic_id,
      bronchodilators_class_id,
      'prescription_drug',
      'draft',
      null,
      company_admin_profile_id,
      company_admin_profile_id,
      null,
      null,
      null,
      null,
      null,
      null,
      null,
      null,
      null,
      null,
      null,
      null,
      null
    );

  insert into public.product_translations (
    product_id,
    locale,
    brand_name
  ) values
    (product_a_id, 'en', 'Cardiostead 5 mg'),
    (product_b_id, 'en', 'Airvento 100 mcg');

  insert into public.product_markets (
    id,
    product_id,
    country_id,
    strength,
    dosage_form,
    route,
    pack_size,
    market_status,
    registration_status,
    registration_number,
    registration_authority,
    registration_expires_on
  ) values
    (
      product_a_market_id,
      product_a_id,
      iraq_country_id,
      '5 mg',
      'Tablet',
      'Oral',
      '30 tablets blister pack',
      'marketed_in_iraq',
      'registered',
      'IQ-DEMO-CARDIO-001',
      'Iraq Ministry of Health',
      '2028-12-31'
    ),
    (
      product_b_market_id,
      product_b_id,
      iraq_country_id,
      '100 mcg per actuation',
      'Metered-dose inhaler',
      'Inhalation',
      '200-dose inhaler',
      'marketed_in_iraq',
      'registered',
      'IQ-DEMO-RESP-001',
      'Iraq Ministry of Health',
      '2028-06-30'
    );

  insert into public.product_market_translations (
    product_market_id,
    locale,
    storage_conditions,
    approved_indications,
    usual_adult_dose,
    contraindications,
    common_adverse_effects
  ) values
    (
      product_a_market_id,
      'en',
      'Store below 25°C in a dry place.',
      'Official demo catalog information for physician review of approved cardiovascular indications.',
      'Use according to the approved product information and physician judgment.',
      'Refer to approved labeling for contraindications.',
      'Refer to approved labeling for warnings and adverse effects.'
    ),
    (
      product_b_market_id,
      'en',
      'Store below 30°C. Protect from direct sunlight.',
      'Official demo catalog information for physician review of approved respiratory indications.',
      'Use according to approved product information and physician judgment.',
      'Refer to approved labeling for contraindications.',
      'Refer to approved labeling for warnings and adverse effects.'
    );

  insert into public.product_specialties (
    product_id,
    specialty_id,
    created_by
  ) values
    (product_a_id, cardiology_specialty_id, company_admin_profile_id),
    (product_b_id, respiratory_specialty_id, company_admin_profile_id);

  perform private.refresh_product_presentation_fingerprint(product_a_id);
  perform private.refresh_product_presentation_fingerprint(product_b_id);
  perform private.refresh_product_search_keywords(product_a_id);
  perform private.refresh_product_search_keywords(product_b_id);
end;
$$;
