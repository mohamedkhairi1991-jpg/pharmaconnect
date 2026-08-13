begin;

select plan(15);

select is(
  (select public from storage.buckets where id = 'catalog-product-media'),
  false,
  'catalog product media bucket is private'
);
select is(
  (select file_size_limit from storage.buckets
   where id = 'catalog-product-media'),
  10485760::bigint,
  'catalog product media bucket limits files to 10 MiB'
);
select is(
  (select allowed_mime_types from storage.buckets
   where id = 'catalog-product-media'),
  array['image/jpeg', 'image/png', 'image/webp']::text[],
  'catalog product media bucket accepts only approved image types'
);

select is(
  (select public from storage.buckets where id = 'catalog-brochures'),
  false,
  'catalog brochure bucket is private'
);
select is(
  (select file_size_limit from storage.buckets
   where id = 'catalog-brochures'),
  26214400::bigint,
  'catalog brochure bucket limits files to 25 MiB'
);
select is(
  (select allowed_mime_types from storage.buckets
   where id = 'catalog-brochures'),
  array['application/pdf']::text[],
  'catalog brochure bucket accepts only PDF files'
);

select is(
  private.catalog_storage_product_id(
    '62000000-0000-4000-8000-000000000040/product.webp'
  ),
  '62000000-0000-4000-8000-000000000040'::uuid,
  'a valid single-folder object path resolves its product id'
);
select is(
  private.catalog_storage_product_id('invalid/product.webp'),
  null::uuid,
  'a non-UUID product folder fails closed'
);
select is(
  private.catalog_storage_product_id(
    '62000000-0000-4000-8000-000000000040/nested/product.webp'
  ),
  null::uuid,
  'nested object paths fail closed'
);

select is(
  (select count(*) from pg_policies
   where schemaname = 'storage' and tablename = 'objects'
     and policyname = 'catalog_storage_read'),
  1::bigint,
  'catalog storage has one read policy'
);
select is(
  (select count(*) from pg_policies
   where schemaname = 'storage' and tablename = 'objects'
     and policyname = 'catalog_storage_insert'),
  1::bigint,
  'catalog storage has one insert policy'
);
select is(
  (select count(*) from pg_policies
   where schemaname = 'storage' and tablename = 'objects'
     and policyname = 'catalog_storage_update'),
  1::bigint,
  'catalog storage has one update policy'
);
select is(
  (select count(*) from pg_policies
   where schemaname = 'storage' and tablename = 'objects'
     and policyname = 'catalog_storage_delete'),
  1::bigint,
  'catalog storage has one delete policy'
);

select is(
  (select count(*) from storage.buckets
   where id in ('catalog-product-media', 'catalog-brochures') and public),
  0::bigint,
  'neither catalog bucket is public'
);
select is(
  (select count(*) from storage.buckets
   where id in ('catalog-product-media', 'catalog-brochures')),
  2::bigint,
  'both catalog storage buckets exist'
);

select * from finish();
rollback;
