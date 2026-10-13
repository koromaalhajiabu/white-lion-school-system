-- White Lion Professional Edition: Supabase foundation
-- Apply in Supabase SQL Editor only after creating a new project.
-- This creates tenant-scoped JSON records; it does NOT by itself connect the HTML app.
create extension if not exists pgcrypto;

create table if not exists public.wl_schools (
  id uuid primary key default gen_random_uuid(),
  name text not null check (length(trim(name)) between 2 and 180),
  created_by uuid not null references auth.users(id) on delete restrict,
  created_at timestamptz not null default now()
);

create table if not exists public.wl_school_members (
  school_id uuid not null references public.wl_schools(id) on delete cascade,
  user_id uuid not null references auth.users(id) on delete cascade,
  role text not null check (role in ('owner','admin','headteacher','bursar','teacher','records_officer','viewer')),
  active boolean not null default true,
  created_at timestamptz not null default now(),
  primary key (school_id, user_id)
);

create table if not exists public.wl_sync_records (
  school_id uuid not null references public.wl_schools(id) on delete cascade,
  entity_type text not null check (entity_type ~ '^[a-z][a-z0-9_-]{0,49}$'),
  record_id text not null check (length(record_id) between 1 and 180),
  payload jsonb not null default '{}'::jsonb check (jsonb_typeof(payload) = 'object'),
  version bigint not null default 1 check (version > 0),
  updated_by uuid not null default auth.uid() references auth.users(id) on delete restrict,
  updated_at timestamptz not null default now(),
  deleted_at timestamptz,
  primary key (school_id, entity_type, record_id)
);

create table if not exists public.wl_audit_log (
  id bigint generated always as identity primary key,
  school_id uuid not null references public.wl_schools(id) on delete cascade,
  actor_id uuid not null default auth.uid() references auth.users(id) on delete restrict,
  action text not null check (length(action) between 1 and 80),
  entity_type text,
  record_id text,
  created_at timestamptz not null default now(),
  details jsonb not null default '{}'::jsonb check (jsonb_typeof(details) = 'object')
);

create index if not exists wl_sync_records_school_updated_idx
  on public.wl_sync_records (school_id, updated_at desc);
create index if not exists wl_audit_log_school_created_idx
  on public.wl_audit_log (school_id, created_at desc);

create or replace function public.wl_is_member(p_school_id uuid)
returns boolean language sql stable security definer
set search_path = public, auth
as $$
  select exists (
    select 1 from public.wl_school_members m
    where m.school_id = p_school_id and m.user_id = (select auth.uid()) and m.active
  );
$$;

create or replace function public.wl_has_role(p_school_id uuid, p_roles text[])
returns boolean language sql stable security definer
set search_path = public, auth
as $$
  select exists (
    select 1 from public.wl_school_members m
    where m.school_id = p_school_id and m.user_id = (select auth.uid())
      and m.active and m.role = any(p_roles)
  );
$$;

-- Create a school and its first owner atomically for the signed-in user.
create or replace function public.wl_create_school(p_name text)
returns uuid language plpgsql security definer
set search_path = public, auth
as $$
declare new_id uuid;
begin
  if auth.uid() is null then raise exception 'Sign in before creating a school'; end if;
  if length(trim(coalesce(p_name,''))) < 2 or length(trim(p_name)) > 180 then
    raise exception 'School name must be between 2 and 180 characters';
  end if;
  insert into public.wl_schools(name, created_by)
    values (trim(p_name), auth.uid()) returning id into new_id;
  insert into public.wl_school_members(school_id, user_id, role)
    values (new_id, auth.uid(), 'owner');
  insert into public.wl_audit_log(school_id, actor_id, action, details)
    values (new_id, auth.uid(), 'school.created', jsonb_build_object('name', trim(p_name)));
  return new_id;
end;
$$;

alter table public.wl_schools enable row level security;
alter table public.wl_school_members enable row level security;
alter table public.wl_sync_records enable row level security;
alter table public.wl_audit_log enable row level security;

drop policy if exists wl_schools_read_member on public.wl_schools;
create policy wl_schools_read_member on public.wl_schools for select to authenticated
  using (public.wl_is_member(id));

drop policy if exists wl_members_read_same_school on public.wl_school_members;
create policy wl_members_read_same_school on public.wl_school_members for select to authenticated
  using (user_id = (select auth.uid()) or public.wl_has_role(school_id, array['owner','admin']));

drop policy if exists wl_members_admin_manage on public.wl_school_members;
create policy wl_members_admin_manage on public.wl_school_members for all to authenticated
  using (public.wl_has_role(school_id, array['owner','admin']))
  with check (public.wl_has_role(school_id, array['owner','admin']));

drop policy if exists wl_records_read_member on public.wl_sync_records;
create policy wl_records_read_member on public.wl_sync_records for select to authenticated
  using (public.wl_is_member(school_id));

drop policy if exists wl_records_insert_writer on public.wl_sync_records;
create policy wl_records_insert_writer on public.wl_sync_records for insert to authenticated
  with check (
    public.wl_has_role(school_id, array['owner','admin','headteacher','bursar','teacher','records_officer'])
    and updated_by = (select auth.uid())
  );

drop policy if exists wl_records_update_writer on public.wl_sync_records;
create policy wl_records_update_writer on public.wl_sync_records for update to authenticated
  using (public.wl_has_role(school_id, array['owner','admin','headteacher','bursar','teacher','records_officer']))
  with check (
    public.wl_has_role(school_id, array['owner','admin','headteacher','bursar','teacher','records_officer'])
    and updated_by = (select auth.uid())
  );

drop policy if exists wl_records_delete_admin on public.wl_sync_records;
create policy wl_records_delete_admin on public.wl_sync_records for delete to authenticated
  using (public.wl_has_role(school_id, array['owner','admin']));

drop policy if exists wl_audit_read_admin on public.wl_audit_log;
create policy wl_audit_read_admin on public.wl_audit_log for select to authenticated
  using (public.wl_has_role(school_id, array['owner','admin','headteacher']));

drop policy if exists wl_audit_insert_member on public.wl_audit_log;
create policy wl_audit_insert_member on public.wl_audit_log for insert to authenticated
  with check (public.wl_is_member(school_id) and actor_id = (select auth.uid()));

revoke all on public.wl_schools, public.wl_school_members, public.wl_sync_records, public.wl_audit_log from anon;
grant select on public.wl_schools, public.wl_school_members, public.wl_sync_records, public.wl_audit_log to authenticated;
grant insert, update, delete on public.wl_school_members to authenticated;
grant insert, update, delete on public.wl_sync_records to authenticated;
grant insert on public.wl_audit_log to authenticated;
grant usage, select on sequence public.wl_audit_log_id_seq to authenticated;
grant execute on function public.wl_is_member(uuid) to authenticated;
grant execute on function public.wl_has_role(uuid, text[]) to authenticated;
grant execute on function public.wl_create_school(text) to authenticated;

comment on table public.wl_sync_records is 'School-scoped sync envelope for White Lion app records. Apply RLS and use authenticated clients only.';
