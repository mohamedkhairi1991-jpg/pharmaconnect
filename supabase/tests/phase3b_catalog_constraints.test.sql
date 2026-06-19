begin;

select plan(10);

insert into auth.users (
  id, instance_id, aud, role, email, encrypted_password,
  email_confirmed_at, raw_app_meta_data, raw_user_meta_data,
  created_at, updated_at
) values (
  '51000000-0000-4000-8000-000000000001',
  '00000000-0000-0000-0000-000000000000',
  'authenticated', 'authenticated', 'constraints-admin@example.com',
  extensions.crypt('password', extensions.gen_salt('bf')), now(),
  '{"provider":"email","providers":["email"]}'::jsonb, '{}'::jsonb,
  now(), now()
);

update public.profiles set role = 'admin', status = 'active'
where auth_user_id = '51000000-0000-4000-8000-000000000001';

insert into public.drug_classes (
  id, code, created_by, updated_by
) select
  '51000000-0000-4000-8000-000000000010', 'constraint_class', id, id
from public.profiles
where auth_user_id = '51000000-0000-4000-8000-000000000001';

select throws_ok(
  $$
    insert into public.drug_classes (
      code, created_by, updated_by
    )
    select 'Bad Code', id, id from public.profiles
    where auth_user_id = '51000000-0000-4000-8000-000000000001'
  $$,
  '23514',
  null,
  'drug class codes are normalized identifiers'
);

select throws_ok(
  $$
    update public.drug_classes set is_active = true
    where id = '51000000-0000-4000-8000-000000000010'
  $$,
  '23514',
  null,
  'English taxonomy content is required before activation'
);

insert into public.drug_class_translations (
  drug_class_id, locale, name
) values (
  '51000000-0000-4000-8000-000000000010', 'en', 'Constraint Class'
);
update public.drug_classes set is_active = true
where id = '51000000-0000-4000-8000-000000000010';

select is(
  (select is_active from public.drug_classes
   where id = '51000000-0000-4000-8000-000000000010'),
  true,
  'taxonomy activates after English content exists'
);

select throws_ok(
  $$
    insert into public.product_translations (
      product_id, locale, brand_name
    ) values (
      '51000000-0000-4000-8000-000000000099', 'en', ''
    )
  $$,
  '23514',
  null,
  'blank product brand names are rejected'
);

select throws_ok(
  $$
    insert into public.product_media (
      product_id, media_type, storage_path, mime_type,
      file_size_bytes, uploaded_by
    ) values (
      '51000000-0000-4000-8000-000000000099',
      'product_image', 'x', 'application/pdf', 1,
      (select id from public.profiles
       where auth_user_id = '51000000-0000-4000-8000-000000000001')
    )
  $$,
  '23514',
  null,
  'non-image media MIME types are rejected'
);

select col_not_null(
  'public', 'products', 'company_id', 'product ownership is required'
);
select col_not_null(
  'public', 'product_markets', 'strength', 'market strength is required'
);
select col_not_null(
  'public', 'product_markets', 'dosage_form', 'dosage form is required'
);
select col_not_null(
  'public', 'product_markets', 'route', 'route is required'
);
select col_not_null(
  'public', 'product_markets', 'pack_size', 'pack size is required'
);

select * from finish();
rollback;
