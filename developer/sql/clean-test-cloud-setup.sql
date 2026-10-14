-- White Lion School Cloud: clean test setup
-- Run ONLY in Supabase project white-lion-school-cloud (homvrbxfwacopbnhujyg).
-- This does NOT drop tables or delete records. It standardizes developer-only
-- access for the four existing cloud tables. Browser CRUD is restricted to the
-- registered developer account through public.is_developer().
-- Cloud sync is NOT enabled by this SQL alone.

BEGIN;

DO $$
BEGIN
  IF to_regclass('public.wl_students') IS NULL
     OR to_regclass('public.wl_attendance') IS NULL
     OR to_regclass('public.wl_grades') IS NULL
     OR to_regclass('public.wl_fees') IS NULL THEN
    RAISE EXCEPTION 'One or more White Lion tables are missing; aborting safely';
  END IF;
  IF to_regprocedure('public.is_developer()') IS NULL THEN
    RAISE EXCEPTION 'public.is_developer() is missing; configure developer authorization first';
  END IF;
END $$;

ALTER TABLE public.wl_students ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.wl_attendance ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.wl_grades ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.wl_fees ENABLE ROW LEVEL SECURITY;

-- No anonymous or PUBLIC access. Authenticated users get SQL privileges, but
-- RLS permits rows only when the registered developer check returns true.
REVOKE ALL ON TABLE public.wl_students, public.wl_attendance, public.wl_grades, public.wl_fees FROM PUBLIC, anon, authenticated;
GRANT SELECT, INSERT, UPDATE, DELETE ON TABLE public.wl_students, public.wl_attendance, public.wl_grades, public.wl_fees TO authenticated;

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

-- Verification query: run after successful execution.
SELECT schemaname, tablename, policyname, roles, cmd
FROM pg_policies
WHERE schemaname='public'
  AND tablename IN ('wl_students','wl_attendance','wl_grades','wl_fees')
ORDER BY tablename, policyname;
