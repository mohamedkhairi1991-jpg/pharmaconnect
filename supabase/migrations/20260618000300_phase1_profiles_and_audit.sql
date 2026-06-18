create table public.profiles (
  id uuid primary key default gen_random_uuid(),
  auth_user_id uuid not null references auth.users(id) on update restrict on delete restrict,
  full_name text,
  email text not null,
  phone text,
  role public.platform_role,
  country_id uuid references public.countries(id) on update restrict on delete restrict,
  city_id uuid references public.cities(id) on update restrict on delete restrict,
  status public.profile_status not null default 'pending',
  created_at timestamptz not null default timezone('utc', now()),
  updated_at timestamptz not null default timezone('utc', now()),
  constraint profiles_auth_user_unique unique (auth_user_id),
  constraint profiles_email_not_blank check (btrim(email) <> ''),
  constraint profiles_full_name_not_blank check (
    full_name is null or btrim(full_name) <> ''
  ),
  constraint profiles_phone_not_blank check (
    phone is null or btrim(phone) <> ''
  ),
  constraint profiles_city_requires_country check (
    city_id is null or country_id is not null
  )
);

create unique index profiles_email_unique_ci
  on public.profiles (lower(email));

create index profiles_role_status_idx
  on public.profiles (role, status);

create index profiles_country_city_idx
  on public.profiles (country_id, city_id);

create table public.audit_logs (
  id uuid primary key default gen_random_uuid(),
  actor_profile_id uuid references public.profiles(id) on update restrict on delete restrict,
  action text not null,
  target_type text not null,
  target_id uuid not null,
  old_data jsonb,
  new_data jsonb,
  created_at timestamptz not null default timezone('utc', now()),
  constraint audit_logs_action_not_blank check (btrim(action) <> ''),
  constraint audit_logs_target_type_not_blank check (btrim(target_type) <> '')
);

create index audit_logs_actor_created_idx
  on public.audit_logs (actor_profile_id, created_at desc);

create index audit_logs_target_created_idx
  on public.audit_logs (target_type, target_id, created_at desc);
