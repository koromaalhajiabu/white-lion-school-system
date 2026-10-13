WHITE LION PROFESSIONAL EDITION — BACKEND SETUP
================================================

This folder contains a starting Supabase SQL schema for school-scoped records,
memberships, role-based access, and audit events.

IMPORTANT
- This SQL is a backend foundation, not a completed sync integration.
- Do not paste a service_role key into the HTML or expose it in GitHub.
- Use only a Supabase project URL and publishable/anon key in a browser app,
  and only after RLS policies have been reviewed and tested.
- Do not use real student records until authentication, role permissions,
  sync conflict handling, offline queue/retry, and restore have been tested.

SETUP
1. Create a Supabase project in your own account.
2. Open SQL Editor and run supabase-schema.sql.
3. Configure authentication and confirm email/sign-in settings.
4. Keep the project URL and publishable (anon) key available for the next
   integration step. Never share the service_role/secret key.
5. Do not merge or publish this schema as proof that app sync already works.
