-- Baseline checks for the proposed school schema migration.
-- Run against a local/test Supabase database after applying migrations:
--   supabase test db
-- These are structural checks only. They do NOT replace behavioural RLS tests
-- with multiple users, multiple schools, and every staff role.

begin;

select plan(18);

select ok(
  (select c.relrowsecurity from pg_class c join pg_namespace n on n.oid = c.relnamespace
   where n.nspname = 'public' and c.relname = 'schools'),
  'RLS is enabled on schools'
);
select ok(
  (select c.relrowsecurity from pg_class c join pg_namespace n on n.oid = c.relnamespace
   where n.nspname = 'public' and c.relname = 'school_memberships'),
  'RLS is enabled on school_memberships'
);
select ok(
  (select c.relrowsecurity from pg_class c join pg_namespace n on n.oid = c.relnamespace
   where n.nspname = 'public' and c.relname = 'students'),
  'RLS is enabled on students'
);
select ok(
  (select c.relrowsecurity from pg_class c join pg_namespace n on n.oid = c.relnamespace
   where n.nspname = 'public' and c.relname = 'attendance'),
  'RLS is enabled on attendance'
);
select ok(
  (select c.relrowsecurity from pg_class c join pg_namespace n on n.oid = c.relnamespace
   where n.nspname = 'public' and c.relname = 'grades'),
  'RLS is enabled on grades'
);
select ok(
  (select c.relrowsecurity from pg_class c join pg_namespace n on n.oid = c.relnamespace
   where n.nspname = 'public' and c.relname = 'fee_payments'),
  'RLS is enabled on fee_payments'
);

select ok(not has_table_privilege('anon', 'public.schools', 'SELECT'), 'anon cannot select schools');
select ok(not has_table_privilege('anon', 'public.school_memberships', 'SELECT'), 'anon cannot select memberships');
select ok(not has_table_privilege('anon', 'public.students', 'SELECT'), 'anon cannot select students');
select ok(not has_table_privilege('anon', 'public.attendance', 'SELECT'), 'anon cannot select attendance');
select ok(not has_table_privilege('anon', 'public.grades', 'SELECT'), 'anon cannot select grades');
select ok(not has_table_privilege('anon', 'public.fee_payments', 'SELECT'), 'anon cannot select fee payments');

select ok(
  (select count(*) >= 1 from pg_policies where schemaname = 'public' and tablename = 'schools'),
  'schools has at least one RLS policy'
);
select ok(
  (select count(*) >= 1 from pg_policies where schemaname = 'public' and tablename = 'school_memberships'),
  'school_memberships has at least one RLS policy'
);
select ok(
  (select count(*) >= 1 from pg_policies where schemaname = 'public' and tablename = 'students'),
  'students has RLS policies'
);
select ok(
  (select count(*) >= 1 from pg_policies where schemaname = 'public' and tablename = 'attendance'),
  'attendance has RLS policies'
);
select ok(
  (select count(*) >= 1 from pg_policies where schemaname = 'public' and tablename = 'grades'),
  'grades has RLS policies'
);
select ok(
  (select count(*) >= 1 from pg_policies where schemaname = 'public' and tablename = 'fee_payments'),
  'fee_payments has RLS policies'
);

select * from finish();
rollback;
