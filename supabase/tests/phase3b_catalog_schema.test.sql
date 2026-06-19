begin;

select plan(28);

select has_table('public', 'drug_classes', 'drug classes table exists');
select has_table('public', 'drug_class_translations', 'drug class translations exist');
select has_table('public', 'active_ingredients', 'active ingredients table exists');
select has_table('public', 'active_ingredient_translations', 'ingredient translations exist');
select has_table('public', 'generic_drugs', 'generic drugs table exists');
select has_table('public', 'generic_drug_translations', 'generic translations exist');
select has_table('public', 'generic_drug_ingredients', 'generic composition exists');
select has_table('public', 'products', 'products table exists');
select has_table('public', 'product_translations', 'product translations exist');
select has_table('public', 'product_markets', 'product markets exist');
select has_table('public', 'product_market_translations', 'market content exists');
select has_table('public', 'product_specialties', 'product specialties exist');
select has_table('public', 'product_media', 'product media metadata exists');
select has_table('public', 'product_brochures', 'brochure metadata exists');
select has_table('public', 'product_search_keywords', 'search keywords exist');

select has_column('public', 'products', 'company_id', 'product has owner');
select has_column('public', 'products', 'generic_drug_id', 'product has generic');
select has_column('public', 'products', 'drug_class_id', 'product has drug class');
select has_column('public', 'products', 'presentation_fingerprint', 'product has fingerprint');
select has_column('public', 'product_markets', 'market_status', 'market status exists');
select has_column('public', 'product_media', 'storage_path', 'media path is metadata');
select has_column('public', 'product_brochures', 'storage_path', 'brochure path is metadata');

select is(
  (
    select array_agg(enumlabel::text order by enumsortorder)
    from pg_enum
    join pg_type on pg_type.oid = pg_enum.enumtypid
    where pg_type.typname = 'product_category'
  ),
  array[
    'prescription_drug',
    'otc_drug',
    'dietary_supplement'
  ]::text[],
  'product categories are restricted to the approved three values'
);

select is(
  (
    select array_agg(enumlabel::text order by enumsortorder)
    from pg_enum
    join pg_type on pg_type.oid = pg_enum.enumtypid
    where pg_type.typname = 'product_status'
  ),
  array[
    'draft',
    'submitted',
    'changes_requested',
    'published',
    'hidden',
    'archived'
  ]::text[],
  'product status includes the Phase 3B draft and Phase 3C lifecycle states'
);

select is(
  (
    select array_agg(enumlabel::text order by enumsortorder)
    from pg_enum
    join pg_type on pg_type.oid = pg_enum.enumtypid
    where pg_type.typname = 'iraq_market_status'
  ),
  array[
    'marketed_in_iraq',
    'not_marketed',
    'discontinued'
  ]::text[],
  'Iraq market values do not model stock or availability'
);

select ok(
  (select relrowsecurity from pg_class where oid = 'public.products'::regclass),
  'products has RLS enabled'
);
select ok(
  (select relrowsecurity from pg_class where oid = 'public.drug_classes'::regclass),
  'taxonomy has RLS enabled'
);
select has_function(
  'public',
  'create_product_draft',
  array['uuid', 'product_category', 'uuid', 'uuid', 'text'],
  'controlled product draft RPC exists'
);

select * from finish();
rollback;
