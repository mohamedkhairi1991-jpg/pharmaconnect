begin;

select plan(13);

insert into auth.users (
  id, instance_id, aud, role, email, encrypted_password,
  email_confirmed_at, raw_app_meta_data, raw_user_meta_data,
  created_at, updated_at
) values
  (
    '63000000-0000-4000-8000-000000000001',
    '00000000-0000-0000-0000-000000000000',
    'authenticated', 'authenticated', 'transition-admin@example.com',
    extensions.crypt('password', extensions.gen_salt('bf')), now(),
    '{"provider":"email","providers":["email"]}'::jsonb, '{}'::jsonb,
    now(), now()
  ),
  (
    '63000000-0000-4000-8000-000000000002',
    '00000000-0000-0000-0000-000000000000',
    'authenticated', 'authenticated', 'transition-company@example.com',
    extensions.crypt('password', extensions.gen_salt('bf')), now(),
    '{"provider":"email","providers":["email"]}'::jsonb, '{}'::jsonb,
    now(), now()
  );

update public.profiles set role = 'admin', status = 'active'
where auth_user_id = '63000000-0000-4000-8000-000000000001';
update public.profiles set role = 'company_user', status = 'active'
where auth_user_id = '63000000-0000-4000-8000-000000000002';

insert into public.companies (
  id, applicant_profile_id, country_id, company_name, legal_name,
  status, verified_by, verified_at
)
select
  '63000000-0000-4000-8000-000000000010', member.id,
  '00000000-0000-4000-8000-000000000368',
  'Transition Company', 'Transition Company LLC',
  'verified', admin_profile.id, now()
from public.profiles member
cross join public.profiles admin_profile
where member.auth_user_id = '63000000-0000-4000-8000-000000000002'
  and admin_profile.auth_user_id = '63000000-0000-4000-8000-000000000001';
insert into public.company_users (
  company_id, profile_id, company_role, created_by
)
select
  '63000000-0000-4000-8000-000000000010', member.id,
  'company_admin', admin_profile.id
from public.profiles member
cross join public.profiles admin_profile
where member.auth_user_id = '63000000-0000-4000-8000-000000000002'
  and admin_profile.auth_user_id = '63000000-0000-4000-8000-000000000001';

insert into public.drug_classes (id, code, created_by, updated_by)
select
  '63000000-0000-4000-8000-000000000020',
  'transition_class', id, id
from public.profiles
where auth_user_id = '63000000-0000-4000-8000-000000000001';
insert into public.drug_class_translations (drug_class_id, locale, name)
values (
  '63000000-0000-4000-8000-000000000020', 'en', 'Transition Class'
);
update public.drug_classes set is_active = true
where id = '63000000-0000-4000-8000-000000000020';

insert into public.products (
  id, company_id, drug_class_id, category, created_by, updated_by
)
select
  '63000000-0000-4000-8000-000000000030',
  '63000000-0000-4000-8000-000000000010',
  '63000000-0000-4000-8000-000000000020',
  'dietary_supplement', id, id
from public.profiles
where auth_user_id = '63000000-0000-4000-8000-000000000002';

select set_config(
  'request.jwt.claim.sub',
  '63000000-0000-4000-8000-000000000001',
  true
);
select set_config('request.jwt.claim.role', 'authenticated', true);
set local role authenticated;
select lives_ok(
  $$
    select public.admin_hide_product(
      '63000000-0000-4000-8000-000000000030',
      'Governance hold'
    )
  $$,
  'admin may hide a draft'
);
select is(
  (select status::text from public.products
   where id = '63000000-0000-4000-8000-000000000030'),
  'hidden',
  'draft becomes hidden'
);
select throws_ok(
  $$
    select public.admin_restore_product(
      '63000000-0000-4000-8000-000000000030',
      'draft', null
    )
  $$,
  '22023', null,
  'restore destination is restricted'
);
select throws_ok(
  $$
    select public.admin_restore_product(
      '63000000-0000-4000-8000-000000000030',
      'changes_requested', 'Provide corrections'
    )
  $$,
  '23514', null,
  'hidden draft cannot become changes_requested without prior submission'
);
select lives_ok(
  $$
    select public.admin_archive_product(
      '63000000-0000-4000-8000-000000000030',
      'Retired by administration'
    )
  $$,
  'admin archives a hidden product'
);
select is(
  (select status::text from public.products
   where id = '63000000-0000-4000-8000-000000000030'),
  'archived',
  'archived is stored as the terminal state'
);
select throws_ok(
  $$
    select public.admin_hide_product(
      '63000000-0000-4000-8000-000000000030',
      'Cannot hide terminal record'
    )
  $$,
  '23514', null,
  'archived product cannot transition again'
);
reset role;

insert into public.products (
  id, company_id, drug_class_id, category, status,
  created_by, updated_by, submitted_by, submitted_at
)
select
  '63000000-0000-4000-8000-000000000031',
  '63000000-0000-4000-8000-000000000010',
  '63000000-0000-4000-8000-000000000020',
  'dietary_supplement', 'submitted', member.id, member.id,
  member.id, now()
from public.profiles member
where member.auth_user_id = '63000000-0000-4000-8000-000000000002';

select set_config(
  'request.jwt.claim.sub',
  '63000000-0000-4000-8000-000000000001',
  true
);
set local role authenticated;
select throws_ok(
  $$
    select public.admin_request_product_changes(
      '63000000-0000-4000-8000-000000000031', ' '
    )
  $$,
  '22023', null,
  'changes request requires a nonblank reason'
);
select lives_ok(
  $$
    select public.admin_request_product_changes(
      '63000000-0000-4000-8000-000000000031',
      'Correct the official information'
    )
  $$,
  'admin returns submitted product for changes'
);
select is(
  (select status::text from public.products
   where id = '63000000-0000-4000-8000-000000000031'),
  'changes_requested',
  'changes-requested state is stored'
);
reset role;

select set_config(
  'request.jwt.claim.sub',
  '63000000-0000-4000-8000-000000000002',
  true
);
set local role authenticated;
select ok(
  private.can_manage_official_product_content(
    '63000000-0000-4000-8000-000000000031'
  ),
  'company may edit a changes-requested record'
);
select lives_ok(
  $$
    select public.withdraw_product_submission(
      '63000000-0000-4000-8000-000000000031'
    )
  $$,
  'company withdraws a changes-requested record to draft'
);
select is(
  (select status::text from public.products
   where id = '63000000-0000-4000-8000-000000000031'),
  'draft',
  'withdrawal clears the review state'
);
reset role;

select * from finish();
rollback;
