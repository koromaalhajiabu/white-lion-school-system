-- White Lion School Management System
-- SECURITY MIGRATION DRAFT — review and test before applying.
-- This file intentionally does not insert, update, delete, or migrate school records.
-- It grants browser CRUD only to authenticated sessions AND policies only permit
-- the explicitly registered developer account. Keep RLS enabled.

BEGIN;

-- Refuse to proceed if the authorization function is missing.
DO $$
BEGIN
  IF to_regprocedure('public.is_developer()') IS NULL THEN
    RAISE EXCEPTION 'public.is_developer() is missing; configure developer authorization first';
  END IF;
END $$;

ALTER TABLE public.wl_students ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.wl_attendance ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.wl_grades ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.wl_fees ENABLE ROW LEVEL SECURITY;

-- Restrict all table access to authenticated role; RLS further restricts rows
-- to the registered developer. No grants to anon or PUBLIC.
REVOKE ALL ON TABLE public.wl_students, public.wl_attendance, public.wl_grades, public.wl_fees FROM PUBLIC, anon, authenticated;
GRANT SELECT, INSERT, UPDATE, DELETE ON TABLE public.wl_students, public.wl_attendance, public.wl_grades, public.wl_fees TO authenticated;

-- Replace only policies bearing these dedicated names, making reruns predictable.
DROP POLICY IF EXISTS wl_developer_only_students ON public.wl_students;
DROP POLICY IF EXISTS wl_developer_only_attendance ON public.wl_attendance;
DROP POLICY IF EXISTS wl_developer_only_grades ON public.wl_grades;
DROP POLICY IF EXISTS wl_developer_only_fees ON public.wl_fees;

CREATE POLICY wl_developer_only_students ON public.wl_students
  FOR ALL TO authenticated
  USING ((SELECT public.is_developer()))
  WITH CHECK ((SELECT public.is_developer()));

CREATE POLICY wl_developer_only_attendance ON public.wl_attendance
  FOR ALL TO authenticated
  USING ((SELECT public.is_developer()))
  WITH CHECK ((SELECT public.is_developer()));

CREATE POLICY wl_developer_only_grades ON public.wl_grades
  FOR ALL TO authenticated
  USING ((SELECT public.is_developer()))
  WITH CHECK ((SELECT public.is_developer()));

CREATE POLICY wl_developer_only_fees ON public.wl_fees
  FOR ALL TO authenticated
  USING ((SELECT public.is_developer()))
  WITH CHECK ((SELECT public.is_developer()));

COMMIT;

-- IMPORTANT:
-- This migration is a proposal and has not been run against the database.
-- Before applying, inspect existing grants, constraints and policies.
-- Cloud sync client code must still be implemented and tested separately.
