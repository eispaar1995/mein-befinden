-- Schema "Mein Befinden": pro Tag ein JSON-Dokument, geschützt durch Row Level Security (nur eigener Login).
create table public.days (
  user_id uuid not null default auth.uid() references auth.users(id) on delete cascade,
  date date not null,
  data jsonb not null default '{}'::jsonb,
  updated_at timestamptz not null default now(),
  primary key (user_id, date)
);
create table public.settings (
  user_id uuid primary key default auth.uid() references auth.users(id) on delete cascade,
  name text not null default '',
  az text not null default '',
  updated_at timestamptz not null default now()
);
alter table public.days enable row level security;
alter table public.settings enable row level security;
create policy "days_own" on public.days for all to authenticated
  using ((select auth.uid()) = user_id) with check ((select auth.uid()) = user_id);
create policy "settings_own" on public.settings for all to authenticated
  using ((select auth.uid()) = user_id) with check ((select auth.uid()) = user_id);
create or replace function public.touch_updated_at() returns trigger language plpgsql set search_path = '' as $$
begin new.updated_at = now(); return new; end $$;
create trigger days_touch before update on public.days for each row execute function public.touch_updated_at();
create trigger settings_touch before update on public.settings for each row execute function public.touch_updated_at();
