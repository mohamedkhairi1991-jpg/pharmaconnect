begin;

select plan(11);

insert into auth.users (
  id, instance_id, aud, role, email, encrypted_password,
  email_confirmed_at, raw_app_meta_data, raw_user_meta_data,
  created_at, updated_at
) values (
  '52000000-0000-4000-8000-000000000001',
  '00000000-0000-0000-0000-000000000000',
  'authenticated', 'authenticated', 'taxonomy-admin@example.com',
  extensions.crypt('password', extensions.gen_salt('bf')), now(),
  '{"provider":"email","providers":["email"]}'::jsonb, '{}'::jsonb,
  now(), now()
);

update public.profiles set role = 'admin', status = 'active'
where auth_user_id = '52000000-0000-4000-8000-000000000001';

select set_config(
  'request.jwt.claim.sub',
  '52000000-0000-4000-8000-000000000001',
  true
);
select set_config('request.jwt.claim.role', 'authenticated', true);
set local role authenticated;

select lives_ok(
  $$ select public.admin_create_drug_class('cardiovascular', null) $$,
  'admin creates a drug class through a controlled RPC'
);
select lives_ok(
  $$
    select public.admin_upsert_drug_class_translation(
      (select id from public.drug_classes where code = 'cardiovascular'),
      'en', 'Cardiovascular', null
    )
  $$,
  'admin adds required English drug class content'
);
select lives_ok(
  $$
    select public.admin_set_drug_class_active(
      (select id from public.drug_classes where code = 'cardiovascular'),
      true
    )
  $$,
  'admin activates a complete drug class'
);
select lives_ok(
  $$ select public.admin_create_active_ingredient('ingredient_one') $$,
  'admin creates an ingredient'
);
select lives_ok(
  $$
    select public.admin_upsert_active_ingredient_translation(
      (select id from public.active_ingredients
       where code = 'ingredient_one'),
      'en', 'Ingredient One', null
    )
  $$,
  'admin adds ingredient English content'
);
select lives_ok(
  $$
    select public.admin_set_active_ingredient_active(
      (select id from public.active_ingredients
       where code = 'ingredient_one'),
      true
    )
  $$,
  'admin activates a complete ingredient'
);
select lives_ok(
  $$
    select public.admin_create_generic_drug(
      'generic_one',
      (select id from public.drug_classes where code = 'cardiovascular')
    )
  $$,
  'admin creates a generic drug'
);
select lives_ok(
  $$
    select public.admin_upsert_generic_drug_translation(
      (select id from public.generic_drugs where code = 'generic_one'),
      'en', 'Generic One', null
    )
  $$,
  'admin adds generic English content'
);
select lives_ok(
  $$
    select * from public.admin_set_generic_drug_ingredients(
      (select id from public.generic_drugs where code = 'generic_one'),
      array[
        (select id from public.active_ingredients
         where code = 'ingredient_one')
      ]
    )
  $$,
  'admin defines generic composition'
);
select lives_ok(
  $$
    select public.admin_set_generic_drug_active(
      (select id from public.generic_drugs where code = 'generic_one'),
      true
    )
  $$,
  'admin activates complete generic drug'
);
select is(
  (select count(*) from public.generic_drug_ingredients
   where generic_drug_id = (
     select id from public.generic_drugs where code = 'generic_one'
   )),
  1::bigint,
  'composition stores one ordered ingredient'
);

reset role;
select * from finish();
rollback;
