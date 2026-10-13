# School Cloud security review and test plan

Status: review document only. The migration has not been applied to any Supabase project, and these checks have not been executed against a database.

## Current boundary

The current school app stores records in browser localStorage. The proposed SQL schema is not connected to the app. Do not merge this migration or load real student data until the checks below pass.

## Review findings to resolve before production

1. **Trusted school and staff provisioning is missing.** Browser clients cannot create schools or memberships by design. Build and test a trusted admin-only provisioning flow before app integration. Never expose a service-role key in browser code.
2. **Behavioral RLS tests are still required.** The current pgTAP file only checks structural properties (RLS flags, anonymous SELECT privileges, and presence of policies). It does not prove that policies prevent cross-school reads/writes or enforce every role.
3. **No auth-to-school onboarding flow exists yet.** A signed-in user with no membership should see no school records and must not be able to grant themselves membership or elevate their role.
4. **Offline sync is not designed or implemented.** Keep localStorage as the current source of truth. Before enabling sync, design stable record IDs, an outbox, retry/idempotency behavior, conflict resolution, and a recovery path that preserves local records.
5. **Auditability needs a decision.** Financial receipts and grades may require an append-only audit trail or controlled correction workflow. Decide how edits/voids are recorded before using real data.
6. **Input validation needs app-level coverage.** Add limits and validation for text fields, phone numbers, dates, amounts, receipt identifiers, and score/term fields. Database constraints are only part of validation.
7. **Review role permissions with actual school workflows.** Confirm whether teachers may add/edit student records, whether bursars can read all student/guardian details, and whether any role should be able to edit or delete payment records. Apply least privilege.

## Required isolated test matrix

Use only a disposable/test project and synthetic records. Create two schools (A and B) and distinct test users for each role. Never use real student data in these tests.

| Test | Expected result |
|---|---|
| Signed-out/anon user selects any exposed table | Denied |
| Authenticated user without membership queries either school | No rows returned |
| School A member queries School B records | No rows returned |
| Teacher creates/updates student, attendance, or grade in own school | Allowed |
| Teacher writes records with School B's school_id | Denied |
| Bursar creates/updates fee payment in own school | Allowed |
| Teacher creates/updates fee payment | Denied |
| Read-only member attempts any insert/update/delete | Denied |
| Non-admin attempts delete | Denied |
| Member attempts to alter their own role or add a membership | Denied |
| Same receipt number is reused within one school | Rejected |
| Duplicate attendance for same student/date/school | Rejected |
| Student ID from another school is used in attendance, grades, or payment | Rejected |
| Offline changes are retried after a timeout | No duplicate records or receipts |
| Conflict occurs after two devices edit one record | Explicit, documented resolution; no silent data loss |

Record the test user, operation, expected result, actual result, and pass/fail for each case. Include automated tests for all negative cases, not only the successful paths.

## Safe next steps

1. Review the migration and test file.
2. Apply to a disposable/test Supabase project only.
3. Run the structural pgTAP checks and add behavioral RLS tests.
4. Implement and test trusted provisioning.
5. Only after these pass, design the app integration and offline sync.
6. Keep a fresh downloadable JSON backup before any future migration, and verify restore on a separate test copy.

## Official references

- Row Level Security: https://supabase.com/docs/guides/database/postgres/row-level-security
- Database functions: https://supabase.com/docs/guides/database/functions
- Supabase CLI database tests: https://supabase.com/docs/guides/local-development/cli/testing-and-linting
