begin;

select plan(10);

insert into auth.users (
  id, instance_id, aud, role, email, encrypted_password,
  email_confirmed_at, raw_app_meta_data, raw_user_meta_data,
  created_at, updated_at
) values
  (
    '66000000-0000-4000-8000-000000000001',
    '00000000-0000-0000-0000-000000000000',
    'authenticated', 'authenticated', 'visibility-admin@example.com',
    extensions.crypt('password', extensions.gen_salt('bf')), now(),
    '{"provider":"email","providers":["email"]}'::jsonb, '{}'::jsonb,
    now(), now()
  ),
  (
    '66000000-0000-4000-8000-000000000002',
    '00000000-0000-0000-0000-000000000000',
    'authenticated', 'authenticated', 'visibility-doctor@example.com',
    extensions.crypt('password', extensions.gen_salt('bf')), now(),
    '{"provider":"email","providers":["email"]}'::jsonb, '{}'::jsonb,
    now(), now()
  ),
  (
    '66000000-0000-4000-8000-000000000003',
    '00000000-0000-0000-0000-000000000000',
    'authenticated', 'authenticated', 'visibility-pharmacist@example.com',
    extensions.crypt('password', extensions.gen_salt('bf')), now(),
    '{"provider":"email","providers":["email"]}'::jsonb, '{}'::jsonb,
    now(), now()
  ),
  (
    '66000000-0000-4000-8000-000000000004',
    '00000000-0000-0000-0000-000000000000',
    'authenticated', 'authenticated', 'visibility-pending@example.com',
    extensions.crypt('password', extensions.gen_salt('bf')), now(),
    '{"provider":"email","providers":["email"]}'::jsonb, '{}'::jsonb,
    now(), now()
  ),
  (
    '66000000-0000-4000-8000-000000000005',
    '00000000-0000-0000-0000-000000000000',
    'authenticated', 'authenticated', 'visibility-suspended@example.com',
    extensions.crypt('password', extensions.gen_salt('bf')), now(),
    '{"provider":"email","providers":["email"]}'::jsonb, '{}'::jsonb,
    now(), now()
  ),
  (
    '66000000-0000-4000-8000-000000000006',
    '00000000-0000-0000-0000-000000000000',
    'authenticated', 'authenticated', 'visibility-company@example.com',
    extensions.crypt('password', extensions.gen_salt('bf')), now(),
    '{"provider":"email","providers":["email"]}'::jsonb, '{}'::jsonb,
    now(), now()
  );

update public.profiles set role = 'admin', status = 'active'
where auth_user_id = '66000000-0000-4000-8000-000000000001';
update public.profiles set role = 'healthcare_professional', status = 'active'
where auth_user_id in (
  '66000000-0000-4000-8000-000000000002',
  '66000000-0000-4000-8000-000000000003',
  '66000000-0000-4000-8000-000000000004'
);
update public.profiles
set role = 'healthcare_professional', status = 'suspended'
where auth_user_id = '66000000-0000-4000-8000-000000000005';
update public.profiles set role = 'company_user', status = 'active'
where auth_user_id = '66000000-0000-4000-8000-000000000006';

insert into public.specialties (
  id, code, profession_type, created_by, updated_by
)
select
  '66000000-0000-4000-8000-000000000010',
  'visibility_general', null, id, id
from public.profiles
where auth_user_id = '66000000-0000-4000-8000-000000000001';
insert into public.specialty_translations (specialty_id, locale, name)
values (
  '66000000-0000-4000-8000-000000000010', 'en',
  'Visibility General'
);
update public.specialties set is_active = true
where id = '66000000-0000-4000-8000-000000000010';

insert into public.healthcare_professionals (
  profile_id, profession_type, specialty_id, license_number,
  verification_status, reviewed_by, reviewed_at
)
select
  professional.id,
  case when professional.auth_user_id =
    '66000000-0000-4000-8000-000000000003'
    then 'pharmacist'::public.profession_type
    else 'physician'::public.profession_type end,
  '66000000-0000-4000-8000-000000000010',
  'VIS-' || right(professional.auth_user_id::text, 4),
  case when professional.auth_user_id =
    '66000000-0000-4000-8000-000000000004'
    then 'pending'::public.healthcare_professional_verification_status
    else 'approved'::public.healthcare_professional_verification_status end,
  case when professional.auth_user_id =
    '66000000-0000-4000-8000-000000000004'
    then null else admin_profile.id end,
  case when professional.auth_user_id =
    '66000000-0000-4000-8000-000000000004'
    then null else now() end
from public.profiles professional
cross join public.profiles admin_profile
where professional.auth_user_id in (
  '66000000-0000-4000-8000-000000000002',
  '66000000-0000-4000-8000-000000000003',
  '66000000-0000-4000-8000-000000000004',
  '66000000-0000-4000-8000-000000000005'
)
and admin_profile.auth_user_id = '66000000-0000-4000-8000-000000000001';

insert into public.companies (
  id, applicant_profile_id, country_id, company_name, legal_name,
  status, verified_by, verified_at
)
select
  '66000000-0000-4000-8000-000000000020', member.id,
  '00000000-0000-4000-8000-000000000368',
  'Visibility Company', 'Visibility Company LLC',
  'verified', admin_profile.id, now()
from public.profiles member
cross join public.profiles admin_profile
where member.auth_user_id = '66000000-0000-4000-8000-000000000006'
  and admin_profile.auth_user_id = '66000000-0000-4000-8000-000000000001';

insert into public.drug_classes (id, code, created_by, updated_by)
select
  '66000000-0000-4000-8000-000000000030',
  'visibility_class', id, id
from public.profiles
where auth_user_id = '66000000-0000-4000-8000-000000000001';
insert into public.drug_class_translations (drug_class_id, locale, name)
values (
  '66000000-0000-4000-8000-000000000030', 'en', 'Visibility Class'
);
update public.drug_classes set is_active = true
where id = '66000000-0000-4000-8000-000000000030';

insert into public.products (
  id, company_id, drug_class_id, category, status,
  created_by, updated_by, submitted_by, submitted_at,
  reviewed_by, reviewed_at, published_by, published_at
)
select
  '66000000-0000-4000-8000-000000000040',
  '66000000-0000-4000-8000-000000000020',
  '66000000-0000-4000-8000-000000000030',
  'dietary_supplement', 'published', member.id, member.id,
  member.id, now(), admin_profile.id, now(), admin_profile.id, now()
from public.profiles member
cross join public.profiles admin_profile
where member.auth_user_id = '66000000-0000-4000-8000-000000000006'
  and admin_profile.auth_user_id = '66000000-0000-4000-8000-000000000001';
insert into public.product_markets (
  product_id, country_id, strength, dosage_form, route, pack_size,
  market_status
) values (
  '66000000-0000-4000-8000-000000000040',
  '00000000-0000-4000-8000-000000000368',
  '10 mg', 'tablet', 'oral', '10 tablets', 'marketed_in_iraq'
);

select set_config(
  'request.jwt.claim.sub',
  '66000000-0000-4000-8000-000000000002',
  true
);
select set_config('request.jwt.claim.role', 'authenticated', true);
select ok(private.is_approved_doctor(), 'approved active physician is eligible');
select ok(
  private.can_read_official_catalog_product(
    '66000000-0000-4000-8000-000000000040'
  ),
  'approved active physician passes official visibility helper'
);
set local role authenticated;
select is(
  (select count(*) from public.products), 1::bigint,
  'approved active physician reads official product'
);
reset role;

select set_config(
  'request.jwt.claim.sub',
  '66000000-0000-4000-8000-000000000003',
  true
);
select is(private.is_approved_doctor(), false, 'pharmacist is not eligible');
set local role authenticated;
select is(
  (select count(*) from public.products), 0::bigint,
  'pharmacist receives no official catalog access'
);
reset role;

select set_config(
  'request.jwt.claim.sub',
  '66000000-0000-4000-8000-000000000004',
  true
);
select is(
  private.is_approved_doctor(), false,
  'pending physician is not eligible'
);
set local role authenticated;
select is(
  (select count(*) from public.products), 0::bigint,
  'pending physician receives no official catalog access'
);
reset role;

select set_config(
  'request.jwt.claim.sub',
  '66000000-0000-4000-8000-000000000005',
  true
);
select is(
  private.is_approved_doctor(), false,
  'suspended physician profile is not eligible'
);
set local role authenticated;
select is(
  (select count(*) from public.products), 0::bigint,
  'suspended physician receives no official catalog access'
);
reset role;

update public.companies
set
  status = 'suspended',
  suspended_by = verified_by,
  suspended_at = now(),
  suspension_reason = 'Visibility test'
where id = '66000000-0000-4000-8000-000000000020';

select set_config(
  'request.jwt.claim.sub',
  '66000000-0000-4000-8000-000000000002',
  true
);
set local role authenticated;
select is(
  (select count(*) from public.products), 0::bigint,
  'company suspension dynamically removes doctor visibility'
);
reset role;

select * from finish();
rollback;
