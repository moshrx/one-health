-- Prototype persistence: clinic-owned JSON workspace with RLS and immutable audit metadata.
-- Apply through the Supabase SQL editor as an administrator.
create table public.clinics (
 id uuid primary key default gen_random_uuid(), name text not null,
 country text not null check(country in ('IN','GB')), created_at timestamptz not null default now()
);
create table public.clinic_members (
 clinic_id uuid not null references public.clinics(id), user_id uuid not null references auth.users(id),
 role text not null check(role in ('owner','practitioner','viewer')), primary key(clinic_id,user_id)
);
create function public.clinic_role(target uuid) returns text language sql stable security definer set search_path = '' as $$
 select role from public.clinic_members where clinic_id = target and user_id = auth.uid();
$$;
revoke all on function public.clinic_role(uuid) from public;
grant execute on function public.clinic_role(uuid) to authenticated;
create table public.clinic_workspaces (
 clinic_id uuid primary key references public.clinics(id),
 payload jsonb not null default '{"patients":[],"entries":[],"bookmarks":[]}'::jsonb,
 updated_at timestamptz not null default now(),
 constraint workspace_shape check (payload ?& array['patients','entries','bookmarks'] and jsonb_typeof(payload->'patients')='array' and jsonb_typeof(payload->'entries')='array' and jsonb_typeof(payload->'bookmarks')='array')
);
create table public.audit_logs (
 id bigint generated always as identity primary key, clinic_id uuid not null references public.clinics(id),
 actor uuid, action text not null, occurred_at timestamptz not null default now()
);
create function public.audit_workspace() returns trigger language plpgsql security definer set search_path='' as $$
begin
 new.updated_at := now();
 insert into public.audit_logs(clinic_id,actor,action) values(new.clinic_id,auth.uid(),TG_OP);
 return new;
end; $$;
create trigger workspace_audit before insert or update on public.clinic_workspaces for each row execute function public.audit_workspace();
alter table public.clinics enable row level security;
alter table public.clinic_members enable row level security;
alter table public.clinic_workspaces enable row level security;
alter table public.audit_logs enable row level security;
create policy clinic_read on public.clinics for select to authenticated using (public.clinic_role(id) is not null);
create policy membership_read on public.clinic_members for select to authenticated using(user_id=auth.uid());
create policy workspace_read on public.clinic_workspaces for select to authenticated using(public.clinic_role(clinic_id) is not null);
create policy workspace_update on public.clinic_workspaces for update to authenticated using(public.clinic_role(clinic_id) in ('owner','practitioner')) with check(public.clinic_role(clinic_id) in ('owner','practitioner'));
create policy audit_read on public.audit_logs for select to authenticated using(public.clinic_role(clinic_id)='owner');
revoke all on public.clinics,public.clinic_members,public.clinic_workspaces,public.audit_logs from anon,authenticated;
grant select on public.clinics,public.clinic_members,public.clinic_workspaces,public.audit_logs to authenticated;
grant update(payload) on public.clinic_workspaces to authenticated;
-- Clinic creation, membership and workspace provisioning are intentionally administrator-only.
