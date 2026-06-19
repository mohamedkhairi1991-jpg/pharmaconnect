create table public.product_specialties (
  id uuid primary key default gen_random_uuid(),
  product_id uuid not null references public.products(id)
    on update restrict on delete restrict,
  specialty_id uuid not null references public.specialties(id)
    on update restrict on delete restrict,
  created_by uuid not null references public.profiles(id)
    on update restrict on delete restrict,
  created_at timestamptz not null default timezone('utc', now()),
  constraint product_specialties_unique unique (product_id, specialty_id)
);

create index product_specialties_specialty_product_idx
  on public.product_specialties (specialty_id, product_id);

create table public.product_media (
  id uuid primary key default gen_random_uuid(),
  product_id uuid not null references public.products(id)
    on update restrict on delete restrict,
  media_type public.product_media_type not null,
  storage_path text not null,
  mime_type text not null,
  file_size_bytes bigint not null,
  sort_order integer not null default 0,
  is_primary boolean not null default false,
  uploaded_by uuid not null references public.profiles(id)
    on update restrict on delete restrict,
  created_at timestamptz not null default timezone('utc', now()),
  updated_at timestamptz not null default timezone('utc', now()),
  constraint product_media_path_not_blank check (btrim(storage_path) <> ''),
  constraint product_media_mime_allowed check (
    lower(mime_type) in ('image/jpeg', 'image/png', 'image/webp')
  ),
  constraint product_media_size_positive check (file_size_bytes > 0),
  constraint product_media_sort_nonnegative check (sort_order >= 0)
);

create unique index product_media_primary_unique
  on public.product_media (product_id, media_type)
  where is_primary;

create index product_media_product_sort_idx
  on public.product_media (product_id, media_type, sort_order);

create table public.product_brochures (
  id uuid primary key default gen_random_uuid(),
  product_market_id uuid not null references public.product_markets(id)
    on update restrict on delete restrict,
  locale public.content_locale not null,
  title text not null,
  storage_path text not null,
  mime_type text not null,
  file_size_bytes bigint not null,
  version integer not null,
  is_current boolean not null default true,
  uploaded_by uuid not null references public.profiles(id)
    on update restrict on delete restrict,
  created_at timestamptz not null default timezone('utc', now()),
  updated_at timestamptz not null default timezone('utc', now()),
  constraint product_brochures_title_not_blank check (btrim(title) <> ''),
  constraint product_brochures_path_not_blank check (
    btrim(storage_path) <> ''
  ),
  constraint product_brochures_pdf_only check (
    lower(mime_type) = 'application/pdf'
  ),
  constraint product_brochures_size_positive check (file_size_bytes > 0),
  constraint product_brochures_version_positive check (version > 0),
  constraint product_brochures_version_unique
    unique (product_market_id, locale, version)
);

create unique index product_brochures_current_unique
  on public.product_brochures (product_market_id, locale)
  where is_current;
