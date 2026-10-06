-- =====================================================================
-- CardSplit v2.9 — Short note on a card item (e.g. "diapers, soap")
-- Run ONCE in Supabase → SQL Editor → New query → paste → Run.
-- Only ADDS one empty column. It never drops, deletes or changes existing data.
-- Safe to run again (it skips the column if it already exists).
-- =====================================================================

alter table public.transactions add column if not exists note text;

-- Tell the Data API about the new column right away.
notify pgrst, 'reload schema';
