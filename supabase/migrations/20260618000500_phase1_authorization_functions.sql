create or replace function private.current_profile_id()
returns uuid
language sql
stable
security definer
set search_path = ''
as $$
  select profile.id
  from public.profiles as profile
  where profile.auth_user_id = (select auth.uid())
  limit 1;
$$;

create or replace function private.current_platform_role()
returns public.platform_role
language sql
stable
security definer
set search_path = ''
as $$
  select profile.role
  from public.profiles as profile
  where profile.auth_user_id = (select auth.uid())
  limit 1;
$$;

create or replace function private.current_profile_status()
returns public.profile_status
language sql
stable
security definer
set search_path = ''
as $$
  select profile.status
  from public.profiles as profile
  where profile.auth_user_id = (select auth.uid())
  limit 1;
$$;

create or replace function private.is_profile_owner(target_profile_id uuid)
returns boolean
language sql
stable
security definer
set search_path = ''
as $$
  select coalesce(private.current_profile_id() = target_profile_id, false);
$$;

create or replace function private.is_active_profile()
returns boolean
language sql
stable
security definer
set search_path = ''
as $$
  select coalesce(private.current_profile_status() = 'active', false);
$$;

create or replace function private.has_platform_role(
  allowed_roles public.platform_role[]
)
returns boolean
language sql
stable
security definer
set search_path = ''
as $$
  select coalesce(private.current_platform_role() = any(allowed_roles), false);
$$;

create or replace function private.is_admin()
returns boolean
language sql
stable
security definer
set search_path = ''
as $$
  select private.is_active_profile()
    and private.has_platform_role(array['admin']::public.platform_role[]);
$$;

create or replace function private.is_super_admin()
returns boolean
language sql
stable
security definer
set search_path = ''
as $$
  select private.is_active_profile()
    and private.has_platform_role(array['super_admin']::public.platform_role[]);
$$;

create or replace function private.is_admin_or_super_admin()
returns boolean
language sql
stable
security definer
set search_path = ''
as $$
  select private.is_active_profile()
    and private.has_platform_role(
      array['admin', 'super_admin']::public.platform_role[]
    );
$$;

create or replace function private.assign_platform_role(
  target_profile_id uuid,
  new_role public.platform_role,
  actor_profile_id uuid,
  reason text
)
returns public.profiles
language plpgsql
security definer
set search_path = ''
as $$
declare
  old_profile public.profiles;
  updated_profile public.profiles;
begin
  if reason is null or btrim(reason) = '' then
    raise exception using
      errcode = '22023',
      message = 'A reason is required to assign a platform role.';
  end if;

  select *
    into old_profile
  from public.profiles
  where id = target_profile_id
  for update;

  if not found then
    raise exception using
      errcode = 'P0002',
      message = 'The target profile does not exist.';
  end if;

  update public.profiles
  set role = new_role
  where id = target_profile_id
  returning * into updated_profile;

  perform private.write_audit_log(
    actor_profile_id,
    'profile_role_changed',
    'profile',
    target_profile_id,
    jsonb_build_object('role', old_profile.role),
    jsonb_build_object('role', updated_profile.role, 'reason', reason)
  );

  return updated_profile;
end;
$$;

create or replace function public.update_my_profile(
  full_name text,
  phone text,
  country_id uuid,
  city_id uuid
)
returns public.profiles
language plpgsql
security definer
set search_path = ''
as $$
declare
  profile_id uuid;
  profile_status public.profile_status;
  updated_profile public.profiles;
begin
  profile_id := private.current_profile_id();
  profile_status := private.current_profile_status();

  if profile_id is null then
    raise exception using
      errcode = '42501',
      message = 'An authenticated profile is required.';
  end if;

  if profile_status in ('suspended', 'archived') then
    raise exception using
      errcode = '42501',
      message = 'This profile cannot be updated.';
  end if;

  if full_name is not null and btrim(full_name) = '' then
    raise exception using
      errcode = '22023',
      message = 'Full name cannot be blank.';
  end if;

  if phone is not null and btrim(phone) = '' then
    raise exception using
      errcode = '22023',
      message = 'Phone cannot be blank.';
  end if;

  update public.profiles
  set
    full_name = case
      when update_my_profile.full_name is null then null
      else btrim(update_my_profile.full_name)
    end,
    phone = case
      when update_my_profile.phone is null then null
      else btrim(update_my_profile.phone)
    end,
    country_id = update_my_profile.country_id,
    city_id = update_my_profile.city_id
  where id = profile_id
  returning * into updated_profile;

  return updated_profile;
end;
$$;

create or replace function public.admin_set_profile_status(
  target_profile_id uuid,
  new_status public.profile_status,
  reason text
)
returns public.profiles
language plpgsql
security definer
set search_path = ''
as $$
declare
  actor_profile_id uuid;
  actor_role public.platform_role;
  old_profile public.profiles;
  updated_profile public.profiles;
begin
  actor_profile_id := private.current_profile_id();
  actor_role := private.current_platform_role();

  if not private.is_admin_or_super_admin() then
    raise exception using
      errcode = '42501',
      message = 'Administrator access is required.';
  end if;

  if reason is null or btrim(reason) = '' then
    raise exception using
      errcode = '22023',
      message = 'A reason is required to change profile status.';
  end if;

  if actor_profile_id = target_profile_id then
    raise exception using
      errcode = '42501',
      message = 'Administrators cannot change their own profile status.';
  end if;

  select *
    into old_profile
  from public.profiles
  where id = target_profile_id
  for update;

  if not found then
    raise exception using
      errcode = 'P0002',
      message = 'The target profile does not exist.';
  end if;

  if actor_role = 'admin'
    and old_profile.role in ('admin', 'super_admin') then
    raise exception using
      errcode = '42501',
      message = 'Administrators cannot change another administrator status.';
  end if;

  update public.profiles
  set status = new_status
  where id = target_profile_id
  returning * into updated_profile;

  perform private.write_audit_log(
    actor_profile_id,
    'profile_status_changed',
    'profile',
    target_profile_id,
    jsonb_build_object('status', old_profile.status),
    jsonb_build_object('status', updated_profile.status, 'reason', reason)
  );

  return updated_profile;
end;
$$;

create or replace function public.super_admin_set_admin_role(
  target_profile_id uuid,
  make_admin boolean,
  reason text
)
returns public.profiles
language plpgsql
security definer
set search_path = ''
as $$
declare
  actor_profile_id uuid;
  target_profile public.profiles;
begin
  if not private.is_super_admin() then
    raise exception using
      errcode = '42501',
      message = 'Super administrator access is required.';
  end if;

  actor_profile_id := private.current_profile_id();

  if actor_profile_id = target_profile_id then
    raise exception using
      errcode = '42501',
      message = 'Super administrators cannot change their own role.';
  end if;

  select *
    into target_profile
  from public.profiles
  where id = target_profile_id;

  if not found then
    raise exception using
      errcode = 'P0002',
      message = 'The target profile does not exist.';
  end if;

  if target_profile.role = 'super_admin' then
    raise exception using
      errcode = '42501',
      message = 'This operation cannot modify another super administrator.';
  end if;

  if make_admin and target_profile.role is not null then
    raise exception using
      errcode = '23514',
      message = 'Only an unclassified profile can be promoted to administrator.';
  end if;

  if not make_admin and target_profile.role <> 'admin' then
    raise exception using
      errcode = '23514',
      message = 'Only an administrator can be demoted by this operation.';
  end if;

  return private.assign_platform_role(
    target_profile_id,
    case when make_admin then 'admin'::public.platform_role else null end,
    actor_profile_id,
    reason
  );
end;
$$;

revoke all on function private.current_profile_id() from public;
revoke all on function private.current_platform_role() from public;
revoke all on function private.current_profile_status() from public;
revoke all on function private.is_profile_owner(uuid) from public;
revoke all on function private.is_active_profile() from public;
revoke all on function private.has_platform_role(public.platform_role[]) from public;
revoke all on function private.is_admin() from public;
revoke all on function private.is_super_admin() from public;
revoke all on function private.is_admin_or_super_admin() from public;
revoke all on function private.assign_platform_role(uuid, public.platform_role, uuid, text) from public;

revoke all on function public.update_my_profile(text, text, uuid, uuid) from public;
revoke all on function public.admin_set_profile_status(uuid, public.profile_status, text) from public;
revoke all on function public.super_admin_set_admin_role(uuid, boolean, text) from public;
