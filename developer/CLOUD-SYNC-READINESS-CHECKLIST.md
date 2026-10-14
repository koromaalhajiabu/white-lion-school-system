# White Lion School — next-step readiness checklist

This checklist is for the repository branch `safe-cloud-sync-readiness`. It is not evidence that the live Supabase project has been changed.

## Current boundary

- The live portal is still localStorage-first.
- The browser must not upload, overwrite, or delete school records automatically.
- The existing Supabase publishable key may be used in browser code; a service-role/secret key must never be placed in HTML, JavaScript, or GitHub.
- Do not merge this preparation branch or announce cloud sync as active until the checks below pass.

## Repository work completed in this branch

- Read-only SQL audits for schema, constraints, RLS policies, grants, and record counts.
- A developer-only access draft, clearly separated from a complete school-user role model.
- A browser connection-check page for developer sign-in and table read permissions.
- A proposed public-table reset script. It is destructive, has not been executed, and is not needed merely to prove that the existing tables are empty.
- This implementation plan and safety checklist.

## Remaining gates

### Gate A — verify the actual database

- [ ] Confirm the selected project is `white-lion-school-cloud` (`homvrbxfwacopbnhujyg`), never the separate White Lion Tech Solutions project.
- [ ] Run the read-only schema/constraints/access audit and review actual output.
- [ ] Confirm exact row counts and primary-key/unique constraints.
- [ ] Confirm developer authorization and the intended access policy for each table.
- [ ] Keep Auth users, developer authorization records, and storage objects intact unless there is a separate, explicit requirement to change them.

### Gate B — define school roles before general access

- [ ] Decide the roles needed: school administrator, teacher, accounts/fees clerk, attendance operator, and read-only viewer as appropriate.
- [ ] Define which school each account belongs to and enforce school-level isolation in PostgreSQL RLS.
- [ ] Avoid using a developer-only policy as the permanent school authorization model.
- [ ] Test unauthorized reads and writes using non-developer test accounts.

### Gate C — map the local data safely

Local browser keys currently documented:
- `wlt_students`
- `wlt_attendance_v2`
- `wlt_grades`
- `wlt_fees`
- `wlt_settings`
- `wlt_notices`

Known cloud tables:
- `public.wl_students`
- `public.wl_attendance`
- `public.wl_grades`
- `public.wl_fees`

- [ ] Compare every field and type before mapping.
- [ ] Decide how local IDs map to cloud IDs without breaking attendance, grades, or fees references.
- [ ] Decide deliberately whether settings and notices should remain device-local or receive cloud tables.
- [ ] Never assume the current local seed records and cloud records are the same dataset.

### Gate D — implement and test synchronisation

- [ ] Take and verify a JSON backup before any import or migration.
- [ ] Preview source counts, destination counts, and field mapping before an upload.
- [ ] Require an explicit confirmation before the first upload.
- [ ] Make retries idempotent; repeated sync must not duplicate records.
- [ ] Preserve offline editing and queue changes until a connection is available.
- [ ] Detect conflicts and stop/report them instead of silently overwriting either copy.
- [ ] Test empty cloud, duplicate IDs, interrupted requests, offline edits, reconnect, and access denied.
- [ ] Keep the existing live portal unchanged until these tests pass.

## Destructive reset note

The file `developer/sql/empty-all-public-tables.sql` is a proposed destructive script, not a completed action. It targets ordinary tables in the `public` schema and may cascade to related public tables. It does not empty every object in every Supabase schema. Review the target project and backup requirements before any execution.

## Honest status

Preparing SQL or HTML files in GitHub does not execute SQL in Supabase and does not deploy a new school portal. Cloud sync remains inactive until the database checks, implementation, tests, and deployment are completed.
