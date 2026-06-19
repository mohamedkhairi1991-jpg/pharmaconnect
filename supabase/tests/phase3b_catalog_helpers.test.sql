begin;

select plan(10);

select is(
  private.normalize_english_text('  Café--TABLET  '),
  'cafe tablet',
  'English normalization folds accents and punctuation'
);
select is(
  private.normalize_arabic_text(U&'\0623\064E\0644\0652\0641'),
  U&'\0627\0644\0641',
  'Arabic normalization removes marks and normalizes alef'
);
select is(
  private.normalize_arabic_text(U&'\0645\0624\0634\0631 \0628\0637\064A\0621'),
  U&'\0645\0648\0634\0631 \0628\0637\064A\0621',
  'Arabic normalization maps waw and ya hamza forms'
);
select is(
  private.normalize_search_text('Brand.Name', 'und'),
  'brand name',
  'undetermined locale uses Latin normalization'
);
select is(
  private.normalize_search_text('   ', 'en'),
  null,
  'blank normalized values become null'
);

insert into auth.users (
  id, instance_id, aud, role, email, encrypted_password,
  email_confirmed_at, raw_app_meta_data, raw_user_meta_data,
  created_at, updated_at
) values (
  '53000000-0000-4000-8000-000000000001',
  '00000000-0000-0000-0000-000000000000',
  'authenticated', 'authenticated', 'helper-company@example.com',
  extensions.crypt('password', extensions.gen_salt('bf')), now(),
  '{"provider":"email","providers":["email"]}'::jsonb, '{}'::jsonb,
  now(), now()
);

update public.profiles set role = 'company_user', status = 'active'
where auth_user_id = '53000000-0000-4000-8000-000000000001';

insert into public.companies (
  id, applicant_profile_id, country_id, company_name, legal_name,
  status, verified_by, verified_at
)
select
  '53000000-0000-4000-8000-000000000010',
  id, '00000000-0000-4000-8000-000000000368',
  'Helper Catalog Company', 'Helper Catalog Company LLC',
  'verified', id, now()
from public.profiles
where auth_user_id = '53000000-0000-4000-8000-000000000001';

insert into public.company_users (
  company_id, profile_id, company_role, created_by
)
select
  '53000000-0000-4000-8000-000000000010', id,
  'product_manager', id
from public.profiles
where auth_user_id = '53000000-0000-4000-8000-000000000001';

select set_config(
  'request.jwt.claim.sub',
  '53000000-0000-4000-8000-000000000001',
  true
);
select set_config('request.jwt.claim.role', 'authenticated', true);

select ok(
  private.is_catalog_taxonomy_reader(),
  'active verified product manager is a taxonomy reader'
);
select is(
  private.current_company_id(),
  '53000000-0000-4000-8000-000000000010'::uuid,
  'catalog helpers use trusted company context'
);

update public.companies
set
  status = 'suspended',
  suspended_by = verified_by,
  suspended_at = now(),
  suspension_reason = 'Helper test'
where id = '53000000-0000-4000-8000-000000000010';

select is(
  private.is_catalog_taxonomy_reader(),
  false,
  'suspended company loses taxonomy access'
);
select is(
  private.can_read_product_draft(
    '53000000-0000-4000-8000-000000000099'
  ),
  false,
  'unknown product access fails closed'
);
select is(
  private.can_manage_product_draft(
    '53000000-0000-4000-8000-000000000099'
  ),
  false,
  'unknown product management fails closed'
);

select * from finish();
rollback;
