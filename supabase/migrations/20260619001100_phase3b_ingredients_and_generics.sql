create table public.active_ingredients (
  id uuid primary key default gen_random_uuid(),
  code text not null,
  is_active boolean not null default false,
  created_by uuid not null references public.profiles(id)
    on update restrict on delete restrict,
  updated_by uuid not null references public.profiles(id)
    on update restrict on delete restrict,
  created_at timestamptz not null default timezone('utc', now()),
  updated_at timestamptz not null default timezone('utc', now()),
  constraint active_ingredients_code_format check (
    code ~ '^[a-z][a-z0-9_]{1,63}$'
  )
);

create unique index active_ingredients_code_unique_ci
  on public.active_ingredients (lower(code));

create table public.active_ingredient_translations (
  id uuid primary key default gen_random_uuid(),
  active_ingredient_id uuid not null references public.active_ingredients(id)
    on update restrict on delete restrict,
  locale public.content_locale not null,
  name text not null,
  description text,
  created_at timestamptz not null default timezone('utc', now()),
  updated_at timestamptz not null default timezone('utc', now()),
  constraint active_ingredient_translations_unique
    unique (active_ingredient_id, locale),
  constraint active_ingredient_translations_name_not_blank check (
    btrim(name) <> ''
  ),
  constraint active_ingredient_translations_description_not_blank check (
    description is null or btrim(description) <> ''
  )
);

create unique index active_ingredient_translations_name_unique_ci
  on public.active_ingredient_translations (locale, lower(btrim(name)));

create table public.generic_drugs (
  id uuid primary key default gen_random_uuid(),
  code text not null,
  drug_class_id uuid not null references public.drug_classes(id)
    on update restrict on delete restrict,
  is_active boolean not null default false,
  created_by uuid not null references public.profiles(id)
    on update restrict on delete restrict,
  updated_by uuid not null references public.profiles(id)
    on update restrict on delete restrict,
  created_at timestamptz not null default timezone('utc', now()),
  updated_at timestamptz not null default timezone('utc', now()),
  constraint generic_drugs_code_format check (
    code ~ '^[a-z][a-z0-9_]{1,63}$'
  )
);

create unique index generic_drugs_code_unique_ci
  on public.generic_drugs (lower(code));

create index generic_drugs_class_active_idx
  on public.generic_drugs (drug_class_id, is_active);

create table public.generic_drug_translations (
  id uuid primary key default gen_random_uuid(),
  generic_drug_id uuid not null references public.generic_drugs(id)
    on update restrict on delete restrict,
  locale public.content_locale not null,
  name text not null,
  description text,
  created_at timestamptz not null default timezone('utc', now()),
  updated_at timestamptz not null default timezone('utc', now()),
  constraint generic_drug_translations_unique
    unique (generic_drug_id, locale),
  constraint generic_drug_translations_name_not_blank check (btrim(name) <> ''),
  constraint generic_drug_translations_description_not_blank check (
    description is null or btrim(description) <> ''
  )
);

create unique index generic_drug_translations_name_unique_ci
  on public.generic_drug_translations (locale, lower(btrim(name)));

create table public.generic_drug_ingredients (
  id uuid primary key default gen_random_uuid(),
  generic_drug_id uuid not null references public.generic_drugs(id)
    on update restrict on delete restrict,
  active_ingredient_id uuid not null references public.active_ingredients(id)
    on update restrict on delete restrict,
  sort_order integer not null,
  created_by uuid not null references public.profiles(id)
    on update restrict on delete restrict,
  created_at timestamptz not null default timezone('utc', now()),
  constraint generic_drug_ingredients_unique
    unique (generic_drug_id, active_ingredient_id),
  constraint generic_drug_ingredients_order_unique
    unique (generic_drug_id, sort_order),
  constraint generic_drug_ingredients_sort_positive check (sort_order > 0)
);

create index generic_drug_ingredients_ingredient_idx
  on public.generic_drug_ingredients (active_ingredient_id, generic_drug_id);
