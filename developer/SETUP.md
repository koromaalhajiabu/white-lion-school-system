# Developer Control Panel setup

This is a separate panel at `/developer/`; it does not replace the existing school app login and does not modify localStorage student records.

## Required setup before live sign-in works

1. Open the **White Lion School Cloud** Supabase project: https://supabase.com/dashboard/project/homvrbxfwacopbnhujyg
2. In **Project Settings → API Keys**, copy only the public **anon/publishable** key. Never use the service-role/secret key in a browser, HTML file, or GitHub.
3. Edit `developer/index.html` and replace `PASTE_PUBLIC_ANON_OR_PUBLISHABLE_KEY_HERE` with that public key. This key is designed to be public; database security must come from Auth and RLS.
4. In Supabase **Authentication → Users**, create/invite the developer account for `koromaalhajiabu0@gmail.com`. Set the password privately in Supabase. Do not send the password to anyone or commit it to a file. Configure email confirmation/recovery appropriately.
5. In **Authentication → URL Configuration**, add the deployed GitHub Pages developer URL to the allowed redirect/site URLs.
6. Commit/merge this branch to `main`, then wait for GitHub Pages deployment. Open `https://koromaalhajiabu0.github.io/white-lion-school-system/developer/`.
7. Test correct credentials, incorrect credentials, a different email, refresh/session persistence, and sign-out.

## Secure developer role foundation

The additive SQL migration at `supabase/migrations/202610140001_developer_admin_foundation.sql` creates a private developer-role table with Row Level Security and grants the role only to the existing Auth account whose email matches the allowlist.

Before any privileged controls can be enabled:

1. Open the project's SQL Editor: https://supabase.com/dashboard/project/homvrbxfwacopbnhujyg/sql/new
2. Review and run the migration file from this repository. Do not paste any service-role key into the SQL editor or browser.
3. Confirm the verification query returns one row for `koromaalhajiabu0@gmail.com`. If it returns no rows, verify that this email exists under Authentication → Users, then rerun the migration.
4. Keep the panel in its current read-only state until each future data operation has its own tested RLS policy or server-side function.

This migration is additive and does not alter school-record tables. It is not applied automatically by GitHub Pages; it must be run in the correct Supabase project's SQL Editor.

## Security boundary

The page checks the signed-in email before showing the panel, but a browser-side email check is **not** authorization for privileged database operations. Do not add data-changing controls until database tables have Row Level Security policies and any privileged operations are enforced by server-side policies/Edge Functions. Do not expose service-role credentials. This initial panel deliberately has no destructive or school-record controls.

## Existing offline records

The current school portal stores some records in the browser's localStorage. This panel does not clear, migrate, or overwrite those records. Supabase authentication setup does not automatically enable cloud backup or sync.
