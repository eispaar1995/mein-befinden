# Mein Befinden

Private Stimmungs- und Befindens-Tracking-App (PWA). Check-ins morgens/mittags/abends, Abendreflexion,
Beeinträchtigungen A–D und Auswertung als Bericht. Daten liegen in Supabase (EU), geschützt durch Login und Row Level Security.

- `index.html` – die App (ohne Build-Schritt)
- `config.js` – Supabase-URL und öffentlicher (publishable) Key
- `supabase/migrations/` – Datenbankschema
- Backup-Dateien mit Gesundheitsdaten gehören **nicht** ins Repo (`.gitignore`).
