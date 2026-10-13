# White Lion School Portal — Security and Multi-Device Sync Preparation

## Status
This is a preparation document only. The current live portal remains unchanged. The Professional Edition currently stores school records in browser localStorage and supports JSON export/import. It does not currently have production-grade school authentication or automatic synchronization between devices.

## Non-negotiable data-safety rules
- Keep the current `main` branch and live portal intact while developing.
- Export a fresh JSON backup before any migration or code change that touches school records.
- Use fictional/test data until authentication, database access rules, and recovery have been independently tested.
- Never commit passwords, API secret keys, service-role keys, student records, or backup files to GitHub.
- Do not use the existing unrelated Supabase project named “White lion Tech Solutions” for school records.
- Current account constraint: keep Supabase on the Free plan and do not pause/delete either active project. Do not create a third project until the account/project situation is deliberately resolved.

## Required target architecture
1. **Identity:** individual accounts for school staff; no shared administrator password.
2. **School isolation:** every school-owned record must have a school identifier, and database policies must prevent users from reading or changing another school's records.
3. **Roles:** at minimum school administrator, teacher, bursar, and read-only roles. Permissions must be enforced by the backend, not just by hiding buttons in the interface.
4. **Data model:** students, attendance, grades, fee payments/receipts, notices, school settings, and staff membership must be related to a school.
5. **Offline queue:** local edits made without connectivity must be queued and synchronized after reconnecting; show pending/success/conflict/error states.
6. **Conflict safety:** avoid silent overwrites. Use record IDs, update timestamps/versioning, and a conflict-resolution path.
7. **Backup and restore:** retain JSON export; add a documented restore rehearsal and backup verification. Do not automatically overwrite local data with cloud data.
8. **Audit trail:** record important administrative actions without logging passwords or unnecessary sensitive data.
9. **Deployment:** secrets stay in provider settings; only public client configuration may be included in the static app. Enforce database Row Level Security (RLS) on all school tables.
10. **Privacy:** collect only required school information, limit access by role, and avoid using real pupil data during testing.

## Implementation gates
- **Gate A — backup:** verify a current export is present and readable.
- **Gate B — backend choice/access:** confirm a dedicated school backend can be used without changing or deleting existing projects. The current account constraint means this gate is not yet cleared.
- **Gate C — database and RLS:** apply schema to the dedicated project and test that a user from School A cannot read/write School B records.
- **Gate D — authentication and roles:** test admin, teacher, bursar, and read-only accounts.
- **Gate E — sync:** implement and test online sync, offline queue, reconnect, duplicate prevention, and conflicts.
- **Gate F — migration rehearsal:** import a copy of fictional/local test data into a test environment, verify counts and reports, and rehearse restore.
- **Gate G — release:** only then consider enabling real school data and publish the tested changes.

## Current limitation
GitHub Pages is a static host; it is not a shared database. A live multi-device implementation cannot be honestly marked complete until a dedicated backend is configured, its policies are tested, and the app is connected to it. Do not treat this plan as proof that cloud sync or production authentication is active.
