create table public.products (
  id uuid primary key default gen_random_uuid(),
  company_id uuid not null references public.companies(id)
    on update restrict on delete restrict,
  generic_drug_id uuid references public.generic_drugs(id)
    on update restrict on delete restrict,
  drug_class_id uuid not null references public.drug_classes(id)
    on update restrict on delete restrict,
  category public.product_category not null,
  status public.product_status not null default 'draft',
  presentation_fingerprint text,
  created_by uuid not null references public.profiles(id)
    on update restrict on delete restrict,
  updated_by uuid not null references public.profiles(id)
    on update restrict on delete restrict,
  created_at timestamptz not null default timezone('utc', now()),
  updated_at timestamptz not null default timezone('utc', now()),
  constraint products_generic_requirement check (
    (
      category in ('prescription_drug', 'otc_drug')
      and generic_drug_id is not null
    )
    or category = 'dietary_supplement'
  ),
  constraint products_draft_only check (status = 'draft')
);

create unique index products_company_presentation_unique
  on public.products (company_id, presentation_fingerprint)
  where presentation_fingerprint is not null;

create index products_company_status_idx
  on public.products (company_id, status);

create index products_generic_status_idx
  on public.products (generic_drug_id, status);

create index products_class_category_idx
  on public.products (drug_class_id, category);

create table public.product_translations (
  id uuid primary key default gen_random_uuid(),
  product_id uuid not null references public.products(id)
    on update restrict on delete restrict,
  locale public.content_locale not null,
  brand_name text not null,
  created_at timestamptz not null default timezone('utc', now()),
  updated_at timestamptz not null default timezone('utc', now()),
  constraint product_translations_unique unique (product_id, locale),
  constraint product_translations_brand_not_blank check (
    btrim(brand_name) <> ''
  )
);

create index product_translations_locale_brand_idx
  on public.product_translations (locale, lower(brand_name));
