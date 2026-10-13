-- White Lion School Cloud: first secure schema foundation
-- Review and test in a non-production project before applying.
-- This migration does not import or alter any existing offline school records.

begin;

create schema if not exists private;

create table if not exists public.schools (
  id uuid primary key default gen_random_uuid(),
  name text not null check (length(trim(name)) between 1 and 200),
  created_at timestamptz not null default now()
);

create table if not exists public.school_memberships (
  school_id uuid not null references public.schools(id) on delete cascade,
  user_id uuid not null references auth.users(id) on delete cascade,
  role text not null check (role in ('admin', 'teacher', 'bursar', 'read_only')),
  created_at timestamptz not null default now(),
  primary key (school_id, user_id)
);
create index if not exists school_memberships_user_id_idx
  on public.school_memberships(user_id);

create table if not exists public.students (
  id uuid primary key default gen_random_uuid(),
  school_id uuid not null references public.schools(id) on delete cascade,
  admission_number text not null,
  first_name text not null,
  last_name text not null,
  class_name text not null default '',
  guardian_name text not null default '',
  guardian_phone text not null default '',
  status text not null default 'active' check (status in ('active', 'inactive', 'graduated')),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  unique (school_id, admission_number),
  unique (school_id, id)
);
create index if not exists students_school_id_idx on public.students(school_id);

create table if not exists public.attendance (
  id uuid primary key default gen_random_uuid(),
  school_id uuid not null references public.schools(id) on delete cascade,
  student_id uuid not null,
  attendance_date date not null default current_date,
  status text not null check (status in ('present', 'absent', 'late', 'excused')),
  notes text not null default '',
  recorded_by uuid references auth.users(id) on delete set null,
  created_at timestamptz not null default now(),
  foreign key (school_id, student_id) references public.students(school_id, id) on delete cascade,
  unique (school_id, student_id, attendance_date)
);
create index if not exists attendance_school_date_idx
  on public.attendance(school_id, attendance_date);

create table if not exists public.grades (
  id uuid primary key default gen_random_uuid(),
  school_id uuid not null references public.schools(id) on delete cascade,
  student_id uuid not null,
  subject text not null,
  term text not null,
  academic_year text not null,
  score numeric(5,2) not null check (score >= 0 and score <= 100),
  remarks text not null default '',
  recorded_by uuid references auth.users(id) on delete set null,
  created_at timestamptz not null default now(),
  foreign key (school_id, student_id) references public.students(school_id, id) on delete cascade
);
create index if not exists grades_school_student_idx on public.grades(school_id, student_id);

create table if not exists public.fee_payments (
  id uuid primary key default gen_random_uuid(),
  school_id uuid not null references public.schools(id) on delete cascade,
  student_id uuid not null,
  receipt_number text not null,
  amount numeric(12,2) not null check (amount > 0),
  currency text not null default 'SLE' check (currency in ('SLE', 'USD')),
  payment_method text not null default 'cash' check (payment_method in ('cash', 'mobile_money', 'bank', 'other')),
  description text not null default '',
  paid_at timestamptz not null default now(),
  received_by uuid references auth.users(id) on delete set null,
  created_at timestamptz not null default now(),
  foreign key (school_id, student_id) references public.students(school_id, id) on delete restrict,
  unique (school_id, receipt_number)
);
create index if not exists fee_payments_school_paid_at_idx
  on public.fee_payments(school_id, paid_at);

-- Membership checks live in a non-exposed schema and are executable only by signed-in users.
-- SECURITY DEFINER is used to avoid recursive RLS checks on school_memberships.
create or replace function private.has_school_role(p_school_id uuid, p_allowed_roles text[] default null)
returns boolean
language sql
stable
security definer
set search_path = ''
as $$
  select exists (
    select 1
    from public.school_memberships m
    where m.school_id = p_school_id
      and m.user_id = (select auth.uid())
      and (p_allowed_roles is null or m.role = any(p_allowed_roles))
  );
$$;

revoke all on function private.has_school_role(uuid, text[]) from public;
revoke all on function private.has_school_role(uuid, text[]) from anon;
grant usage on schema private to authenticated;
grant execute on function private.has_school_role(uuid, text[]) to authenticated;

-- Explicit grants matter: RLS policies do not replace SQL privileges.
revoke all on public.schools, public.school_memberships, public.students,
  public.attendance, public.grades, public.fee_payments from public, anon;
grant select on public.schools to authenticated;
grant select on public.school_memberships to authenticated;
grant select, insert, update, delete on public.students, public.attendance,
  public.grades, public.fee_payments to authenticated;

alter table public.schools enable row level security;
alter table public.school_memberships enable row level security;
alter table public.students enable row level security;
alter table public.attendance enable row level security;
alter table public.grades enable row level security;
alter table public.fee_payments enable row level security;

-- School creation and staff membership provisioning are deliberately not available
-- to browser clients. Provision these through a trusted administrative workflow.
create policy schools_read_member
  on public.schools for select to authenticated
  using ((select private.has_school_role(id, null)));

create policy memberships_read_own
  on public.school_memberships for select to authenticated
  using (user_id = (select auth.uid()));

create policy students_read_member
  on public.students for select to authenticated
  using ((select private.has_school_role(school_id, null)));
create policy students_insert_staff
  on public.students for insert to authenticated
  with check ((select private.has_school_role(school_id, array['admin','teacher']::text[])));
create policy students_update_admin_teacher
  on public.students for update to authenticated
  using ((select private.has_school_role(school_id, array['admin','teacher']::text[])))
  with check ((select private.has_school_role(school_id, array['admin','teacher']::text[])));
create policy students_delete_admin
  on public.students for delete to authenticated
  using ((select private.has_school_role(school_id, array['admin']::text[])));

create policy attendance_read_member
  on public.attendance for select to authenticated
  using ((select private.has_school_role(school_id, null)));
create policy attendance_insert_staff
  on public.attendance for insert to authenticated
  with check ((select private.has_school_role(school_id, array['admin','teacher']::text[])));
create policy attendance_update_staff
  on public.attendance for update to authenticated
  using ((select private.has_school_role(school_id, array['admin','teacher']::text[])))
  with check ((select private.has_school_role(school_id, array['admin','teacher']::text[])));
create policy attendance_delete_admin
  on public.attendance for delete to authenticated
  using ((select private.has_school_role(school_id, array['admin']::text[])));

create policy grades_read_member
  on public.grades for select to authenticated
  using ((select private.has_school_role(school_id, null)));
create policy grades_insert_staff
  on public.grades for insert to authenticated
  with check ((select private.has_school_role(school_id, array['admin','teacher']::text[])));
create policy grades_update_staff
  on public.grades for update to authenticated
  using ((select private.has_school_role(school_id, array['admin','teacher']::text[])))
  with check ((select private.has_school_role(school_id, array['admin','teacher']::text[])));
create policy grades_delete_admin
  on public.grades for delete to authenticated
  using ((select private.has_school_role(school_id, array['admin']::text[])));

create policy fee_payments_read_member
  on public.fee_payments for select to authenticated
  using ((select private.has_school_role(school_id, null)));
create policy fee_payments_insert_bursar
  on public.fee_payments for insert to authenticated
  with check ((select private.has_school_role(school_id, array['admin','bursar']::text[])));
create policy fee_payments_update_bursar
  on public.fee_payments for update to authenticated
  using ((select private.has_school_role(school_id, array['admin','bursar']::text[])))
  with check ((select private.has_school_role(school_id, array['admin','bursar']::text[])));
create policy fee_payments_delete_admin
  on public.fee_payments for delete to authenticated
  using ((select private.has_school_role(school_id, array['admin']::text[])));

commit;
