# Supabase Seed Data

This folder is reserved for approved non-production seed data.

## MVP catalog demo seed

`demo_mvp_catalog_seed.sql` prepares fake local/demo public-table data for the
PharmaConnect MVP catalog walkthrough:

1. An approved doctor views an already published official catalog product.
2. A verified company admin opens a draft workflow product.
3. The company admin edits, saves, and submits the product.
4. An admin reviewer opens the submitted product in the review queue.
5. The admin reviewer may request changes, then later publish.
6. The approved doctor can see the newly published product in the official catalog.

This seed is non-production only and is not a migration.

## Required Auth users

The public-table seed assumes these Supabase Auth users already exist:

- `doctor.demo@pharmaconnect.local`
- `company.admin.demo@pharmaconnect.local`
- `admin.demo@pharmaconnect.local`

Create those Auth users manually or through a separate local Auth seed before
running `demo_mvp_catalog_seed.sql`. The SQL seed looks up these users by email
and fails clearly if any are missing.

Suggested local/manual demo password only:

- `DemoPass!2026`

Do not use production credentials with this seed.
Do not use production secrets, real patient data, or real doctor/company
personal data with this seed.

## Demo data included

The demo seed creates or updates:

- active demo profiles for the doctor, company admin, and admin reviewer;
- an approved physician record for the doctor;
- a verified demo company named `Tigris Pharma`;
- an active `company_admin` membership for the company admin;
- active English taxonomy/reference records for:
  - Cardiology;
  - Respiratory Medicine;
  - Beta Blockers;
  - Bronchodilators;
  - Bisoprolol;
  - Salbutamol;
- one published official product: `Cardiostead 5 mg`;
- one draft workflow product: `Airvento 100 mcg`.

The seed uses fake demo identities and stable demo identifiers where safe. It
does not include media files or brochure files.

## Idempotency notes

The seed is designed to be rerun in a local/demo database. It upserts accounts,
company, membership, and taxonomy records. It resets only the two known demo
product IDs before recreating them, so a walkthrough can be repeated after the
workflow product has been submitted or published during a demo.

Do not run this seed against production data.
