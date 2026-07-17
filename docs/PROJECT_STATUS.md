# PharmaConnect / Pharamty Project Status

Last canonical update: Phase OPS-1

## Identity and environment

| Item | Current state |
|---|---|
| Public brand | Pharamty |
| Technical/internal name | PharmaConnect |
| Backend demo project | PharmaConnect Demo |
| Supabase project reference | `oymnmcqzxmnshsknrgam` |
| Current branch | `feature/pharamty-design-system` |
| Current phase | Phase OPS-1 and Phase 6D.3A2 cloud validation |
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

## Active UI work

Phase 6D.3A2 is implemented but remains open until GitHub Actions validation is
green. The local machine is not the primary validation environment because
repeated Dart and Flutter commands have timed out without diagnostics.

Docker is not required for ordinary UI work. Normal UI validation must not run
Supabase, migrations, seeds, or database services.

The next planned feature phase is Pharamty authentication and shared states.

## Compact checklist

| Work item | Status |
|---|---|
| Cloud backend migrations and RLS | Verified |
| Demo accounts and catalog data | Verified |
| Mobile and admin web scaffolds | Verified |
| Phase 6D.3A2 design foundation implementation | In progress |
| GitHub Actions authoritative validation | In progress |
| Pharamty authentication and shared states | Not started |
| Local Flutter validation | Blocked |
| Pull Request merge | Blocked — user approval required |

Status vocabulary: **Not started**, **In progress**, **Verified**, **Blocked**.
