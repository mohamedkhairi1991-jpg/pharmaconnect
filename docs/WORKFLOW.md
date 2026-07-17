# PharmaConnect Development Workflow

## Ordinary feature workflow

1. Create a scoped feature branch.
2. Inspect the affected files and current repository status.
3. Implement one coherent feature group.
4. Run targeted local validation when practical.
5. Push the feature branch.
6. Open a Pull Request targeting `main`.
7. Run authoritative cloud validation.
8. Perform a separate review of the complete diff.
9. Produce screenshots, artifacts, or a preview URL where applicable.
10. Obtain explicit user approval.
11. Merge only after approval.

Do not combine unrelated refactors, database work, or deployment changes with
ordinary UI work.

## Sensitive workflow

Database, Auth, security, deployment, architecture, and production operations
follow:

1. Read-only audit.
2. Explicit approval.
3. Controlled implementation.
4. Independent verification.
5. Separate merge or deployment approval.

## Logical roles

### Implementer

The implementer confirms scope, makes the smallest coherent change, preserves
business logic, and records targeted validation evidence.

### Reviewer

The reviewer inspects the complete diff for correctness, security,
accessibility, scope, and architecture alignment. The reviewer must not
silently expand implementation scope.

### Validator

The validator runs only the approved checks and reports exact command results.
A timed-out, cancelled, skipped, or incomplete command is not a pass.

One person or agent may perform multiple roles, but implementation, review, and
validation must remain logically separate passes.

## Validation principles

- Prefer feature-level formatting, analysis, and tests.
- Use the scripts in `tool/` for repeatable UI validation.
- Do not run Docker, Supabase, migrations, or seeds for ordinary UI changes.
- Do not upgrade dependencies as part of validation.
- Use full-workspace checks only for shared routing, workspace configuration,
  or architectural changes.
- GitHub Actions is authoritative when the local environment cannot complete
  Flutter validation.

## Short report format

1. What changed
2. Files changed
3. Validation
4. Preview or artifacts
5. Risks
6. Branch and Pull Request status

Database, security, Auth, architecture, and deployment work may require a more
detailed report.
