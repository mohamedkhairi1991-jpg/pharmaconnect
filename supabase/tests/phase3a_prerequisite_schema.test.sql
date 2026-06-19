begin;

select plan(28);

select has_type('public', 'profession_type', 'profession type enum exists');
select has_type(
  'public',
  'healthcare_professional_verification_status',
  'professional verification enum exists'
);
select has_type('public', 'company_status', 'company status enum exists');
select has_type('public', 'company_role', 'company role enum exists');
select has_type('public', 'content_locale', 'content locale enum exists');

select enum_has_labels(
  'public',
  'profession_type',
  array['physician', 'pharmacist'],
  'profession values are exact'
);
select enum_has_labels(
  'public',
  'healthcare_professional_verification_status',
  array['pending', 'approved', 'rejected', 'documents_requested'],
  'professional verification values are exact'
);
select enum_has_labels(
  'public',
  'company_status',
  array['pending', 'verified', 'suspended', 'archived'],
  'company status values are exact'
);
select enum_has_labels(
  'public',
  'company_role',
  array[
    'company_admin',
    'marketing_manager',
    'product_manager',
    'representative',
    'viewer'
  ],
  'company role values are exact'
);
select enum_has_labels(
  'public',
  'content_locale',
  array['en', 'ar'],
  'content locale values are exact'
);

select has_table('public', 'specialties', 'specialties table exists');
select has_table(
  'public',
  'specialty_translations',
  'specialty translations table exists'
);
select has_table(
  'public',
  'healthcare_professionals',
  'healthcare professionals table exists'
);
select has_table('public', 'companies', 'companies table exists');
select has_table('public', 'company_users', 'company users table exists');

select col_type_is(
  'public',
  'healthcare_professionals',
  'profession_type',
  'profession_type',
  'professional uses profession enum'
);
select col_type_is(
  'public',
  'healthcare_professionals',
  'verification_status',
  'healthcare_professional_verification_status',
  'professional uses verification enum'
);
select col_type_is(
  'public',
  'companies',
  'status',
  'company_status',
  'company uses status enum'
);
select col_type_is(
  'public',
  'company_users',
  'company_role',
  'company_role',
  'membership uses company role enum'
);
select col_type_is(
  'public',
  'specialty_translations',
  'locale',
  'content_locale',
  'specialty translation uses locale enum'
);

select col_is_unique(
  'public',
  'healthcare_professionals',
  'profile_id',
  'one professional record is allowed per profile'
);
select col_is_unique(
  'public',
  'company_users',
  'profile_id',
  'one company membership is allowed per profile'
);
select col_is_unique(
  'public',
  'companies',
  'applicant_profile_id',
  'one company application is allowed per applicant'
);

select is(
  (
    select column_default
    from information_schema.columns
    where table_schema = 'public'
      and table_name = 'specialties'
      and column_name = 'is_active'
  ),
  'false',
  'specialties default to inactive'
);
select is(
  (
    select column_default
    from information_schema.columns
    where table_schema = 'public'
      and table_name = 'healthcare_professionals'
      and column_name = 'verification_status'
  ),
  '''pending''::healthcare_professional_verification_status',
  'professional verification defaults to pending'
);
select is(
  (
    select column_default
    from information_schema.columns
    where table_schema = 'public'
      and table_name = 'companies'
      and column_name = 'status'
  ),
  '''pending''::company_status',
  'company status defaults to pending'
);

select table_privs_are(
  'public',
  'healthcare_professionals',
  'authenticated',
  array['SELECT'],
  'authenticated role receives read-only direct professional access'
);
select table_privs_are(
  'public',
  'company_users',
  'authenticated',
  array['SELECT'],
  'authenticated role receives read-only direct membership access'
);

select * from finish();
rollback;
