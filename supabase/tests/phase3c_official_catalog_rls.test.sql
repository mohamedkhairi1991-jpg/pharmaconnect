begin;

select plan(12);

insert into auth.users (
  id, instance_id, aud, role, email, encrypted_password,
  email_confirmed_at, raw_app_meta_data, raw_user_meta_data,
  created_at, updated_at
) values
  (
    '65000000-0000-4000-8000-000000000001',
    '00000000-0000-0000-0000-000000000000',
    'authenticated', 'authenticated', 'official-rls-admin@example.com',
    extensions.crypt('password', extensions.gen_salt('bf')), now(),
    '{"provider":"email","providers":["email"]}'::jsonb, '{}'::jsonb,
    now(), now()
  ),
  (
    '65000000-0000-4000-8000-000000000002',
    '00000000-0000-0000-0000-000000000000',
    'authenticated', 'authenticated', 'official-rls-doctor@example.com',
    extensions.crypt('password', extensions.gen_salt('bf')), now(),
    '{"provider":"email","providers":["email"]}'::jsonb, '{}'::jsonb,
    now(), now()
  ),
  (
    '65000000-0000-4000-8000-000000000003',
    '00000000-0000-0000-0000-000000000000',
    'authenticated', 'authenticated', 'official-rls-company@example.com',
    extensions.crypt('password', extensions.gen_salt('bf')), now(),
    '{"provider":"email","providers":["email"]}'::jsonb, '{}'::jsonb,
    now(), now()
  );

update public.profiles set role = 'admin', status = 'active'
where auth_user_id = '65000000-0000-4000-8000-000000000001';
update public.profiles set role = 'healthcare_professional', status = 'active'
where auth_user_id = '65000000-0000-4000-8000-000000000002';
update public.profiles set role = 'company_user', status = 'active'
where auth_user_id = '65000000-0000-4000-8000-000000000003';

insert into public.specialties (
  id, code, profession_type, created_by, updated_by
)
select
  '65000000-0000-4000-8000-000000000010',
  'official_rls_specialty', 'physician', id, id
from public.profiles
where auth_user_id = '65000000-0000-4000-8000-000000000001';
insert into public.specialty_translations (specialty_id, locale, name)
values (
  '65000000-0000-4000-8000-000000000010', 'en',
  'Official RLS Specialty'
);
update public.specialties set is_active = true
where id = '65000000-0000-4000-8000-000000000010';

insert into public.healthcare_professionals (
  profile_id, profession_type, specialty_id, license_number,
  verification_status, reviewed_by, reviewed_at
)
select
  doctor.id, 'physician',
  '65000000-0000-4000-8000-000000000010',
  'OFFICIAL-RLS-DOC', 'approved', admin_profile.id, now()
from public.profiles doctor
cross join public.profiles admin_profile
where doctor.auth_user_id = '65000000-0000-4000-8000-000000000002'
  and admin_profile.auth_user_id = '65000000-0000-4000-8000-000000000001';

insert into public.companies (
  id, applicant_profile_id, country_id, company_name, legal_name,
  status, verified_by, verified_at
)
select
  '65000000-0000-4000-8000-000000000020', member.id,
  '00000000-0000-4000-8000-000000000368',
  'Official RLS Company', 'Official RLS Company LLC',
  'verified', admin_profile.id, now()
from public.profiles member
cross join public.profiles admin_profile
where member.auth_user_id = '65000000-0000-4000-8000-000000000003'
  and admin_profile.auth_user_id = '65000000-0000-4000-8000-000000000001';
insert into public.company_users (
  company_id, profile_id, company_role, created_by
)
select
  '65000000-0000-4000-8000-000000000020', member.id,
  'company_admin', admin_profile.id
from public.profiles member
cross join public.profiles admin_profile
where member.auth_user_id = '65000000-0000-4000-8000-000000000003'
  and admin_profile.auth_user_id = '65000000-0000-4000-8000-000000000001';

insert into public.drug_classes (id, code, created_by, updated_by)
select
  '65000000-0000-4000-8000-000000000030',
  'official_rls_class', id, id
from public.profiles
where auth_user_id = '65000000-0000-4000-8000-000000000001';
insert into public.drug_class_translations (drug_class_id, locale, name)
values (
  '65000000-0000-4000-8000-000000000030', 'en',
  'Official RLS Class'
);
update public.drug_classes set is_active = true
where id = '65000000-0000-4000-8000-000000000030';

insert into public.products (
  id, company_id, drug_class_id, category, status,
  created_by, updated_by, submitted_by, submitted_at,
  reviewed_by, reviewed_at, published_by, published_at
)
select
  '65000000-0000-4000-8000-000000000040',
  '65000000-0000-4000-8000-000000000020',
  '65000000-0000-4000-8000-000000000030',
  'dietary_supplement', 'published', member.id, member.id,
  member.id, now(), admin_profile.id, now(), admin_profile.id, now()
from public.profiles member
cross join public.profiles admin_profile
where member.auth_user_id = '65000000-0000-4000-8000-000000000003'
  and admin_profile.auth_user_id = '65000000-0000-4000-8000-000000000001';
insert into public.product_translations (product_id, locale, brand_name)
values (
  '65000000-0000-4000-8000-000000000040', 'en',
  'Official RLS Brand'
);
insert into public.product_markets (
  id, product_id, country_id, strength, dosage_form, route, pack_size,
  market_status
) values (
  '65000000-0000-4000-8000-000000000041',
  '65000000-0000-4000-8000-000000000040',
  '00000000-0000-4000-8000-000000000368',
  '25 mg', 'tablet', 'oral', '10 tablets', 'marketed_in_iraq'
);
insert into public.product_market_translations (
  product_market_id, locale, storage_conditions, approved_indications,
  usual_adult_dose, contraindications, common_adverse_effects
) values (
  '65000000-0000-4000-8000-000000000041', 'en',
  'Store dry', 'Approved indication', 'One daily',
  'Known hypersensitivity', 'Mild effects'
);
insert into public.product_specialties (
  product_id, specialty_id, created_by
)
select
  '65000000-0000-4000-8000-000000000040',
  '65000000-0000-4000-8000-000000000010', id
from public.profiles
where auth_user_id = '65000000-0000-4000-8000-000000000003';
select private.refresh_product_search_keywords(
  '65000000-0000-4000-8000-000000000040'
);

set local role anon;
select throws_ok(
  $$ select count(*) from public.products $$,
  '42501', null,
  'anonymous users cannot read official catalog products'
);
select throws_ok(
  $$ select count(*) from public.product_search_keywords $$,
  '42501', null,
  'anonymous users cannot read official search keywords'
);
reset role;

select set_config(
  'request.jwt.claim.sub',
  '65000000-0000-4000-8000-000000000002',
  true
);
select set_config('request.jwt.claim.role', 'authenticated', true);
set local role authenticated;
select is(
  (select count(*) from public.products), 1::bigint,
  'approved physician reads published official product'
);
select is(
  (select count(*) from public.product_translations), 1::bigint,
  'product translations inherit official visibility'
);
select is(
  (select count(*) from public.product_markets), 1::bigint,
  'Iraq market inherits official visibility'
);
select is(
  (select count(*) from public.product_market_translations), 1::bigint,
  'clinical content inherits official visibility'
);
select is(
  (select count(*) from public.product_specialties), 1::bigint,
  'specialty links inherit official visibility'
);
select is(
  (select count(*) from public.product_search_keywords), 3::bigint,
  'search keywords inherit parent visibility'
);
select is(
  (select count(*) from public.drug_classes), 1::bigint,
  'approved physician reads active taxonomy'
);
reset role;

select set_config(
  'request.jwt.claim.sub',
  '65000000-0000-4000-8000-000000000001',
  true
);
set local role authenticated;
select public.admin_hide_product(
  '65000000-0000-4000-8000-000000000040',
  'Immediate safety moderation'
);
reset role;

select set_config(
  'request.jwt.claim.sub',
  '65000000-0000-4000-8000-000000000002',
  true
);
set local role authenticated;
select is(
  (select count(*) from public.products), 0::bigint,
  'hidden product immediately disappears from doctor visibility'
);
select is(
  (select count(*) from public.product_search_keywords), 0::bigint,
  'hidden product keywords do not grant independent access'
);
select is(
  (select count(*) from public.product_market_translations), 0::bigint,
  'hidden child content immediately disappears'
);
reset role;

select * from finish();
rollback;
