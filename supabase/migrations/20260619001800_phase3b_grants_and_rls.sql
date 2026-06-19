alter table public.drug_classes enable row level security;
alter table public.drug_class_translations enable row level security;
alter table public.active_ingredients enable row level security;
alter table public.active_ingredient_translations enable row level security;
alter table public.generic_drugs enable row level security;
alter table public.generic_drug_translations enable row level security;
alter table public.generic_drug_ingredients enable row level security;
alter table public.products enable row level security;
alter table public.product_translations enable row level security;
alter table public.product_markets enable row level security;
alter table public.product_market_translations enable row level security;
alter table public.product_specialties enable row level security;
alter table public.product_media enable row level security;
alter table public.product_brochures enable row level security;
alter table public.product_search_keywords enable row level security;

revoke all on table public.drug_classes from anon, authenticated;
revoke all on table public.drug_class_translations from anon, authenticated;
revoke all on table public.active_ingredients from anon, authenticated;
revoke all on table public.active_ingredient_translations from anon, authenticated;
revoke all on table public.generic_drugs from anon, authenticated;
revoke all on table public.generic_drug_translations from anon, authenticated;
revoke all on table public.generic_drug_ingredients from anon, authenticated;
revoke all on table public.products from anon, authenticated;
revoke all on table public.product_translations from anon, authenticated;
revoke all on table public.product_markets from anon, authenticated;
revoke all on table public.product_market_translations from anon, authenticated;
revoke all on table public.product_specialties from anon, authenticated;
revoke all on table public.product_media from anon, authenticated;
revoke all on table public.product_brochures from anon, authenticated;
revoke all on table public.product_search_keywords from anon, authenticated;

grant select on table public.drug_classes to authenticated;
grant select on table public.drug_class_translations to authenticated;
grant select on table public.active_ingredients to authenticated;
grant select on table public.active_ingredient_translations to authenticated;
grant select on table public.generic_drugs to authenticated;
grant select on table public.generic_drug_translations to authenticated;
grant select on table public.generic_drug_ingredients to authenticated;
grant select on table public.products to authenticated;
grant select on table public.product_translations to authenticated;
grant select on table public.product_markets to authenticated;
grant select on table public.product_market_translations to authenticated;
grant select on table public.product_specialties to authenticated;
grant select on table public.product_media to authenticated;
grant select on table public.product_brochures to authenticated;
grant select on table public.product_search_keywords to authenticated;

grant execute on function private.is_catalog_taxonomy_reader()
  to authenticated;
grant execute on function private.can_read_product_draft(uuid)
  to authenticated;
grant execute on function private.can_manage_product_draft(uuid)
  to authenticated;

grant execute on function public.admin_create_drug_class(text, uuid)
  to authenticated;
grant execute on function public.admin_update_drug_class(uuid, text, uuid)
  to authenticated;
grant execute on function public.admin_set_drug_class_active(uuid, boolean)
  to authenticated;
grant execute on function public.admin_upsert_drug_class_translation(
  uuid, public.content_locale, text, text
) to authenticated;
grant execute on function public.admin_create_active_ingredient(text)
  to authenticated;
grant execute on function public.admin_update_active_ingredient(uuid, text)
  to authenticated;
grant execute on function public.admin_set_active_ingredient_active(
  uuid, boolean
) to authenticated;
grant execute on function public.admin_upsert_active_ingredient_translation(
  uuid, public.content_locale, text, text
) to authenticated;
grant execute on function public.admin_create_generic_drug(text, uuid)
  to authenticated;
grant execute on function public.admin_update_generic_drug(uuid, text, uuid)
  to authenticated;
grant execute on function public.admin_upsert_generic_drug_translation(
  uuid, public.content_locale, text, text
) to authenticated;
grant execute on function public.admin_set_generic_drug_ingredients(
  uuid, uuid[]
) to authenticated;
grant execute on function public.admin_set_generic_drug_active(uuid, boolean)
  to authenticated;
grant execute on function public.create_product_draft(
  uuid, public.product_category, uuid, uuid, text
) to authenticated;
grant execute on function public.update_product_draft(
  uuid, public.product_category, uuid, uuid
) to authenticated;
grant execute on function public.upsert_product_translation(
  uuid, public.content_locale, text
) to authenticated;
grant execute on function public.upsert_product_market(
  uuid, text, text, text, text, public.iraq_market_status,
  public.product_registration_status, text, text, date
) to authenticated;
grant execute on function public.upsert_product_market_translation(
  uuid, public.content_locale, text, text, text, text, text
) to authenticated;
grant execute on function public.set_product_specialties(uuid, uuid[])
  to authenticated;
grant execute on function public.upsert_product_media_metadata(
  uuid, uuid, public.product_media_type, text, text, bigint,
  integer, boolean
) to authenticated;
grant execute on function public.upsert_product_brochure_metadata(
  uuid, uuid, public.content_locale, text, text, bigint, integer, boolean
) to authenticated;
grant execute on function public.upsert_product_keyword_alias(
  uuid, public.keyword_locale, text, public.product_keyword_type
) to authenticated;

create policy drug_classes_active_taxonomy_read
on public.drug_classes
for select
to authenticated
using (
  is_active
  and private.is_catalog_taxonomy_reader()
);

create policy drug_classes_admin_read
on public.drug_classes
for select
to authenticated
using (private.is_admin_or_super_admin());

create policy drug_class_translations_active_taxonomy_read
on public.drug_class_translations
for select
to authenticated
using (
  private.is_catalog_taxonomy_reader()
  and exists (
    select 1
    from public.drug_classes as drug_class
    where drug_class.id = drug_class_translations.drug_class_id
      and drug_class.is_active
  )
);

create policy drug_class_translations_admin_read
on public.drug_class_translations
for select
to authenticated
using (private.is_admin_or_super_admin());

create policy active_ingredients_active_taxonomy_read
on public.active_ingredients
for select
to authenticated
using (
  is_active
  and private.is_catalog_taxonomy_reader()
);

create policy active_ingredients_admin_read
on public.active_ingredients
for select
to authenticated
using (private.is_admin_or_super_admin());

create policy active_ingredient_translations_active_taxonomy_read
on public.active_ingredient_translations
for select
to authenticated
using (
  private.is_catalog_taxonomy_reader()
  and exists (
    select 1
    from public.active_ingredients as ingredient
    where ingredient.id =
      active_ingredient_translations.active_ingredient_id
      and ingredient.is_active
  )
);

create policy active_ingredient_translations_admin_read
on public.active_ingredient_translations
for select
to authenticated
using (private.is_admin_or_super_admin());

create policy generic_drugs_active_taxonomy_read
on public.generic_drugs
for select
to authenticated
using (
  is_active
  and private.is_catalog_taxonomy_reader()
);

create policy generic_drugs_admin_read
on public.generic_drugs
for select
to authenticated
using (private.is_admin_or_super_admin());

create policy generic_drug_translations_active_taxonomy_read
on public.generic_drug_translations
for select
to authenticated
using (
  private.is_catalog_taxonomy_reader()
  and exists (
    select 1
    from public.generic_drugs as generic_drug
    where generic_drug.id = generic_drug_translations.generic_drug_id
      and generic_drug.is_active
  )
);

create policy generic_drug_translations_admin_read
on public.generic_drug_translations
for select
to authenticated
using (private.is_admin_or_super_admin());

create policy generic_drug_ingredients_active_taxonomy_read
on public.generic_drug_ingredients
for select
to authenticated
using (
  private.is_catalog_taxonomy_reader()
  and exists (
    select 1
    from public.generic_drugs as generic_drug
    where generic_drug.id = generic_drug_ingredients.generic_drug_id
      and generic_drug.is_active
  )
  and exists (
    select 1
    from public.active_ingredients as ingredient
    where ingredient.id = generic_drug_ingredients.active_ingredient_id
      and ingredient.is_active
  )
);

create policy generic_drug_ingredients_admin_read
on public.generic_drug_ingredients
for select
to authenticated
using (private.is_admin_or_super_admin());

create policy products_draft_read
on public.products
for select
to authenticated
using (private.can_read_product_draft(id));

create policy product_translations_draft_read
on public.product_translations
for select
to authenticated
using (private.can_read_product_draft(product_id));

create policy product_markets_draft_read
on public.product_markets
for select
to authenticated
using (private.can_read_product_draft(product_id));

create policy product_market_translations_draft_read
on public.product_market_translations
for select
to authenticated
using (
  exists (
    select 1
    from public.product_markets as market
    where market.id = product_market_translations.product_market_id
      and private.can_read_product_draft(market.product_id)
  )
);

create policy product_specialties_draft_read
on public.product_specialties
for select
to authenticated
using (private.can_read_product_draft(product_id));

create policy product_media_draft_read
on public.product_media
for select
to authenticated
using (private.can_read_product_draft(product_id));

create policy product_brochures_draft_read
on public.product_brochures
for select
to authenticated
using (
  exists (
    select 1
    from public.product_markets as market
    where market.id = product_brochures.product_market_id
      and private.can_read_product_draft(market.product_id)
  )
);

create policy product_search_keywords_draft_read
on public.product_search_keywords
for select
to authenticated
using (private.can_read_product_draft(product_id));
