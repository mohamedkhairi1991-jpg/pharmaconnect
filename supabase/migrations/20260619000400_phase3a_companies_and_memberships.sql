create table public.companies (
  id uuid primary key default gen_random_uuid(),
  applicant_profile_id uuid not null references public.profiles(id) on update restrict on delete restrict,
  country_id uuid not null references public.countries(id) on update restrict on delete restrict,
  city_id uuid references public.cities(id) on update restrict on delete restrict,
  company_name text not null,
  legal_name text not null,
  description text,
  website_url text,
  contact_email text,
  contact_phone text,
  status public.company_status not null default 'pending',
  verified_by uuid references public.profiles(id) on update restrict on delete restrict,
  verified_at timestamptz,
  suspended_by uuid references public.profiles(id) on update restrict on delete restrict,
  suspended_at timestamptz,
  suspension_reason text,
  archived_by uuid references public.profiles(id) on update restrict on delete restrict,
  archived_at timestamptz,
  archive_reason text,
  created_at timestamptz not null default timezone('utc', now()),
  updated_at timestamptz not null default timezone('utc', now()),
  constraint companies_applicant_unique unique (applicant_profile_id),
  constraint companies_company_name_not_blank check (btrim(company_name) <> ''),
  constraint companies_legal_name_not_blank check (btrim(legal_name) <> ''),
  constraint companies_description_not_blank check (
    description is null or btrim(description) <> ''
  ),
  constraint companies_website_url_format check (
    website_url is null or website_url ~* '^https?://'
  ),
  constraint companies_contact_email_not_blank check (
    contact_email is null or btrim(contact_email) <> ''
  ),
  constraint companies_contact_phone_not_blank check (
    contact_phone is null or btrim(contact_phone) <> ''
  ),
  constraint companies_city_requires_country check (
    city_id is null or country_id is not null
  ),
  constraint companies_status_metadata check (
    (
      status = 'pending'
      and verified_by is null
      and verified_at is null
      and suspended_by is null
      and suspended_at is null
      and suspension_reason is null
      and archived_by is null
      and archived_at is null
      and archive_reason is null
    )
    or (
      status = 'verified'
      and verified_by is not null
      and verified_at is not null
      and suspended_by is null
      and suspended_at is null
      and suspension_reason is null
      and archived_by is null
      and archived_at is null
      and archive_reason is null
    )
    or (
      status = 'suspended'
      and verified_by is not null
      and verified_at is not null
      and suspended_by is not null
      and suspended_at is not null
      and suspension_reason is not null
      and archived_by is null
      and archived_at is null
      and archive_reason is null
    )
    or (
      status = 'archived'
      and archived_by is not null
      and archived_at is not null
      and archive_reason is not null
    )
  )
);

create unique index companies_legal_name_unique_ci
  on public.companies (lower(btrim(legal_name)));

create index companies_status_name_idx
  on public.companies (status, lower(company_name));

create index companies_country_city_idx
  on public.companies (country_id, city_id);

create table public.company_users (
  id uuid primary key default gen_random_uuid(),
  company_id uuid not null references public.companies(id) on update restrict on delete restrict,
  profile_id uuid not null references public.profiles(id) on update restrict on delete restrict,
  company_role public.company_role not null,
  is_active boolean not null default true,
  created_by uuid not null references public.profiles(id) on update restrict on delete restrict,
  deactivated_by uuid references public.profiles(id) on update restrict on delete restrict,
  deactivated_at timestamptz,
  deactivation_reason text,
  created_at timestamptz not null default timezone('utc', now()),
  updated_at timestamptz not null default timezone('utc', now()),
  constraint company_users_profile_unique unique (profile_id),
  constraint company_users_deactivation_reason_not_blank check (
    deactivation_reason is null or btrim(deactivation_reason) <> ''
  ),
  constraint company_users_activation_metadata check (
    (
      is_active
      and deactivated_by is null
      and deactivated_at is null
      and deactivation_reason is null
    )
    or (
      not is_active
      and deactivated_by is not null
      and deactivated_at is not null
      and deactivation_reason is not null
    )
  )
);

create index company_users_company_active_role_idx
  on public.company_users (company_id, is_active, company_role);
