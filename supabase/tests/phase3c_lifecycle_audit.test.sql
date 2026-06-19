begin;

select plan(10);

insert into auth.users (
  id, instance_id, aud, role, email, encrypted_password,
  email_confirmed_at, raw_app_meta_data, raw_user_meta_data,
  created_at, updated_at
) values
  (
    '67000000-0000-4000-8000-000000000001',
    '00000000-0000-0000-0000-000000000000',
    'authenticated', 'authenticated', 'lifecycle-audit-admin@example.com',
    extensions.crypt('password', extensions.gen_salt('bf')), now(),
    '{"provider":"email","providers":["email"]}'::jsonb, '{}'::jsonb,
    now(), now()
  ),
  (
    '67000000-0000-4000-8000-000000000002',
    '00000000-0000-0000-0000-000000000000',
    'authenticated', 'authenticated', 'lifecycle-audit-company@example.com',
    extensions.crypt('password', extensions.gen_salt('bf')), now(),
    '{"provider":"email","providers":["email"]}'::jsonb, '{}'::jsonb,
    now(), now()
  );

update public.profiles set role = 'admin', status = 'active'
where auth_user_id = '67000000-0000-4000-8000-000000000001';
update public.profiles set role = 'company_user', status = 'active'
where auth_user_id = '67000000-0000-4000-8000-000000000002';

insert into public.companies (
  id, applicant_profile_id, country_id, company_name, legal_name,
  status, verified_by, verified_at
)
select
  '67000000-0000-4000-8000-000000000010', member.id,
  '00000000-0000-4000-8000-000000000368',
  'Lifecycle Audit Company', 'Lifecycle Audit Company LLC',
  'verified', admin_profile.id, now()
from public.profiles member
cross join public.profiles admin_profile
where member.auth_user_id = '67000000-0000-4000-8000-000000000002'
  and admin_profile.auth_user_id = '67000000-0000-4000-8000-000000000001';
insert into public.company_users (
  company_id, profile_id, company_role, created_by
)
select
  '67000000-0000-4000-8000-000000000010', member.id,
  'company_admin', admin_profile.id
from public.profiles member
cross join public.profiles admin_profile
where member.auth_user_id = '67000000-0000-4000-8000-000000000002'
  and admin_profile.auth_user_id = '67000000-0000-4000-8000-000000000001';

insert into public.drug_classes (id, code, created_by, updated_by)
select
  '67000000-0000-4000-8000-000000000020',
  'lifecycle_audit_class', id, id
from public.profiles
where auth_user_id = '67000000-0000-4000-8000-000000000001';
insert into public.drug_class_translations (drug_class_id, locale, name)
values (
  '67000000-0000-4000-8000-000000000020', 'en',
  'Lifecycle Audit Class'
);
update public.drug_classes set is_active = true
where id = '67000000-0000-4000-8000-000000000020';

insert into public.specialties (
  id, code, profession_type, created_by, updated_by
)
select
  '67000000-0000-4000-8000-000000000030',
  'lifecycle_audit_specialty', 'physician', id, id
from public.profiles
where auth_user_id = '67000000-0000-4000-8000-000000000001';
insert into public.specialty_translations (specialty_id, locale, name)
values (
  '67000000-0000-4000-8000-000000000030', 'en',
  'Lifecycle Audit Specialty'
);
update public.specialties set is_active = true
where id = '67000000-0000-4000-8000-000000000030';

insert into public.products (
  id, company_id, drug_class_id, category, created_by, updated_by
)
select
  '67000000-0000-4000-8000-000000000040',
  '67000000-0000-4000-8000-000000000010',
  '67000000-0000-4000-8000-000000000020',
  'dietary_supplement', id, id
from public.profiles
where auth_user_id = '67000000-0000-4000-8000-000000000002';
insert into public.product_translations (product_id, locale, brand_name)
values (
  '67000000-0000-4000-8000-000000000040', 'en',
  'Lifecycle Audit Brand'
);
insert into public.product_markets (
  product_id, country_id, strength, dosage_form, route, pack_size,
  market_status
) values (
  '67000000-0000-4000-8000-000000000040',
  '00000000-0000-4000-8000-000000000368',
  '75 mg', 'capsule', 'oral', '30 capsules', 'marketed_in_iraq'
);
insert into public.product_market_translations (
  product_market_id, locale, storage_conditions, approved_indications,
  usual_adult_dose, contraindications, common_adverse_effects
)
select
  id, 'en', 'Store dry', 'Approved indication', 'One daily',
  'Known hypersensitivity', 'Mild effects'
from public.product_markets
where product_id = '67000000-0000-4000-8000-000000000040';
insert into public.product_specialties (
  product_id, specialty_id, created_by
)
select
  '67000000-0000-4000-8000-000000000040',
  '67000000-0000-4000-8000-000000000030', id
from public.profiles
where auth_user_id = '67000000-0000-4000-8000-000000000002';

select set_config(
  'request.jwt.claim.sub',
  '67000000-0000-4000-8000-000000000002',
  true
);
select set_config('request.jwt.claim.role', 'authenticated', true);
set local role authenticated;
select public.submit_product_for_review(
  '67000000-0000-4000-8000-000000000040'
);
select public.withdraw_product_submission(
  '67000000-0000-4000-8000-000000000040'
);
select public.submit_product_for_review(
  '67000000-0000-4000-8000-000000000040'
);
reset role;

select set_config(
  'request.jwt.claim.sub',
  '67000000-0000-4000-8000-000000000001',
  true
);
set local role authenticated;
select public.admin_request_product_changes(
  '67000000-0000-4000-8000-000000000040',
  'Clarify official information'
);
reset role;

select set_config(
  'request.jwt.claim.sub',
  '67000000-0000-4000-8000-000000000002',
  true
);
set local role authenticated;
select public.submit_product_for_review(
  '67000000-0000-4000-8000-000000000040'
);
reset role;

select set_config(
  'request.jwt.claim.sub',
  '67000000-0000-4000-8000-000000000001',
  true
);
set local role authenticated;
select public.admin_publish_product(
  '67000000-0000-4000-8000-000000000040'
);
select public.admin_hide_product(
  '67000000-0000-4000-8000-000000000040',
  'Temporary safety hold'
);
select public.admin_restore_product(
  '67000000-0000-4000-8000-000000000040',
  'published', null
);
select public.admin_archive_product(
  '67000000-0000-4000-8000-000000000040',
  'Official record retired'
);
reset role;

select ok(
  exists (select 1 from public.audit_logs
    where action = 'product_submitted'
      and target_id = '67000000-0000-4000-8000-000000000040'),
  'submission is audited'
);
select ok(
  exists (select 1 from public.audit_logs
    where action = 'product_submission_withdrawn'
      and target_id = '67000000-0000-4000-8000-000000000040'),
  'withdrawal is audited'
);
select ok(
  exists (select 1 from public.audit_logs
    where action = 'product_changes_requested'
      and target_id = '67000000-0000-4000-8000-000000000040'),
  'changes request is audited'
);
select ok(
  exists (select 1 from public.audit_logs
    where action = 'product_published'
      and target_id = '67000000-0000-4000-8000-000000000040'),
  'publication is audited'
);
select ok(
  exists (select 1 from public.audit_logs
    where action = 'product_hidden'
      and target_id = '67000000-0000-4000-8000-000000000040'),
  'hiding is audited'
);
select ok(
  exists (select 1 from public.audit_logs
    where action = 'product_restored'
      and target_id = '67000000-0000-4000-8000-000000000040'),
  'restoration is audited'
);
select ok(
  exists (select 1 from public.audit_logs
    where action = 'product_archived'
      and target_id = '67000000-0000-4000-8000-000000000040'),
  'archival is audited'
);
select is(
  (select count(*) from public.audit_logs
   where action = 'product_submitted'
     and target_id = '67000000-0000-4000-8000-000000000040'),
  3::bigint,
  'each submission and resubmission creates an immutable audit event'
);
select ok(
  not exists (
    select 1 from public.audit_logs
    where target_id = '67000000-0000-4000-8000-000000000040'
      and (
        new_data ? 'approved_indications'
        or new_data ? 'brochure'
        or new_data ? 'file_data'
        or new_data ? 'brand_name'
      )
  ),
  'lifecycle audit payloads exclude clinical, file, and translation content'
);
select is(
  (select status::text from public.products
   where id = '67000000-0000-4000-8000-000000000040'),
  'archived',
  'audited lifecycle finishes in terminal archived state'
);

select * from finish();
rollback;
