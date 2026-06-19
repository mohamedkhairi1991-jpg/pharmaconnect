create or replace function private.is_catalog_taxonomy_reader()
returns boolean
language sql
stable
security definer
set search_path = ''
as $$
  select private.is_admin_or_super_admin()
    or (
      private.is_approved_doctor()
      and exists (
        select 1
        from public.products as product
        where private.is_official_catalog_product_visible(product.id)
      )
    )
    or (
      private.current_company_id() is not null
      and private.current_company_role() in (
        'company_admin',
        'product_manager'
      )
    );
$$;

create or replace function private.can_read_product_draft(
  target_product_id uuid
)
returns boolean
language sql
stable
security definer
set search_path = ''
as $$
  select private.can_read_company_product_record(target_product_id);
$$;

create or replace function private.can_manage_product_draft(
  target_product_id uuid
)
returns boolean
language sql
stable
security definer
set search_path = ''
as $$
  select private.can_manage_official_product_content(target_product_id);
$$;

revoke all on function private.is_catalog_taxonomy_reader() from public;
revoke all on function private.can_read_product_draft(uuid) from public;
revoke all on function private.can_manage_product_draft(uuid) from public;
