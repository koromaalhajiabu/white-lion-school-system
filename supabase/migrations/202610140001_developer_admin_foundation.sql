-- White Lion developer access foundation.
-- Additive only: does not alter or delete school records.
-- Apply manually in the Supabase SQL Editor for project white-lion-school-cloud.
-- The allowlisted account must already exist in Supabase Auth.

create table if not exists public.developer_admins (
  user_id uuid primary key references auth.users(id) on delete cascade,
  email text not null,
  role text not null default 'developer_admin' check (role = 'developer_admin'),
  created_at timestamptz not null default now()
);

alter table public.developer_admins enable row level security;

-- Authenticated users can read only their own developer role.
drop policy if exists "Developer can read own role" on public.developer_admins;
create policy "Developer can read own role"
  on public.developer_admins
  for select
  to authenticated
  using (user_id = auth.uid());

-- Intentionally create no client INSERT, UPDATE, or DELETE policies.
-- Do not grant this table to anon; RLS still applies to authenticated users.
revoke all on public.developer_admins from anon;
revoke insert, update, delete, truncate, references, trigger
  on public.developer_admins from authenticated;
grant select on public.developer_admins to authenticated;

-- Grant the role only to the named developer if that Auth account exists.
-- This is safe to re-run. If zero rows are inserted, create the Auth user first.
insert into public.developer_admins (user_id, email)
select id, lower(email)
from auth.users
where lower(email) = 'koromaalhajiabu0@gmail.com'
on conflict (user_id) do update
set email = excluded.email;

-- Verification: should return exactly one row for the intended developer.
select user_id, email, role, created_at
from public.developer_admins
where email = 'koromaalhajiabu0@gmail.com';
