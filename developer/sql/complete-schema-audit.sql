-- White Lion School Management System
-- Schema completion: safe inventory + validation report.
-- READ-ONLY. Run this first in the White Lion School Cloud SQL Editor.
-- It does not alter, insert, update, or delete any records.
-- Project ref: homvrbxfwacopbnhujyg

BEGIN READ ONLY;

-- A. Full column inventory for all four existing school tables.
SELECT c.table_name, c.ordinal_position, c.column_name, c.data_type,
       c.udt_name, c.is_nullable, c.column_default,
       CASE WHEN c.is_identity='YES' THEN 'IDENTITY' ELSE '' END AS identity_kind
FROM information_schema.columns c
WHERE c.table_schema='public'
  AND c.table_name IN ('wl_students','wl_attendance','wl_grades','wl_fees')
ORDER BY c.table_name,c.ordinal_position;

-- B. Primary keys, unique constraints, foreign keys, and check constraints.
SELECT tc.table_name,tc.constraint_type,tc.constraint_name,
       string_agg(kcu.column_name,', ' ORDER BY kcu.ordinal_position) AS columns,
       max(ccu.table_name) AS referenced_table,
       string_agg(ccu.column_name,', ' ORDER BY ccu.column_name) FILTER
         (WHERE ccu.column_name IS NOT NULL) AS referenced_columns,
       max(ch.check_clause) AS check_clause
FROM information_schema.table_constraints tc
LEFT JOIN information_schema.key_column_usage kcu
  ON kcu.constraint_schema=tc.constraint_schema
 AND kcu.constraint_name=tc.constraint_name
 AND kcu.table_name=tc.table_name
LEFT JOIN information_schema.constraint_column_usage ccu
  ON ccu.constraint_schema=tc.constraint_schema
 AND ccu.constraint_name=tc.constraint_name
 AND ccu.table_name=tc.table_name
LEFT JOIN information_schema.check_constraints ch
  ON ch.constraint_schema=tc.constraint_schema
 AND ch.constraint_name=tc.constraint_name
WHERE tc.table_schema='public'
  AND tc.table_name IN ('wl_students','wl_attendance','wl_grades','wl_fees')
GROUP BY tc.table_name,tc.constraint_type,tc.constraint_name
ORDER BY tc.table_name,tc.constraint_type,tc.constraint_name;

-- C. RLS and policy status.
SELECT n.nspname AS schema_name,c.relname AS table_name,
       c.relrowsecurity AS rls_enabled,c.relforcerowsecurity AS rls_forced
FROM pg_class c JOIN pg_namespace n ON n.oid=c.relnamespace
WHERE n.nspname='public' AND c.relname IN
 ('wl_students','wl_attendance','wl_grades','wl_fees') AND c.relkind='r'
ORDER BY c.relname;

SELECT schemaname,tablename,policyname,permissive,roles,cmd,qual,with_check
FROM pg_policies
WHERE schemaname='public' AND tablename IN
 ('wl_students','wl_attendance','wl_grades','wl_fees')
ORDER BY tablename,policyname;

-- D. Browser role grants. Grants alone do not permit access when RLS denies it.
SELECT table_name,grantee,privilege_type
FROM information_schema.role_table_grants
WHERE table_schema='public' AND table_name IN
 ('wl_students','wl_attendance','wl_grades','wl_fees')
AND grantee IN ('anon','authenticated','PUBLIC')
ORDER BY table_name,grantee,privilege_type;

-- E. Counts only; no student or financial details are returned.
SELECT 'wl_students' AS table_name,count(*) AS row_count FROM public.wl_students
UNION ALL SELECT 'wl_attendance',count(*) FROM public.wl_attendance
UNION ALL SELECT 'wl_grades',count(*) FROM public.wl_grades
UNION ALL SELECT 'wl_fees',count(*) FROM public.wl_fees
ORDER BY table_name;

COMMIT;

-- NEXT STEP:
-- Use the actual column inventory above to generate/apply any schema migration.
-- Do not guess column names or add foreign keys until the real key types and
-- existing identifier formats have been confirmed. This script is intentionally
-- read-only so it cannot damage existing school data.