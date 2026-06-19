begin;

select plan(16);

insert into auth.users (
  id, instance_id, aud, role, email, encrypted_password,
  email_confirmed_at, raw_app_meta_data, raw_user_meta_data,
  created_at, updated_at
)
values
  (
    '44000000-0000-4000-8000-000000000001',
    '00000000-0000-0000-0000-000000000000',
    'authenticated', 'authenticated', 'rls-admin@example.com',
    extensions.crypt('password', extensions.gen_salt('bf')), now(),
    '{"provider":"email","providers":["email"]}'::jsonb, '{}'::jsonb,
    now(), now()
  ),
  (
    '44000000-0000-4000-8000-000000000002',
    '00000000-0000-0000-0000-000000000000',
    'authenticated', 'authenticated', 'rls-doctor@example.com',
    extensions.crypt('password', extensions.gen_salt('bf')), now(),
    '{"provider":"email","providers":["email"]}'::jsonb, '{}'::jsonb,
    now(), now()
  ),
  (
    '44000000-0000-4000-8000-000000000003',
    '00000000-0000-0000-0000-000000000000',
    'authenticated', 'authenticated', 'rls-applicant@example.com',
    extensions.crypt('password', extensions.gen_salt('bf')), now(),
    '{"provider":"email","providers":["email"]}'::jsonb, '{}'::jsonb,
    now(), now()
  ),
  (
    '44000000-0000-4000-8000-000000000004',
    '00000000-0000-0000-0000-000000000000',
    'authenticated', 'authenticated', 'rls-company-admin@example.com',
    extensions.crypt('password', extensions.gen_salt('bf')), now(),
    '{"provider":"email","providers":["email"]}'::jsonb, '{}'::jsonb,
    now(), now()
  ),
  (
    '44000000-0000-4000-8000-000000000005',
    '00000000-0000-0000-0000-000000000000',
    'authenticated', 'authenticated', 'rls-company-viewer@example.com',
    extensions.crypt('password', extensions.gen_salt('bf')), now(),
    '{"provider":"email","providers":["email"]}'::jsonb, '{}'::jsonb,
    now(), now()
  ),
  (
    '44000000-0000-4000-8000-000000000006',
    '00000000-0000-0000-0000-000000000000',
    'authenticated', 'authenticated', 'rls-outsider@example.com',
    extensions.crypt('password', extensions.gen_salt('bf')), now(),
    '{"provider":"email","providers":["email"]}'::jsonb, '{}'::jsonb,
    now(), now()
  );

update public.profiles set role = 'admin', status = 'active'
where auth_user_id = '44000000-0000-4000-8000-000000000001';
update public.profiles set role = 'healthcare_professional', status = 'active'
where auth_user_id = '44000000-0000-4000-8000-000000000002';
update public.profiles set role = 'company_user', status = 'active'
where auth_user_id in (
  '44000000-0000-4000-8000-000000000004',
  '44000000-0000-4000-8000-000000000005'
);

insert into public.specialties (
  id, code, profession_type, created_by, updated_by
)
select
  '44000000-0000-4000-8000-000000000010',
  'rls_internal_medicine',
  'physician',
  id,
  id
from public.profiles
where auth_user_id = '44000000-0000-4000-8000-000000000001';
insert into public.specialty_translations (specialty_id, locale, name)
values (
  '44000000-0000-4000-8000-000000000010',
  'en',
  'Internal Medicine'
);
update public.specialties set is_active = true
where id = '44000000-0000-4000-8000-000000000010';

insert into public.healthcare_professionals (
  id, profile_id, profession_type, specialty_id, license_number,
  verification_status, reviewed_by, reviewed_at
)
select
  '44000000-0000-4000-8000-000000000020',
  doctor.id,
  'physician',
  '44000000-0000-4000-8000-000000000010',
  'RLS-DOC-001',
  'approved',
  admin_profile.id,
  now()
from public.profiles as doctor
cross join public.profiles as admin_profile
where doctor.auth_user_id = '44000000-0000-4000-8000-000000000002'
  and admin_profile.auth_user_id = '44000000-0000-4000-8000-000000000001';

insert into public.companies (
  id, applicant_profile_id, country_id, company_name, legal_name
)
select
  '44000000-0000-4000-8000-000000000030',
  id,
  '00000000-0000-4000-8000-000000000368',
  'Pending RLS Pharma',
  'Pending RLS Pharma LLC'
from public.profiles
where auth_user_id = '44000000-0000-4000-8000-000000000003';

insert into public.companies (
  id, applicant_profile_id, country_id, company_name, legal_name,
  status, verified_by, verified_at
)
select
  '44000000-0000-4000-8000-000000000031',
  company_admin.id,
  '00000000-0000-4000-8000-000000000368',
  'Verified RLS Pharma',
  'Verified RLS Pharma LLC',
  'verified',
  admin_profile.id,
  now()
from public.profiles as company_admin
cross join public.profiles as admin_profile
where company_admin.auth_user_id = '44000000-0000-4000-8000-000000000004'
  and admin_profile.auth_user_id = '44000000-0000-4000-8000-000000000001';

insert into public.company_users (
  id, company_id, profile_id, company_role, created_by
)
select
  '44000000-0000-4000-8000-000000000040',
  '44000000-0000-4000-8000-000000000031',
  company_admin.id,
  'company_admin',
  admin_profile.id
from public.profiles as company_admin
cross join public.profiles as admin_profile
where company_admin.auth_user_id = '44000000-0000-4000-8000-000000000004'
  and admin_profile.auth_user_id = '44000000-0000-4000-8000-000000000001';

insert into public.company_users (
  id, company_id, profile_id, company_role, created_by
)
select
  '44000000-0000-4000-8000-000000000041',
  '44000000-0000-4000-8000-000000000031',
  company_viewer.id,
  'viewer',
  admin_profile.id
from public.profiles as company_viewer
cross join public.profiles as admin_profile
where company_viewer.auth_user_id = '44000000-0000-4000-8000-000000000005'
  and admin_profile.auth_user_id = '44000000-0000-4000-8000-000000000001';

set constraints all immediate;

set local role anon;
select throws_ok(
  $$ select count(*) from public.healthcare_professionals $$,
  '42501',
  null,
  'anonymous users have no professional-table access'
);
select throws_ok(
  $$ select count(*) from public.companies $$,
  '42501',
  null,
  'anonymous users have no company-table access'
);
select throws_ok(
  $$ select count(*) from public.company_users $$,
  '42501',
  null,
  'anonymous users have no membership-table access'
);
reset role;

select set_config(
  'request.jwt.claim.sub',
  '44000000-0000-4000-8000-000000000002',
  true
);
select set_config('request.jwt.claim.role', 'authenticated', true);
set local role authenticated;
select is(
  (select count(*) from public.healthcare_professionals),
  1::bigint,
  'professional owner reads only own record'
);
select is(
  (select count(*) from public.companies),
  1::bigint,
  'approved doctor reads only verified company'
);
select throws_ok(
  $$
    update public.healthcare_professionals
    set verification_status = 'approved'
  $$,
  '42501',
  null,
  'professional owner cannot directly mutate verification'
);
reset role;

select set_config(
  'request.jwt.claim.sub',
  '44000000-0000-4000-8000-000000000003',
  true
);
set local role authenticated;
select is(
  (select count(*) from public.companies),
  1::bigint,
  'applicant reads only own pending company'
);
select is(
  (select count(*) from public.company_users),
  0::bigint,
  'applicant cannot read memberships'
);
reset role;

select set_config(
  'request.jwt.claim.sub',
  '44000000-0000-4000-8000-000000000004',
  true
);
set local role authenticated;
select is(
  (select count(*) from public.companies),
  1::bigint,
  'company member reads own verified company'
);
select is(
  (select count(*) from public.company_users),
  2::bigint,
  'company admin reads memberships in own company'
);
select throws_ok(
  $$
    insert into public.company_users (
      company_id, profile_id, company_role, created_by
    )
    values (
      '44000000-0000-4000-8000-000000000031',
      private.current_profile_id(),
      'viewer',
      private.current_profile_id()
    )
  $$,
  '42501',
  null,
  'company admin cannot directly create membership'
);
reset role;

select set_config(
  'request.jwt.claim.sub',
  '44000000-0000-4000-8000-000000000005',
  true
);
set local role authenticated;
select is(
  (select count(*) from public.company_users),
  1::bigint,
  'non-admin company member reads only own membership'
);
reset role;

select set_config(
  'request.jwt.claim.sub',
  '44000000-0000-4000-8000-000000000006',
  true
);
set local role authenticated;
select is(
  (select count(*) from public.companies),
  0::bigint,
  'ordinary outsider cannot read company records'
);
select is(
  (select count(*) from public.healthcare_professionals),
  0::bigint,
  'ordinary outsider cannot read professional records'
);
reset role;

select set_config(
  'request.jwt.claim.sub',
  '44000000-0000-4000-8000-000000000001',
  true
);
set local role authenticated;
select is(
  (select count(*) from public.companies),
  2::bigint,
  'admin reads all companies'
);
select is(
  (select count(*) from public.company_users),
  2::bigint,
  'admin reads all memberships'
);
reset role;

select * from finish();
rollback;
