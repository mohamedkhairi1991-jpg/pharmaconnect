begin;

select plan(10);

insert into auth.users (
  id, instance_id, aud, role, email, encrypted_password,
  email_confirmed_at, raw_app_meta_data, raw_user_meta_data,
  created_at, updated_at
) values
  (
    '61000000-0000-4000-8000-000000000001',
    '00000000-0000-0000-0000-000000000000',
    'authenticated', 'authenticated', 'submission-admin@example.com',
    extensions.crypt('password', extensions.gen_salt('bf')), now(),
    '{"provider":"email","providers":["email"]}'::jsonb, '{}'::jsonb,
    now(), now()
  ),
  (
    '61000000-0000-4000-8000-000000000002',
    '00000000-0000-0000-0000-000000000000',
    'authenticated', 'authenticated', 'submission-company@example.com',
    extensions.crypt('password', extensions.gen_salt('bf')), now(),
    '{"provider":"email","providers":["email"]}'::jsonb, '{}'::jsonb,
    now(), now()
  );

update public.profiles set role = 'admin', status = 'active'
where auth_user_id = '61000000-0000-4000-8000-000000000001';
update public.profiles set role = 'company_user', status = 'active'
where auth_user_id = '61000000-0000-4000-8000-000000000002';

insert into public.companies (
  id, applicant_profile_id, country_id, company_name, legal_name,
  status, verified_by, verified_at
)
select
  '61000000-0000-4000-8000-000000000010', member.id,
  '00000000-0000-4000-8000-000000000368',
  'Submission Company', 'Submission Company LLC',
  'verified', admin_profile.id, now()
from public.profiles member
cross join public.profiles admin_profile
where member.auth_user_id = '61000000-0000-4000-8000-000000000002'
  and admin_profile.auth_user_id = '61000000-0000-4000-8000-000000000001';

insert into public.company_users (
  company_id, profile_id, company_role, created_by
)
select
  '61000000-0000-4000-8000-000000000010', member.id,
  'product_manager', admin_profile.id
from public.profiles member
cross join public.profiles admin_profile
where member.auth_user_id = '61000000-0000-4000-8000-000000000002'
  and admin_profile.auth_user_id = '61000000-0000-4000-8000-000000000001';

insert into public.drug_classes (id, code, created_by, updated_by)
select
  '61000000-0000-4000-8000-000000000020',
  'submission_class', id, id
from public.profiles
where auth_user_id = '61000000-0000-4000-8000-000000000001';
insert into public.drug_class_translations (drug_class_id, locale, name)
values (
  '61000000-0000-4000-8000-000000000020', 'en', 'Submission Class'
);
update public.drug_classes set is_active = true
where id = '61000000-0000-4000-8000-000000000020';

insert into public.specialties (
  id, code, profession_type, created_by, updated_by
)
select
  '61000000-0000-4000-8000-000000000030',
  'submission_specialty', 'physician', id, id
from public.profiles
where auth_user_id = '61000000-0000-4000-8000-000000000001';
insert into public.specialty_translations (specialty_id, locale, name)
values (
  '61000000-0000-4000-8000-000000000030', 'en',
  'Submission Specialty'
);
update public.specialties set is_active = true
where id = '61000000-0000-4000-8000-000000000030';

insert into public.products (
  id, company_id, drug_class_id, category, created_by, updated_by
)
select
  '61000000-0000-4000-8000-000000000040',
  '61000000-0000-4000-8000-000000000010',
  '61000000-0000-4000-8000-000000000020',
  'dietary_supplement', id, id
from public.profiles
where auth_user_id = '61000000-0000-4000-8000-000000000002';
insert into public.product_translations (product_id, locale, brand_name)
values (
  '61000000-0000-4000-8000-000000000040', 'en', 'Submission Brand'
);

select ok(
  'iraq_market_missing' = any(
    private.product_validation_errors(
      '61000000-0000-4000-8000-000000000040', 'submission'
    )
  ),
  'submission detects a missing Iraq market'
);
select ok(
  'active_specialty_missing' = any(
    private.product_validation_errors(
      '61000000-0000-4000-8000-000000000040', 'submission'
    )
  ),
  'submission detects a missing specialty'
);
select ok(
  'presentation_fingerprint_missing' = any(
    private.product_validation_errors(
      '61000000-0000-4000-8000-000000000040', 'submission'
    )
  ),
  'submission detects a missing fingerprint'
);

select set_config(
  'request.jwt.claim.sub',
  '61000000-0000-4000-8000-000000000002',
  true
);
select set_config('request.jwt.claim.role', 'authenticated', true);
set local role authenticated;
select throws_ok(
  $$
    select public.submit_product_for_review(
      '61000000-0000-4000-8000-000000000040'
    )
  $$,
  '23514', null,
  'incomplete product cannot be submitted'
);
reset role;

insert into public.product_markets (
  product_id, country_id, strength, dosage_form, route, pack_size,
  market_status
) values (
  '61000000-0000-4000-8000-000000000040',
  '00000000-0000-4000-8000-000000000368',
  '100 mg', 'tablet', 'oral', '30 tablets', 'not_marketed'
);
insert into public.product_market_translations (
  product_market_id, locale, storage_conditions, approved_indications,
  usual_adult_dose, contraindications, common_adverse_effects
)
select
  id, 'en', 'Store dry', 'Approved indication', 'One daily',
  'Known hypersensitivity', 'Mild effects'
from public.product_markets
where product_id = '61000000-0000-4000-8000-000000000040';
insert into public.product_specialties (
  product_id, specialty_id, created_by
)
select
  '61000000-0000-4000-8000-000000000040',
  '61000000-0000-4000-8000-000000000030', id
from public.profiles
where auth_user_id = '61000000-0000-4000-8000-000000000002';
select private.refresh_product_presentation_fingerprint(
  '61000000-0000-4000-8000-000000000040'
);

select is(
  private.product_validation_errors(
    '61000000-0000-4000-8000-000000000040', 'submission'
  ),
  array[]::text[],
  'complete unpublished product is submission-ready'
);
select ok(
  private.is_product_submission_ready(
    '61000000-0000-4000-8000-000000000040'
  ),
  'submission readiness helper succeeds'
);

select set_config(
  'request.jwt.claim.sub',
  '61000000-0000-4000-8000-000000000002',
  true
);
set local role authenticated;
select lives_ok(
  $$
    select public.submit_product_for_review(
      '61000000-0000-4000-8000-000000000040'
    )
  $$,
  'company product manager submits a complete record'
);
select is(
  (select status::text from public.products
   where id = '61000000-0000-4000-8000-000000000040'),
  'submitted',
  'submission changes status to submitted'
);
select ok(
  (select submitted_by is not null and submitted_at is not null
   from public.products
   where id = '61000000-0000-4000-8000-000000000040'),
  'submission metadata is populated'
);
select throws_ok(
  $$
    select public.update_product_draft(
      '61000000-0000-4000-8000-000000000040',
      'dietary_supplement', null,
      '61000000-0000-4000-8000-000000000020'
    )
  $$,
  '42501', null,
  'submitted product content is locked'
);
reset role;

select * from finish();
rollback;
