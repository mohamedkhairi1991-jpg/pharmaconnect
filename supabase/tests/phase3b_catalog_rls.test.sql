begin;

select plan(13);

insert into auth.users (
  id, instance_id, aud, role, email, encrypted_password,
  email_confirmed_at, raw_app_meta_data, raw_user_meta_data,
  created_at, updated_at
) values
  (
    '55000000-0000-4000-8000-000000000001',
    '00000000-0000-0000-0000-000000000000',
    'authenticated', 'authenticated', 'catalog-rls-admin@example.com',
    extensions.crypt('password', extensions.gen_salt('bf')), now(),
    '{"provider":"email","providers":["email"]}'::jsonb, '{}'::jsonb,
    now(), now()
  ),
  (
    '55000000-0000-4000-8000-000000000002',
    '00000000-0000-0000-0000-000000000000',
    'authenticated', 'authenticated', 'catalog-rls-doctor@example.com',
    extensions.crypt('password', extensions.gen_salt('bf')), now(),
    '{"provider":"email","providers":["email"]}'::jsonb, '{}'::jsonb,
    now(), now()
  ),
  (
    '55000000-0000-4000-8000-000000000003',
    '00000000-0000-0000-8000-000000000000',
    'authenticated', 'authenticated', 'catalog-rls-company@example.com',
    extensions.crypt('password', extensions.gen_salt('bf')), now(),
    '{"provider":"email","providers":["email"]}'::jsonb, '{}'::jsonb,
    now(), now()
  ),
  (
    '55000000-0000-4000-8000-000000000004',
    '00000000-0000-0000-0000-000000000000',
    'authenticated', 'authenticated', 'catalog-rls-marketing@example.com',
    extensions.crypt('password', extensions.gen_salt('bf')), now(),
    '{"provider":"email","providers":["email"]}'::jsonb, '{}'::jsonb,
    now(), now()
  ),
  (
    '55000000-0000-4000-8000-000000000005',
    '00000000-0000-0000-0000-000000000000',
    'authenticated', 'authenticated', 'catalog-rls-viewer@example.com',
    extensions.crypt('password', extensions.gen_salt('bf')), now(),
    '{"provider":"email","providers":["email"]}'::jsonb, '{}'::jsonb,
    now(), now()
  );

update public.profiles set role = 'admin', status = 'active'
where auth_user_id = '55000000-0000-4000-8000-000000000001';
update public.profiles set role = 'healthcare_professional', status = 'active'
where auth_user_id = '55000000-0000-4000-8000-000000000002';
update public.profiles set role = 'company_user', status = 'active'
where auth_user_id in (
  '55000000-0000-4000-8000-000000000003',
  '55000000-0000-4000-8000-000000000004',
  '55000000-0000-4000-8000-000000000005'
);

insert into public.specialties (
  id, code, profession_type, created_by, updated_by
)
select
  '55000000-0000-4000-8000-000000000010',
  'catalog_rls_physician', 'physician', id, id
from public.profiles
where auth_user_id = '55000000-0000-4000-8000-000000000001';
insert into public.specialty_translations (specialty_id, locale, name)
values (
  '55000000-0000-4000-8000-000000000010', 'en', 'Catalog RLS'
);
update public.specialties set is_active = true
where id = '55000000-0000-4000-8000-000000000010';

insert into public.healthcare_professionals (
  profile_id, profession_type, specialty_id, license_number,
  verification_status, reviewed_by, reviewed_at
)
select
  doctor.id, 'physician',
  '55000000-0000-4000-8000-000000000010', 'CATALOG-RLS-DOC',
  'approved', admin_profile.id, now()
from public.profiles doctor
cross join public.profiles admin_profile
where doctor.auth_user_id = '55000000-0000-4000-8000-000000000002'
  and admin_profile.auth_user_id = '55000000-0000-4000-8000-000000000001';

insert into public.companies (
  id, applicant_profile_id, country_id, company_name, legal_name,
  status, verified_by, verified_at
)
select
  '55000000-0000-4000-8000-000000000020', member.id,
  '00000000-0000-4000-8000-000000000368',
  'Catalog RLS Company', 'Catalog RLS Company LLC',
  'verified', admin_profile.id, now()
from public.profiles member
cross join public.profiles admin_profile
where member.auth_user_id = '55000000-0000-4000-8000-000000000003'
  and admin_profile.auth_user_id = '55000000-0000-4000-8000-000000000001';

insert into public.company_users (
  company_id, profile_id, company_role, created_by
)
select
  '55000000-0000-4000-8000-000000000020', member.id,
  case member.auth_user_id
    when '55000000-0000-4000-8000-000000000003'
      then 'company_admin'::public.company_role
    when '55000000-0000-4000-8000-000000000004'
      then 'marketing_manager'::public.company_role
    else 'viewer'::public.company_role
  end,
  admin_profile.id
from public.profiles member
cross join public.profiles admin_profile
where member.auth_user_id in (
  '55000000-0000-4000-8000-000000000003',
  '55000000-0000-4000-8000-000000000004',
  '55000000-0000-4000-8000-000000000005'
)
and admin_profile.auth_user_id = '55000000-0000-4000-8000-000000000001';

insert into public.drug_classes (id, code, created_by, updated_by)
select
  '55000000-0000-4000-8000-000000000030', 'catalog_rls_class',
  id, id
from public.profiles
where auth_user_id = '55000000-0000-4000-8000-000000000001';
insert into public.drug_class_translations (drug_class_id, locale, name)
values (
  '55000000-0000-4000-8000-000000000030', 'en', 'Catalog RLS Class'
);
update public.drug_classes set is_active = true
where id = '55000000-0000-4000-8000-000000000030';

insert into public.products (
  id, company_id, drug_class_id, category, created_by, updated_by
)
select
  '55000000-0000-4000-8000-000000000040',
  '55000000-0000-4000-8000-000000000020',
  '55000000-0000-4000-8000-000000000030',
  'dietary_supplement', id, id
from public.profiles
where auth_user_id = '55000000-0000-4000-8000-000000000003';
insert into public.product_translations (product_id, locale, brand_name)
values (
  '55000000-0000-4000-8000-000000000040', 'en', 'Catalog RLS Brand'
);

set local role anon;
select throws_ok(
  $$ select count(*) from public.products $$,
  '42501', null, 'anonymous users have no product access'
);
select throws_ok(
  $$ select count(*) from public.drug_classes $$,
  '42501', null, 'anonymous users have no taxonomy access'
);
reset role;

select set_config(
  'request.jwt.claim.sub',
  '55000000-0000-4000-8000-000000000002',
  true
);
select set_config('request.jwt.claim.role', 'authenticated', true);
set local role authenticated;
select is(
  (select count(*) from public.products), 0::bigint,
  'approved physician cannot read Phase 3B products'
);
select is(
  (select count(*) from public.drug_classes), 0::bigint,
  'approved physician cannot read Phase 3B taxonomy'
);
reset role;

select set_config(
  'request.jwt.claim.sub',
  '55000000-0000-4000-8000-000000000003',
  true
);
set local role authenticated;
select is(
  (select count(*) from public.products), 1::bigint,
  'company admin reads own-company draft'
);
select is(
  (select count(*) from public.product_translations), 1::bigint,
  'child product records inherit draft read access'
);
select is(
  (select count(*) from public.drug_classes), 1::bigint,
  'company admin reads active taxonomy'
);
select throws_ok(
  $$ update public.products set updated_at = now() $$,
  '42501', null, 'company admin cannot bypass controlled RPCs'
);
reset role;

select set_config(
  'request.jwt.claim.sub',
  '55000000-0000-4000-8000-000000000004',
  true
);
set local role authenticated;
select is(
  (select count(*) from public.products), 1::bigint,
  'marketing manager reads own-company draft'
);
select is(
  (select count(*) from public.drug_classes), 0::bigint,
  'marketing manager does not receive taxonomy access'
);
reset role;

select set_config(
  'request.jwt.claim.sub',
  '55000000-0000-4000-8000-000000000005',
  true
);
set local role authenticated;
select is(
  (select count(*) from public.products), 0::bigint,
  'viewer receives no draft access'
);
select is(
  (select count(*) from public.drug_classes), 0::bigint,
  'viewer receives no taxonomy access'
);
reset role;

select set_config(
  'request.jwt.claim.sub',
  '55000000-0000-4000-8000-000000000001',
  true
);
set local role authenticated;
select is(
  (select count(*) from public.products), 1::bigint,
  'admin reads all drafts'
);
reset role;

select * from finish();
rollback;
