alter table public.specialties enable row level security;
alter table public.specialty_translations enable row level security;
alter table public.healthcare_professionals enable row level security;
alter table public.companies enable row level security;
alter table public.company_users enable row level security;

revoke all on table public.specialties from anon, authenticated;
revoke all on table public.specialty_translations from anon, authenticated;
revoke all on table public.healthcare_professionals from anon, authenticated;
revoke all on table public.companies from anon, authenticated;
revoke all on table public.company_users from anon, authenticated;

grant select on table public.specialties to anon, authenticated;
grant select on table public.specialty_translations to anon, authenticated;
grant select on table public.healthcare_professionals to authenticated;
grant select on table public.companies to authenticated;
grant select on table public.company_users to authenticated;

grant execute on function private.current_healthcare_professional_id()
  to authenticated;
grant execute on function private.is_healthcare_professional_owner(uuid)
  to authenticated;
grant execute on function private.is_approved_doctor() to authenticated;
grant execute on function private.current_company_id() to authenticated;
grant execute on function private.current_company_role() to authenticated;
grant execute on function private.is_active_company_member(uuid)
  to authenticated;
grant execute on function private.has_company_role(
  uuid,
  public.company_role[]
) to authenticated;
grant execute on function private.is_verified_company(uuid)
  to authenticated;
grant execute on function private.is_company_admin(uuid) to authenticated;
grant execute on function private.can_access_company(uuid) to authenticated;

grant execute on function public.admin_create_specialty(
  text,
  public.profession_type
) to authenticated;
grant execute on function public.admin_update_specialty(
  uuid,
  text,
  public.profession_type
) to authenticated;
grant execute on function public.admin_set_specialty_active(uuid, boolean)
  to authenticated;
grant execute on function public.admin_upsert_specialty_translation(
  uuid,
  public.content_locale,
  text,
  text
) to authenticated;
grant execute on function public.create_my_healthcare_professional_record(
  public.profession_type,
  uuid,
  text,
  text
) to authenticated;
grant execute on function public.update_my_healthcare_professional_record(
  public.profession_type,
  uuid,
  text,
  text
) to authenticated;
grant execute on function public.admin_review_healthcare_professional(
  uuid,
  public.healthcare_professional_verification_status,
  text
) to authenticated;
grant execute on function public.create_company_application(
  uuid,
  uuid,
  text,
  text,
  text,
  text,
  text,
  text
) to authenticated;
grant execute on function public.admin_verify_company(uuid, text)
  to authenticated;
grant execute on function public.admin_suspend_company(uuid, text)
  to authenticated;
grant execute on function public.admin_restore_company(uuid, text)
  to authenticated;
grant execute on function public.admin_archive_company(uuid, text)
  to authenticated;

create policy specialties_active_read
on public.specialties
for select
to anon, authenticated
using (is_active);

create policy specialties_admin_read
on public.specialties
for select
to authenticated
using (private.is_admin_or_super_admin());

create policy specialty_translations_active_read
on public.specialty_translations
for select
to anon, authenticated
using (
  exists (
    select 1
    from public.specialties as specialty
    where specialty.id = specialty_translations.specialty_id
      and specialty.is_active
  )
);

create policy specialty_translations_admin_read
on public.specialty_translations
for select
to authenticated
using (private.is_admin_or_super_admin());

create policy healthcare_professionals_owner_read
on public.healthcare_professionals
for select
to authenticated
using (profile_id = private.current_profile_id());

create policy healthcare_professionals_admin_read
on public.healthcare_professionals
for select
to authenticated
using (private.is_admin_or_super_admin());

create policy companies_applicant_read
on public.companies
for select
to authenticated
using (
  status = 'pending'
  and applicant_profile_id = private.current_profile_id()
);

create policy companies_member_read
on public.companies
for select
to authenticated
using (private.is_active_company_member(id));

create policy companies_approved_doctor_read
on public.companies
for select
to authenticated
using (
  status = 'verified'
  and private.is_approved_doctor()
);

create policy companies_admin_read
on public.companies
for select
to authenticated
using (private.is_admin_or_super_admin());

create policy company_users_owner_read
on public.company_users
for select
to authenticated
using (profile_id = private.current_profile_id());

create policy company_users_company_admin_read
on public.company_users
for select
to authenticated
using (private.is_company_admin(company_id));

create policy company_users_admin_read
on public.company_users
for select
to authenticated
using (private.is_admin_or_super_admin());
