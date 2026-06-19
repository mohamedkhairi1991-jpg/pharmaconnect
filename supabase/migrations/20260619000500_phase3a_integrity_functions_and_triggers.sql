create or replace function private.validate_active_specialty(
  target_specialty_id uuid,
  target_profession_type public.profession_type
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
      from public.specialties as specialty
      where specialty.id = target_specialty_id
        and specialty.is_active
        and (
          specialty.profession_type is null
          or specialty.profession_type = target_profession_type
        )
    ),
    false
  );
$$;

create or replace function private.validate_business_geography(
  target_country_id uuid,
  target_city_id uuid
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
      from public.countries as country
      where country.id = target_country_id
        and country.is_active
        and (
          target_city_id is null
          or exists (
            select 1
            from public.cities as city
            where city.id = target_city_id
              and city.country_id = country.id
              and city.is_active
          )
        )
    ),
    false
  );
$$;

create or replace function private.prevent_immutable_relationship_change()
returns trigger
language plpgsql
set search_path = ''
as $$
begin
  if tg_table_name = 'healthcare_professionals'
    and (to_jsonb(new) ->> 'profile_id')
      is distinct from (to_jsonb(old) ->> 'profile_id') then
    raise exception using
      errcode = '55000',
      message = 'The healthcare professional profile relationship is immutable.';
  elsif tg_table_name = 'companies'
    and (to_jsonb(new) ->> 'applicant_profile_id')
      is distinct from (to_jsonb(old) ->> 'applicant_profile_id') then
    raise exception using
      errcode = '55000',
      message = 'The company applicant relationship is immutable.';
  elsif tg_table_name = 'company_users'
    and (
      (to_jsonb(new) ->> 'company_id')
        is distinct from (to_jsonb(old) ->> 'company_id')
      or (to_jsonb(new) ->> 'profile_id')
        is distinct from (to_jsonb(old) ->> 'profile_id')
    ) then
    raise exception using
      errcode = '55000',
      message = 'Company membership relationships are immutable.';
  end if;

  return new;
end;
$$;

create or replace function private.company_has_active_admin(
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
      from public.company_users as membership
      join public.profiles as profile
        on profile.id = membership.profile_id
      where membership.company_id = target_company_id
        and membership.is_active
        and membership.company_role = 'company_admin'
        and profile.status = 'active'
        and profile.role = 'company_user'
    ),
    false
  );
$$;

create or replace function private.validate_specialty_activation()
returns trigger
language plpgsql
security definer
set search_path = ''
as $$
begin
  if new.is_active
    and not exists (
      select 1
      from public.specialty_translations as translation
      where translation.specialty_id = new.id
        and translation.locale = 'en'
        and btrim(translation.name) <> ''
    ) then
    raise exception using
      errcode = '23514',
      message = 'An English translation is required before activating a specialty.';
  end if;

  return new;
end;
$$;

create or replace function private.validate_healthcare_professional()
returns trigger
language plpgsql
security definer
set search_path = ''
as $$
begin
  if new.specialty_id is not null
    and not private.validate_active_specialty(
      new.specialty_id,
      new.profession_type
    ) then
    raise exception using
      errcode = '23514',
      message = 'The selected specialty must be active and compatible with the profession.';
  end if;

  if new.verification_status = 'approved' then
    if new.specialty_id is null then
      raise exception using
        errcode = '23514',
        message = 'An active specialty is required for approval.';
    end if;

    if new.license_number is null or btrim(new.license_number) = '' then
      raise exception using
        errcode = '23514',
        message = 'A license number is required for approval.';
    end if;
  end if;

  return new;
end;
$$;

create or replace function private.validate_company_geography()
returns trigger
language plpgsql
security definer
set search_path = ''
as $$
begin
  if not private.validate_business_geography(new.country_id, new.city_id) then
    raise exception using
      errcode = '23514',
      message = 'The company country and city must be active and consistent.';
  end if;

  return new;
end;
$$;

create or replace function private.enforce_verified_company_admin()
returns trigger
language plpgsql
security definer
set search_path = ''
as $$
declare
  target_company_id uuid;
  target_status public.company_status;
begin
  if tg_table_name = 'companies' then
    target_company_id := (to_jsonb(new) ->> 'id')::uuid;
  else
    target_company_id := coalesce(
      (to_jsonb(new) ->> 'company_id')::uuid,
      (to_jsonb(old) ->> 'company_id')::uuid
    );
  end if;

  select company.status
    into target_status
  from public.companies as company
  where company.id = target_company_id;

  if target_status = 'verified'
    and not private.company_has_active_admin(target_company_id) then
    raise exception using
      errcode = '23514',
      message = 'A verified company must retain an active company administrator.';
  end if;

  return null;
end;
$$;

create trigger specialties_set_updated_at
before update on public.specialties
for each row execute function private.set_updated_at();

create trigger specialty_translations_set_updated_at
before update on public.specialty_translations
for each row execute function private.set_updated_at();

create trigger healthcare_professionals_set_updated_at
before update on public.healthcare_professionals
for each row execute function private.set_updated_at();

create trigger companies_set_updated_at
before update on public.companies
for each row execute function private.set_updated_at();

create trigger company_users_set_updated_at
before update on public.company_users
for each row execute function private.set_updated_at();

create trigger specialties_validate_activation
before insert or update of is_active on public.specialties
for each row execute function private.validate_specialty_activation();

create trigger healthcare_professionals_validate
before insert or update on public.healthcare_professionals
for each row execute function private.validate_healthcare_professional();

create trigger companies_validate_geography
before insert or update of country_id, city_id on public.companies
for each row execute function private.validate_company_geography();

create trigger healthcare_professionals_immutable_relationship
before update on public.healthcare_professionals
for each row execute function private.prevent_immutable_relationship_change();

create trigger companies_immutable_relationship
before update on public.companies
for each row execute function private.prevent_immutable_relationship_change();

create trigger company_users_immutable_relationship
before update on public.company_users
for each row execute function private.prevent_immutable_relationship_change();

create constraint trigger companies_require_active_admin
after insert or update of status on public.companies
deferrable initially deferred
for each row execute function private.enforce_verified_company_admin();

create constraint trigger company_users_require_active_admin
after insert or update or delete on public.company_users
deferrable initially deferred
for each row execute function private.enforce_verified_company_admin();

revoke all on function private.validate_active_specialty(
  uuid,
  public.profession_type
) from public;
revoke all on function private.validate_business_geography(uuid, uuid)
  from public;
revoke all on function private.prevent_immutable_relationship_change()
  from public;
revoke all on function private.company_has_active_admin(uuid) from public;
revoke all on function private.validate_specialty_activation() from public;
revoke all on function private.validate_healthcare_professional() from public;
revoke all on function private.validate_company_geography() from public;
revoke all on function private.enforce_verified_company_admin() from public;
