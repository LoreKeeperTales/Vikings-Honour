-- Run once in Supabase SQL Editor. Designed for Viking's Honour multiplayer test.
create extension if not exists pgcrypto;
create table if not exists public.characters (
  id uuid primary key default gen_random_uuid(),
  owner_id uuid not null references auth.users(id) on delete cascade,
  data jsonb not null default '{}'::jsonb,
  updated_at timestamptz not null default now()
);
create table if not exists public.campaigns (
  id uuid primary key default gen_random_uuid(),
  owner_id uuid not null references auth.users(id) on delete cascade,
  name text not null check (char_length(name) between 1 and 120),
  invite_code text not null unique check (char_length(invite_code) between 8 and 24),
  town_data jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now()
);
create table if not exists public.campaign_members (
  campaign_id uuid not null references public.campaigns(id) on delete cascade,
  user_id uuid not null references auth.users(id) on delete cascade,
  role text not null default 'player' check(role in ('owner','manager','player')),
  primary key(campaign_id,user_id)
);
create index if not exists campaign_members_user_idx on public.campaign_members(user_id);
create index if not exists characters_owner_idx on public.characters(owner_id);
alter table public.characters enable row level security;
alter table public.campaigns enable row level security;
alter table public.campaign_members enable row level security;
-- Security definer avoids recursive RLS policies on campaign membership.
create or replace function public.is_campaign_member(cid uuid) returns boolean
language sql stable security definer set search_path='' as $$
 select exists(select 1 from public.campaign_members where campaign_id=cid and user_id=(select auth.uid()));
$$;
create or replace function public.can_manage_campaign(cid uuid) returns boolean
language sql stable security definer set search_path='' as $$
 select exists(select 1 from public.campaign_members where campaign_id=cid and user_id=(select auth.uid()) and role in ('owner','manager'));
$$;
revoke all on function public.is_campaign_member(uuid) from public;
revoke all on function public.can_manage_campaign(uuid) from public;
grant execute on function public.is_campaign_member(uuid) to authenticated;
grant execute on function public.can_manage_campaign(uuid) to authenticated;
create policy "read own characters" on public.characters for select to authenticated using(owner_id=(select auth.uid()));
create policy "insert own characters" on public.characters for insert to authenticated with check(owner_id=(select auth.uid()));
create policy "update own characters" on public.characters for update to authenticated using(owner_id=(select auth.uid())) with check(owner_id=(select auth.uid()));
create policy "read joined campaigns" on public.campaigns for select to authenticated using(public.is_campaign_member(id) or owner_id=(select auth.uid()));
create policy "create own campaign" on public.campaigns for insert to authenticated with check(owner_id=(select auth.uid()));
create policy "manage campaign" on public.campaigns for update to authenticated using(public.can_manage_campaign(id)) with check(public.can_manage_campaign(id));
create policy "read fellow members" on public.campaign_members for select to authenticated using(public.is_campaign_member(campaign_id));
-- Automatically enroll campaign creator as owner.
create or replace function public.enroll_campaign_owner() returns trigger
language plpgsql security definer set search_path='' as $$
begin
 insert into public.campaign_members(campaign_id,user_id,role) values(new.id,new.owner_id,'owner');
 return new;
end $$;
drop trigger if exists enroll_campaign_owner_trigger on public.campaigns;
create trigger enroll_campaign_owner_trigger after insert on public.campaigns for each row execute function public.enroll_campaign_owner();
-- Invitation code lookup only through RPC. Never expose all campaigns publicly.
create or replace function public.join_campaign(join_code text) returns uuid
language plpgsql security definer set search_path='' as $$
declare cid uuid;
begin
 if (select auth.uid()) is null then raise exception 'Sign in first'; end if;
 select id into cid from public.campaigns where invite_code=upper(trim(join_code));
 if cid is null then raise exception 'Invalid invitation code'; end if;
 insert into public.campaign_members(campaign_id,user_id,role)
 values(cid,(select auth.uid()),'player') on conflict do nothing;
 return cid;
end $$;
revoke all on function public.join_campaign(text) from public;
grant execute on function public.join_campaign(text) to authenticated;
-- Protect privileged columns on campaign updates: clients may only change town_data.
revoke update on public.campaigns from authenticated;
grant update (town_data) on public.campaigns to authenticated;
-- Grant table access for authenticated clients (RLS still applies).
grant select,insert,update on public.characters to authenticated;
grant select,insert on public.campaigns to authenticated;
grant select on public.campaign_members to authenticated;
-- Realtime broadcasts town updates (optional; clients can also refresh manually).
do $$ begin
 alter publication supabase_realtime add table public.campaigns;
exception when duplicate_object then null; end $$;
