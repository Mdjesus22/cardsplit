-- =====================================================================
-- CardSplit v2.6 — Downpayment per person on an installment
-- Run ONCE in Supabase → SQL Editor → New query → paste → Run.
-- Only ADDS two columns to installment_shares. It never drops, deletes or changes existing data.
-- Safe to run again (it skips columns that already exist).
-- =====================================================================
alter table public.installment_shares add column if not exists downpayment numeric(12,2) not null default 0 check (downpayment >= 0);
alter table public.installment_shares add column if not exists downpayment_on date;

-- Tell the Data API about the new columns right away.
notify pgrst, 'reload schema';
