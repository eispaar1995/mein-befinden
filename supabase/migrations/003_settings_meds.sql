-- Medikamenten- und Supplementliste (pro Nutzer), Einnahmen stehen im Tagesdokument (days.data.meds / days.data.bedarf).
alter table public.settings add column if not exists meds jsonb not null default '[]'::jsonb;
