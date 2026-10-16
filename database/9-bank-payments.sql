-- =====================================================================
-- CardSplit v3.2 — Pay a card bill in parts (e.g. half via bank app, half via GCash)
-- Run ONCE in Supabase → SQL Editor → New query → paste → Run.
-- Only CREATES one new table. It never drops, deletes or changes existing data.
-- Safe to run again (it skips anything that already exists).
-- =====================================================================

-- One row per payment you made to the bank for a card's statement.
create table if not exists public.bank_payments (
  id          bigint generated always as identity primary key,
  card_id     bigint not null references public.cards(id) on delete cascade,
  month       date   not null check (extract(day from month) = 1),   -- statement month the payment is for
  amount      numeric(12,2) not null check (amount > 0),
  paid_on     date   not null default current_date,
  paid_from   text,                                                  -- e.g. Bank app, GCash, Maya
  note        text,
  created_at  timestamptz not null default now()
);
create index if not exists bank_payments_card_month on public.bank_payments (card_id, month);

-- Security: same rule as the other tables (only you, the owner, can read or change it).
alter table public.bank_payments enable row level security;
do $$
begin
  if not exists (select 1 from pg_policies
                 where schemaname = 'public' and tablename = 'bank_payments' and policyname = 'owner_only') then
    create policy owner_only on public.bank_payments for all to authenticated
      using ((select auth.uid()) = public.app_owner())
      with check ((select auth.uid()) = public.app_owner());
  end if;
end $$;
grant select, insert, update, delete on public.bank_payments to authenticated;

-- Tell the Data API about the new table right away.
notify pgrst, 'reload schema';
