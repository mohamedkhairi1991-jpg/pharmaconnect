begin;

select plan(13);

select has_schema('private', 'private authorization schema exists');
select has_type('public', 'platform_role', 'platform role enum exists');
select has_type('public', 'profile_status', 'profile status enum exists');
select has_table('public', 'countries', 'countries table exists');
select has_table('public', 'cities', 'cities table exists');
select has_table('public', 'profiles', 'profiles table exists');
select has_table('public', 'audit_logs', 'audit logs table exists');

select col_type_is(
  'public',
  'profiles',
  'auth_user_id',
  'uuid',
  'profile auth user identifier is UUID'
);

select col_type_is(
  'public',
  'profiles',
  'role',
  'platform_role',
  'profile role uses the platform enum'
);

select col_type_is(
  'public',
  'profiles',
  'status',
  'profile_status',
  'profile status uses the status enum'
);

select is(
  (
    select column_default
    from information_schema.columns
    where table_schema = 'public'
      and table_name = 'profiles'
      and column_name = 'status'
  ),
  '''pending''::profile_status',
  'new profiles default to pending'
);

select is(
  (
    select is_nullable
    from information_schema.columns
    where table_schema = 'public'
      and table_name = 'profiles'
      and column_name = 'role'
  ),
  'YES',
  'new profiles may be unclassified'
);

select is(
  (
    select count(*)
    from public.countries
    where id = '00000000-0000-4000-8000-000000000368'
      and name = 'Iraq'
      and iso_code = 'IQ'
      and is_active
  ),
  1::bigint,
  'Iraq is the only required Phase 1 country seed'
);

select * from finish();
rollback;
