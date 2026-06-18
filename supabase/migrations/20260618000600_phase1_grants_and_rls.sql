alter table public.countries enable row level security;
alter table public.cities enable row level security;
alter table public.profiles enable row level security;
alter table public.audit_logs enable row level security;

revoke all on table public.countries from anon, authenticated;
revoke all on table public.cities from anon, authenticated;
revoke all on table public.profiles from anon, authenticated;
revoke all on table public.audit_logs from anon, authenticated;

grant select on table public.countries to anon, authenticated;
grant select on table public.cities to anon, authenticated;
grant select on table public.profiles to authenticated;
grant select on table public.audit_logs to authenticated;

grant usage on schema private to authenticated;

grant execute on function private.current_profile_id() to authenticated;
grant execute on function private.current_platform_role() to authenticated;
grant execute on function private.current_profile_status() to authenticated;
grant execute on function private.is_profile_owner(uuid) to authenticated;
grant execute on function private.is_active_profile() to authenticated;
grant execute on function private.has_platform_role(public.platform_role[]) to authenticated;
grant execute on function private.is_admin() to authenticated;
grant execute on function private.is_super_admin() to authenticated;
grant execute on function private.is_admin_or_super_admin() to authenticated;

grant execute on function public.update_my_profile(text, text, uuid, uuid)
  to authenticated;
grant execute on function public.admin_set_profile_status(
  uuid,
  public.profile_status,
  text
) to authenticated;
grant execute on function public.super_admin_set_admin_role(
  uuid,
  boolean,
  text
) to authenticated;

create policy countries_active_read
on public.countries
for select
to anon, authenticated
using (is_active);

create policy countries_admin_read
on public.countries
for select
to authenticated
using (private.is_admin_or_super_admin());

create policy cities_active_read
on public.cities
for select
to anon, authenticated
using (
  is_active
  and exists (
    select 1
    from public.countries as country
    where country.id = cities.country_id
      and country.is_active
  )
);

create policy cities_admin_read
on public.cities
for select
to authenticated
using (private.is_admin_or_super_admin());

create policy profiles_owner_read
on public.profiles
for select
to authenticated
using (auth_user_id = (select auth.uid()));

create policy profiles_admin_read
on public.profiles
for select
to authenticated
using (private.is_admin_or_super_admin());

create policy audit_logs_admin_read
on public.audit_logs
for select
to authenticated
using (private.is_admin_or_super_admin());
