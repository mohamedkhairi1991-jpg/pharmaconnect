create table public.drug_classes (
  id uuid primary key default gen_random_uuid(),
  code text not null,
  parent_drug_class_id uuid references public.drug_classes(id)
    on update restrict on delete restrict,
  is_active boolean not null default false,
  created_by uuid not null references public.profiles(id)
    on update restrict on delete restrict,
  updated_by uuid not null references public.profiles(id)
    on update restrict on delete restrict,
  created_at timestamptz not null default timezone('utc', now()),
  updated_at timestamptz not null default timezone('utc', now()),
  constraint drug_classes_code_format check (
    code ~ '^[a-z][a-z0-9_]{1,63}$'
  ),
  constraint drug_classes_not_self_parent check (
    parent_drug_class_id is null or parent_drug_class_id <> id
  )
);

create unique index drug_classes_code_unique_ci
  on public.drug_classes (lower(code));

create index drug_classes_parent_active_idx
  on public.drug_classes (parent_drug_class_id, is_active);

create table public.drug_class_translations (
  id uuid primary key default gen_random_uuid(),
  drug_class_id uuid not null references public.drug_classes(id)
    on update restrict on delete restrict,
  locale public.content_locale not null,
  name text not null,
  description text,
  created_at timestamptz not null default timezone('utc', now()),
  updated_at timestamptz not null default timezone('utc', now()),
  constraint drug_class_translations_unique unique (drug_class_id, locale),
  constraint drug_class_translations_name_not_blank check (btrim(name) <> ''),
  constraint drug_class_translations_description_not_blank check (
    description is null or btrim(description) <> ''
  )
);

create index drug_class_translations_locale_name_idx
  on public.drug_class_translations (locale, lower(name));
