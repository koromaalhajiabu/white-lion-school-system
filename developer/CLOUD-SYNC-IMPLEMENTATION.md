# White Lion cloud sync implementation plan

Project: `white-lion-school-cloud` (`homvrbxfwacopbnhujyg`)

## Current verified state

- The school portal in `professional/index.html` is a localStorage-first React app.
- Local keys are `wlt_students`, `wlt_attendance_v2`, `wlt_grades`, `wlt_fees`, `wlt_settings`, and `wlt_notices`.
- The existing cloud tables are `public.wl_students`, `wl_attendance`, `wl_grades`, and `wl_fees`.
- A developer-only authorization RPC `public.is_developer()` was previously verified.
- The portal has no Supabase client code today. Cloud sync must not be described as active.
- A previous metadata query returned 28 columns across the four cloud tables; table counts previously showed zero cloud rows. That does not describe local browser data.

## Safety model

1. Local storage remains the source of truth until the user explicitly enables sync.
2. Never auto-upload, auto-delete, or overwrite on sign-in.
3. Show a preview of counts and mapping before first upload.
4. Use stable UUIDs for cloud primary keys and keep a durable local-to-cloud ID map if local IDs are not UUIDs.
5. Do not add foreign keys until the exact ID types and values are verified.
6. Keep the Supabase publishable key public only; never put a service-role/secret key in HTML, JavaScript, GitHub, or browser storage.
7. Enforce RLS in PostgreSQL. Client-side checks are not security controls.
8. Sync only after a successful backup and explicit user action. On conflicts, stop and report; never silently choose a winner.
9. Preserve offline access; queue changes locally and retry only after authenticated access is available.
10. Do not merge/deploy this branch until SQL and browser integration are tested against the actual project.

## Local app record formats

- Students: array in `wlt_students`
- Attendance: object in `wlt_attendance_v2`
- Grades: array in `wlt_grades`
- Fees: array in `wlt_fees`
- Settings: object in `wlt_settings`
- Notices: array in `wlt_notices`

The four existing cloud tables do not yet represent settings/notices in the known table list. Those sections require a deliberate schema decision before they can be cloud-synced.

## Required implementation gates

- [ ] Confirm all cloud column names/types, primary keys, uniqueness and policies.
- [ ] Apply and verify least-privilege RLS and table grants.
- [ ] Define deterministic field mapping for all local records.
- [ ] Handle local IDs that are not UUIDs without losing references.
- [ ] Add authenticated Supabase client and session handling.
- [ ] Add sync preview, explicit confirmation, retry queue, conflict detection and audit messages.
- [ ] Test empty cloud, repeated sync (idempotency), offline edits, reconnect, duplicate IDs, unauthorized user, and failed requests.
- [ ] Deploy only after all tests pass.

## SQL artifacts

- `sql/complete-schema-audit.sql`: read-only inventory and row counts.
- `sql/constraints-and-access-audit.sql`: read-only constraint and permission audit.
- `sql/clean-test-cloud-setup.sql`: proposed developer-only access migration. It has not been executed by this repository workflow. Review against the live project before applying.

## Important scope note

The developer-only RLS policy is suitable for a restricted developer test phase, not a complete school-user authorization design. Before ordinary teachers, clerks, administrators or multiple schools use cloud sync, define user roles and school-level row isolation rather than granting everyone developer access.
