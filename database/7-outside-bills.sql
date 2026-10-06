-- =====================================================================
-- CardSplit v2.8 — Outside bills (paid in cash for someone, e.g. St. Peter)
-- Run ONCE in Supabase → SQL Editor → New query → paste → Run.
-- Only ADDS two columns. It never drops, deletes or changes existing data.
-- Safe to run again (it skips columns that already exist).
-- =====================================================================
alter table public.cards add column if not exists kind text not null default 'card' check (kind in ('card','bill'));
alter table public.installments add column if not exists collect_day int check (collect_day between 1 and 31);

-- Tell the Data API about the new columns right away.
notify pgrst, 'reload schema';
