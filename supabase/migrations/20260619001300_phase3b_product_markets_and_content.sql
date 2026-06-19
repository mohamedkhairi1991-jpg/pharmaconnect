create table public.product_markets (
  id uuid primary key default gen_random_uuid(),
  product_id uuid not null references public.products(id)
    on update restrict on delete restrict,
  country_id uuid not null references public.countries(id)
    on update restrict on delete restrict,
  strength text not null,
  dosage_form text not null,
  route text not null,
  pack_size text not null,
  market_status public.iraq_market_status not null,
  registration_status public.product_registration_status
    not null default 'not_recorded',
  registration_number text,
  registration_authority text,
  registration_expires_on date,
  created_at timestamptz not null default timezone('utc', now()),
  updated_at timestamptz not null default timezone('utc', now()),
  constraint product_markets_unique unique (product_id, country_id),
  constraint product_markets_strength_not_blank check (btrim(strength) <> ''),
  constraint product_markets_form_not_blank check (btrim(dosage_form) <> ''),
  constraint product_markets_route_not_blank check (btrim(route) <> ''),
  constraint product_markets_pack_not_blank check (btrim(pack_size) <> ''),
  constraint product_markets_registration_number_not_blank check (
    registration_number is null or btrim(registration_number) <> ''
  ),
  constraint product_markets_registration_authority_not_blank check (
    registration_authority is null or btrim(registration_authority) <> ''
  ),
  constraint product_markets_registration_metadata check (
    (
      registration_status = 'not_recorded'
      and registration_number is null
      and registration_authority is null
      and registration_expires_on is null
    )
    or (
      registration_status = 'registered'
      and registration_number is not null
      and registration_authority is not null
    )
    or (
      registration_status = 'expired'
      and registration_number is not null
      and registration_authority is not null
      and registration_expires_on is not null
    )
    or (
      registration_status = 'withdrawn'
      and registration_number is not null
      and registration_authority is not null
      and market_status <> 'marketed_in_iraq'
    )
  )
);

create index product_markets_country_status_idx
  on public.product_markets (country_id, market_status);

create index product_markets_product_status_idx
  on public.product_markets (product_id, market_status);

create table public.product_market_translations (
  id uuid primary key default gen_random_uuid(),
  product_market_id uuid not null references public.product_markets(id)
    on update restrict on delete restrict,
  locale public.content_locale not null,
  storage_conditions text not null,
  approved_indications text not null,
  usual_adult_dose text not null,
  contraindications text not null,
  common_adverse_effects text not null,
  created_at timestamptz not null default timezone('utc', now()),
  updated_at timestamptz not null default timezone('utc', now()),
  constraint product_market_translations_unique
    unique (product_market_id, locale),
  constraint product_market_translations_storage_not_blank check (
    btrim(storage_conditions) <> ''
  ),
  constraint product_market_translations_indications_not_blank check (
    btrim(approved_indications) <> ''
  ),
  constraint product_market_translations_dose_not_blank check (
    btrim(usual_adult_dose) <> ''
  ),
  constraint product_market_translations_contraindications_not_blank check (
    btrim(contraindications) <> ''
  ),
  constraint product_market_translations_effects_not_blank check (
    btrim(common_adverse_effects) <> ''
  )
);
