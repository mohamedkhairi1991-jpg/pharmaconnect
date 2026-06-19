begin;

select plan(7);

insert into auth.users (
  id, instance_id, aud, role, email, encrypted_password,
  email_confirmed_at, raw_app_meta_data, raw_user_meta_data,
  created_at, updated_at
) values
  (
    '56000000-0000-4000-8000-000000000001',
    '00000000-0000-0000-0000-000000000000',
    'authenticated', 'authenticated', 'audit-admin@example.com',
    extensions.crypt('password', extensions.gen_salt('bf')), now(),
    '{"provider":"email","providers":["email"]}'::jsonb, '{}'::jsonb,
    now(), now()
  ),
  (
    '56000000-0000-4000-8000-000000000002',
    '00000000-0000-0000-0000-000000000000',
    'authenticated', 'authenticated', 'audit-company@example.com',
    extensions.crypt('password', extensions.gen_salt('bf')), now(),
    '{"provider":"email","providers":["email"]}'::jsonb, '{}'::jsonb,
    now(), now()
  );

update public.profiles set role = 'admin', status = 'active'
where auth_user_id = '56000000-0000-4000-8000-000000000001';
update public.profiles set role = 'company_user', status = 'active'
where auth_user_id = '56000000-0000-4000-8000-000000000002';

insert into public.companies (
  id, applicant_profile_id, country_id, company_name, legal_name,
  status, verified_by, verified_at
)
select
  '56000000-0000-4000-8000-000000000010', member.id,
  '00000000-0000-4000-8000-000000000368',
  'Audit Catalog Company', 'Audit Catalog Company LLC',
  'verified', admin_profile.id, now()
from public.profiles member
cross join public.profiles admin_profile
where member.auth_user_id = '56000000-0000-4000-8000-000000000002'
  and admin_profile.auth_user_id = '56000000-0000-4000-8000-000000000001';
insert into public.company_users (
  company_id, profile_id, company_role, created_by
)
select
  '56000000-0000-4000-8000-000000000010', member.id,
  'company_admin', admin_profile.id
from public.profiles member
cross join public.profiles admin_profile
where member.auth_user_id = '56000000-0000-4000-8000-000000000002'
  and admin_profile.auth_user_id = '56000000-0000-4000-8000-000000000001';

select set_config(
  'request.jwt.claim.sub',
  '56000000-0000-4000-8000-000000000001',
  true
);
select set_config('request.jwt.claim.role', 'authenticated', true);
set local role authenticated;
select lives_ok(
  $$ select public.admin_create_drug_class('audit_class', null) $$,
  'admin taxonomy creation succeeds'
);
select lives_ok(
  $$
    select public.admin_upsert_drug_class_translation(
      (select id from public.drug_classes where code = 'audit_class'),
      'en', 'Audit Class', null
    )
  $$,
  'admin taxonomy translation succeeds'
);
select lives_ok(
  $$
    select public.admin_set_drug_class_active(
      (select id from public.drug_classes where code = 'audit_class'),
      true
    )
  $$,
  'admin taxonomy activation succeeds'
);
reset role;

select set_config(
  'request.jwt.claim.sub',
  '56000000-0000-4000-8000-000000000002',
  true
);
set local role authenticated;
select lives_ok(
  $$
    select public.create_product_draft(
      '56000000-0000-4000-8000-000000000010',
      'dietary_supplement', null,
      (select id from public.drug_classes where code = 'audit_class'),
      'Audit Brand'
    )
  $$,
  'company draft creation succeeds'
);
reset role;

select is(
  (select count(*) from public.audit_logs
   where action in (
     'drug_class_created',
     'drug_class_translation_changed',
     'drug_class_activated'
   )),
  3::bigint,
  'taxonomy mutations create audit records'
);
select is(
  (select count(*) from public.audit_logs
   where action = 'product_draft_created'
     and target_type = 'product'),
  1::bigint,
  'product draft creation creates an audit record'
);
select ok(
  not exists (
    select 1
    from public.audit_logs
    where action = 'product_draft_created'
      and new_data ? 'brand_name'
  ),
  'product audit payload excludes localized clinical and brand content'
);

select * from finish();
rollback;
