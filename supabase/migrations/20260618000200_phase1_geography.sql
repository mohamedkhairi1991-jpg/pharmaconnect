create table public.countries (
  id uuid primary key default gen_random_uuid(),
  name text not null,
  iso_code text not null,
  is_active boolean not null default true,
  created_at timestamptz not null default timezone('utc', now()),
  updated_at timestamptz not null default timezone('utc', now()),
  constraint countries_name_not_blank check (btrim(name) <> ''),
  constraint countries_iso_code_format check (iso_code ~ '^[A-Z]{2}$'),
  constraint countries_iso_code_unique unique (iso_code)
);

create unique index countries_name_unique_ci
  on public.countries (lower(name));

create table public.cities (
  id uuid primary key default gen_random_uuid(),
  country_id uuid not null references public.countries(id) on update restrict on delete restrict,
  name text not null,
  is_active boolean not null default true,
  created_at timestamptz not null default timezone('utc', now()),
  updated_at timestamptz not null default timezone('utc', now()),
  constraint cities_name_not_blank check (btrim(name) <> '')
);

create unique index cities_country_name_unique_ci
  on public.cities (country_id, lower(name));

create index cities_country_active_idx
  on public.cities (country_id, is_active);
