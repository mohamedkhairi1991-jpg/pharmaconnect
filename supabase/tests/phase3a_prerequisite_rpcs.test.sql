begin;

select plan(19);

insert into auth.users (
  id, instance_id, aud, role, email, encrypted_password,
  email_confirmed_at, raw_app_meta_data, raw_user_meta_data,
  created_at, updated_at
)
values
  (
    '43000000-0000-4000-8000-000000000001',
    '00000000-0000-0000-0000-000000000000',
    'authenticated', 'authenticated', 'rpc-admin@example.com',
    extensions.crypt('password', extensions.gen_salt('bf')), now(),
    '{"provider":"email","providers":["email"]}'::jsonb, '{}'::jsonb,
    now(), now()
  ),
  (
    '43000000-0000-4000-8000-000000000002',
    '00000000-0000-0000-0000-000000000000',
    'authenticated', 'authenticated', 'rpc-doctor@example.com',
    extensions.crypt('password', extensions.gen_salt('bf')), now(),
    '{"provider":"email","providers":["email"]}'::jsonb, '{}'::jsonb,
    now(), now()
  ),
  (
    '43000000-0000-4000-8000-000000000003',
    '00000000-0000-0000-0000-000000000000',
    'authenticated', 'authenticated', 'rpc-company@example.com',
    extensions.crypt('password', extensions.gen_salt('bf')), now(),
    '{"provider":"email","providers":["email"]}'::jsonb, '{}'::jsonb,
    now(), now()
  );

update public.profiles
set role = 'admin', status = 'active'
where auth_user_id = '43000000-0000-4000-8000-000000000001';

select set_config(
  'request.jwt.claim.sub',
  '43000000-0000-4000-8000-000000000001',
  true
);
select set_config('request.jwt.claim.role', 'authenticated', true);
set local role authenticated;

select lives_ok(
  $$
    select public.admin_create_specialty('rpc_cardiology', 'physician')
  $$,
  'admin creates inactive specialty'
);
select lives_ok(
  $$
    select public.admin_upsert_specialty_translation(
      (select id from public.specialties where code = 'rpc_cardiology'),
      'en',
      'Cardiology',
      null
    )
  $$,
  'admin creates English specialty translation'
);
select lives_ok(
  $$
    select public.admin_set_specialty_active(
      (select id from public.specialties where code = 'rpc_cardiology'),
      true
    )
  $$,
  'admin activates translated specialty'
);

reset role;
select set_config(
  'request.jwt.claim.sub',
  '43000000-0000-4000-8000-000000000002',
  true
);
set local role authenticated;

select lives_ok(
  $$
    select public.create_my_healthcare_professional_record(
      'physician',
      (select id from public.specialties where code = 'rpc_cardiology'),
      'Teaching Hospital',
      'RPC-DOC-001'
    )
  $$,
  'user creates own pending professional record'
);

select is(
  (
    select verification_status::text
    from public.healthcare_professionals
    where profile_id = private.current_profile_id()
  ),
  'pending',
  'self-created professional record remains pending'
);

select throws_ok(
  $$
    select public.admin_review_healthcare_professional(
      (select id from public.healthcare_professionals
       where profile_id = private.current_profile_id()),
      'approved',
      null
    )
  $$,
  '42501',
  'Administrator access is required.',
  'ordinary user cannot approve self'
);

reset role;
select set_config(
  'request.jwt.claim.sub',
  '43000000-0000-4000-8000-000000000001',
  true
);
set local role authenticated;

select lives_ok(
  $$
    select public.admin_review_healthcare_professional(
      (
        select professional.id
        from public.healthcare_professionals as professional
        join public.profiles as profile on profile.id = professional.profile_id
        where profile.auth_user_id = '43000000-0000-4000-8000-000000000002'
      ),
      'approved',
      null
    )
  $$,
  'admin approves complete physician record'
);

reset role;
select is(
  (
    select role::text
    from public.profiles
    where auth_user_id = '43000000-0000-4000-8000-000000000002'
  ),
  'healthcare_professional',
  'approval assigns healthcare professional platform role'
);
select is(
  (
    select status::text
    from public.profiles
    where auth_user_id = '43000000-0000-4000-8000-000000000002'
  ),
  'active',
  'approval activates profile'
);

select set_config(
  'request.jwt.claim.sub',
  '43000000-0000-4000-8000-000000000003',
  true
);
set local role authenticated;

select lives_ok(
  $$
    select public.create_company_application(
      '00000000-0000-4000-8000-000000000368',
      null,
      'RPC Pharma',
      'RPC Pharma LLC',
      'Company application',
      'https://rpc.example.com',
      'INFO@RPC.EXAMPLE.COM',
      '+9647000000000'
    )
  $$,
  'eligible user creates pending company application'
);

select throws_ok(
  $$
    select public.admin_verify_company(
      (select id from public.companies
       where applicant_profile_id = private.current_profile_id()),
      'self verification'
    )
  $$,
  '42501',
  'Administrator access is required.',
  'ordinary applicant cannot verify own company'
);

reset role;
select set_config(
  'request.jwt.claim.sub',
  '43000000-0000-4000-8000-000000000001',
  true
);
set local role authenticated;

select lives_ok(
  $$
    select public.admin_verify_company(
      (
        select company.id
        from public.companies as company
        join public.profiles as profile
          on profile.id = company.applicant_profile_id
        where profile.auth_user_id = '43000000-0000-4000-8000-000000000003'
      ),
      'Verified application'
    )
  $$,
  'admin verifies company atomically'
);

reset role;
select is(
  (
    select role::text from public.profiles
    where auth_user_id = '43000000-0000-4000-8000-000000000003'
  ),
  'company_user',
  'company verification assigns company user role'
);
select is(
  (
    select membership.company_role::text
    from public.company_users as membership
    join public.profiles as profile on profile.id = membership.profile_id
    where profile.auth_user_id = '43000000-0000-4000-8000-000000000003'
  ),
  'company_admin',
  'company verification creates initial company admin'
);

select set_config(
  'request.jwt.claim.sub',
  '43000000-0000-4000-8000-000000000001',
  true
);
set local role authenticated;

select lives_ok(
  $$
    select public.admin_suspend_company(
      (select id from public.companies where legal_name = 'RPC Pharma LLC'),
      'Compliance review'
    )
  $$,
  'admin suspends verified company'
);
select lives_ok(
  $$
    select public.admin_restore_company(
      (select id from public.companies where legal_name = 'RPC Pharma LLC'),
      'Compliance issue resolved'
    )
  $$,
  'admin restores suspended company'
);
select lives_ok(
  $$
    select public.admin_archive_company(
      (select id from public.companies where legal_name = 'RPC Pharma LLC'),
      'Company closed'
    )
  $$,
  'admin archives company'
);
select throws_ok(
  $$
    select public.admin_restore_company(
      (select id from public.companies where legal_name = 'RPC Pharma LLC'),
      'invalid restore'
    )
  $$,
  '23514',
  'Only a suspended company can be restored.',
  'archived company cannot be restored'
);

reset role;
select is(
  (
    select count(*)
    from pg_proc
    where pronamespace = 'public'::regnamespace
      and proname like '%member%'
      and proname not in ('admin_set_profile_status')
  ),
  0::bigint,
  'Phase 3A exposes no membership creation or management RPC'
);

select * from finish();
rollback;
