begin;

select plan(11);

insert into auth.users (
  id, instance_id, aud, role, email, encrypted_password,
  email_confirmed_at, raw_app_meta_data, raw_user_meta_data,
  created_at, updated_at
)
values
  (
    '41000000-0000-4000-8000-000000000001',
    '00000000-0000-0000-0000-000000000000',
    'authenticated', 'authenticated', 'constraint-admin@example.com',
    extensions.crypt('password', extensions.gen_salt('bf')), now(),
    '{"provider":"email","providers":["email"]}'::jsonb, '{}'::jsonb,
    now(), now()
  ),
  (
    '41000000-0000-4000-8000-000000000002',
    '00000000-0000-0000-0000-000000000000',
    'authenticated', 'authenticated', 'constraint-user@example.com',
    extensions.crypt('password', extensions.gen_salt('bf')), now(),
    '{"provider":"email","providers":["email"]}'::jsonb, '{}'::jsonb,
    now(), now()
  ),
  (
    '41000000-0000-4000-8000-000000000003',
    '00000000-0000-0000-0000-000000000000',
    'authenticated', 'authenticated', 'constraint-other@example.com',
    extensions.crypt('password', extensions.gen_salt('bf')), now(),
    '{"provider":"email","providers":["email"]}'::jsonb, '{}'::jsonb,
    now(), now()
  );

update public.profiles
set role = 'admin', status = 'active'
where auth_user_id = '41000000-0000-4000-8000-000000000001';

insert into public.specialties (
  id, code, profession_type, created_by, updated_by
)
select
  '41000000-0000-4000-8000-000000000010',
  'constraint_cardiology',
  'physician',
  id,
  id
from public.profiles
where auth_user_id = '41000000-0000-4000-8000-000000000001';

select throws_ok(
  $$
    update public.specialties
    set is_active = true
    where id = '41000000-0000-4000-8000-000000000010'
  $$,
  '23514',
  'An English translation is required before activating a specialty.',
  'specialty activation requires English'
);

insert into public.specialty_translations (
  specialty_id, locale, name
)
values (
  '41000000-0000-4000-8000-000000000010',
  'en',
  'Cardiology'
);

update public.specialties
set is_active = true
where id = '41000000-0000-4000-8000-000000000010';

select ok(
  (
    select is_active from public.specialties
    where id = '41000000-0000-4000-8000-000000000010'
  ),
  'specialty activates after English translation'
);

insert into public.healthcare_professionals (
  id, profile_id, profession_type, specialty_id
)
select
  '41000000-0000-4000-8000-000000000020',
  id,
  'physician',
  '41000000-0000-4000-8000-000000000010'
from public.profiles
where auth_user_id = '41000000-0000-4000-8000-000000000002';

select throws_ok(
  $$
    insert into public.healthcare_professionals (
      profile_id, profession_type, specialty_id
    )
    select
      id, 'physician', '41000000-0000-4000-8000-000000000010'
    from public.profiles
    where auth_user_id = '41000000-0000-4000-8000-000000000002'
  $$,
  '23505',
  null,
  'duplicate professional record is rejected'
);

select throws_ok(
  $$
    update public.healthcare_professionals
    set
      verification_status = 'approved',
      reviewed_by = (
        select id from public.profiles
        where auth_user_id = '41000000-0000-4000-8000-000000000001'
      ),
      reviewed_at = now()
    where id = '41000000-0000-4000-8000-000000000020'
  $$,
  '23514',
  null,
  'approval without license is rejected'
);

select throws_ok(
  $$
    update public.healthcare_professionals
    set profile_id = (
      select id from public.profiles
      where auth_user_id = '41000000-0000-4000-8000-000000000003'
    )
    where id = '41000000-0000-4000-8000-000000000020'
  $$,
  '55000',
  'The healthcare professional profile relationship is immutable.',
  'professional ownership is immutable'
);

insert into public.companies (
  id, applicant_profile_id, country_id, company_name, legal_name
)
select
  '41000000-0000-4000-8000-000000000030',
  id,
  '00000000-0000-4000-8000-000000000368',
  'Constraint Pharma',
  'Constraint Pharma LLC'
from public.profiles
where auth_user_id = '41000000-0000-4000-8000-000000000003';

select throws_ok(
  $$
    insert into public.companies (
      applicant_profile_id, country_id, company_name, legal_name
    )
    select
      (
        select id from public.profiles
        where auth_user_id = '41000000-0000-4000-8000-000000000002'
      ),
      '00000000-0000-4000-8000-000000000368',
      'Other Name',
      '  constraint pharma llc  '
  $$,
  '23505',
  null,
  'normalized legal name must be unique'
);

select throws_ok(
  $$
    update public.companies
    set applicant_profile_id = (
      select id from public.profiles
      where auth_user_id = '41000000-0000-4000-8000-000000000002'
    )
    where id = '41000000-0000-4000-8000-000000000030'
  $$,
  '55000',
  'The company applicant relationship is immutable.',
  'company applicant is immutable'
);

select throws_ok(
  $$
    insert into public.companies (
      applicant_profile_id, country_id, city_id, company_name, legal_name
    )
    select
      (
        select id from public.profiles
        where auth_user_id = '41000000-0000-4000-8000-000000000002'
      ),
      '00000000-0000-4000-8000-000000000368',
      gen_random_uuid(),
      'Bad Geography',
      'Bad Geography LLC'
  $$,
  '23514',
  'The company country and city must be active and consistent.',
  'invalid company geography is rejected'
);

select throws_ok(
  $$
    insert into public.company_users (
      company_id, profile_id, company_role, created_by
    )
    select
      '41000000-0000-4000-8000-000000000030',
      user_profile.id,
      'viewer',
      admin_profile.id
    from public.profiles as user_profile
    cross join public.profiles as admin_profile
    where user_profile.auth_user_id = '41000000-0000-4000-8000-000000000002'
      and admin_profile.auth_user_id = '41000000-0000-4000-8000-000000000001';

    insert into public.company_users (
      company_id, profile_id, company_role, created_by
    )
    select
      '41000000-0000-4000-8000-000000000030',
      user_profile.id,
      'viewer',
      admin_profile.id
    from public.profiles as user_profile
    cross join public.profiles as admin_profile
    where user_profile.auth_user_id = '41000000-0000-4000-8000-000000000002'
      and admin_profile.auth_user_id = '41000000-0000-4000-8000-000000000001'
  $$,
  '23505',
  null,
  'one company membership per profile is enforced'
);

insert into public.company_users (
  company_id, profile_id, company_role, created_by
)
select
  '41000000-0000-4000-8000-000000000030',
  user_profile.id,
  'viewer',
  admin_profile.id
from public.profiles as user_profile
cross join public.profiles as admin_profile
where user_profile.auth_user_id = '41000000-0000-4000-8000-000000000002'
  and admin_profile.auth_user_id = '41000000-0000-4000-8000-000000000001';

select throws_ok(
  $$
    update public.company_users
    set company_id = gen_random_uuid()
    where profile_id = (
      select id from public.profiles
      where auth_user_id = '41000000-0000-4000-8000-000000000002'
    )
  $$,
  '55000',
  'Company membership relationships are immutable.',
  'membership ownership is immutable'
);

select throws_ok(
  $$
    insert into public.company_users (
      company_id, profile_id, company_role, is_active, created_by
    )
    select
      '41000000-0000-4000-8000-000000000030',
      user_profile.id,
      'viewer',
      false,
      admin_profile.id
    from public.profiles as user_profile
    cross join public.profiles as admin_profile
    where user_profile.auth_user_id = '41000000-0000-4000-8000-000000000003'
      and admin_profile.auth_user_id = '41000000-0000-4000-8000-000000000001'
  $$,
  '23514',
  null,
  'inactive membership requires deactivation metadata'
);

select * from finish();
rollback;
