create type public.profession_type as enum (
  'physician',
  'pharmacist'
);

create type public.healthcare_professional_verification_status as enum (
  'pending',
  'approved',
  'rejected',
  'documents_requested'
);

create type public.company_status as enum (
  'pending',
  'verified',
  'suspended',
  'archived'
);

create type public.company_role as enum (
  'company_admin',
  'marketing_manager',
  'product_manager',
  'representative',
  'viewer'
);

create type public.content_locale as enum (
  'en',
  'ar'
);
