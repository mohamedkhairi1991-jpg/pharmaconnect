create table public.specialties (
  id uuid primary key default gen_random_uuid(),
  code text not null,
  profession_type public.profession_type,
  is_active boolean not null default false,
  created_by uuid not null references public.profiles(id) on update restrict on delete restrict,
  updated_by uuid not null references public.profiles(id) on update restrict on delete restrict,
  created_at timestamptz not null default timezone('utc', now()),
  updated_at timestamptz not null default timezone('utc', now()),
  constraint specialties_code_format check (
    code ~ '^[a-z][a-z0-9_]{1,63}$'
  )
);

create unique index specialties_code_unique_ci
  on public.specialties (lower(code));

create index specialties_profession_active_idx
  on public.specialties (profession_type, is_active);

create table public.specialty_translations (
  id uuid primary key default gen_random_uuid(),
  specialty_id uuid not null references public.specialties(id) on update restrict on delete restrict,
  locale public.content_locale not null,
  name text not null,
  description text,
  created_at timestamptz not null default timezone('utc', now()),
  updated_at timestamptz not null default timezone('utc', now()),
  constraint specialty_translations_unique unique (specialty_id, locale),
  constraint specialty_translations_name_not_blank check (btrim(name) <> ''),
  constraint specialty_translations_description_not_blank check (
    description is null or btrim(description) <> ''
  )
);

create index specialty_translations_locale_name_idx
  on public.specialty_translations (locale, lower(name));
