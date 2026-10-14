-- DESTRUCTIVE RESET: White Lion School Cloud
-- Target project ONLY: homvrbxfwacopbnhujyg
-- Effect: removes every row from every ordinary/partitioned table in the public schema.
-- Keeps tables, columns, indexes, constraints, functions, policies, Supabase Auth users,
-- and objects in auth/storage/private schemas. CASCADE may also empty public tables
-- linked by foreign keys. This action cannot be undone without a backup.
-- Review the target project before running. Do not run against White Lion Tech Solutions.

BEGIN;

DO $reset$
DECLARE
  tbl record;
BEGIN
  FOR tbl IN
    SELECT schemaname, tablename
    FROM pg_tables
    WHERE schemaname = 'public'
    ORDER BY tablename
  LOOP
    EXECUTE format('TRUNCATE TABLE %I.%I RESTART IDENTITY CASCADE',
                   tbl.schemaname, tbl.tablename);
    RAISE NOTICE 'Emptied %.%', tbl.schemaname, tbl.tablename;
  END LOOP;
END
$reset$;

COMMIT;

-- Verification: should return zero for every listed public table.
SELECT schemaname, relname AS table_name, n_live_tup AS estimated_rows
FROM pg_stat_user_tables
WHERE schemaname = 'public'
ORDER BY relname;
