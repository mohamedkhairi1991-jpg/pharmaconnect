# PharmaConnect / Pharamty Project Status

Last canonical update: Secure catalog media foundation

## Identity and environment

| Item | Current state |
|---|---|
| Public brand | Pharamty |
| Technical/internal name | PharmaConnect |
| Backend demo project | PharmaConnect Demo |
| Supabase project reference | `oymnmcqzxmnshsknrgam` |
| Current branch | `feature/secure-catalog-media-foundation` |
| Current phase | Secure private storage foundation for official catalog media |
| Merge status | No merge approved |

Technical identifiers remain PharmaConnect unless a dedicated rename phase is
explicitly approved.

## Verified backend and demo state

- Backend migrations: 30/30 applied
- Application tables: 24/24 with Row Level Security enabled
- Demo users: doctor, company admin, and platform admin
- Demo seed: executed and verified
- Published official product: Cardiostead 5 mg
- Workflow draft product: Airvento 100 mcg
- Mobile web scaffold: committed
- Admin web scaffold: committed

The demo environment uses fake, non-production data. It must not contain real
doctor, company, patient, credential, or commercial information.

## Active work

The doctor, company, and admin catalog UI phases are merged and verified. The
complete company submission, admin review, request-changes, resubmission,
publication, and doctor discovery cycle has also been verified against the
non-production demo environment.

The active phase adds private Supabase Storage buckets and least-privilege
object policies for official product images, package images, and PDF brochure
files. It does not yet add upload UI or enforce media as a publication
requirement. Publication enforcement must follow only after the upload and
review workflows are usable and validated.

Docker is not required for ordinary UI work. Normal UI validation must not run
Supabase, migrations, seeds, or database services.

The next planned feature phase will be selected after Phase 6D.3A6 closes.

## Compact checklist

| Work item | Status |
|---|---|
| Cloud backend migrations and RLS | Verified |
| Demo accounts and catalog data | Verified |
| Mobile and admin web scaffolds | Verified |
| Phase 6D.3A2 design foundation implementation | Verified |
| Phase 6D.3A2 GitHub Actions validation | Verified |
| Pharamty authentication and shared states | Verified |
| Phase 6D.3A3 GitHub Actions validation | Verified |
| Pharamty doctor catalog UI | Verified |
| Phase 6D.3A4 GitHub Actions validation | Verified |
| Pharamty company catalog UI | Verified |
| Phase 6D.3A5 GitHub Actions validation | Verified |
| Pharamty admin catalog review UI | Verified |
| Phase 6D.3A6 GitHub Actions validation | Verified |
| End-to-end official catalog lifecycle | Verified |
| Secure catalog storage foundation | In progress |
| Scoped local Flutter validation | Verified |
| Pull Request merge | Blocked — user approval required |

Status vocabulary: **Not started**, **In progress**, **Verified**, **Blocked**.
