begin;

select plan(11);

insert into auth.users (
  id, instance_id, aud, role, email, encrypted_password,
  email_confirmed_at, raw_app_meta_data, raw_user_meta_data,
  created_at, updated_at
) values
  (
    '62000000-0000-4000-8000-000000000001',
    '00000000-0000-0000-0000-000000000000',
    'authenticated', 'authenticated', 'publication-admin@example.com',
    extensions.crypt('password', extensions.gen_salt('bf')), now(),
    '{"provider":"email","providers":["email"]}'::jsonb, '{}'::jsonb,
    now(), now()
  ),
  (
    '62000000-0000-4000-8000-000000000002',
    '00000000-0000-0000-0000-000000000000',
    'authenticated', 'authenticated', 'publication-company@example.com',
    extensions.crypt('password', extensions.gen_salt('bf')), now(),
    '{"provider":"email","providers":["email"]}'::jsonb, '{}'::jsonb,
    now(), now()
  );

update public.profiles set role = 'admin', status = 'active'
where auth_user_id = '62000000-0000-4000-8000-000000000001';
update public.profiles set role = 'company_user', status = 'active'
where auth_user_id = '62000000-0000-4000-8000-000000000002';

insert into public.companies (
  id, applicant_profile_id, country_id, company_name, legal_name,
  status, verified_by, verified_at
)
select
  '62000000-0000-4000-8000-000000000010', member.id,
  '00000000-0000-4000-8000-000000000368',
  'Publication Company', 'Publication Company LLC',
  'verified', admin_profile.id, now()
from public.profiles member
cross join public.profiles admin_profile
where member.auth_user_id = '62000000-0000-4000-8000-000000000002'
  and admin_profile.auth_user_id = '62000000-0000-4000-8000-000000000001';
insert into public.company_users (
  company_id, profile_id, company_role, created_by
)
select
  '62000000-0000-4000-8000-000000000010', member.id,
  'company_admin', admin_profile.id
from public.profiles member
cross join public.profiles admin_profile
where member.auth_user_id = '62000000-0000-4000-8000-000000000002'
  and admin_profile.auth_user_id = '62000000-0000-4000-8000-000000000001';

insert into public.drug_classes (id, code, created_by, updated_by)
select
  '62000000-0000-4000-8000-000000000020',
  'publication_class', id, id
from public.profiles
where auth_user_id = '62000000-0000-4000-8000-000000000001';
insert into public.drug_class_translations (drug_class_id, locale, name)
values (
  '62000000-0000-4000-8000-000000000020', 'en', 'Publication Class'
);
update public.drug_classes set is_active = true
where id = '62000000-0000-4000-8000-000000000020';

insert into public.specialties (
  id, code, profession_type, created_by, updated_by
)
select
  '62000000-0000-4000-8000-000000000030',
  'publication_specialty', 'physician', id, id
from public.profiles
where auth_user_id = '62000000-0000-4000-8000-000000000001';
insert into public.specialty_translations (specialty_id, locale, name)
values (
  '62000000-0000-4000-8000-000000000030', 'en',
  'Publication Specialty'
);
update public.specialties set is_active = true
where id = '62000000-0000-4000-8000-000000000030';

insert into public.products (
  id, company_id, drug_class_id, category, created_by, updated_by
)
select
  '62000000-0000-4000-8000-000000000040',
  '62000000-0000-4000-8000-000000000010',
  '62000000-0000-4000-8000-000000000020',
  'dietary_supplement', id, id
from public.profiles
where auth_user_id = '62000000-0000-4000-8000-000000000002';
insert into public.product_translations (product_id, locale, brand_name)
values (
  '62000000-0000-4000-8000-000000000040', 'en', 'Publication Brand'
);
insert into public.product_markets (
  product_id, country_id, strength, dosage_form, route, pack_size,
  market_status
) values (
  '62000000-0000-4000-8000-000000000040',
  '00000000-0000-4000-8000-000000000368',
  '50 mg', 'capsule', 'oral', '20 capsules', 'not_marketed'
);
insert into public.product_market_translations (
  product_market_id, locale, storage_conditions, approved_indications,
  usual_adult_dose, contraindications, common_adverse_effects
)
select
  id, 'en', 'Store dry', 'Approved indication', 'One daily',
  'Known hypersensitivity', 'Mild effects'
from public.product_markets
where product_id = '62000000-0000-4000-8000-000000000040';
insert into public.product_specialties (
  product_id, specialty_id, created_by
)
select
  '62000000-0000-4000-8000-000000000040',
  '62000000-0000-4000-8000-000000000030', id
from public.profiles
where auth_user_id = '62000000-0000-4000-8000-000000000002';
select private.refresh_product_presentation_fingerprint(
  '62000000-0000-4000-8000-000000000040'
);

select set_config(
  'request.jwt.claim.sub',
  '62000000-0000-4000-8000-000000000002',
  true
);
select set_config('request.jwt.claim.role', 'authenticated', true);
set local role authenticated;
select public.submit_product_for_review(
  '62000000-0000-4000-8000-000000000040'
);
select throws_ok(
  $$
    select public.admin_publish_product(
      '62000000-0000-4000-8000-000000000040'
    )
  $$,
  '42501', null,
  'company cannot publish an official catalog product'
);
reset role;

select ok(
  'not_marketed_in_iraq' = any(
    private.product_validation_errors(
      '62000000-0000-4000-8000-000000000040', 'publication'
    )
  ),
  'publication requires marketed_in_iraq'
);

select set_config(
  'request.jwt.claim.sub',
  '62000000-0000-4000-8000-000000000001',
  true
);
set local role authenticated;
select throws_ok(
  $$
    select public.admin_publish_product(
      '62000000-0000-4000-8000-000000000040'
    )
  $$,
  '23514', null,
  'admin cannot publish a product that is not marketed in Iraq'
);
reset role;

update public.product_markets
set market_status = 'marketed_in_iraq'
where product_id = '62000000-0000-4000-8000-000000000040';

select is(
  (select count(*) from public.product_media
   where product_id = '62000000-0000-4000-8000-000000000040'),
  0::bigint,
  'publication fixture has no image metadata'
);
select is(
  (select count(*) from public.product_brochures as brochure
   join public.product_markets as market
     on market.id = brochure.product_market_id
   where market.product_id = '62000000-0000-4000-8000-000000000040'),
  0::bigint,
  'publication fixture has no brochure metadata'
);
select is(
  private.product_validation_errors(
    '62000000-0000-4000-8000-000000000040', 'publication'
  ),
  array[]::text[],
  'media and storage are not publication requirements in Phase 3C'
);

select set_config(
  'request.jwt.claim.sub',
  '62000000-0000-4000-8000-000000000001',
  true
);
set local role authenticated;
select lives_ok(
  $$
    select public.admin_publish_product(
      '62000000-0000-4000-8000-000000000040'
    )
  $$,
  'admin publishes a complete submitted product without storage'
);
select is(
  (select status::text from public.products
   where id = '62000000-0000-4000-8000-000000000040'),
  'published',
  'official product becomes published'
);
select ok(
  (select reviewed_by is not null and reviewed_at is not null
      and published_by is not null and published_at is not null
   from public.products
   where id = '62000000-0000-4000-8000-000000000040'),
  'publication metadata is complete'
);
select ok(
  private.is_official_catalog_product_visible(
    '62000000-0000-4000-8000-000000000040'
  ),
  'published product satisfies data-level catalog visibility'
);
select throws_ok(
  $$
    select public.admin_publish_product(
      '62000000-0000-4000-8000-000000000040'
    )
  $$,
  '23514', null,
  'published product cannot be published twice'
);
reset role;

select * from finish();
rollback;
