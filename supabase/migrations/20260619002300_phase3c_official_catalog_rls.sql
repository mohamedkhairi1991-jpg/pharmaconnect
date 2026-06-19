drop policy products_draft_read on public.products;
drop policy product_translations_draft_read on public.product_translations;
drop policy product_markets_draft_read on public.product_markets;
drop policy product_market_translations_draft_read
  on public.product_market_translations;
drop policy product_specialties_draft_read on public.product_specialties;
drop policy product_media_draft_read on public.product_media;
drop policy product_brochures_draft_read on public.product_brochures;
drop policy product_search_keywords_draft_read
  on public.product_search_keywords;

grant execute on function private.product_validation_errors(uuid, text)
  to authenticated;
grant execute on function private.is_product_submission_ready(uuid)
  to authenticated;
grant execute on function private.is_product_publishable(uuid)
  to authenticated;
grant execute on function private.can_manage_official_product_content(uuid)
  to authenticated;
grant execute on function private.can_read_company_product_record(uuid)
  to authenticated;
grant execute on function private.is_official_catalog_product_visible(uuid)
  to authenticated;
grant execute on function private.can_read_official_catalog_product(uuid)
  to authenticated;

grant execute on function public.submit_product_for_review(uuid)
  to authenticated;
grant execute on function public.withdraw_product_submission(uuid)
  to authenticated;
grant execute on function public.archive_own_product(uuid, text)
  to authenticated;
grant execute on function public.admin_request_product_changes(uuid, text)
  to authenticated;
grant execute on function public.admin_publish_product(uuid)
  to authenticated;
grant execute on function public.admin_hide_product(uuid, text)
  to authenticated;
grant execute on function public.admin_restore_product(
  uuid, public.product_status, text
) to authenticated;
grant execute on function public.admin_archive_product(uuid, text)
  to authenticated;

create policy products_official_catalog_read
on public.products
for select
to authenticated
using (
  private.can_read_company_product_record(id)
  or private.can_read_official_catalog_product(id)
);

create policy product_translations_official_catalog_read
on public.product_translations
for select
to authenticated
using (
  private.can_read_company_product_record(product_id)
  or private.can_read_official_catalog_product(product_id)
);

create policy product_markets_official_catalog_read
on public.product_markets
for select
to authenticated
using (
  private.can_read_company_product_record(product_id)
  or private.can_read_official_catalog_product(product_id)
);

create policy product_market_translations_official_catalog_read
on public.product_market_translations
for select
to authenticated
using (
  exists (
    select 1
    from public.product_markets as market
    where market.id = product_market_translations.product_market_id
      and (
        private.can_read_company_product_record(market.product_id)
        or private.can_read_official_catalog_product(market.product_id)
      )
  )
);

create policy product_specialties_official_catalog_read
on public.product_specialties
for select
to authenticated
using (
  private.can_read_company_product_record(product_id)
  or private.can_read_official_catalog_product(product_id)
);

create policy product_media_official_catalog_read
on public.product_media
for select
to authenticated
using (
  private.can_read_company_product_record(product_id)
  or private.can_read_official_catalog_product(product_id)
);

create policy product_brochures_official_catalog_read
on public.product_brochures
for select
to authenticated
using (
  exists (
    select 1
    from public.product_markets as market
    where market.id = product_brochures.product_market_id
      and (
        private.can_read_company_product_record(market.product_id)
        or private.can_read_official_catalog_product(market.product_id)
      )
  )
);

create policy product_search_keywords_official_catalog_read
on public.product_search_keywords
for select
to authenticated
using (
  private.can_read_company_product_record(product_id)
  or private.can_read_official_catalog_product(product_id)
);
