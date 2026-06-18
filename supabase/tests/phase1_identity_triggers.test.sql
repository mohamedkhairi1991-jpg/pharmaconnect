begin;

select plan(10);

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
values (
  '10000000-0000-4000-8000-000000000001',
  '00000000-0000-0000-0000-000000000000',
  'authenticated',
  'authenticated',
  'phase1-user@example.com',
  extensions.crypt('phase1-password', extensions.gen_salt('bf')),
  now(),
  '{"provider":"email","providers":["email"]}'::jsonb,
  '{"role":"super_admin","status":"active"}'::jsonb,
  now(),
  now()
);

select is(
  (
    select count(*)
    from public.profiles
    where auth_user_id = '10000000-0000-4000-8000-000000000001'
  ),
  1::bigint,
  'Auth insertion creates exactly one profile'
);

select is(
  (
    select role::text
    from public.profiles
    where auth_user_id = '10000000-0000-4000-8000-000000000001'
  ),
  null,
  'Auth metadata cannot assign a platform role'
);

select is(
  (
    select status::text
    from public.profiles
    where auth_user_id = '10000000-0000-4000-8000-000000000001'
  ),
  'pending',
  'Auth metadata cannot assign profile status'
);

update auth.users
set email = 'phase1-updated@example.com'
where id = '10000000-0000-4000-8000-000000000001';

select is(
  (
    select email
    from public.profiles
    where auth_user_id = '10000000-0000-4000-8000-000000000001'
  ),
  'phase1-updated@example.com',
  'verified Auth email changes synchronize to the profile'
);

insert into public.cities (
  id,
  country_id,
  name
)
values (
  '20000000-0000-4000-8000-000000000001',
  '00000000-0000-4000-8000-000000000368',
  'Phase 1 Test City'
);

select set_config(
  'request.jwt.claim.sub',
  '10000000-0000-4000-8000-000000000001',
  true
);
select set_config('request.jwt.claim.role', 'authenticated', true);
set local role authenticated;

select is(
  private.current_profile_id(),
  (
    select id
    from public.profiles
    where auth_user_id = '10000000-0000-4000-8000-000000000001'
  ),
  'current profile helper resolves the JWT user'
);

select is(
  private.current_profile_status()::text,
  'pending',
  'current profile status helper returns pending'
);

select is(
  private.is_active_profile(),
  false,
  'pending profiles are not active'
);

select lives_ok(
  $$
    select public.update_my_profile(
      'Phase One User',
      '+9647000000000',
      '00000000-0000-4000-8000-000000000368',
      '20000000-0000-4000-8000-000000000001'
    )
  $$,
  'a pending user may update safe profile fields'
);

select is(
  (
    select full_name
    from public.profiles
    where auth_user_id = '10000000-0000-4000-8000-000000000001'
  ),
  'Phase One User',
  'safe profile update persists'
);

select throws_ok(
  $$
    select public.update_my_profile(
      'Phase One User',
      '+9647000000000',
      null,
      '20000000-0000-4000-8000-000000000001'
    )
  $$,
  '23514',
  'A country is required when a city is selected.',
  'city selection requires a country'
);

reset role;

select * from finish();
rollback;
