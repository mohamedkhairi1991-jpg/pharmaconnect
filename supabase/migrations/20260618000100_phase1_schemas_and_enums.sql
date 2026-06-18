create extension if not exists pgcrypto with schema extensions;

create schema if not exists private;

revoke all on schema private from public;
revoke all on schema private from anon;
revoke all on schema private from authenticated;

create type public.platform_role as enum (
  'healthcare_professional',
  'company_user',
  'admin',
  'super_admin'
);

create type public.profile_status as enum (
  'pending',
  'active',
  'suspended',
  'archived'
);
