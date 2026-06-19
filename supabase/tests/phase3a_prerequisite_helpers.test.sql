begin;

select plan(14);

insert into auth.users (
  id, instance_id, aud, role, email, encrypted_password,
  email_confirmed_at, raw_app_meta_data, raw_user_meta_data,
  created_at, updated_at
)
values
  (
    '42000000-0000-4000-8000-000000000001',
    '00000000-0000-0000-0000-000000000000',
    'authenticated', 'authenticated', 'helper-admin@example.com',
    extensions.crypt('password', extensions.gen_salt('bf')), now(),
    '{"provider":"email","providers":["email"]}'::jsonb, '{}'::jsonb,
    now(), now()
  ),
  (
    '42000000-0000-4000-8000-000000000002',
    '00000000-0000-0000-0000-000000000000',
    'authenticated', 'authenticated', 'helper-doctor@example.com',
    extensions.crypt('password', extensions.gen_salt('bf')), now(),
    '{"provider":"email","providers":["email"]}'::jsonb, '{}'::jsonb,
    now(), now()
  ),
  (
    '42000000-0000-4000-8000-000000000003',
    '00000000-0000-0000-0000-000000000000',
    'authenticated', 'authenticated', 'helper-pharmacist@example.com',
    extensions.crypt('password', extensions.gen_salt('bf')), now(),
    '{"provider":"email","providers":["email"]}'::jsonb, '{}'::jsonb,
    now(), now()
  ),
  (
    '42000000-0000-4000-8000-000000000004',
    '00000000-0000-0000-0000-000000000000',
    'authenticated', 'authenticated', 'helper-company@example.com',
    extensions.crypt('password', extensions.gen_salt('bf')), now(),
    '{"provider":"email","providers":["email"]}'::jsonb, '{}'::jsonb,
    now(), now()
  ),
  (
    '42000000-0000-4000-8000-000000000005',
    '00000000-0000-0000-0000-000000000000',
    'authenticated', 'authenticated', 'helper-pending@example.com',
    extensions.crypt('password', extensions.gen_salt('bf')), now(),
    '{"provider":"email","providers":["email"]}'::jsonb, '{}'::jsonb,
    now(), now()
  );

update public.profiles
set role = 'admin', status = 'active'
where auth_user_id = '42000000-0000-4000-8000-000000000001';

update public.profiles
set role = 'healthcare_professional', status = 'active'
where auth_user_id in (
  '42000000-0000-4000-8000-000000000002',
  '42000000-0000-4000-8000-000000000003'
);

update public.profiles
set role = 'company_user', status = 'active'
where auth_user_id = '42000000-0000-4000-8000-000000000004';

insert into public.specialties (
  id, code, profession_type, created_by, updated_by
)
select
  '42000000-0000-4000-8000-000000000010',
  'helper_general',
  null,
  id,
  id
from public.profiles
where auth_user_id = '42000000-0000-4000-8000-000000000001';

insert into public.specialty_translations (specialty_id, locale, name)
values (
  '42000000-0000-4000-8000-000000000010',
  'en',
  'General Practice'
);

update public.specialties
set is_active = true
where id = '42000000-0000-4000-8000-000000000010';

insert into public.healthcare_professionals (
  id, profile_id, profession_type, specialty_id, license_number,
  verification_status, reviewed_by, reviewed_at
)
select
  '42000000-0000-4000-8000-000000000020',
  doctor.id,
  'physician',
  '42000000-0000-4000-8000-000000000010',
  'DOC-HELPER-1',
  'approved',
  admin_profile.id,
  now()
from public.profiles as doctor
cross join public.profiles as admin_profile
where doctor.auth_user_id = '42000000-0000-4000-8000-000000000002'
  and admin_profile.auth_user_id = '42000000-0000-4000-8000-000000000001';

insert into public.healthcare_professionals (
  id, profile_id, profession_type, specialty_id, license_number,
  verification_status, reviewed_by, reviewed_at
)
select
  '42000000-0000-4000-8000-000000000021',
  pharmacist.id,
  'pharmacist',
  '42000000-0000-4000-8000-000000000010',
  'PHA-HELPER-1',
  'approved',
  admin_profile.id,
  now()
from public.profiles as pharmacist
cross join public.profiles as admin_profile
where pharmacist.auth_user_id = '42000000-0000-4000-8000-000000000003'
  and admin_profile.auth_user_id = '42000000-0000-4000-8000-000000000001';

insert into public.healthcare_professionals (
  id, profile_id, profession_type, specialty_id, license_number
)
select
  '42000000-0000-4000-8000-000000000022',
  id,
  'physician',
  '42000000-0000-4000-8000-000000000010',
  'DOC-PENDING-1'
from public.profiles
where auth_user_id = '42000000-0000-4000-8000-000000000005';

insert into public.companies (
  id, applicant_profile_id, country_id, company_name, legal_name,
  status, verified_by, verified_at
)
select
  '42000000-0000-4000-8000-000000000030',
  company_profile.id,
  '00000000-0000-4000-8000-000000000368',
  'Helper Pharma',
  'Helper Pharma LLC',
  'verified',
  admin_profile.id,
  now()
from public.profiles as company_profile
cross join public.profiles as admin_profile
where company_profile.auth_user_id = '42000000-0000-4000-8000-000000000004'
  and admin_profile.auth_user_id = '42000000-0000-4000-8000-000000000001';

insert into public.company_users (
  id, company_id, profile_id, company_role, created_by
)
select
  '42000000-0000-4000-8000-000000000040',
  '42000000-0000-4000-8000-000000000030',
  company_profile.id,
  'company_admin',
  admin_profile.id
from public.profiles as company_profile
cross join public.profiles as admin_profile
where company_profile.auth_user_id = '42000000-0000-4000-8000-000000000004'
  and admin_profile.auth_user_id = '42000000-0000-4000-8000-000000000001';

set constraints all immediate;

select set_config(
  'request.jwt.claim.sub',
  '42000000-0000-4000-8000-000000000002',
  true
);
select set_config('request.jwt.claim.role', 'authenticated', true);

select ok(private.is_approved_doctor(), 'approved physician is eligible');
select is(
  private.current_healthcare_professional_id(),
  '42000000-0000-4000-8000-000000000020'::uuid,
  'current professional resolves for approved active doctor'
);
select ok(
  private.is_healthcare_professional_owner(
    '42000000-0000-4000-8000-000000000020'
  ),
  'professional ownership helper resolves current doctor'
);

select set_config(
  'request.jwt.claim.sub',
  '42000000-0000-4000-8000-000000000003',
  true
);
select is(
  private.is_approved_doctor(),
  false,
  'approved pharmacist is not doctor eligible'
);

select set_config(
  'request.jwt.claim.sub',
  '42000000-0000-4000-8000-000000000005',
  true
);
select is(
  private.is_approved_doctor(),
  false,
  'pending professional is not doctor eligible'
);
select is(
  private.current_healthcare_professional_id(),
  null,
  'pending unclassified profile has no current professional context'
);

select set_config(
  'request.jwt.claim.sub',
  '42000000-0000-4000-8000-000000000004',
  true
);
select is(
  private.current_company_id(),
  '42000000-0000-4000-8000-000000000030'::uuid,
  'active verified membership resolves company'
);
select is(
  private.current_company_role()::text,
  'company_admin',
  'active membership resolves company role'
);
select ok(
  private.is_active_company_member(
    '42000000-0000-4000-8000-000000000030'
  ),
  'active company member helper succeeds'
);
select ok(
  private.has_company_role(
    '42000000-0000-4000-8000-000000000030',
    array['company_admin']::public.company_role[]
  ),
  'required company role succeeds'
);
select ok(
  private.is_company_admin(
    '42000000-0000-4000-8000-000000000030'
  ),
  'company admin helper succeeds'
);
select ok(
  private.is_verified_company(
    '42000000-0000-4000-8000-000000000030'
  ),
  'verified company helper succeeds'
);
select ok(
  private.can_access_company(
    '42000000-0000-4000-8000-000000000030'
  ),
  'company access helper succeeds for active member'
);

update public.companies
set
  status = 'suspended',
  suspended_by = (
    select id from public.profiles
    where auth_user_id = '42000000-0000-4000-8000-000000000001'
  ),
  suspended_at = now(),
  suspension_reason = 'Helper test'
where id = '42000000-0000-4000-8000-000000000030';

select is(
  private.current_company_id(),
  null,
  'suspended company fails closed'
);

select * from finish();
rollback;
