# White Lion School Portal: Offline and Cloud Sync Design

Status: design proposal only. This document does not change the live app, upload records, or enable synchronization.

## Safety rules

- Keep the existing browser data as the source of truth until a tested migration is approved.
- Never clear browser/site data as a troubleshooting step while it may contain school records.
- Export a fresh JSON backup before every migration or sync experiment. Save it outside the repository, then test restore into a separate test profile/device using synthetic data.
- Never commit student records, backup files, access tokens, Supabase service-role keys, or database passwords to GitHub.
- Do not enable cloud sync until authentication, school membership provisioning, row-level security (RLS), and recovery tests pass.

## Proposed phases

1. **Backup and restore first.** Add a versioned export format, a preview/validation step before import, and a restore test that runs against an empty test profile. Import must not silently overwrite existing data.
2. **Secure database foundation.** Apply the proposed schema only to a disposable Supabase project. Run structural and behavioural RLS tests for anonymous access, users without memberships, cross-school isolation, and every role. Build trusted staff/school provisioning before production.
3. **Local change queue.** Keep offline edits local and record each change in a durable outbox. Prefer IndexedDB for queued operations and larger structured data; migrate existing localStorage data only with a backup and verified rollback.
4. **Authenticated sync.** When online, send queued changes only after a user is authenticated and their school membership is verified. Use the publishable/anon key only with RLS; never put a service-role key in the browser.
5. **Recovery and rollout.** Start with synthetic records, then a small opt-in pilot after passing the full test matrix. Keep sync disabled by default until conflict and restore behaviour is proven.

## Outbox record requirements

Each queued operation should include:

- `operation_id`: a stable UUID generated once on the device and reused for every retry (idempotency key).
- `school_id`, `record_type`, and `record_id`: stable identifiers; do not use array positions as record IDs.
- `operation`: create, update, or delete/tombstone.
- `base_version` or `base_updated_at`: the server version the edit was based on.
- `payload`: validated fields only; never include credentials.
- `created_at`, `attempt_count`, and `last_error`: local diagnostics.

An operation is removed from the pending queue only after the server confirms it was applied or safely recognized as an already-applied retry. Transient failures must remain queued and be retryable. A permanent validation or permission error must be shown to the user and must not be silently discarded.

## Idempotency and duplicate prevention

- Reuse the same `operation_id` for every retry; never generate a new one when a request times out.
- Enforce a unique server-side idempotency key for accepted operations, scoped to the school where appropriate.
- Keep the existing unique constraints for admission numbers, receipt numbers, and attendance per student/date.
- Treat a duplicate receipt number with different payment details as a conflict requiring review, not as a successful retry.
- Test duplicate submissions after a simulated timeout and after the app is closed/reopened.

## Conflict policy (must be implemented and tested before sync)

- **Student/contact details:** compare server version to `base_version`. If changed on both sides, present a review/merge choice; do not silently overwrite.
- **Attendance:** use one record per student/date. Conflicting statuses require an authorized correction workflow and audit entry.
- **Grades:** retain an audit trail of who changed a score, when, and why. Conflicts require review; no silent last-write-wins.
- **Fee payments/receipts:** do not silently overwrite or delete. Corrections should be recorded as controlled void/reversal events with an audit trail; receipt numbers remain unique.
- **Deletes:** use tombstones and an admin-controlled restore path so a delayed device cannot resurrect deleted data unnoticed.

## Minimum test gates

- Offline create/update survives app refresh and device restart.
- Export then restore reproduces the same synthetic records and totals.
- A failed upload stays queued and retries after connectivity returns.
- Retrying the same operation multiple times creates one server effect only.
- Two devices editing the same record produce a visible conflict.
- A user with no membership cannot read or write school records.
- A member of School A cannot read or write School B records.
- Teacher, bursar, read-only, and admin permissions match the approved school workflow.
- A restore never silently merges into or overwrites a non-empty profile.
- Logs and error messages do not expose student details, passwords, or access tokens.

## Rollback

- Keep the pre-migration JSON export untouched and stored outside GitHub.
- Keep sync feature-flagged/off until acceptance tests pass.
- If a pilot fails, disable uploads first, preserve local records and the outbox, export a fresh backup, and investigate using synthetic copies.
- Never resolve a failed migration by clearing browser storage or dropping production tables.

## Current limitation

The live portal remains a localStorage-based app. This design does not itself provide cloud backup, multi-device synchronization, authentication, or automatic recovery. Those require implementation and tests in later reviewed changes.
