create or replace function private.set_updated_at()
returns trigger
language plpgsql
set search_path = ''
as $$
begin
  new.updated_at := now();
  return new;
end;
$$;

create or replace function private.validate_profile_geography()
returns trigger
language plpgsql
set search_path = ''
as $$
declare
  selected_city_country_id uuid;
  selected_city_active boolean;
  selected_country_active boolean;
begin
  if new.city_id is null then
    return new;
  end if;

  if new.country_id is null then
    raise exception using
      errcode = '23514',
      message = 'A country is required when a city is selected.';
  end if;

  select city.country_id, city.is_active
    into selected_city_country_id, selected_city_active
  from public.cities as city
  where city.id = new.city_id;

  if selected_city_country_id is null then
    raise exception using
      errcode = '23503',
      message = 'The selected city does not exist.';
  end if;

  if selected_city_country_id <> new.country_id then
    raise exception using
      errcode = '23514',
      message = 'The selected city does not belong to the selected country.';
  end if;

  select country.is_active
    into selected_country_active
  from public.countries as country
  where country.id = new.country_id;

  if not coalesce(selected_city_active, false)
    or not coalesce(selected_country_active, false) then
    raise exception using
      errcode = '23514',
      message = 'The selected country and city must be active.';
  end if;

  return new;
end;
$$;

create or replace function private.write_audit_log(
  actor_profile_id uuid,
  action text,
  target_type text,
  target_id uuid,
  old_data jsonb default null,
  new_data jsonb default null
)
returns uuid
language plpgsql
security definer
set search_path = ''
as $$
declare
  audit_id uuid;
begin
  insert into public.audit_logs (
    actor_profile_id,
    action,
    target_type,
    target_id,
    old_data,
    new_data
  )
  values (
    actor_profile_id,
    action,
    target_type,
    target_id,
    old_data,
    new_data
  )
  returning id into audit_id;

  return audit_id;
end;
$$;

create or replace function private.prevent_audit_log_mutation()
returns trigger
language plpgsql
set search_path = ''
as $$
begin
  raise exception using
    errcode = '55000',
    message = 'Audit logs are immutable.';
end;
$$;

create or replace function private.handle_auth_user_created()
returns trigger
language plpgsql
security definer
set search_path = ''
as $$
begin
  if new.email is null or btrim(new.email) = '' then
    raise exception using
      errcode = '23502',
      message = 'An email address is required to create a PharmaConnect profile.';
  end if;

  insert into public.profiles (
    auth_user_id,
    email
  )
  values (
    new.id,
    lower(btrim(new.email))
  )
  on conflict (auth_user_id) do nothing;

  return new;
end;
$$;

create or replace function private.handle_auth_user_email_changed()
returns trigger
language plpgsql
security definer
set search_path = ''
as $$
begin
  if new.email is null or btrim(new.email) = '' then
    raise exception using
      errcode = '23502',
      message = 'An email address is required for a PharmaConnect profile.';
  end if;

  update public.profiles
  set email = lower(btrim(new.email))
  where auth_user_id = new.id;

  return new;
end;
$$;

create trigger countries_set_updated_at
before update on public.countries
for each row execute function private.set_updated_at();

create trigger cities_set_updated_at
before update on public.cities
for each row execute function private.set_updated_at();

create trigger profiles_set_updated_at
before update on public.profiles
for each row execute function private.set_updated_at();

create trigger profiles_validate_geography
before insert or update of country_id, city_id on public.profiles
for each row execute function private.validate_profile_geography();

create trigger audit_logs_prevent_update
before update on public.audit_logs
for each row execute function private.prevent_audit_log_mutation();

create trigger audit_logs_prevent_delete
before delete on public.audit_logs
for each row execute function private.prevent_audit_log_mutation();

create trigger auth_users_create_profile
after insert on auth.users
for each row execute function private.handle_auth_user_created();

create trigger auth_users_sync_profile_email
after update of email on auth.users
for each row
when (old.email is distinct from new.email)
execute function private.handle_auth_user_email_changed();

revoke all on function private.set_updated_at() from public;
revoke all on function private.validate_profile_geography() from public;
revoke all on function private.write_audit_log(uuid, text, text, uuid, jsonb, jsonb) from public;
revoke all on function private.prevent_audit_log_mutation() from public;
revoke all on function private.handle_auth_user_created() from public;
revoke all on function private.handle_auth_user_email_changed() from public;
