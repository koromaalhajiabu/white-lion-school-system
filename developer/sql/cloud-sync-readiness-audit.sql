-- White Lion School Management System
-- READ-ONLY cloud synchronization readiness audit.
-- Safe to run in the Supabase SQL Editor. This script does not alter data,
-- permissions, policies, or table definitions.
-- Project: white-lion-school-cloud (homvrbxfwacopbnhujyg)

-- 1) Exact columns and data types used by the existing public tables.
SELECT table_name, ordinal_position, column_name, data_type, is_nullable, column_default
FROM information_schema.columns
WHERE table_schema = 'public'
  AND table_name IN ('wl_students', 'wl_attendance', 'wl_grades', 'wl_fees')
ORDER BY table_name, ordinal_position;

-- 2) Row-level security status for these tables.
SELECT n.nspname AS schema_name,
       c.relname AS table_name,
       c.relrowsecurity AS rls_enabled,
       c.relforcerowsecurity AS rls_forced
FROM pg_class c
JOIN pg_namespace n ON n.oid = c.relnamespace
WHERE n.nspname = 'public'
  AND c.relname IN ('wl_students', 'wl_attendance', 'wl_grades', 'wl_fees')
  AND c.relkind = 'r'
ORDER BY c.relname;

-- 3) Existing RLS policies (zero rows means no policies exist).
SELECT schemaname, tablename, policyname, permissive, roles, cmd, qual, with_check
FROM pg_policies
WHERE schemaname = 'public'
  AND tablename IN ('wl_students', 'wl_attendance', 'wl_grades', 'wl_fees')
ORDER BY tablename, policyname;

-- 4) Table-level privileges for browser roles (anon/authenticated/PUBLIC).
-- This shows grants only; it does not prove that a policy permits access.
SELECT table_schema, table_name, grantee, privilege_type
FROM information_schema.role_table_grants
WHERE table_schema = 'public'
  AND table_name IN ('wl_students', 'wl_attendance', 'wl_grades', 'wl_fees')
  AND grantee IN ('anon', 'authenticated', 'PUBLIC')
ORDER BY table_name, grantee, privilege_type;

-- 5) Constraints, including primary keys, unique constraints, checks and FKs.
SELECT tc.table_name, tc.constraint_type, tc.constraint_name,
       kcu.column_name,
       ccu.table_name AS referenced_table,
       ccu.column_name AS referenced_column
FROM information_schema.table_constraints tc
LEFT JOIN information_schema.key_column_usage kcu
  ON kcu.constraint_schema = tc.constraint_schema
 AND kcu.constraint_name = tc.constraint_name
 AND kcu.table_name = tc.table_name
LEFT JOIN information_schema.constraint_column_usage ccu
  ON ccu.constraint_schema = tc.constraint_schema
 AND ccu.constraint_name = tc.constraint_name
WHERE tc.table_schema = 'public'
  AND tc.table_name IN ('wl_students', 'wl_attendance', 'wl_grades', 'wl_fees')
ORDER BY tc.table_name, tc.constraint_type, tc.constraint_name;

-- 6) Record counts only; no record contents are exposed.
SELECT 'wl_students' AS table_name, COUNT(*) AS record_count FROM public.wl_students
UNION ALL
SELECT 'wl_attendance', COUNT(*) FROM public.wl_attendance
UNION ALL
SELECT 'wl_grades', COUNT(*) FROM public.wl_grades
UNION ALL
SELECT 'wl_fees', COUNT(*) FROM public.wl_fees
ORDER BY table_name;
