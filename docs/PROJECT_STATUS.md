# PharmaConnect / Pharamty Project Status

Last canonical update: Phase 6D.3A5

## Identity and environment

| Item | Current state |
|---|---|
| Public brand | Pharamty |
| Technical/internal name | PharmaConnect |
| Backend demo project | PharmaConnect Demo |
| Supabase project reference | `oymnmcqzxmnshsknrgam` |
| Current branch | `feature/pharamty-company-catalog-ui` |
| Current phase | Phase 6D.3A5 Pharamty company catalog UI |
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

Phase 6D.3A2 through Phase 6D.3A4 are merged and verified. Phase 6D.3A5 applies
the shared Pharamty visual identity to the company catalog home, product
workflow cards, create/edit surfaces, lifecycle states, completion indicators,
and responsive mobile/web layouts while preserving company access, mutation,
readiness, and publication-separation behavior.

Phase 6D.3A5 remains open until scoped validation, preview, GitHub Actions, and
the separate diff review are complete. GitHub Actions remains the authoritative
cloud validation environment. The scoped local formatter, analyzer, company
catalog widget tests, mobile access-routing tests, and whitespace checks pass.

Docker is not required for ordinary UI work. Normal UI validation must not run
Supabase, migrations, seeds, or database services.

The next planned feature phase will be selected after Phase 6D.3A5 closes.

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
| Pharamty company catalog UI | In progress |
| Phase 6D.3A5 GitHub Actions validation | In progress |
| Scoped local Flutter validation | Verified |
| Pull Request merge | Blocked — user approval required |

Status vocabulary: **Not started**, **In progress**, **Verified**, **Blocked**.
