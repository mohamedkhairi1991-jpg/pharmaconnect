create or replace function private.current_healthcare_professional_id()
returns uuid
language sql
stable
security definer
set search_path = ''
as $$
  select professional.id
  from public.healthcare_professionals as professional
  join public.profiles as profile
    on profile.id = professional.profile_id
  where profile.auth_user_id = (select auth.uid())
    and profile.status = 'active'
    and profile.role = 'healthcare_professional'
  limit 1;
$$;

create or replace function private.is_healthcare_professional_owner(
  target_healthcare_professional_id uuid
)
returns boolean
language sql
stable
security definer
set search_path = ''
as $$
  select coalesce(
    private.current_healthcare_professional_id()
      = target_healthcare_professional_id,
    false
  );
$$;

create or replace function private.is_approved_doctor()
returns boolean
language sql
stable
security definer
set search_path = ''
as $$
  select coalesce(
    exists (
      select 1
      from public.profiles as profile
      join public.healthcare_professionals as professional
        on professional.profile_id = profile.id
      where profile.auth_user_id = (select auth.uid())
        and profile.status = 'active'
        and profile.role = 'healthcare_professional'
        and professional.profession_type = 'physician'
        and professional.verification_status = 'approved'
    ),
    false
  );
$$;

create or replace function private.current_company_id()
returns uuid
language sql
stable
security definer
set search_path = ''
as $$
  select membership.company_id
  from public.profiles as profile
  join public.company_users as membership
    on membership.profile_id = profile.id
  join public.companies as company
    on company.id = membership.company_id
  where profile.auth_user_id = (select auth.uid())
    and profile.status = 'active'
    and profile.role = 'company_user'
    and membership.is_active
    and company.status = 'verified'
  limit 1;
$$;

create or replace function private.current_company_role()
returns public.company_role
language sql
stable
security definer
set search_path = ''
as $$
  select membership.company_role
  from public.profiles as profile
  join public.company_users as membership
    on membership.profile_id = profile.id
  join public.companies as company
    on company.id = membership.company_id
  where profile.auth_user_id = (select auth.uid())
    and profile.status = 'active'
    and profile.role = 'company_user'
    and membership.is_active
    and company.status = 'verified'
  limit 1;
$$;

create or replace function private.is_active_company_member(
  target_company_id uuid
)
returns boolean
language sql
stable
security definer
set search_path = ''
as $$
  select coalesce(private.current_company_id() = target_company_id, false);
$$;

create or replace function private.has_company_role(
  target_company_id uuid,
  allowed_roles public.company_role[]
)
returns boolean
language sql
stable
security definer
set search_path = ''
as $$
  select private.is_active_company_member(target_company_id)
    and coalesce(private.current_company_role() = any(allowed_roles), false);
$$;

create or replace function private.is_verified_company(
  target_company_id uuid
)
returns boolean
language sql
stable
security definer
set search_path = ''
as $$
  select coalesce(
    exists (
      select 1
      from public.companies as company
      where company.id = target_company_id
        and company.status = 'verified'
    ),
    false
  );
$$;

create or replace function private.is_company_admin(
  target_company_id uuid
)
returns boolean
language sql
stable
security definer
set search_path = ''
as $$
  select private.has_company_role(
    target_company_id,
    array['company_admin']::public.company_role[]
  );
$$;

create or replace function private.can_access_company(
  target_company_id uuid
)
returns boolean
language sql
stable
security definer
set search_path = ''
as $$
  select private.is_admin_or_super_admin()
    or private.is_active_company_member(target_company_id)
    or coalesce(
      exists (
        select 1
        from public.companies as company
        where company.id = target_company_id
          and company.status = 'pending'
          and company.applicant_profile_id = private.current_profile_id()
      ),
      false
    );
$$;

revoke all on function private.current_healthcare_professional_id()
  from public;
revoke all on function private.is_healthcare_professional_owner(uuid)
  from public;
revoke all on function private.is_approved_doctor() from public;
revoke all on function private.current_company_id() from public;
revoke all on function private.current_company_role() from public;
revoke all on function private.is_active_company_member(uuid) from public;
revoke all on function private.has_company_role(
  uuid,
  public.company_role[]
) from public;
revoke all on function private.is_verified_company(uuid) from public;
revoke all on function private.is_company_admin(uuid) from public;
revoke all on function private.can_access_company(uuid) from public;
