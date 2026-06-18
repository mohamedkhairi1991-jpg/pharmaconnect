begin;

select plan(13);

insert into auth.users (
  id,
  instance_id,
  aud,
  role,
  email,
  encrypted_password,
  email_confirmed_at,
  raw_app_meta_data,
  raw_user_meta_data,
  created_at,
  updated_at
)
values
  (
    '30000000-0000-4000-8000-000000000001',
    '00000000-0000-0000-0000-000000000000',
    'authenticated',
    'authenticated',
    'ordinary@example.com',
    extensions.crypt('phase1-password', extensions.gen_salt('bf')),
    now(),
    '{"provider":"email","providers":["email"]}'::jsonb,
    '{}'::jsonb,
    now(),
    now()
  ),
  (
    '30000000-0000-4000-8000-000000000002',
    '00000000-0000-0000-0000-000000000000',
    'authenticated',
    'authenticated',
    'other@example.com',
    extensions.crypt('phase1-password', extensions.gen_salt('bf')),
    now(),
    '{"provider":"email","providers":["email"]}'::jsonb,
    '{}'::jsonb,
    now(),
    now()
  ),
  (
    '30000000-0000-4000-8000-000000000003',
    '00000000-0000-0000-0000-000000000000',
    'authenticated',
    'authenticated',
    'admin@example.com',
    extensions.crypt('phase1-password', extensions.gen_salt('bf')),
    now(),
    '{"provider":"email","providers":["email"]}'::jsonb,
    '{}'::jsonb,
    now(),
    now()
  ),
  (
    '30000000-0000-4000-8000-000000000004',
    '00000000-0000-0000-0000-000000000000',
    'authenticated',
    'authenticated',
    'super-admin@example.com',
    extensions.crypt('phase1-password', extensions.gen_salt('bf')),
    now(),
    '{"provider":"email","providers":["email"]}'::jsonb,
    '{}'::jsonb,
    now(),
    now()
  );

update public.profiles
set role = 'admin', status = 'active'
where auth_user_id = '30000000-0000-4000-8000-000000000003';

update public.profiles
set role = 'super_admin', status = 'active'
where auth_user_id = '30000000-0000-4000-8000-000000000004';

select set_config(
  'request.jwt.claim.sub',
  '30000000-0000-4000-8000-000000000001',
  true
);
select set_config('request.jwt.claim.role', 'authenticated', true);
set local role authenticated;

select is(
  (select count(*) from public.profiles),
  1::bigint,
  'ordinary users can read only their own profile'
);

select is(
  (select count(*) from public.audit_logs),
  0::bigint,
  'ordinary users cannot read audit logs'
);

select is(
  (select count(*) from public.countries where iso_code = 'IQ'),
  1::bigint,
  'authenticated users can read active Iraq geography'
);

select throws_ok(
  $$
    update public.profiles
    set role = 'super_admin'
    where auth_user_id = '30000000-0000-4000-8000-000000000001'
  $$,
  '42501',
  null,
  'ordinary users cannot directly update protected profile fields'
);

select throws_ok(
  $$
    insert into public.audit_logs (
      action,
      target_type,
      target_id
    )
    values (
      'forged',
      'profile',
      '30000000-0000-4000-8000-000000000001'
    )
  $$,
  '42501',
  null,
  'ordinary users cannot forge audit records'
);

select throws_ok(
  $$
    select public.admin_set_profile_status(
      (
        select id
        from public.profiles
        where auth_user_id = '30000000-0000-4000-8000-000000000002'
      ),
      'suspended',
      'unauthorized attempt'
    )
  $$,
  '42501',
  'Administrator access is required.',
  'ordinary users cannot invoke administrator status changes'
);

reset role;

select set_config(
  'request.jwt.claim.sub',
  '30000000-0000-4000-8000-000000000003',
  true
);
select set_config('request.jwt.claim.role', 'authenticated', true);
set local role authenticated;

select is(
  (select count(*) from public.profiles),
  4::bigint,
  'active administrators can read all profiles'
);

select lives_ok(
  $$
    select public.admin_set_profile_status(
      (
        select id
        from public.profiles
        where auth_user_id = '30000000-0000-4000-8000-000000000002'
      ),
      'suspended',
      'Phase 1 authorization test'
    )
  $$,
  'administrators can suspend ordinary profiles'
);

select throws_ok(
  $$
    select public.admin_set_profile_status(
      (
        select id
        from public.profiles
        where auth_user_id = '30000000-0000-4000-8000-000000000004'
      ),
      'suspended',
      'unauthorized administrator attempt'
    )
  $$,
  '42501',
  'Administrators cannot change another administrator status.',
  'administrators cannot change super administrator status'
);

select is(
  (select count(*) from public.audit_logs),
  1::bigint,
  'administrator status changes create one audit record'
);

reset role;

select is(
  (
    select status::text
    from public.profiles
    where auth_user_id = '30000000-0000-4000-8000-000000000002'
  ),
  'suspended',
  'controlled status change persists'
);

select throws_ok(
  $$
    update public.audit_logs
    set action = 'tampered'
  $$,
  '55000',
  'Audit logs are immutable.',
  'audit records cannot be updated'
);

select throws_ok(
  $$
    delete from public.audit_logs
  $$,
  '55000',
  'Audit logs are immutable.',
  'audit records cannot be deleted'
);

select * from finish();
rollback;
