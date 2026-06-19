begin;

select plan(14);

insert into auth.users (
  id, instance_id, aud, role, email, encrypted_password,
  email_confirmed_at, raw_app_meta_data, raw_user_meta_data,
  created_at, updated_at
) values
  (
    '64000000-0000-4000-8000-000000000001',
    '00000000-0000-0000-0000-000000000000',
    'authenticated', 'authenticated', 'workflow-admin@example.com',
    extensions.crypt('password', extensions.gen_salt('bf')), now(),
    '{"provider":"email","providers":["email"]}'::jsonb, '{}'::jsonb,
    now(), now()
  ),
  (
    '64000000-0000-4000-8000-000000000002',
    '00000000-0000-0000-0000-000000000000',
    'authenticated', 'authenticated', 'workflow-manager@example.com',
    extensions.crypt('password', extensions.gen_salt('bf')), now(),
    '{"provider":"email","providers":["email"]}'::jsonb, '{}'::jsonb,
    now(), now()
  ),
  (
    '64000000-0000-4000-8000-000000000003',
    '00000000-0000-0000-0000-000000000000',
    'authenticated', 'authenticated', 'workflow-marketing@example.com',
    extensions.crypt('password', extensions.gen_salt('bf')), now(),
    '{"provider":"email","providers":["email"]}'::jsonb, '{}'::jsonb,
    now(), now()
  ),
  (
    '64000000-0000-4000-8000-000000000004',
    '00000000-0000-0000-0000-000000000000',
    'authenticated', 'authenticated', 'workflow-viewer@example.com',
    extensions.crypt('password', extensions.gen_salt('bf')), now(),
    '{"provider":"email","providers":["email"]}'::jsonb, '{}'::jsonb,
    now(), now()
  ),
  (
    '64000000-0000-4000-8000-000000000005',
    '00000000-0000-0000-0000-000000000000',
    'authenticated', 'authenticated', 'workflow-other@example.com',
    extensions.crypt('password', extensions.gen_salt('bf')), now(),
    '{"provider":"email","providers":["email"]}'::jsonb, '{}'::jsonb,
    now(), now()
  );

update public.profiles set role = 'admin', status = 'active'
where auth_user_id = '64000000-0000-4000-8000-000000000001';
update public.profiles set role = 'company_user', status = 'active'
where auth_user_id in (
  '64000000-0000-4000-8000-000000000002',
  '64000000-0000-4000-8000-000000000003',
  '64000000-0000-4000-8000-000000000004',
  '64000000-0000-4000-8000-000000000005'
);

insert into public.companies (
  id, applicant_profile_id, country_id, company_name, legal_name,
  status, verified_by, verified_at
)
select
  '64000000-0000-4000-8000-000000000010', member.id,
  '00000000-0000-4000-8000-000000000368',
  'Workflow Company', 'Workflow Company LLC',
  'verified', admin_profile.id, now()
from public.profiles member
cross join public.profiles admin_profile
where member.auth_user_id = '64000000-0000-4000-8000-000000000002'
  and admin_profile.auth_user_id = '64000000-0000-4000-8000-000000000001';
insert into public.companies (
  id, applicant_profile_id, country_id, company_name, legal_name,
  status, verified_by, verified_at
)
select
  '64000000-0000-4000-8000-000000000011', member.id,
  '00000000-0000-4000-8000-000000000368',
  'Other Workflow Company', 'Other Workflow Company LLC',
  'verified', admin_profile.id, now()
from public.profiles member
cross join public.profiles admin_profile
where member.auth_user_id = '64000000-0000-4000-8000-000000000005'
  and admin_profile.auth_user_id = '64000000-0000-4000-8000-000000000001';

insert into public.company_users (
  company_id, profile_id, company_role, created_by
)
select
  case when member.auth_user_id =
    '64000000-0000-4000-8000-000000000005'
    then '64000000-0000-4000-8000-000000000011'::uuid
    else '64000000-0000-4000-8000-000000000010'::uuid end,
  member.id,
  case member.auth_user_id
    when '64000000-0000-4000-8000-000000000002'
      then 'product_manager'::public.company_role
    when '64000000-0000-4000-8000-000000000003'
      then 'marketing_manager'::public.company_role
    when '64000000-0000-4000-8000-000000000004'
      then 'viewer'::public.company_role
    else 'product_manager'::public.company_role
  end,
  admin_profile.id
from public.profiles member
cross join public.profiles admin_profile
where member.auth_user_id in (
  '64000000-0000-4000-8000-000000000002',
  '64000000-0000-4000-8000-000000000003',
  '64000000-0000-4000-8000-000000000004',
  '64000000-0000-4000-8000-000000000005'
)
and admin_profile.auth_user_id = '64000000-0000-4000-8000-000000000001';

insert into public.drug_classes (id, code, created_by, updated_by)
select
  '64000000-0000-4000-8000-000000000020',
  'workflow_class', id, id
from public.profiles
where auth_user_id = '64000000-0000-4000-8000-000000000001';
insert into public.drug_class_translations (drug_class_id, locale, name)
values (
  '64000000-0000-4000-8000-000000000020', 'en', 'Workflow Class'
);
update public.drug_classes set is_active = true
where id = '64000000-0000-4000-8000-000000000020';

insert into public.products (
  id, company_id, drug_class_id, category, status,
  created_by, updated_by, submitted_by, submitted_at,
  reviewed_by, reviewed_at, published_by, published_at
)
select
  product_id,
  '64000000-0000-4000-8000-000000000010',
  '64000000-0000-4000-8000-000000000020',
  'dietary_supplement',
  product_status,
  member.id,
  member.id,
  case when product_status = 'draft' then null else member.id end,
  case when product_status = 'draft' then null else now() end,
  case when product_status = 'published' then admin_profile.id else null end,
  case when product_status = 'published' then now() else null end,
  case when product_status = 'published' then admin_profile.id else null end,
  case when product_status = 'published' then now() else null end
from (
  values
    ('64000000-0000-4000-8000-000000000030'::uuid,
      'draft'::public.product_status),
    ('64000000-0000-4000-8000-000000000031'::uuid,
      'submitted'::public.product_status),
    ('64000000-0000-4000-8000-000000000032'::uuid,
      'published'::public.product_status)
) as fixture(product_id, product_status)
cross join public.profiles member
cross join public.profiles admin_profile
where member.auth_user_id = '64000000-0000-4000-8000-000000000002'
  and admin_profile.auth_user_id = '64000000-0000-4000-8000-000000000001';

set local role anon;
select throws_ok(
  $$ select count(*) from public.products $$,
  '42501', null,
  'anonymous users cannot read official product workflow records'
);
reset role;

select set_config(
  'request.jwt.claim.sub',
  '64000000-0000-4000-8000-000000000002',
  true
);
select set_config('request.jwt.claim.role', 'authenticated', true);
set local role authenticated;
select is(
  (select count(*) from public.products), 3::bigint,
  'product manager reads all own-company workflow states'
);
select ok(
  private.can_manage_official_product_content(
    '64000000-0000-4000-8000-000000000030'
  ),
  'product manager may edit draft'
);
select is(
  private.can_manage_official_product_content(
    '64000000-0000-4000-8000-000000000031'
  ),
  false,
  'product manager cannot edit submitted content'
);
select is(
  private.can_manage_official_product_content(
    '64000000-0000-4000-8000-000000000032'
  ),
  false,
  'product manager cannot edit published content'
);
reset role;

select set_config(
  'request.jwt.claim.sub',
  '64000000-0000-4000-8000-000000000003',
  true
);
set local role authenticated;
select is(
  (select count(*) from public.products), 3::bigint,
  'marketing manager has read-only workflow visibility'
);
select is(
  private.can_manage_official_product_content(
    '64000000-0000-4000-8000-000000000030'
  ),
  false,
  'marketing manager cannot edit draft content'
);
reset role;

select set_config(
  'request.jwt.claim.sub',
  '64000000-0000-4000-8000-000000000004',
  true
);
set local role authenticated;
select is(
  (select count(*) from public.products), 0::bigint,
  'viewer has no official-product workflow access'
);
reset role;

select set_config(
  'request.jwt.claim.sub',
  '64000000-0000-4000-8000-000000000005',
  true
);
set local role authenticated;
select is(
  (select count(*) from public.products), 0::bigint,
  'another company cannot read workflow records'
);
select throws_ok(
  $$
    select public.withdraw_product_submission(
      '64000000-0000-4000-8000-000000000031'
    )
  $$,
  '42501', null,
  'another company cannot withdraw the submission'
);
reset role;

select set_config(
  'request.jwt.claim.sub',
  '64000000-0000-4000-8000-000000000001',
  true
);
set local role authenticated;
select is(
  (select count(*) from public.products), 3::bigint,
  'admin reads all official product workflow records'
);
reset role;

update public.companies
set
  status = 'suspended',
  suspended_by = verified_by,
  suspended_at = now(),
  suspension_reason = 'Workflow test'
where id = '64000000-0000-4000-8000-000000000010';

select set_config(
  'request.jwt.claim.sub',
  '64000000-0000-4000-8000-000000000002',
  true
);
set local role authenticated;
select is(
  (select count(*) from public.products), 0::bigint,
  'suspended company loses workflow read access'
);
select is(
  private.can_manage_official_product_content(
    '64000000-0000-4000-8000-000000000030'
  ),
  false,
  'suspended company loses workflow write access'
);
reset role;

select set_config(
  'request.jwt.claim.sub',
  '64000000-0000-4000-8000-000000000001',
  true
);
set local role authenticated;
select lives_ok(
  $$
    select public.admin_archive_product(
      '64000000-0000-4000-8000-000000000032',
      'Archive after company suspension'
    )
  $$,
  'admin may archive retained content after company suspension'
);
reset role;

select * from finish();
rollback;
