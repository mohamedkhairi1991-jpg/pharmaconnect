create extension if not exists pg_trgm with schema extensions;
create extension if not exists unaccent with schema extensions;

create type public.product_category as enum (
  'prescription_drug',
  'otc_drug',
  'dietary_supplement'
);

create type public.product_status as enum (
  'draft'
);

create type public.iraq_market_status as enum (
  'marketed_in_iraq',
  'not_marketed',
  'discontinued'
);

create type public.product_registration_status as enum (
  'not_recorded',
  'registered',
  'expired',
  'withdrawn'
);

create type public.product_media_type as enum (
  'product_image',
  'package_image'
);

create type public.product_keyword_type as enum (
  'brand',
  'generic',
  'company',
  'ingredient',
  'drug_class',
  'alias',
  'transliteration'
);

create type public.keyword_locale as enum (
  'en',
  'ar',
  'und'
);
