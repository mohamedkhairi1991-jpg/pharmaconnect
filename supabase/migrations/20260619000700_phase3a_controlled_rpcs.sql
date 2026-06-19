create or replace function public.admin_create_specialty(
  p_code text,
  p_profession_type public.profession_type
)
returns public.specialties
language plpgsql
security definer
set search_path = ''
as $$
declare
  actor_profile_id uuid;
  created_specialty public.specialties;
begin
  if not private.is_admin_or_super_admin() then
    raise exception using
      errcode = '42501',
      message = 'Administrator access is required.';
  end if;

  actor_profile_id := private.current_profile_id();

  insert into public.specialties (
    code,
    profession_type,
    created_by,
    updated_by
  )
  values (
    lower(btrim(p_code)),
    p_profession_type,
    actor_profile_id,
    actor_profile_id
  )
  returning * into created_specialty;

  perform private.write_audit_log(
    actor_profile_id,
    'specialty_created',
    'specialty',
    created_specialty.id,
    null,
    jsonb_build_object(
      'code', created_specialty.code,
      'profession_type', created_specialty.profession_type,
      'is_active', created_specialty.is_active
    )
  );

  return created_specialty;
end;
$$;

create or replace function public.admin_update_specialty(
  p_specialty_id uuid,
  p_code text,
  p_profession_type public.profession_type
)
returns public.specialties
language plpgsql
security definer
set search_path = ''
as $$
declare
  actor_profile_id uuid;
  old_specialty public.specialties;
  updated_specialty public.specialties;
begin
  if not private.is_admin_or_super_admin() then
    raise exception using
      errcode = '42501',
      message = 'Administrator access is required.';
  end if;

  actor_profile_id := private.current_profile_id();

  select *
    into old_specialty
  from public.specialties
  where id = p_specialty_id
  for update;

  if not found then
    raise exception using
      errcode = 'P0002',
      message = 'The specialty does not exist.';
  end if;

  if old_specialty.profession_type is distinct from p_profession_type
    and exists (
      select 1
      from public.healthcare_professionals as professional
      where professional.specialty_id = p_specialty_id
        and p_profession_type is not null
        and professional.profession_type <> p_profession_type
    ) then
    raise exception using
      errcode = '23514',
      message = 'The specialty profession is incompatible with an existing professional.';
  end if;

  update public.specialties
  set
    code = lower(btrim(p_code)),
    profession_type = p_profession_type,
    updated_by = actor_profile_id
  where id = p_specialty_id
  returning * into updated_specialty;

  perform private.write_audit_log(
    actor_profile_id,
    'specialty_updated',
    'specialty',
    p_specialty_id,
    jsonb_build_object(
      'code', old_specialty.code,
      'profession_type', old_specialty.profession_type
    ),
    jsonb_build_object(
      'code', updated_specialty.code,
      'profession_type', updated_specialty.profession_type
    )
  );

  return updated_specialty;
end;
$$;

create or replace function public.admin_set_specialty_active(
  p_specialty_id uuid,
  p_is_active boolean
)
returns public.specialties
language plpgsql
security definer
set search_path = ''
as $$
declare
  actor_profile_id uuid;
  old_specialty public.specialties;
  updated_specialty public.specialties;
begin
  if not private.is_admin_or_super_admin() then
    raise exception using
      errcode = '42501',
      message = 'Administrator access is required.';
  end if;

  actor_profile_id := private.current_profile_id();

  select *
    into old_specialty
  from public.specialties
  where id = p_specialty_id
  for update;

  if not found then
    raise exception using
      errcode = 'P0002',
      message = 'The specialty does not exist.';
  end if;

  update public.specialties
  set
    is_active = p_is_active,
    updated_by = actor_profile_id
  where id = p_specialty_id
  returning * into updated_specialty;

  perform private.write_audit_log(
    actor_profile_id,
    case
      when p_is_active then 'specialty_activated'
      else 'specialty_deactivated'
    end,
    'specialty',
    p_specialty_id,
    jsonb_build_object('is_active', old_specialty.is_active),
    jsonb_build_object('is_active', updated_specialty.is_active)
  );

  return updated_specialty;
end;
$$;

create or replace function public.admin_upsert_specialty_translation(
  p_specialty_id uuid,
  p_locale public.content_locale,
  p_name text,
  p_description text
)
returns public.specialty_translations
language plpgsql
security definer
set search_path = ''
as $$
declare
  actor_profile_id uuid;
  old_translation public.specialty_translations;
  updated_translation public.specialty_translations;
begin
  if not private.is_admin_or_super_admin() then
    raise exception using
      errcode = '42501',
      message = 'Administrator access is required.';
  end if;

  actor_profile_id := private.current_profile_id();

  if not exists (
    select 1 from public.specialties where id = p_specialty_id
  ) then
    raise exception using
      errcode = 'P0002',
      message = 'The specialty does not exist.';
  end if;

  select *
    into old_translation
  from public.specialty_translations
  where specialty_id = p_specialty_id
    and locale = p_locale;

  insert into public.specialty_translations (
    specialty_id,
    locale,
    name,
    description
  )
  values (
    p_specialty_id,
    p_locale,
    btrim(p_name),
    case when p_description is null then null else btrim(p_description) end
  )
  on conflict (specialty_id, locale) do update
  set
    name = excluded.name,
    description = excluded.description
  returning * into updated_translation;

  perform private.write_audit_log(
    actor_profile_id,
    'specialty_translation_changed',
    'specialty',
    p_specialty_id,
    case
      when old_translation.id is null then null
      else jsonb_build_object(
        'locale', old_translation.locale,
        'name', old_translation.name
      )
    end,
    jsonb_build_object(
      'locale', updated_translation.locale,
      'name', updated_translation.name
    )
  );

  return updated_translation;
end;
$$;

create or replace function public.create_my_healthcare_professional_record(
  p_profession_type public.profession_type,
  p_specialty_id uuid,
  p_workplace text,
  p_license_number text
)
returns public.healthcare_professionals
language plpgsql
security definer
set search_path = ''
as $$
declare
  actor_profile_id uuid;
  actor_role public.platform_role;
  created_professional public.healthcare_professionals;
begin
  actor_profile_id := private.current_profile_id();
  actor_role := private.current_platform_role();

  if actor_profile_id is null then
    raise exception using
      errcode = '42501',
      message = 'An authenticated profile is required.';
  end if;

  if private.current_profile_status() in ('suspended', 'archived') then
    raise exception using
      errcode = '42501',
      message = 'This profile cannot create a professional record.';
  end if;

  if actor_role is not null and actor_role <> 'healthcare_professional' then
    raise exception using
      errcode = '23514',
      message = 'The profile role is incompatible with a professional record.';
  end if;

  if exists (
    select 1
    from public.company_users
    where profile_id = actor_profile_id
  ) or exists (
    select 1
    from public.companies
    where applicant_profile_id = actor_profile_id
  ) then
    raise exception using
      errcode = '23514',
      message = 'A company-associated profile cannot create a professional record.';
  end if;

  insert into public.healthcare_professionals (
    profile_id,
    profession_type,
    specialty_id,
    workplace,
    license_number
  )
  values (
    actor_profile_id,
    p_profession_type,
    p_specialty_id,
    case when p_workplace is null then null else btrim(p_workplace) end,
    case
      when p_license_number is null then null
      else btrim(p_license_number)
    end
  )
  returning * into created_professional;

  perform private.write_audit_log(
    actor_profile_id,
    'healthcare_professional_created',
    'healthcare_professional',
    created_professional.id,
    null,
    jsonb_build_object(
      'profession_type', created_professional.profession_type,
      'specialty_id', created_professional.specialty_id,
      'verification_status', created_professional.verification_status,
      'license_present', created_professional.license_number is not null
    )
  );

  return created_professional;
end;
$$;

create or replace function public.update_my_healthcare_professional_record(
  p_profession_type public.profession_type,
  p_specialty_id uuid,
  p_workplace text,
  p_license_number text
)
returns public.healthcare_professionals
language plpgsql
security definer
set search_path = ''
as $$
declare
  actor_profile_id uuid;
  old_professional public.healthcare_professionals;
  updated_professional public.healthcare_professionals;
begin
  actor_profile_id := private.current_profile_id();

  if actor_profile_id is null
    or private.current_profile_status() in ('suspended', 'archived') then
    raise exception using
      errcode = '42501',
      message = 'This professional record cannot be updated.';
  end if;

  select *
    into old_professional
  from public.healthcare_professionals
  where profile_id = actor_profile_id
  for update;

  if not found then
    raise exception using
      errcode = 'P0002',
      message = 'The healthcare professional record does not exist.';
  end if;

  if old_professional.verification_status = 'approved'
    and (
      old_professional.profession_type is distinct from p_profession_type
      or old_professional.specialty_id is distinct from p_specialty_id
      or old_professional.license_number is distinct from
        case
          when p_license_number is null then null
          else btrim(p_license_number)
        end
    ) then
    raise exception using
      errcode = '42501',
      message = 'Approved identity fields require administrator review.';
  end if;

  update public.healthcare_professionals
  set
    profession_type = p_profession_type,
    specialty_id = p_specialty_id,
    workplace = case when p_workplace is null then null else btrim(p_workplace) end,
    license_number = case
      when p_license_number is null then null
      else btrim(p_license_number)
    end
  where id = old_professional.id
  returning * into updated_professional;

  perform private.write_audit_log(
    actor_profile_id,
    'healthcare_professional_updated',
    'healthcare_professional',
    updated_professional.id,
    jsonb_build_object(
      'profession_type', old_professional.profession_type,
      'specialty_id', old_professional.specialty_id,
      'license_present', old_professional.license_number is not null
    ),
    jsonb_build_object(
      'profession_type', updated_professional.profession_type,
      'specialty_id', updated_professional.specialty_id,
      'license_present', updated_professional.license_number is not null
    )
  );

  return updated_professional;
end;
$$;

create or replace function public.admin_review_healthcare_professional(
  p_healthcare_professional_id uuid,
  p_new_status public.healthcare_professional_verification_status,
  p_reason text
)
returns public.healthcare_professionals
language plpgsql
security definer
set search_path = ''
as $$
declare
  actor_profile_id uuid;
  old_professional public.healthcare_professionals;
  target_profile public.profiles;
  updated_professional public.healthcare_professionals;
begin
  if not private.is_admin_or_super_admin() then
    raise exception using
      errcode = '42501',
      message = 'Administrator access is required.';
  end if;

  if p_new_status = 'pending' then
    raise exception using
      errcode = '22023',
      message = 'Pending is not an administrator review decision.';
  end if;

  if p_new_status in ('rejected', 'documents_requested')
    and (p_reason is null or btrim(p_reason) = '') then
    raise exception using
      errcode = '22023',
      message = 'A review reason is required.';
  end if;

  actor_profile_id := private.current_profile_id();

  select *
    into old_professional
  from public.healthcare_professionals
  where id = p_healthcare_professional_id
  for update;

  if not found then
    raise exception using
      errcode = 'P0002',
      message = 'The healthcare professional record does not exist.';
  end if;

  select *
    into target_profile
  from public.profiles
  where id = old_professional.profile_id
  for update;

  if p_new_status = 'approved' then
    if target_profile.role is not null
      and target_profile.role <> 'healthcare_professional' then
      raise exception using
        errcode = '23514',
        message = 'The profile role is incompatible with professional approval.';
    end if;

    if exists (
      select 1 from public.company_users
      where profile_id = target_profile.id
    ) or exists (
      select 1 from public.companies
      where applicant_profile_id = target_profile.id
    ) then
      raise exception using
        errcode = '23514',
        message = 'A company-associated profile cannot be approved as a professional.';
    end if;

    if old_professional.specialty_id is null
      or not private.validate_active_specialty(
        old_professional.specialty_id,
        old_professional.profession_type
      )
      or old_professional.license_number is null
      or btrim(old_professional.license_number) = '' then
      raise exception using
        errcode = '23514',
        message = 'An active compatible specialty and license number are required for approval.';
    end if;
  end if;

  update public.healthcare_professionals
  set
    verification_status = p_new_status,
    reviewed_by = actor_profile_id,
    reviewed_at = now(),
    review_reason = case
      when p_new_status = 'approved' then null
      else btrim(p_reason)
    end
  where id = p_healthcare_professional_id
  returning * into updated_professional;

  if p_new_status = 'approved' then
    if target_profile.role is null then
      perform private.assign_platform_role(
        target_profile.id,
        'healthcare_professional',
        actor_profile_id,
        'Healthcare professional approved'
      );
    end if;

    update public.profiles
    set status = 'active'
    where id = target_profile.id;
  end if;

  perform private.write_audit_log(
    actor_profile_id,
    case p_new_status
      when 'approved' then 'healthcare_professional_approved'
      when 'rejected' then 'healthcare_professional_rejected'
      else 'healthcare_professional_documents_requested'
    end,
    'healthcare_professional',
    p_healthcare_professional_id,
    jsonb_build_object(
      'verification_status', old_professional.verification_status
    ),
    jsonb_build_object(
      'verification_status', updated_professional.verification_status,
      'reason', updated_professional.review_reason
    )
  );

  return updated_professional;
end;
$$;

create or replace function public.create_company_application(
  p_country_id uuid,
  p_city_id uuid,
  p_company_name text,
  p_legal_name text,
  p_description text,
  p_website_url text,
  p_contact_email text,
  p_contact_phone text
)
returns public.companies
language plpgsql
security definer
set search_path = ''
as $$
declare
  actor_profile_id uuid;
  created_company public.companies;
begin
  actor_profile_id := private.current_profile_id();

  if actor_profile_id is null then
    raise exception using
      errcode = '42501',
      message = 'An authenticated profile is required.';
  end if;

  if private.current_profile_status() in ('suspended', 'archived')
    or private.current_platform_role() is not null then
    raise exception using
      errcode = '23514',
      message = 'The profile is not eligible to create a company application.';
  end if;

  if exists (
    select 1 from public.healthcare_professionals
    where profile_id = actor_profile_id
  ) or exists (
    select 1 from public.company_users
    where profile_id = actor_profile_id
  ) then
    raise exception using
      errcode = '23514',
      message = 'The profile already has an incompatible professional or company association.';
  end if;

  insert into public.companies (
    applicant_profile_id,
    country_id,
    city_id,
    company_name,
    legal_name,
    description,
    website_url,
    contact_email,
    contact_phone
  )
  values (
    actor_profile_id,
    p_country_id,
    p_city_id,
    btrim(p_company_name),
    btrim(p_legal_name),
    case when p_description is null then null else btrim(p_description) end,
    case when p_website_url is null then null else btrim(p_website_url) end,
    case
      when p_contact_email is null then null
      else lower(btrim(p_contact_email))
    end,
    case when p_contact_phone is null then null else btrim(p_contact_phone) end
  )
  returning * into created_company;

  perform private.write_audit_log(
    actor_profile_id,
    'company_application_created',
    'company',
    created_company.id,
    null,
    jsonb_build_object(
      'company_name', created_company.company_name,
      'legal_name', created_company.legal_name,
      'status', created_company.status
    )
  );

  return created_company;
end;
$$;

create or replace function public.admin_verify_company(
  p_company_id uuid,
  p_reason text
)
returns public.companies
language plpgsql
security definer
set search_path = ''
as $$
declare
  actor_profile_id uuid;
  old_company public.companies;
  applicant_profile public.profiles;
  updated_company public.companies;
  created_membership public.company_users;
begin
  if not private.is_admin_or_super_admin() then
    raise exception using
      errcode = '42501',
      message = 'Administrator access is required.';
  end if;

  if p_reason is null or btrim(p_reason) = '' then
    raise exception using
      errcode = '22023',
      message = 'A verification reason is required.';
  end if;

  actor_profile_id := private.current_profile_id();

  select *
    into old_company
  from public.companies
  where id = p_company_id
  for update;

  if not found then
    raise exception using
      errcode = 'P0002',
      message = 'The company does not exist.';
  end if;

  if old_company.status <> 'pending' then
    raise exception using
      errcode = '23514',
      message = 'Only a pending company can be verified.';
  end if;

  select *
    into applicant_profile
  from public.profiles
  where id = old_company.applicant_profile_id
  for update;

  if applicant_profile.role is not null
    or applicant_profile.status in ('suspended', 'archived')
    or exists (
      select 1 from public.healthcare_professionals
      where profile_id = applicant_profile.id
    )
    or exists (
      select 1 from public.company_users
      where profile_id = applicant_profile.id
    ) then
    raise exception using
      errcode = '23514',
      message = 'The applicant is not eligible to become the initial company administrator.';
  end if;

  update public.companies
  set
    status = 'verified',
    verified_by = actor_profile_id,
    verified_at = now()
  where id = p_company_id
  returning * into updated_company;

  perform private.assign_platform_role(
    applicant_profile.id,
    'company_user',
    actor_profile_id,
    p_reason
  );

  update public.profiles
  set status = 'active'
  where id = applicant_profile.id;

  insert into public.company_users (
    company_id,
    profile_id,
    company_role,
    created_by
  )
  values (
    p_company_id,
    applicant_profile.id,
    'company_admin',
    actor_profile_id
  )
  returning * into created_membership;

  perform private.write_audit_log(
    actor_profile_id,
    'company_membership_created',
    'company_membership',
    created_membership.id,
    null,
    jsonb_build_object(
      'company_id', created_membership.company_id,
      'profile_id', created_membership.profile_id,
      'company_role', created_membership.company_role,
      'is_active', created_membership.is_active
    )
  );

  perform private.write_audit_log(
    actor_profile_id,
    'company_verified',
    'company',
    p_company_id,
    jsonb_build_object('status', old_company.status),
    jsonb_build_object(
      'status', updated_company.status,
      'reason', btrim(p_reason)
    )
  );

  return updated_company;
end;
$$;

create or replace function public.admin_suspend_company(
  p_company_id uuid,
  p_reason text
)
returns public.companies
language plpgsql
security definer
set search_path = ''
as $$
declare
  actor_profile_id uuid;
  old_company public.companies;
  updated_company public.companies;
begin
  if not private.is_admin_or_super_admin() then
    raise exception using
      errcode = '42501',
      message = 'Administrator access is required.';
  end if;
  if p_reason is null or btrim(p_reason) = '' then
    raise exception using
      errcode = '22023',
      message = 'A suspension reason is required.';
  end if;

  actor_profile_id := private.current_profile_id();
  select * into old_company
  from public.companies
  where id = p_company_id
  for update;

  if not found or old_company.status <> 'verified' then
    raise exception using
      errcode = '23514',
      message = 'Only a verified company can be suspended.';
  end if;

  update public.companies
  set
    status = 'suspended',
    suspended_by = actor_profile_id,
    suspended_at = now(),
    suspension_reason = btrim(p_reason)
  where id = p_company_id
  returning * into updated_company;

  perform private.write_audit_log(
    actor_profile_id,
    'company_suspended',
    'company',
    p_company_id,
    jsonb_build_object('status', old_company.status),
    jsonb_build_object(
      'status', updated_company.status,
      'reason', updated_company.suspension_reason
    )
  );
  return updated_company;
end;
$$;

create or replace function public.admin_restore_company(
  p_company_id uuid,
  p_reason text
)
returns public.companies
language plpgsql
security definer
set search_path = ''
as $$
declare
  actor_profile_id uuid;
  old_company public.companies;
  updated_company public.companies;
begin
  if not private.is_admin_or_super_admin() then
    raise exception using
      errcode = '42501',
      message = 'Administrator access is required.';
  end if;
  if p_reason is null or btrim(p_reason) = '' then
    raise exception using
      errcode = '22023',
      message = 'A restoration reason is required.';
  end if;

  actor_profile_id := private.current_profile_id();
  select * into old_company
  from public.companies
  where id = p_company_id
  for update;

  if not found or old_company.status <> 'suspended' then
    raise exception using
      errcode = '23514',
      message = 'Only a suspended company can be restored.';
  end if;

  update public.companies
  set
    status = 'verified',
    suspended_by = null,
    suspended_at = null,
    suspension_reason = null
  where id = p_company_id
  returning * into updated_company;

  perform private.write_audit_log(
    actor_profile_id,
    'company_restored',
    'company',
    p_company_id,
    jsonb_build_object('status', old_company.status),
    jsonb_build_object(
      'status', updated_company.status,
      'reason', btrim(p_reason)
    )
  );
  return updated_company;
end;
$$;

create or replace function public.admin_archive_company(
  p_company_id uuid,
  p_reason text
)
returns public.companies
language plpgsql
security definer
set search_path = ''
as $$
declare
  actor_profile_id uuid;
  old_company public.companies;
  updated_company public.companies;
begin
  if not private.is_admin_or_super_admin() then
    raise exception using
      errcode = '42501',
      message = 'Administrator access is required.';
  end if;
  if p_reason is null or btrim(p_reason) = '' then
    raise exception using
      errcode = '22023',
      message = 'An archive reason is required.';
  end if;

  actor_profile_id := private.current_profile_id();
  select * into old_company
  from public.companies
  where id = p_company_id
  for update;

  if not found then
    raise exception using
      errcode = 'P0002',
      message = 'The company does not exist.';
  end if;
  if old_company.status = 'archived' then
    raise exception using
      errcode = '23514',
      message = 'The company is already archived.';
  end if;

  update public.companies
  set
    status = 'archived',
    archived_by = actor_profile_id,
    archived_at = now(),
    archive_reason = btrim(p_reason)
  where id = p_company_id
  returning * into updated_company;

  perform private.write_audit_log(
    actor_profile_id,
    'company_archived',
    'company',
    p_company_id,
    jsonb_build_object('status', old_company.status),
    jsonb_build_object(
      'status', updated_company.status,
      'reason', updated_company.archive_reason
    )
  );
  return updated_company;
end;
$$;

revoke all on function public.admin_create_specialty(
  text,
  public.profession_type
) from public;
revoke all on function public.admin_update_specialty(
  uuid,
  text,
  public.profession_type
) from public;
revoke all on function public.admin_set_specialty_active(uuid, boolean)
  from public;
revoke all on function public.admin_upsert_specialty_translation(
  uuid,
  public.content_locale,
  text,
  text
) from public;
revoke all on function public.create_my_healthcare_professional_record(
  public.profession_type,
  uuid,
  text,
  text
) from public;
revoke all on function public.update_my_healthcare_professional_record(
  public.profession_type,
  uuid,
  text,
  text
) from public;
revoke all on function public.admin_review_healthcare_professional(
  uuid,
  public.healthcare_professional_verification_status,
  text
) from public;
revoke all on function public.create_company_application(
  uuid,
  uuid,
  text,
  text,
  text,
  text,
  text,
  text
) from public;
revoke all on function public.admin_verify_company(uuid, text) from public;
revoke all on function public.admin_suspend_company(uuid, text) from public;
revoke all on function public.admin_restore_company(uuid, text) from public;
revoke all on function public.admin_archive_company(uuid, text) from public;
