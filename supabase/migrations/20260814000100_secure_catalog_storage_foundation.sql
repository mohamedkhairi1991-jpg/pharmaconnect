insert into storage.buckets (
  id,
  name,
  public,
  file_size_limit,
  allowed_mime_types
)
values
  (
    'catalog-product-media',
    'catalog-product-media',
    false,
    10485760,
    array['image/jpeg', 'image/png', 'image/webp']::text[]
  ),
  (
    'catalog-brochures',
    'catalog-brochures',
    false,
    26214400,
    array['application/pdf']::text[]
  )
on conflict (id) do update
set
  public = excluded.public,
  file_size_limit = excluded.file_size_limit,
  allowed_mime_types = excluded.allowed_mime_types;

create or replace function private.catalog_storage_product_id(
  object_name text
)
returns uuid
language plpgsql
stable
security definer
set search_path = ''
as $$
declare
  folders text[];
begin
  folders := storage.foldername(object_name);

  if cardinality(folders) <> 1
    or folders[1] !~* '^[0-9a-f]{8}-[0-9a-f]{4}-[1-5][0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$' then
    return null;
  end if;

  return folders[1]::uuid;
exception
  when invalid_text_representation then
    return null;
end;
$$;

revoke all on function private.catalog_storage_product_id(text) from public;
grant execute on function private.catalog_storage_product_id(text)
  to authenticated;

create policy catalog_storage_read
on storage.objects
for select
to authenticated
using (
  bucket_id in ('catalog-product-media', 'catalog-brochures')
  and (
    private.can_read_company_product_record(
      private.catalog_storage_product_id(name)
    )
    or private.can_read_official_catalog_product(
      private.catalog_storage_product_id(name)
    )
  )
);

create policy catalog_storage_insert
on storage.objects
for insert
to authenticated
with check (
  (
    (
      bucket_id = 'catalog-product-media'
      and lower(storage.extension(name)) in ('jpg', 'jpeg', 'png', 'webp')
    )
    or (
      bucket_id = 'catalog-brochures'
      and lower(storage.extension(name)) = 'pdf'
    )
  )
  and private.can_manage_official_product_content(
    private.catalog_storage_product_id(name)
  )
);

create policy catalog_storage_update
on storage.objects
for update
to authenticated
using (
  bucket_id in ('catalog-product-media', 'catalog-brochures')
  and private.can_manage_official_product_content(
    private.catalog_storage_product_id(name)
  )
)
with check (
  (
    (
      bucket_id = 'catalog-product-media'
      and lower(storage.extension(name)) in ('jpg', 'jpeg', 'png', 'webp')
    )
    or (
      bucket_id = 'catalog-brochures'
      and lower(storage.extension(name)) = 'pdf'
    )
  )
  and private.can_manage_official_product_content(
    private.catalog_storage_product_id(name)
  )
);

create policy catalog_storage_delete
on storage.objects
for delete
to authenticated
using (
  bucket_id in ('catalog-product-media', 'catalog-brochures')
  and private.can_manage_official_product_content(
    private.catalog_storage_product_id(name)
  )
);
