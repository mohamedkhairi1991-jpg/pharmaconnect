create table public.healthcare_professionals (
  id uuid primary key default gen_random_uuid(),
  profile_id uuid not null references public.profiles(id) on update restrict on delete restrict,
  profession_type public.profession_type not null,
  specialty_id uuid references public.specialties(id) on update restrict on delete restrict,
  workplace text,
  license_number text,
  verification_status public.healthcare_professional_verification_status
    not null default 'pending',
  reviewed_by uuid references public.profiles(id) on update restrict on delete restrict,
  reviewed_at timestamptz,
  review_reason text,
  created_at timestamptz not null default timezone('utc', now()),
  updated_at timestamptz not null default timezone('utc', now()),
  constraint healthcare_professionals_profile_unique unique (profile_id),
  constraint healthcare_professionals_workplace_not_blank check (
    workplace is null or btrim(workplace) <> ''
  ),
  constraint healthcare_professionals_license_not_blank check (
    license_number is null or btrim(license_number) <> ''
  ),
  constraint healthcare_professionals_review_reason_not_blank check (
    review_reason is null or btrim(review_reason) <> ''
  ),
  constraint healthcare_professionals_review_metadata check (
    (
      verification_status = 'pending'
      and reviewed_by is null
      and reviewed_at is null
      and review_reason is null
    )
    or (
      verification_status = 'approved'
      and reviewed_by is not null
      and reviewed_at is not null
      and license_number is not null
    )
    or (
      verification_status in ('rejected', 'documents_requested')
      and reviewed_by is not null
      and reviewed_at is not null
      and review_reason is not null
    )
  )
);

create unique index healthcare_professionals_license_unique_ci
  on public.healthcare_professionals (
    profession_type,
    lower(btrim(license_number))
  )
  where license_number is not null;

create index healthcare_professionals_status_profession_idx
  on public.healthcare_professionals (verification_status, profession_type);

create index healthcare_professionals_specialty_idx
  on public.healthcare_professionals (specialty_id);
