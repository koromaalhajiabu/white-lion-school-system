-- White Lion School Cloud: constraints and access audit (corrected)
-- READ-ONLY. Project ref: homvrbxfwacopbnhujyg.
-- This script reads metadata only and makes no changes.

BEGIN READ ONLY;

-- 1. Constraints on the four school tables.
SELECT
  tc.table_name,
  tc.constraint_type,
  tc.constraint_name,
  string_agg(kcu.column_name, ', ' ORDER BY kcu.ordinal_position)
    FILTER (WHERE kcu.column_name IS NOT NULL) AS columns,
  max(ccu.table_name) AS referenced_table,
  string_agg(DISTINCT ccu.column_name, ', ' ORDER BY ccu.column_name)
    FILTER (WHERE ccu.column_name IS NOT NULL) AS referenced_columns,
  max(ch.check_clause) AS check_clause
FROM information_schema.table_constraints tc
LEFT JOIN information_schema.key_column_usage kcu
  ON kcu.constraint_schema = tc.constraint_schema
 AND kcu.constraint_name = tc.constraint_name
 AND kcu.table_name = tc.table_name
 AND kcu.table_schema = tc.table_schema
LEFT JOIN information_schema.constraint_column_usage ccu
  ON ccu.constraint_schema = tc.constraint_schema
 AND ccu.constraint_name = tc.constraint_name
 AND ccu.table_name = tc.table_name
 AND ccu.table_schema = tc.table_schema
LEFT JOIN information_schema.check_constraints ch
  ON ch.constraint_schema = tc.constraint_schema
 AND ch.constraint_name = tc.constraint_name
WHERE tc.table_schema = 'public'
  AND tc.table_name IN ('wl_students','wl_attendance','wl_grades','wl_fees')
GROUP BY tc.table_name, tc.constraint_type, tc.constraint_name
ORDER BY tc.table_name, tc.constraint_type, tc.constraint_name;

-- 2. Row-level security state.
SELECT c.relname AS table_name,
       c.relrowsecurity AS rls_enabled,
       c.relforcerowsecurity AS rls_forced
FROM pg_class c
JOIN pg_namespace n ON n.oid = c.relnamespace
WHERE n.nspname = 'public'
  AND c.relname IN ('wl_students','wl_attendance','wl_grades','wl_fees')
  AND c.relkind = 'r'
ORDER BY c.relname;

-- 3. Installed policies.
SELECT schemaname, tablename, policyname, permissive, roles, cmd, qual, with_check
FROM pg_policies
WHERE schemaname = 'public'
  AND tablename IN ('wl_students','wl_attendance','wl_grades','wl_fees')
ORDER BY tablename, policyname;

-- 4. Browser-role table privileges.
SELECT table_name, grantee, privilege_type
FROM information_schema.role_table_grants
WHERE table_schema = 'public'
  AND table_name IN ('wl_students','wl_attendance','wl_grades','wl_fees')
  AND grantee IN ('anon','authenticated','PUBLIC')
ORDER BY table_name, grantee, privilege_type;

COMMIT;
