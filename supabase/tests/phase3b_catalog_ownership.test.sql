begin;

select plan(8);

insert into auth.users (
  id, instance_id, aud, role, email, encrypted_password,
  email_confirmed_at, raw_app_meta_data, raw_user_meta_data,
  created_at, updated_at
) values
  (
    '54000000-0000-4000-8000-000000000001',
    '00000000-0000-0000-0000-000000000000',
    'authenticated', 'authenticated', 'owner-admin@example.com',
    extensions.crypt('password', extensions.gen_salt('bf')), now(),
    '{"provider":"email","providers":["email"]}'::jsonb, '{}'::jsonb,
    now(), now()
  ),
  (
    '54000000-0000-4000-8000-000000000002',
    '00000000-0000-0000-0000-000000000000',
    'authenticated', 'authenticated', 'owner-company-admin@example.com',
    extensions.crypt('password', extensions.gen_salt('bf')), now(),
    '{"provider":"email","providers":["email"]}'::jsonb, '{}'::jsonb,
    now(), now()
  ),
  (
    '54000000-0000-4000-8000-000000000003',
    '00000000-0000-0000-0000-000000000000',
    'authenticated', 'authenticated', 'owner-marketing@example.com',
    extensions.crypt('password', extensions.gen_salt('bf')), now(),
    '{"provider":"email","providers":["email"]}'::jsonb, '{}'::jsonb,
    now(), now()
  ),
  (
    '54000000-0000-4000-8000-000000000004',
    '00000000-0000-0000-0000-000000000000',
    'authenticated', 'authenticated', 'owner-viewer@example.com',
    extensions.crypt('password', extensions.gen_salt('bf')), now(),
    '{"provider":"email","providers":["email"]}'::jsonb, '{}'::jsonb,
    now(), now()
  ),
  (
    '54000000-0000-4000-8000-000000000005',
    '00000000-0000-0000-0000-000000000000',
    'authenticated', 'authenticated', 'owner-other-manager@example.com',
    extensions.crypt('password', extensions.gen_salt('bf')), now(),
    '{"provider":"email","providers":["email"]}'::jsonb, '{}'::jsonb,
    now(), now()
  );

update public.profiles set role = 'admin', status = 'active'
where auth_user_id = '54000000-0000-4000-8000-000000000001';
update public.profiles set role = 'company_user', status = 'active'
where auth_user_id <> '54000000-0000-4000-8000-000000000001'
  and auth_user_id::text like '54000000-%';

insert into public.drug_classes (id, code, created_by, updated_by)
select
  '54000000-0000-4000-8000-000000000010', 'owner_class', id, id
from public.profiles
where auth_user_id = '54000000-0000-4000-8000-000000000001';
insert into public.drug_class_translations (drug_class_id, locale, name)
values ('54000000-0000-4000-8000-000000000010', 'en', 'Owner Class');
update public.drug_classes set is_active = true
where id = '54000000-0000-4000-8000-000000000010';

insert into public.companies (
  id, applicant_profile_id, country_id, company_name, legal_name,
  status, verified_by, verified_at
)
select
  '54000000-0000-4000-8000-000000000020', applicant.id,
  '00000000-0000-4000-8000-000000000368',
  'Owner Company', 'Owner Company LLC', 'verified', admin_profile.id, now()
from public.profiles applicant
cross join public.profiles admin_profile
where applicant.auth_user_id = '54000000-0000-4000-8000-000000000002'
  and admin_profile.auth_user_id = '54000000-0000-4000-8000-000000000001';

insert into public.companies (
  id, applicant_profile_id, country_id, company_name, legal_name,
  status, verified_by, verified_at
)
select
  '54000000-0000-4000-8000-000000000021', applicant.id,
  '00000000-0000-4000-8000-000000000368',
  'Other Company', 'Other Company LLC', 'verified', admin_profile.id, now()
from public.profiles applicant
cross join public.profiles admin_profile
where applicant.auth_user_id = '54000000-0000-4000-8000-000000000005'
  and admin_profile.auth_user_id = '54000000-0000-4000-8000-000000000001';

insert into public.company_users (
  company_id, profile_id, company_role, created_by
)
select
  case
    when profile.auth_user_id = '54000000-0000-4000-8000-000000000005'
      then '54000000-0000-4000-8000-000000000021'::uuid
    else '54000000-0000-4000-8000-000000000020'::uuid
  end,
  profile.id,
  case profile.auth_user_id
    when '54000000-0000-4000-8000-000000000002'
      then 'company_admin'::public.company_role
    when '54000000-0000-4000-8000-000000000003'
      then 'marketing_manager'::public.company_role
    when '54000000-0000-4000-8000-000000000004'
      then 'viewer'::public.company_role
    else 'product_manager'::public.company_role
  end,
  admin_profile.id
from public.profiles profile
cross join public.profiles admin_profile
where profile.auth_user_id in (
  '54000000-0000-4000-8000-000000000002',
  '54000000-0000-4000-8000-000000000003',
  '54000000-0000-4000-8000-000000000004',
  '54000000-0000-4000-8000-000000000005'
)
and admin_profile.auth_user_id = '54000000-0000-4000-8000-000000000001';

select set_config(
  'request.jwt.claim.sub',
  '54000000-0000-4000-8000-000000000002',
  true
);
select set_config('request.jwt.claim.role', 'authenticated', true);
set local role authenticated;

select lives_ok(
  $$
    select public.create_product_draft(
      '54000000-0000-4000-8000-000000000020',
      'dietary_supplement', null,
      '54000000-0000-4000-8000-000000000010',
      'Owner Brand'
    )
  $$,
  'company admin creates own-company draft'
);
select is(
  (select status::text from public.products limit 1),
  'draft',
  'created product remains draft'
);
select is(
  (select company_id from public.products limit 1),
  '54000000-0000-4000-8000-000000000020'::uuid,
  'draft ownership is assigned to the requested verified company'
);
reset role;

select throws_ok(
  $$
    update public.products
    set company_id = '54000000-0000-4000-8000-000000000021'
  $$,
  '55000',
  null,
  'company ownership is immutable'
);

select set_config(
  'request.jwt.claim.sub',
  '54000000-0000-4000-8000-000000000003',
  true
);
set local role authenticated;
select throws_ok(
  $$
    select public.update_product_draft(
      (select id from public.products limit 1),
      'dietary_supplement', null,
      '54000000-0000-4000-8000-000000000010'
    )
  $$,
  '42501',
  null,
  'marketing manager cannot edit a draft'
);
reset role;

select set_config(
  'request.jwt.claim.sub',
  '54000000-0000-4000-8000-000000000004',
  true
);
set local role authenticated;
select throws_ok(
  $$
    select public.create_product_draft(
      '54000000-0000-4000-8000-000000000020',
      'dietary_supplement', null,
      '54000000-0000-4000-8000-000000000010',
      'Viewer Brand'
    )
  $$,
  '42501',
  null,
  'viewer cannot create a draft'
);
reset role;

select set_config(
  'request.jwt.claim.sub',
  '54000000-0000-4000-8000-000000000005',
  true
);
set local role authenticated;
select throws_ok(
  $$
    select public.update_product_draft(
      (select id from public.products limit 1),
      'dietary_supplement', null,
      '54000000-0000-4000-8000-000000000010'
    )
  $$,
  '42501',
  null,
  'another company product manager cannot edit the draft'
);
reset role;

update public.companies
set
  status = 'suspended',
  suspended_by = verified_by,
  suspended_at = now(),
  suspension_reason = 'Ownership test'
where id = '54000000-0000-4000-8000-000000000020';

select set_config(
  'request.jwt.claim.sub',
  '54000000-0000-4000-8000-000000000002',
  true
);
set local role authenticated;
select throws_ok(
  $$
    select public.update_product_draft(
      (select id from public.products limit 1),
      'dietary_supplement', null,
      '54000000-0000-4000-8000-000000000010'
    )
  $$,
  '42501',
  null,
  'suspended company loses draft write access'
);
reset role;

select * from finish();
rollback;
