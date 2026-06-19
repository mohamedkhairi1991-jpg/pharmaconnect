create table public.product_search_keywords (
  id uuid primary key default gen_random_uuid(),
  product_id uuid not null references public.products(id)
    on update restrict on delete restrict,
  locale public.keyword_locale not null,
  keyword text not null,
  normalized_keyword text not null,
  keyword_type public.product_keyword_type not null,
  source_reference text,
  created_at timestamptz not null default timezone('utc', now()),
  constraint product_search_keywords_keyword_not_blank check (
    btrim(keyword) <> ''
  ),
  constraint product_search_keywords_normalized_not_blank check (
    btrim(normalized_keyword) <> ''
  ),
  constraint product_search_keywords_source_not_blank check (
    source_reference is null or btrim(source_reference) <> ''
  ),
  constraint product_search_keywords_unique unique (
    product_id,
    locale,
    normalized_keyword,
    keyword_type
  )
);

create index product_search_keywords_product_type_locale_idx
  on public.product_search_keywords (product_id, keyword_type, locale);

create index product_search_keywords_normalized_locale_idx
  on public.product_search_keywords (normalized_keyword, locale);

create index product_search_keywords_trgm_idx
  on public.product_search_keywords
  using gin (normalized_keyword extensions.gin_trgm_ops);

create or replace function private.normalize_english_text(value text)
returns text
language sql
immutable
set search_path = ''
as $$
  select nullif(
    btrim(
      regexp_replace(
        regexp_replace(
          lower(extensions.unaccent(coalesce(value, ''))),
          '[^a-z0-9]+',
          ' ',
          'g'
        ),
        '\s+',
        ' ',
        'g'
      )
    ),
    ''
  );
$$;

create or replace function private.normalize_arabic_text(value text)
returns text
language sql
immutable
set search_path = ''
as $$
  select nullif(
    btrim(
      regexp_replace(
        regexp_replace(
          translate(
            regexp_replace(
              coalesce(value, ''),
              U&'[\0640\064B-\065F\0670\06D6-\06ED]',
              '',
              'g'
            ),
            U&'\0623\0625\0622\0671\0649\0624\0626',
            U&'\0627\0627\0627\0627\064A\0648\064A'
          ),
          U&'[^\0621-\064A0-9]+',
          ' ',
          'g'
        ),
        '\s+',
        ' ',
        'g'
      )
    ),
    ''
  );
$$;

create or replace function private.normalize_search_text(
  value text,
  locale public.keyword_locale
)
returns text
language sql
immutable
set search_path = ''
as $$
  select case
    when locale = 'ar' then private.normalize_arabic_text(value)
    else private.normalize_english_text(value)
  end;
$$;

create or replace function private.refresh_product_search_keywords(
  target_product_id uuid
)
returns void
language plpgsql
security definer
set search_path = ''
as $$
begin
  if not exists (
    select 1 from public.products where id = target_product_id
  ) then
    raise exception using
      errcode = 'P0002',
      message = 'The product does not exist.';
  end if;

  delete from public.product_search_keywords
  where product_id = target_product_id
    and keyword_type in (
      'brand',
      'generic',
      'company',
      'ingredient',
      'drug_class'
    );

  insert into public.product_search_keywords (
    product_id,
    locale,
    keyword,
    normalized_keyword,
    keyword_type,
    source_reference
  )
  select
    translation.product_id,
    translation.locale::text::public.keyword_locale,
    translation.brand_name,
    private.normalize_search_text(
      translation.brand_name,
      translation.locale::text::public.keyword_locale
    ),
    'brand',
    'product_translation:' || translation.id::text
  from public.product_translations as translation
  where translation.product_id = target_product_id
  on conflict do nothing;

  insert into public.product_search_keywords (
    product_id,
    locale,
    keyword,
    normalized_keyword,
    keyword_type,
    source_reference
  )
  select
    product.id,
    translation.locale::text::public.keyword_locale,
    translation.name,
    private.normalize_search_text(
      translation.name,
      translation.locale::text::public.keyword_locale
    ),
    'generic',
    'generic_translation:' || translation.id::text
  from public.products as product
  join public.generic_drug_translations as translation
    on translation.generic_drug_id = product.generic_drug_id
  where product.id = target_product_id
  on conflict do nothing;

  insert into public.product_search_keywords (
    product_id,
    locale,
    keyword,
    normalized_keyword,
    keyword_type,
    source_reference
  )
  select
    product.id,
    'und',
    company.company_name,
    private.normalize_search_text(company.company_name, 'und'),
    'company',
    'company:' || company.id::text
  from public.products as product
  join public.companies as company on company.id = product.company_id
  where product.id = target_product_id
  on conflict do nothing;

  insert into public.product_search_keywords (
    product_id,
    locale,
    keyword,
    normalized_keyword,
    keyword_type,
    source_reference
  )
  select
    product.id,
    translation.locale::text::public.keyword_locale,
    translation.name,
    private.normalize_search_text(
      translation.name,
      translation.locale::text::public.keyword_locale
    ),
    'ingredient',
    'ingredient_translation:' || translation.id::text
  from public.products as product
  join public.generic_drug_ingredients as composition
    on composition.generic_drug_id = product.generic_drug_id
  join public.active_ingredient_translations as translation
    on translation.active_ingredient_id = composition.active_ingredient_id
  where product.id = target_product_id
  on conflict do nothing;

  insert into public.product_search_keywords (
    product_id,
    locale,
    keyword,
    normalized_keyword,
    keyword_type,
    source_reference
  )
  select
    product.id,
    translation.locale::text::public.keyword_locale,
    translation.name,
    private.normalize_search_text(
      translation.name,
      translation.locale::text::public.keyword_locale
    ),
    'drug_class',
    'drug_class_translation:' || translation.id::text
  from public.products as product
  join public.drug_class_translations as translation
    on translation.drug_class_id = product.drug_class_id
  where product.id = target_product_id
  on conflict do nothing;
end;
$$;

revoke all on function private.normalize_english_text(text) from public;
revoke all on function private.normalize_arabic_text(text) from public;
revoke all on function private.normalize_search_text(
  text,
  public.keyword_locale
) from public;
revoke all on function private.refresh_product_search_keywords(uuid)
  from public;
