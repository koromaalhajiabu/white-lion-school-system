# Dedicated Supabase project for White Lion School Management System

## Purpose
This guide is for setting up a separate backend for the school product. It must not connect to the football system project named "White lion Tech Solutions" or change the live GitHub Pages app.

## Current state
- The live Professional Edition uses browser localStorage when opened on GitHub Pages.
- The existing shared mode checks for a separate `window.claude` runtime integration; it is not a Supabase integration.
- This guide is preparation only. No database schema has been applied and no cloud synchronization is active.
- The `builddesk-shop-cloud` project was reported as paused, while `White lion Tech Solutions` contains the football system.
- Supabase documentation says the Free plan allows two active projects and paused projects do not count toward that limit. Confirm the current dashboard before creating anything.

## Safe setup steps
1. Open the Supabase dashboard and verify the status and organization of both existing projects.
2. Choose **New project** only if the dashboard confirms there is an available project slot and the owner is comfortable creating a dedicated school project.
3. Name the new project clearly, for example `white-lion-school-cloud`.
4. Store the database password in a password manager. Do not send it in chat or commit it to GitHub.
5. Do not use the football project's URL, keys, database, or tables for school records.
6. Do not connect the new project to the live school app until the schema, authentication, and access policies have been reviewed and tested.
7. Keep using the existing local portal and JSON backups while cloud features are under development.

## Required implementation before launch
- A migration that creates school-scoped tables for students, attendance, grades, fee payments, notices, settings, staff membership, and audit events.
- Row Level Security (RLS) enabled and policies tested so one school's staff cannot read or modify another school's records.
- Individual Supabase Auth accounts and role enforcement for administrator, teacher, bursar, and read-only staff.
- Safe offline queue, reconnect synchronization, duplicate prevention, and visible conflict handling.
- A migration rehearsal with fictional data and a verified export/restore before touching any real records.

## Security rules
- Never expose a Supabase secret/service-role key in browser code or GitHub.
- Only the publishable/anon client key may be used in a browser, and only after RLS policies are correct and independently tested.
- Do not import existing local records automatically. Make a separate backup and use an explicit, verified migration process.
- Do not merge a backend integration into `main` until tests pass and the owner approves.
