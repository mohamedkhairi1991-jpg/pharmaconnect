begin;

select plan(10);

insert into auth.users (
  id, instance_id, aud, role, email, encrypted_password,
  email_confirmed_at, raw_app_meta_data, raw_user_meta_data,
  created_at, updated_at
) values
  (
    '57000000-0000-4000-8000-000000000001',
    '00000000-0000-0000-0000-000000000000',
    'authenticated', 'authenticated', 'search-admin@example.com',
    extensions.crypt('password', extensions.gen_salt('bf')), now(),
    '{"provider":"email","providers":["email"]}'::jsonb, '{}'::jsonb,
    now(), now()
  ),
  (
    '57000000-0000-4000-8000-000000000002',
    '00000000-0000-0000-0000-000000000000',
    'authenticated', 'authenticated', 'search-company@example.com',
    extensions.crypt('password', extensions.gen_salt('bf')), now(),
    '{"provider":"email","providers":["email"]}'::jsonb, '{}'::jsonb,
    now(), now()
  );

update public.profiles set role = 'admin', status = 'active'
where auth_user_id = '57000000-0000-4000-8000-000000000001';
update public.profiles set role = 'company_user', status = 'active'
where auth_user_id = '57000000-0000-4000-8000-000000000002';

insert into public.companies (
  id, applicant_profile_id, country_id, company_name, legal_name,
  status, verified_by, verified_at
)
select
  '57000000-0000-4000-8000-000000000010', member.id,
  '00000000-0000-4000-8000-000000000368',
  'Search Pharma Company', 'Search Pharma Company LLC',
  'verified', admin_profile.id, now()
from public.profiles member
cross join public.profiles admin_profile
where member.auth_user_id = '57000000-0000-4000-8000-000000000002'
  and admin_profile.auth_user_id = '57000000-0000-4000-8000-000000000001';
insert into public.company_users (
  company_id, profile_id, company_role, created_by
)
select
  '57000000-0000-4000-8000-000000000010', member.id,
  'product_manager', admin_profile.id
from public.profiles member
cross join public.profiles admin_profile
where member.auth_user_id = '57000000-0000-4000-8000-000000000002'
  and admin_profile.auth_user_id = '57000000-0000-4000-8000-000000000001';

select set_config(
  'request.jwt.claim.sub',
  '57000000-0000-4000-8000-000000000001',
  true
);
select set_config('request.jwt.claim.role', 'authenticated', true);
set local role authenticated;

select public.admin_create_drug_class('search_class', null);
select public.admin_upsert_drug_class_translation(
  (select id from public.drug_classes where code = 'search_class'),
  'en', 'Search Drug Class', null
);
select public.admin_set_drug_class_active(
  (select id from public.drug_classes where code = 'search_class'), true
);
select public.admin_create_active_ingredient('search_ingredient');
select public.admin_upsert_active_ingredient_translation(
  (select id from public.active_ingredients
   where code = 'search_ingredient'),
  'en', 'Search Ingredient', null
);
select public.admin_set_active_ingredient_active(
  (select id from public.active_ingredients
   where code = 'search_ingredient'), true
);
select public.admin_create_generic_drug(
  'search_generic',
  (select id from public.drug_classes where code = 'search_class')
);
select public.admin_upsert_generic_drug_translation(
  (select id from public.generic_drugs where code = 'search_generic'),
  'en', 'Search Generic', null
);
select * from public.admin_set_generic_drug_ingredients(
  (select id from public.generic_drugs where code = 'search_generic'),
  array[
    (select id from public.active_ingredients
     where code = 'search_ingredient')
  ]
);
select public.admin_set_generic_drug_active(
  (select id from public.generic_drugs where code = 'search_generic'), true
);
reset role;

select set_config(
  'request.jwt.claim.sub',
  '57000000-0000-4000-8000-000000000002',
  true
);
set local role authenticated;
select public.create_product_draft(
  '57000000-0000-4000-8000-000000000010',
  'prescription_drug',
  (select id from public.generic_drugs where code = 'search_generic'),
  (select id from public.drug_classes where code = 'search_class'),
  'Café Brand'
);

select is(
  (select count(*) from public.product_search_keywords
   where keyword_type = 'brand'),
  1::bigint,
  'brand keyword is generated'
);
select is(
  (select normalized_keyword from public.product_search_keywords
   where keyword_type = 'brand'),
  'cafe brand',
  'brand keyword is normalized'
);
select is(
  (select count(*) from public.product_search_keywords
   where keyword_type = 'generic'),
  1::bigint,
  'generic keyword is generated'
);
select is(
  (select count(*) from public.product_search_keywords
   where keyword_type = 'company'),
  1::bigint,
  'company keyword is generated'
);
select is(
  (select count(*) from public.product_search_keywords
   where keyword_type = 'ingredient'),
  1::bigint,
  'ingredient keyword is generated'
);
select is(
  (select count(*) from public.product_search_keywords
   where keyword_type = 'drug_class'),
  1::bigint,
  'drug class keyword is generated'
);
select lives_ok(
  $$
    select public.upsert_product_keyword_alias(
      (select id from public.products limit 1),
      'ar', U&'\0623\064E\0644\0652\0641',
      'alias'
    )
  $$,
  'company product manager adds a trusted alias'
);
select is(
  (select normalized_keyword from public.product_search_keywords
   where keyword_type = 'alias'),
  U&'\0627\0644\0641',
  'Arabic alias is normalized'
);
select throws_ok(
  $$
    select public.upsert_product_keyword_alias(
      (select id from public.products limit 1),
      'en', 'Forbidden generated keyword', 'brand'
    )
  $$,
  '42501', null,
  'manual RPC cannot forge generated keyword types'
);
select is(
  (select count(*) from public.product_search_keywords),
  6::bigint,
  'keyword foundation stores generated and manual values without ranking'
);
reset role;

select * from finish();
rollback;
