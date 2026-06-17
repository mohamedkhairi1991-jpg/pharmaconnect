# PharmaConnect Architecture Closure

Version: 1.0

Status: Final Implementation Baseline

Document Type: Architecture Closure and Source of Truth

---

# 1. Authority and Scope

This document resolves the blocking architecture gaps that must be closed before Flutter or Supabase implementation begins.

It is the final source of truth for:

- Product data architecture.
- Product lifecycle.
- Product and company favorites.
- Company invitations and membership activation.
- Campaign target references.
- Platform and company-role permissions.
- MVP scope.

If this document conflicts with any of the following documents, this document takes precedence:

- `PROJECT_REQUIREMENTS.md`
- `ENGINEERING_PRD.md`
- `DATABASE_SCHEMA.md`
- `RLS_POLICIES.md`
- `CODEX_EXECUTION_PLAN.md`

Requirements not addressed by this document remain governed by the existing documentation.

No implementation may introduce a different schema, lifecycle, permission, or MVP boundary without an approved architecture amendment.

---

# 2. Normative Conventions

## 2.1 Identifiers

- All primary keys use UUID.
- All foreign keys use UUID.
- Foreign-key constraints are mandatory.
- Referential actions must be explicitly defined.

## 2.2 Timestamps

- Mutable business records contain `created_at` and `updated_at`.
- Lifecycle transitions contain their own actor and timestamp fields where specified.
- Append-only relationship records may contain only `created_at`.
- All timestamps are stored in UTC.

## 2.3 Deletion

- Products, companies, campaigns, and memberships are never hard-deleted through normal application workflows.
- Favorites and expired or cancelled invitations may be hard-deleted only where explicitly permitted.
- Archival is the terminal normal state for retained business records.

## 2.4 Roles

Platform roles:

- `healthcare_professional`
- `company_user`
- `admin`
- `super_admin`

Company roles:

- `company_admin`
- `marketing_manager`
- `product_manager`
- `representative`
- `viewer`

Platform roles and company roles are separate. A company role has meaning only when an active `company_users` membership exists.

## 2.5 Trusted operations

The following actions must execute through trusted backend logic and must not be performed through unrestricted client table writes:

- Platform-role assignment.
- Initial company-admin assignment.
- Company invitation acceptance.
- Company-role changes.
- Product publication and lifecycle transitions.
- Product moderation.
- Campaign activation.
- Search-keyword generation.
- Audit-log creation.

Trusted backend logic may be implemented through security-controlled PostgreSQL functions or Supabase Edge Functions. The client must never contain the Supabase service-role key.

---

# 3. Product Architecture

## 3.1 Product model decision

A product is a canonical company-owned catalog item. Country-specific availability and pharmaceutical content are stored separately.

The model is:

```text
companies
    → products
        → product_translations
        → product_markets
            → product_market_translations
        → product_specialties
        → product_media
        → product_brochures
        → product_search_keywords
```

This replaces the earlier rule that a product directly belongs to exactly one country.

For the Iraq MVP:

- Every publishable product must have one active Iraq `product_markets` record.
- Launch scope is Iraq only.
- Multi-country expansion is future.
- The schema remains capable of adding other countries later without duplicating the canonical product.

## 3.2 `products`

Purpose:

Stores canonical product identity, ownership, classification, and lifecycle.

| Field | Requirement |
|---|---|
| `id` | UUID primary key. |
| `company_id` | Required foreign key to `companies.id`. Immutable after creation. |
| `generic_drug_id` | Foreign key to `generic_drugs.id`. Required for prescription and OTC drugs; optional for dietary supplements. |
| `drug_class_id` | Required foreign key to `drug_classes.id`. |
| `category` | Required: `prescription_drug`, `otc_drug`, or `dietary_supplement`. |
| `status` | Required product lifecycle state. |
| `created_by` | Required foreign key to `profiles.id`. |
| `updated_by` | Required foreign key to `profiles.id`. |
| `published_by` | Nullable foreign key to `profiles.id`. |
| `published_at` | Nullable timestamp. |
| `hidden_by` | Nullable foreign key to `profiles.id`. |
| `hidden_at` | Nullable timestamp. |
| `hidden_reason` | Nullable text; required while status is `hidden`. |
| `archived_by` | Nullable foreign key to `profiles.id`. |
| `archived_at` | Nullable timestamp. |
| `archive_reason` | Nullable text. |
| `created_at` | Required timestamp. |
| `updated_at` | Required timestamp. |

Required constraints:

- `company_id` cannot change after creation.
- `generic_drug_id` is required when category is `prescription_drug` or `otc_drug`.
- `published_by` and `published_at` are set when a product first becomes published.
- `hidden_by`, `hidden_at`, and `hidden_reason` are required when status is `hidden`.
- `archived_by` and `archived_at` are required when status is `archived`.
- A product cannot be published unless its company is `verified`.
- A product cannot be published without all required content defined in Section 4.

Required indexes:

- `(company_id, status)`
- `(generic_drug_id, status)`
- `(drug_class_id, status)`
- `(category, status)`
- `updated_at`

## 3.3 `product_translations`

Purpose:

Stores localized canonical product identity.

| Field | Requirement |
|---|---|
| `id` | UUID primary key. |
| `product_id` | Required foreign key to `products.id`. |
| `locale` | Required: `en` or `ar`. |
| `brand_name` | Required localized brand name. |
| `created_at` | Required timestamp. |
| `updated_at` | Required timestamp. |

Required constraints:

- Unique `(product_id, locale)`.
- English is required before publication.
- Arabic is optional in MVP.
- Brand names are searchable in every available locale.

## 3.4 `product_markets`

Purpose:

Stores country-specific product availability and structured pharmaceutical information.

| Field | Requirement |
|---|---|
| `id` | UUID primary key. |
| `product_id` | Required foreign key to `products.id`. |
| `country_id` | Required foreign key to `countries.id`. |
| `strength` | Required text. |
| `dosage_form` | Required text. |
| `route` | Required text. |
| `pack_size` | Required text. |
| `market_status` | Required: `draft`, `available`, `unavailable`, or `archived`. |
| `created_at` | Required timestamp. |
| `updated_at` | Required timestamp. |

Required constraints:

- Unique `(product_id, country_id)`.
- Iraq market data must exist and be `available` before MVP publication.
- A market cannot be `available` when the parent product is archived.

Required indexes:

- `(country_id, market_status)`
- `(product_id, market_status)`

## 3.5 `product_market_translations`

Purpose:

Stores localized country-specific pharmaceutical and clinical content.

| Field | Requirement |
|---|---|
| `id` | UUID primary key. |
| `product_market_id` | Required foreign key to `product_markets.id`. |
| `locale` | Required: `en` or `ar`. |
| `storage_conditions` | Required text. |
| `approved_indications` | Required text. |
| `usual_adult_dose` | Required text. |
| `contraindications` | Required text. |
| `common_adverse_effects` | Required text. |
| `created_at` | Required timestamp. |
| `updated_at` | Required timestamp. |

Required constraints:

- Unique `(product_market_id, locale)`.
- English is required before publication.
- Arabic is optional in MVP.
- Content is informational and must be displayed with the platform medical-information disclaimer.

## 3.6 `product_specialties`

Purpose:

Links products to specialties for filtering and discovery.

| Field | Requirement |
|---|---|
| `id` | UUID primary key. |
| `product_id` | Required foreign key to `products.id`. |
| `specialty_id` | Required foreign key to `specialties.id`. |
| `created_by` | Required foreign key to `profiles.id`. |
| `created_at` | Required timestamp. |

Required constraints:

- Unique `(product_id, specialty_id)`.
- At least one specialty is required before publication.
- Only active specialties may be assigned.
- Write access is inherited from permission to manage the parent product.
- Public or professional visibility is inherited from the parent product; the relationship is never independently public.

Required indexes:

- `(specialty_id, product_id)`
- `product_id`

## 3.7 `product_media`

Purpose:

Stores product and package-image metadata.

| Field | Requirement |
|---|---|
| `id` | UUID primary key. |
| `product_id` | Required foreign key to `products.id`. |
| `media_type` | Required: `product_image` or `package_image`. |
| `storage_path` | Required private ownership path in the relevant bucket. |
| `mime_type` | Required. |
| `file_size_bytes` | Required. |
| `sort_order` | Required integer, default `0`. |
| `is_primary` | Required boolean, default `false`. |
| `uploaded_by` | Required foreign key to `profiles.id`. |
| `created_at` | Required timestamp. |
| `updated_at` | Required timestamp. |

Required constraints:

- At least one product image and one package image are required before publication.
- Only one primary item is permitted per product and media type.
- Storage ownership and read visibility are inherited from the parent product.

## 3.8 `product_brochures`

Purpose:

Stores brochure metadata and localized brochure versions.

| Field | Requirement |
|---|---|
| `id` | UUID primary key. |
| `product_market_id` | Required foreign key to `product_markets.id`. |
| `locale` | Required: `en` or `ar`. |
| `title` | Required text. |
| `storage_path` | Required path in the private brochures bucket. |
| `mime_type` | Required and limited to PDF. |
| `file_size_bytes` | Required. |
| `version` | Required positive integer. |
| `is_current` | Required boolean. |
| `uploaded_by` | Required foreign key to `profiles.id`. |
| `created_at` | Required timestamp. |
| `updated_at` | Required timestamp. |

Required constraints:

- Only one current brochure per product market and locale.
- At least one current brochure is required before publication.
- Brochures are not public storage objects.
- Download authorization is checked before issuing a signed URL.
- Previous versions are retained for audit history but are not presented as current.

## 3.9 `product_search_keywords`

Purpose:

Stores system-generated normalized search terms, aliases, and transliterations.

| Field | Requirement |
|---|---|
| `id` | UUID primary key. |
| `product_id` | Required foreign key to `products.id`. |
| `locale` | Required: `en`, `ar`, or `und` for language-independent terms. |
| `keyword` | Required original keyword. |
| `normalized_keyword` | Required normalized keyword used for search. |
| `keyword_type` | Required: `brand`, `generic`, `company`, `drug_class`, `alias`, or `transliteration`. |
| `created_at` | Required timestamp. |

Required constraints:

- Unique `(product_id, locale, normalized_keyword, keyword_type)`.
- Clients cannot insert, update, or delete keyword rows.
- Rows are generated by trusted backend logic after relevant product, company, generic-drug, drug-class, or translation changes.
- Search results must still apply product visibility rules; keyword existence never grants access to a product.

Required normalization:

- Case folding for English.
- Whitespace and punctuation normalization.
- Arabic diacritic removal.
- Arabic letter-form normalization.
- Preservation of the original display value.
- Explicit transliteration aliases where approved.

---

# 4. Product Publication Requirements

A product is publishable only when all of the following are true:

- Parent company status is `verified`.
- Product category, drug class, and applicable generic drug are valid.
- An English `product_translations` record exists.
- At least one active specialty is assigned.
- An Iraq `product_markets` record exists with `market_status = available`.
- An English `product_market_translations` record exists for Iraq.
- At least one product image exists.
- At least one package image exists.
- At least one current PDF brochure exists for Iraq.
- All required pharmaceutical and clinical fields are non-empty.
- The acting user is an active `company_admin` or `product_manager` for the owning company.

Publication does not require per-product administrator approval.

---

# 5. Product Lifecycle

## 5.1 Product states

| State | Meaning | Public/professional visibility |
|---|---|---|
| `draft` | Company-owned work in progress. | Not visible outside authorized company users and administrators. |
| `published` | Company-published product satisfying all publication requirements. | Visible to approved healthcare professionals and authorized platform/company users. |
| `hidden` | Product removed from discovery by an administrator for governance or safety reasons. | Not visible to healthcare professionals. |
| `archived` | Retired product retained for history. | Not visible to healthcare professionals. |

The term `approved product` must not be used. The correct public state is `published`.

## 5.2 Allowed transitions

| From | To | Authorized actor | Conditions |
|---|---|---|---|
| New | `draft` | Company admin or product manager | Product belongs to actor’s active company. |
| `draft` | `published` | Company admin or product manager | All publication requirements pass and company is verified. |
| `published` | `draft` | Company admin or product manager | Used when voluntarily withdrawing for editing. |
| `published` | `hidden` | Admin or super admin | `hidden_reason` is mandatory. |
| `draft` | `hidden` | Admin or super admin | Used for governance intervention. |
| `hidden` | `published` | Admin or super admin | Product still satisfies publication requirements. |
| `hidden` | `draft` | Admin or super admin | Product requires company correction before republication. |
| `draft` | `archived` | Company admin, product manager, admin, or super admin | Archive metadata is recorded. |
| `published` | `archived` | Company admin, product manager, admin, or super admin | Archive metadata is recorded. |
| `hidden` | `archived` | Admin or super admin | Archive metadata is recorded. |

`archived` is terminal in MVP. Restoration requires an administrator-approved architecture or governance procedure and is not an ordinary client action.

## 5.3 Lifecycle effects

When a product becomes `hidden` or `archived`:

- It is removed from search and generic landing-page counts.
- It is removed from company public product portfolios.
- New favorites are prohibited.
- Existing favorites remain stored but do not appear in active favorite lists.
- New brochure signed URLs are prohibited.
- Active campaigns targeting the product immediately become ineligible for delivery.
- Existing analytics and audit records are retained.
- Company users may still view the record according to the permission matrix.

When a company becomes `suspended` or `archived`:

- Its products are treated as non-public regardless of individual product status.
- Product records are retained.
- Campaign delivery stops.
- Company users lose write access while suspension is active.

Every lifecycle transition must create an immutable audit record.

---

# 6. Favorites Architecture

## 6.1 `favorite_products`

| Field | Requirement |
|---|---|
| `id` | UUID primary key. |
| `healthcare_professional_id` | Required foreign key to `healthcare_professionals.id`. |
| `product_id` | Required foreign key to `products.id`. |
| `created_at` | Required timestamp. |

Required constraints:

- Unique `(healthcare_professional_id, product_id)`.
- Only approved, active healthcare professionals may create favorites.
- Only currently visible published products may be favorited.
- Insert is idempotent from the application perspective.
- The owner may delete the favorite.
- Favorite rows are never readable by companies.

## 6.2 `favorite_companies`

| Field | Requirement |
|---|---|
| `id` | UUID primary key. |
| `healthcare_professional_id` | Required foreign key to `healthcare_professionals.id`. |
| `company_id` | Required foreign key to `companies.id`. |
| `created_at` | Required timestamp. |

Required constraints:

- Unique `(healthcare_professional_id, company_id)`.
- Only approved, active healthcare professionals may create favorites.
- Only verified, publicly visible companies may be favorited.
- Insert is idempotent from the application perspective.
- The owner may delete the favorite.
- Favorite rows are never readable by companies.

## 6.3 Favorite visibility and analytics

- A favorite remains stored if its target becomes hidden, archived, suspended, or unavailable.
- Inactive targets are omitted from the normal favorites list.
- The user may still remove a favorite whose target is inactive.
- Companies may receive only aggregated favorite counts.
- No company response may expose favorite-owner identity or individual activity.
- Aggregates must suppress any demographic breakdown with fewer than ten distinct healthcare professionals.

---

# 7. Company Invitation and Membership Workflow

## 7.1 `company_invitations`

Purpose:

Represents an invitation to join one company with one company role.

| Field | Requirement |
|---|---|
| `id` | UUID primary key. |
| `company_id` | Required foreign key to `companies.id`. |
| `email` | Required normalized lowercase email. |
| `company_role` | Required company role. |
| `status` | Required: `pending`, `accepted`, `declined`, `cancelled`, or `expired`. |
| `token_hash` | Required secure hash; the raw token is never stored. |
| `invited_by` | Required foreign key to `profiles.id`. |
| `expires_at` | Required timestamp. |
| `accepted_by` | Nullable foreign key to `profiles.id`. |
| `accepted_at` | Nullable timestamp. |
| `cancelled_by` | Nullable foreign key to `profiles.id`. |
| `cancelled_at` | Nullable timestamp. |
| `created_at` | Required timestamp. |
| `updated_at` | Required timestamp. |

Required constraints:

- Only one pending invitation may exist for the same company and normalized email.
- Expiration is seven calendar days after creation.
- An accepted, declined, cancelled, or expired invitation cannot be reused.
- The invitation company and role cannot change after creation.
- Raw invitation tokens must not be persisted.

## 7.2 Invitation creation

An invitation may be created only when:

- The inviter is an active `company_admin`.
- The inviter belongs to the target company.
- The company is `verified`.
- The invited role is a company role, never a platform admin role.
- The target email is not already an active member of another company.
- The target company has not exceeded its active-user entitlement.
- No pending duplicate invitation exists.

Company admins may invite any company role, including another `company_admin`.

Invitation creation is audited.

## 7.3 Invitation acceptance

Acceptance is a trusted backend operation:

1. Validate the invitation token hash, status, and expiration.
2. Require an authenticated Supabase user whose verified email matches the invitation email.
3. Ensure that the profile is not an admin, super admin, healthcare professional, or member of another company.
4. Create or confirm a `profiles` record with platform role `company_user`.
5. Create one active `company_users` membership using the invitation company and role.
6. Mark the invitation `accepted`.
7. Record `accepted_by` and `accepted_at`.
8. Create audit records for invitation acceptance and membership creation.

The client cannot directly assign `profiles.role`, `company_users.company_id`, or `company_users.company_role`.

## 7.4 Initial company administrator

The first company administrator is assigned only after an administrator verifies a company application.

The verification operation must:

1. Set the company status to `verified`.
2. Assign the verified applicant profile the platform role `company_user`.
3. Create an active `company_users` membership with role `company_admin`.
4. Record the verifying administrator and timestamp.
5. Create an audit record.

The applicant cannot self-create the initial company-admin membership.

## 7.5 Membership changes

- Only an active company admin may change roles or deactivate members in the same company.
- A company admin cannot modify their own role or deactivate themselves when they are the last active company admin.
- At least one active company admin must remain.
- Deactivation sets `company_users.is_active = false`; it is not a hard delete.
- A deactivated user immediately loses company-data access.
- Reactivation and role changes are audited.
- A profile may have only one company membership in MVP, whether active or inactive, unless an administrator formally transfers it.
- Company transfer is not an MVP self-service workflow.

---

# 8. Campaign Target Model

## 8.1 Campaign decision

A campaign owns scheduling and audience targeting. A campaign target identifies the content being promoted.

MVP campaign types:

- `featured_product`
- `featured_company`

Post-MVP campaign types:

- `banner_campaign`
- `sponsored_event`

## 8.2 Required additions to `campaigns`

The existing `campaigns` table must additionally contain:

| Field | Requirement |
|---|---|
| `created_by` | Required foreign key to `profiles.id`. |
| `approved_by` | Nullable foreign key to `profiles.id`. |
| `approved_at` | Nullable timestamp. |
| `status_reason` | Nullable text. |
| `priority` | Required integer used for deterministic ordering. |
| `placement` | Required placement identifier; MVP value is `search`. |
| `updated_at` | Required timestamp. |

Campaign status values remain:

- `draft`
- `active`
- `paused`
- `completed`
- `archived`

Only administrators or super administrators may transition a campaign into `active`.

## 8.3 `campaign_targets`

| Field | Requirement |
|---|---|
| `id` | UUID primary key. |
| `campaign_id` | Required foreign key to `campaigns.id`. |
| `target_type` | Required: `product`, `company`, `event`, or `banner`. |
| `product_id` | Nullable foreign key to `products.id`. |
| `company_id` | Nullable foreign key to `companies.id`. |
| `event_id` | Nullable foreign key to `events.id`. |
| `banner_asset_path` | Nullable storage path. |
| `destination_url` | Nullable validated URL; used only for banner targets. |
| `created_at` | Required timestamp. |
| `updated_at` | Required timestamp. |

Required constraints:

- Exactly one target reference is populated.
- The populated reference must match `target_type`.
- Unique `campaign_id`; one target per campaign in MVP.
- A `featured_product` campaign requires `target_type = product`.
- A `featured_company` campaign requires `target_type = company`.
- A `sponsored_event` campaign requires `target_type = event`.
- A `banner_campaign` requires `target_type = banner`.
- Product and event targets must belong to the campaign’s company.
- A company target must equal the campaign’s company.

## 8.4 Campaign eligibility

A campaign may be delivered only when:

- Campaign status is `active`.
- Current UTC time is within `start_date` and `end_date`.
- Campaign company is verified.
- Country, city, and specialty targeting match the requesting user.
- Target content is visible and eligible.
- Product targets are `published` and available in Iraq.
- Company targets are verified and public.
- The campaign has been approved by an administrator or super administrator.

If a target becomes ineligible, the campaign remains stored but is excluded from delivery.

## 8.5 Sponsored search ranking

Search responses must return sponsored and organic sections separately.

Sponsored selection order:

1. Eligible campaigns matching the search query and filters.
2. Higher `priority`.
3. Earlier `start_date`.
4. Stable campaign UUID ordering as final tie-breaker.

Rules:

- Maximum three sponsored results per search response.
- Every sponsored result must include a sponsored label.
- A target shown as sponsored must not be duplicated in the organic section.
- Organic relevance is not altered by campaign priority.
- Sponsored impressions and clicks must be recorded as analytics events.

---

# 9. Permission Matrix

## 9.1 Access-state decision

Anonymous users do not have access to the product catalog, company profiles, brochures, favorites, campaigns, or events.

Anonymous access is limited to:

- Authentication screens.
- Password recovery.
- Public legal documents.
- Active country, city, and specialty lookup data needed for registration.

Registered users with pending, rejected, documents-requested, suspended, or archived status do not receive healthcare-professional catalog access.

Only an active healthcare professional with `verification_status = approved` receives the professional discovery experience.

## 9.2 Platform access matrix

Legend:

- `R` — Read.
- `C` — Create.
- `U` — Update.
- `T` — Authorized lifecycle transition.
- `D` — Hard delete where explicitly allowed.
- `—` — No access.

| Resource/action | Anonymous | Pending HCP | Approved HCP | Company user | Admin | Super admin |
|---|---:|---:|---:|---:|---:|---:|
| Registration lookups | R | R | R | R | R | R |
| Own profile | — | R/U safe fields | R/U safe fields | R/U safe fields | R/U | R/U |
| Verified public companies | — | — | R | R | R | R |
| Published products | — | — | R | R | R | R |
| Own company drafts/hidden/archived products | — | — | — | Role-dependent R | R | R |
| Brochure download | — | — | R | Own-company R | R | R |
| Product favorites | — | — | C/R/D own | — | R for governance only | R |
| Company favorites | — | — | C/R/D own | — | R for governance only | R |
| Reports | — | — | C/R own | C/R own | R/U | R/U |
| Company invitations | — | — | — | Role-dependent | R | R |
| Campaign management | — | — | — | Role-dependent | R/U/T | R/U/T |
| Raw analytics events | — | — | — | — | R | R |
| Aggregated company analytics | — | — | — | Role-dependent own company | R | R |
| Audit logs | — | — | — | — | R | R |

Safe profile fields exclude:

- Platform role.
- Account status.
- Authentication-user linkage.
- Verification decisions.
- Administrative metadata.

## 9.3 Company-role matrix

| Capability | Company admin | Marketing manager | Product manager | Representative | Viewer |
|---|---:|---:|---:|---:|---:|
| View own company profile | Yes | Yes | Yes | Yes | Yes |
| Edit company profile | Yes | Yes | No | No | No |
| Manage social links | Yes | Yes | No | No | No |
| View all own-company products | Yes | Yes | Yes | Published only | Published only |
| Create and edit product drafts | Yes | No | Yes | No | No |
| Publish or withdraw products | Yes | No | Yes | No | No |
| Archive products | Yes | No | Yes | No | No |
| Override administrator-hidden status | No | No | No | No | No |
| Upload product images and brochures | Yes | No | Yes | No | No |
| Create and edit campaign drafts | Yes | Yes | No | No | No |
| Activate campaigns | No | No | No | No | No |
| Pause own active campaigns | Yes | Yes | No | No | No |
| View aggregated company analytics | Yes | Yes | No | No | No |
| Invite company users | Yes | No | No | No | No |
| Change company roles | Yes | No | No | No | No |
| Deactivate company users | Yes | No | No | No | No |

Representative product assignments are not part of MVP. Representatives receive read-only access to their company’s published products only.

## 9.4 Product RLS requirements

Product read access must enforce all of the following:

- Approved healthcare professionals may read only published products of verified companies available in Iraq.
- Company users may read records belonging to their active company according to company role.
- Admins and super admins may read all product states.
- Product relationships, media metadata, brochures, translations, and keywords inherit parent-product visibility.

Product write access must enforce:

- Company ownership through active `company_users` membership.
- Company role of `company_admin` or `product_manager`.
- Verified company status for publication.
- Immutable `company_id`.
- No client modification of moderation actor/timestamp fields.
- Lifecycle transitions through trusted operations.

## 9.5 Favorites RLS requirements

- The authenticated profile must map to `healthcare_professional_id`.
- Owners can read and delete only their own rows.
- Owners can insert only their own identifier.
- The target must satisfy current visibility rules at insertion.
- Companies have no raw access.

## 9.6 Invitation RLS requirements

- Company admins may read invitations for their own company.
- Company admins may request creation and cancellation for their own company.
- Invitees may read only the minimum invitation details required for acceptance after token validation.
- Invitation acceptance is a trusted operation.
- Company membership insertion and role assignment are prohibited through direct client writes.

## 9.7 Campaign RLS requirements

- Company admins and marketing managers may manage campaign drafts belonging to their company.
- Company users cannot set `approved_by`, `approved_at`, or directly set status to `active`.
- Admins and super admins may approve, activate, pause, complete, or archive campaigns.
- Approved healthcare professionals receive only eligible campaign results through the sponsored-search query, not unrestricted campaign-table access.
- Campaign target writes require ownership validation against the campaign company.

---

# 10. MVP Scope Matrix

## 10.1 MVP clients

| Client | MVP decision |
|---|---|
| Flutter mobile app | Required for healthcare professionals and company users. |
| Flutter admin web app | Required for admins and super admins. |
| Dedicated company web portal | Post-MVP. |

Company profile, product, team, and campaign management are provided to company users through the mobile app in MVP.

## 10.2 Feature scope

| Capability | MVP classification | Closure decision |
|---|---|---|
| Email/password authentication | Required | Includes verification, reset, session recovery, and sign-out. |
| Healthcare-professional onboarding | Required | Includes profile, specialty, geography, and verification status. |
| Healthcare-professional verification | Required | Admin approval, rejection, and document-request workflow. |
| Company application and verification | Required | Includes initial company-admin bootstrap. |
| Company invitations and membership | Required | Includes invitation, acceptance, role changes, and deactivation. |
| Company profiles | Required | English public content is required; Arabic content is optional. |
| Product taxonomy | Required | Admin-managed drug classes, generic drugs, and specialties. |
| Product management | Required | Draft, publish, withdraw, hide, and archive lifecycle. |
| Product localization | Required | English content is required before publication; Arabic content is optional in MVP. |
| Iraq product market | Required | Every published MVP product must be available in Iraq. |
| Multi-country expansion | Post-MVP | Launch scope is Iraq only; the schema remains expansion-ready. |
| Product search | Required | Brand, generic, company, drug class, and specialty. |
| Generic landing pages | Required | Product and company counts include only visible products. |
| Product and company favorites | Required | Approved healthcare professionals only. |
| Brochure downloads | Required | Authorized signed downloads and download analytics. |
| Reporting | Required | Product and company reporting with admin resolution. |
| Sponsored search | Required | Maximum three labeled featured products or companies. |
| Campaign management | Required, limited | Featured product and featured company campaigns only. |
| Banner campaigns | Post-MVP | Schema-reserved. |
| Sponsored events | Post-MVP | Schema-reserved. |
| Events and registrations | Post-MVP | Existing schema remains reserved; no MVP UI or workflow. |
| Company analytics dashboard | Post-MVP | MVP records required product, brochure, favorite, sponsored-impression, and sponsored-click events only. |
| Subscription plans and enforcement | Post-MVP | Campaign approval is managed administratively in MVP. |
| Online payments | Excluded | No MVP payment processing. |
| In-app notifications | Post-MVP | Status is shown through relevant screens in MVP. |
| Push notifications | Post-MVP | Not included. |
| Representative assignments | Post-MVP | Representatives have read-only published-product access. |
| Messaging, forums, telemedicine, e-prescribing, online pharmacy | Excluded | No implementation. |
| AI recommendations or assistant | Excluded | No implementation. |

## 10.3 MVP administration

The admin web application must include:

- Healthcare-professional verification.
- Company verification and initial-admin activation.
- Company suspension and archival.
- Product hiding, unhiding, and archival.
- Drug-class, generic-drug, and specialty management.
- Report review and resolution.
- Campaign review, approval, activation, pausing, completion, and archival.
- User suspension.
- Audit-log access.

Subscription management, event management, and platform analytics dashboards are not MVP requirements.

## 10.4 MVP discovery access

- Product and company discovery requires authentication and approved healthcare-professional status.
- Company users may view published catalog content and their authorized company workspace.
- There is no anonymous catalog.
- Sponsored content is shown only to approved healthcare professionals.
- Search and generic landing-page counts exclude draft, hidden, archived, unavailable, and suspended-company products.

---

# 11. Implementation Preconditions

Flutter development and Supabase migration implementation may begin only after the implementation team accepts this document as the governing baseline.

The first implementation phases must follow this dependency order:

1. Identity, roles, profiles, and trusted authorization helpers.
2. Healthcare-professional and company verification.
3. Company membership and invitation workflow.
4. Product taxonomy.
5. Product schema, localization, storage metadata, and lifecycle.
6. Product discovery and search-keyword generation.
7. Favorites and reporting.
8. Campaign targets and sponsored search.
9. Admin governance workflows.
10. Security, privacy, RTL, integration, and release verification.

No product search implementation may begin before the product schema and lifecycle policies exist.

No company invitation UI may begin before trusted invitation acceptance and membership constraints exist.

No sponsored search implementation may begin before campaign target ownership and eligibility rules exist.

---

# 12. Closure Decisions Summary

The following decisions are final:

- Products are canonical company-owned records with country-specific market records.
- Iraq is the only active product market required for MVP.
- Launch scope is Iraq only; multi-country expansion is future.
- English product content is mandatory before publication; Arabic content is optional in MVP.
- Product states are `draft`, `published`, `hidden`, and `archived`.
- There is no product approval state and no per-product administrator approval.
- Administrators may moderate products without editing company-authored clinical content.
- Product and company favorites belong only to approved healthcare professionals.
- Companies never receive raw favorite records.
- Company users join through a secure invitation or initial-admin verification workflow.
- Clients cannot assign platform roles, company ownership, or company roles directly.
- Campaign targets use typed foreign keys and exactly one target per campaign in MVP.
- MVP campaigns support featured products and featured companies only.
- Sponsored search is part of MVP and is limited to three clearly labeled results.
- Anonymous users cannot access the catalog.
- Company management is delivered through the Flutter mobile app in MVP.
- Events, subscriptions, company analytics dashboards, notifications, and the dedicated company portal are post-MVP.
- This document overrides conflicting product, permission, workflow, and MVP statements in earlier documentation.

---

End of Document
