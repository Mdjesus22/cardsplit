-- =====================================================================
-- CardSplit v1.7 — "expected money" (salary or other money not received yet)
-- Run ONCE in Supabase → SQL Editor → New query → paste → Run.
-- Only ADDS one column to entries. It never drops, deletes or changes existing data.
-- Safe to run again (it skips the column if it's already there).
-- =====================================================================
alter table public.entries add column if not exists expected boolean not null default false;

-- Tell the Data API about the new column right away.
notify pgrst, 'reload schema';
