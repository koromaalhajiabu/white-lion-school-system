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

## Security boundary

The page checks the signed-in email before showing the panel, but a browser-side email check is **not** authorization for privileged database operations. Do not add data-changing controls until database tables have Row Level Security policies and any privileged operations are enforced by server-side policies/Edge Functions. Do not expose service-role credentials. This initial panel deliberately has no destructive or school-record controls.

## Existing offline records

The current school portal stores some records in the browser's localStorage. This panel does not clear, migrate, or overwrite those records. Supabase authentication setup does not automatically enable cloud backup or sync.
