-- Wöchentliche Sicherungskopie (sonntags 03:00 UTC) aller Tage je Nutzer, 26 Wochen aufbewahrt.
-- Nur lesbar für den Besitzer; geschrieben wird ausschließlich durch die Datenbank selbst.
create extension if not exists pg_cron;
create table public.snapshots (
  id bigint generated always as identity primary key,
  user_id uuid not null references auth.users(id) on delete cascade,
  taken_at timestamptz not null default now(),
  day_count int not null,
  data jsonb not null
);
create index snapshots_user_taken_idx on public.snapshots (user_id, taken_at desc);
alter table public.snapshots enable row level security;
create policy "snapshots_read_own" on public.snapshots for select to authenticated
  using ((select auth.uid()) = user_id);
create or replace function public.take_weekly_snapshots() returns void
language plpgsql security definer set search_path = '' as $$
begin
  insert into public.snapshots (user_id, day_count, data)
  select d.user_id, count(*)::int,
         jsonb_build_object('app','Mein Befinden','format',1,'takenAt',now(),
           'settings',(select to_jsonb(s) - 'user_id' - 'updated_at' from public.settings s where s.user_id = d.user_id),
           'days',jsonb_object_agg(d.date::text, d.data))
  from public.days d group by d.user_id;
  delete from public.snapshots where taken_at < now() - interval '26 weeks';
end $$;
revoke all on function public.take_weekly_snapshots() from public, anon, authenticated;
select cron.schedule('befinden-weekly-snapshot', '0 3 * * 0', $$select public.take_weekly_snapshots()$$);
