# PharmaConnect Repository Operating Contract

## Product identity

- Public brand: **Pharamty**
- Technical/internal name: **PharmaConnect**
- Keep repository names, folders, Dart packages, imports, class names, bundle
  identifiers, URL schemes, Supabase names, and other technical identifiers
  unchanged unless a dedicated rename phase is explicitly approved.

## Product purpose

Pharamty is an Iraq-focused professional pharmaceutical information platform.
Its official catalog allows approved healthcare professionals to search
official published products by:

- brand or trade name;
- generic or scientific name;
- company.

## Strict MVP exclusions

The MVP is not a pharmacy, ecommerce system, distributor platform,
sales-office tracker, stock or availability service, pricing platform,
ordering or delivery system, supply-chain system, or medical-device catalog.

## Source-of-truth hierarchy

1. `ARCHITECTURE_CLOSURE.md`
2. `docs/PROJECT_STATUS.md`
3. Committed repository and runtime evidence
4. The approved task-specific prompt
5. Previous reports and chat history

## Communication

- Report in English only.
- Keep ordinary UI reports short.
- Use detailed reports for database, security, Auth, deployment, and
  architecture work.

## Git policy

- Do not implement ordinary feature work directly on `main`.
- Use one scoped feature branch per coherent task.
- Commit and push a feature branch only when the task explicitly permits it.
- Open a Pull Request for review.
- Never merge to `main` without explicit user approval.
- Never force-push unless explicitly approved.
- Never delete remote branches without approval.

## Validation policy

Ordinary UI work follows:

`Inspect → Implement → Validate → Preview/Artifacts → Report`

Sensitive work follows:

`Audit → Approval → Implement → Verify`

Prefer targeted validation. Use full-workspace validation only when a change
affects shared routing, workspace configuration, or architecture. Never claim
that a command passed unless it completed successfully.

## Security rules

- Never commit secrets.
- Never print service-role keys.
- Never place database passwords or tokens in reports.
- Frontend builds may use only the public Supabase URL and publishable/anon key.
- Do not change a cloud database without explicit approval.
- Do not deploy to production without explicit approval.

## Design identity

- Formal clinical dark interface
- Graphite-grey background and layered grey surfaces
- Clinical blue interactive accents
- High-contrast typography
- Restrained borders and elevation
- No ecommerce or pharmacy-store appearance
- Green only for approved, success, and published states
- Amber for pending, review, and action-required states
- Red for errors, rejection, and destructive states

## Quality rules

- Preserve business logic while restyling.
- Do not combine unrelated refactors with UI work.
- Do not duplicate design tokens.
- Do not add text below 11px.
- Preserve accessibility and responsive layouts.
- Keep official catalog publication separate from company-page publication.
