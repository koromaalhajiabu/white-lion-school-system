# School cloud database foundation

This branch proposes the first database migration for the separate `white-lion-school-cloud` Supabase project.

## Safety status

- This migration is committed on the review branch only; it has **not** been run against Supabase.
- It does not modify `professional/index.html`, the live GitHub Pages deployment, or existing browser-local records.
- Do not import real student data until the SQL is reviewed, applied to the intended school project, and tested.
- Staff memberships are intentionally not writable from the browser. A trusted admin provisioning procedure is still required.
- This is a schema foundation, not a completed online/offline sync implementation.

## Proposed first tables

- `schools` and `school_memberships` for school isolation and staff roles.
- `students`, `attendance`, `grades`, and `fee_payments` for core records.
- RLS is enabled on every table; anonymous table privileges are revoked.
- Policies limit student/attendance/grade editing to admins and teachers, and fee-payment editing to admins and bursars. Only admins can delete records.
- Read-only staff can read records but cannot write them.

## Before applying

1. Review the SQL against the exact target project ID.
2. Apply first to a disposable/test project or during a controlled test window.
3. Test signed-out requests, a user with no membership, users in two different schools, and each staff role. Confirm denied reads and writes fail.
4. Add automated RLS tests and a safe staff/school provisioning workflow.
5. Only after the tests pass, design the app adapter and offline queue/conflict strategy. Keep localStorage as the current source of truth until migration and reconciliation are explicitly tested.

Never place a database password, secret/service-role key, real student data, or a backup export in this repository.