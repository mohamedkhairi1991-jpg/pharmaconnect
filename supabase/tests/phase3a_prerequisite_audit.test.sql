begin;

select plan(19);

insert into auth.users (
  id, instance_id, aud, role, email, encrypted_password,
  email_confirmed_at, raw_app_meta_data, raw_user_meta_data,
  created_at, updated_at
)
values
  (
    '45000000-0000-4000-8000-000000000001',
    '00000000-0000-0000-0000-000000000000',
    'authenticated', 'authenticated', 'audit-admin@example.com',
    extensions.crypt('password', extensions.gen_salt('bf')), now(),
    '{"provider":"email","providers":["email"]}'::jsonb, '{}'::jsonb,
    now(), now()
  ),
  (
    '45000000-0000-4000-8000-000000000002',
    '00000000-0000-0000-0000-000000000000',
    'authenticated', 'authenticated', 'audit-doctor@example.com',
    extensions.crypt('password', extensions.gen_salt('bf')), now(),
    '{"provider":"email","providers":["email"]}'::jsonb, '{}'::jsonb,
    now(), now()
  ),
  (
    '45000000-0000-4000-8000-000000000003',
    '00000000-0000-0000-0000-000000000000',
    'authenticated', 'authenticated', 'audit-company@example.com',
    extensions.crypt('password', extensions.gen_salt('bf')), now(),
    '{"provider":"email","providers":["email"]}'::jsonb, '{}'::jsonb,
    now(), now()
  );

update public.profiles
set role = 'admin', status = 'active'
where auth_user_id = '45000000-0000-4000-8000-000000000001';

select set_config(
  'request.jwt.claim.sub',
  '45000000-0000-4000-8000-000000000001',
  true
);
select set_config('request.jwt.claim.role', 'authenticated', true);
set local role authenticated;

select public.admin_create_specialty('audit_specialty', 'physician');
select public.admin_upsert_specialty_translation(
  (select id from public.specialties where code = 'audit_specialty'),
  'en',
  'Audit Specialty',
  null
);
select public.admin_set_specialty_active(
  (select id from public.specialties where code = 'audit_specialty'),
  true
);
select public.admin_update_specialty(
  (select id from public.specialties where code = 'audit_specialty'),
  'audit_specialty_updated',
  'physician'
);
select public.admin_set_specialty_active(
  (select id from public.specialties where code = 'audit_specialty_updated'),
  false
);
select public.admin_set_specialty_active(
  (select id from public.specialties where code = 'audit_specialty_updated'),
  true
);

reset role;
select set_config(
  'request.jwt.claim.sub',
  '45000000-0000-4000-8000-000000000002',
  true
);
set local role authenticated;

select public.create_my_healthcare_professional_record(
  'physician',
  (select id from public.specialties where code = 'audit_specialty_updated'),
  'Initial Workplace',
  'AUDIT-LICENSE-SECRET'
);
select public.update_my_healthcare_professional_record(
  'physician',
  (select id from public.specialties where code = 'audit_specialty_updated'),
  'Updated Workplace',
  'AUDIT-LICENSE-SECRET'
);

reset role;
select set_config(
  'request.jwt.claim.sub',
  '45000000-0000-4000-8000-000000000001',
  true
);
set local role authenticated;

select public.admin_review_healthcare_professional(
  (
    select professional.id
    from public.healthcare_professionals as professional
    join public.profiles as profile on profile.id = professional.profile_id
    where profile.auth_user_id = '45000000-0000-4000-8000-000000000002'
  ),
  'documents_requested',
  'Additional document required'
);
select public.admin_review_healthcare_professional(
  (
    select professional.id
    from public.healthcare_professionals as professional
    join public.profiles as profile on profile.id = professional.profile_id
    where profile.auth_user_id = '45000000-0000-4000-8000-000000000002'
  ),
  'rejected',
  'Document was insufficient'
);
select public.admin_review_healthcare_professional(
  (
    select professional.id
    from public.healthcare_professionals as professional
    join public.profiles as profile on profile.id = professional.profile_id
    where profile.auth_user_id = '45000000-0000-4000-8000-000000000002'
  ),
  'approved',
  null
);

reset role;
select set_config(
  'request.jwt.claim.sub',
  '45000000-0000-4000-8000-000000000003',
  true
);
set local role authenticated;

select public.create_company_application(
  '00000000-0000-4000-8000-000000000368',
  null,
  'Audit Pharma',
  'Audit Pharma LLC',
  null,
  null,
  null,
  null
);

reset role;
select set_config(
  'request.jwt.claim.sub',
  '45000000-0000-4000-8000-000000000001',
  true
);
set local role authenticated;

select public.admin_verify_company(
  (select id from public.companies where legal_name = 'Audit Pharma LLC'),
  'Audit verification'
);
select public.admin_suspend_company(
  (select id from public.companies where legal_name = 'Audit Pharma LLC'),
  'Audit suspension'
);
select public.admin_restore_company(
  (select id from public.companies where legal_name = 'Audit Pharma LLC'),
  'Audit restoration'
);
select public.admin_archive_company(
  (select id from public.companies where legal_name = 'Audit Pharma LLC'),
  'Audit archive'
);

reset role;

select is((select count(*) from public.audit_logs where action = 'healthcare_professional_created'), 1::bigint, 'professional creation audited');
select is((select count(*) from public.audit_logs where action = 'healthcare_professional_updated'), 1::bigint, 'professional update audited');
select is((select count(*) from public.audit_logs where action = 'healthcare_professional_approved'), 1::bigint, 'professional approval audited');
select is((select count(*) from public.audit_logs where action = 'healthcare_professional_rejected'), 1::bigint, 'professional rejection audited');
select is((select count(*) from public.audit_logs where action = 'healthcare_professional_documents_requested'), 1::bigint, 'document request audited');
select is((select count(*) from public.audit_logs where action = 'company_application_created'), 1::bigint, 'company application audited');
select is((select count(*) from public.audit_logs where action = 'company_verified'), 1::bigint, 'company verification audited');
select is((select count(*) from public.audit_logs where action = 'company_suspended'), 1::bigint, 'company suspension audited');
select is((select count(*) from public.audit_logs where action = 'company_restored'), 1::bigint, 'company restoration audited');
select is((select count(*) from public.audit_logs where action = 'company_archived'), 1::bigint, 'company archive audited');
select is((select count(*) from public.audit_logs where action = 'company_membership_created'), 1::bigint, 'initial membership creation audited');
select is((select count(*) from public.audit_logs where action = 'specialty_created'), 1::bigint, 'specialty creation audited');
select is((select count(*) from public.audit_logs where action = 'specialty_updated'), 1::bigint, 'specialty update audited');
select ok((select count(*) from public.audit_logs where action = 'specialty_activated') >= 1, 'specialty activation audited');
select is((select count(*) from public.audit_logs where action = 'specialty_deactivated'), 1::bigint, 'specialty deactivation audited');
select is((select count(*) from public.audit_logs where action = 'specialty_translation_changed'), 1::bigint, 'specialty translation audited');
select is(
  (
    select count(*)
    from public.audit_logs
    where coalesce(old_data::text, '') like '%AUDIT-LICENSE-SECRET%'
       or coalesce(new_data::text, '') like '%AUDIT-LICENSE-SECRET%'
  ),
  0::bigint,
  'audit JSON does not copy raw license number'
);
select throws_ok(
  $$ update public.audit_logs set action = 'tampered' $$,
  '55000',
  'Audit logs are immutable.',
  'audit records remain update-protected'
);
select throws_ok(
  $$ delete from public.audit_logs $$,
  '55000',
  'Audit logs are immutable.',
  'audit records remain delete-protected'
);

select * from finish();
rollback;
