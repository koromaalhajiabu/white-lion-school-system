-- White Lion School Cloud: constraints and access audit
-- READ-ONLY. Run in project homvrbxfwacopbnhujyg.
-- This script does not read student names or financial records and makes no changes.

BEGIN READ ONLY;

-- 1. Primary keys, unique constraints, foreign keys, and checks on the four tables.
SELECT
  tc.table_name,
  tc.constraint_type,
  tc.constraint_name,
  string_agg(kcu.column_name, ', ' ORDER BY kcu.ordinal_position) AS columns,
  ccu.table_name AS referenced_table,
  string_agg(ccu.column_name, ', ' ORDER BY ccu.ordinal_position)
    FILTER (WHERE ccu.column_name IS NOT NULL) AS referenced_columns,
  ch.check_clause
FROM information_schema.table_constraints tc
LEFT JOIN information_schema.key_column_usage kcu
  ON kcu.constraint_schema = tc.constraint_schema
 AND kcu.constraint_name = tc.constraint_name
 AND kcu.table_name = tc.table_name
LEFT JOIN information_schema.constraint_column_usage ccu
  ON ccu.constraint_schema = tc.constraint_schema
 AND ccu.constraint_name = tc.constraint_name
 AND ccu.table_name = tc.table_name
LEFT JOIN information_schema.check_constraints ch
  ON ch.constraint_schema = tc.constraint_schema
 AND ch.constraint_name = tc.constraint_name
WHERE tc.table_schema = 'public'
  AND tc.table_name IN ('wl_students','wl_attendance','wl_grades','wl_fees')
GROUP BY tc.table_name, tc.constraint_type, tc.constraint_name,
         ccu.table_name, ch.check_clause
ORDER BY tc.table_name, tc.constraint_type, tc.constraint_name;

-- 2. RLS state for the four tables.
SELECT c.relname AS table_name,
       c.relrowsecurity AS rls_enabled,
       c.relforcerowsecurity AS rls_forced
FROM pg_class c
JOIN pg_namespace n ON n.oid = c.relnamespace
WHERE n.nspname = 'public'
  AND c.relname IN ('wl_students','wl_attendance','wl_grades','wl_fees')
  AND c.relkind = 'r'
ORDER BY c.relname;

-- 3. Policies currently installed.
SELECT schemaname, tablename, policyname, permissive, roles, cmd, qual, with_check
FROM pg_policies
WHERE schemaname = 'public'
  AND tablename IN ('wl_students','wl_attendance','wl_grades','wl_fees')
ORDER BY tablename, policyname;

-- 4. Table privileges granted to browser roles.
SELECT table_name, grantee, privilege_type
FROM information_schema.role_table_grants
WHERE table_schema = 'public'
  AND table_name IN ('wl_students','wl_attendance','wl_grades','wl_fees')
  AND grantee IN ('anon','authenticated','PUBLIC')
ORDER BY table_name, grantee, privilege_type;

COMMIT;
