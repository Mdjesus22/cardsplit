-- =====================================================================
-- CardSplit v2.3 — Safety box (your own savings) and loans paid back into it
-- Run ONCE in Supabase → SQL Editor → New query → paste → Run.
-- Only CREATES two new tables. It never drops, deletes or changes existing data.
-- Safe to run again (it skips anything that already exists).
-- =====================================================================

-- A loan from the safety box: a card ride you paid with your own money, or plain cash you lent.
create table if not exists public.vault_loans (
  id                  bigint generated always as identity primary key,
  person_id           bigint not null references public.people(id),
  charge_id           bigint references public.charges(id) on delete set null,   -- the card ride it covers (optional)
  item                text not null,
  principal           numeric(12,2) not null check (principal > 0),
  months              int not null check (months > 0),
  interest_per_month  numeric(12,2) not null default 0 check (interest_per_month >= 0),
  first_due           date not null,                                             -- first monthly payment
  status              text not null default 'active' check (status in ('active','closed')),
  note                text,
  created_at          timestamptz not null default now()
);
create unique index if not exists vault_loans_charge on public.vault_loans (charge_id) where charge_id is not null;

-- Every peso in or out of the safety box.
--   deposit  = you put money in        withdraw = you took money out
--   lend     = money out for a loan    repay    = a loan payment put back in
create table if not exists public.vault_moves (
  id          bigint generated always as identity primary key,
  kind        text not null check (kind in ('deposit','withdraw','lend','repay')),
  amount      numeric(12,2) not null check (amount > 0),
  move_date   date not null default current_date,
  loan_id     bigint references public.vault_loans(id) on delete cascade,
  note        text,
  created_at  timestamptz not null default now()
);
create index if not exists vault_moves_loan on public.vault_moves (loan_id);

-- Security: same rule as the other tables (only you, the owner, can read or change them).
do $$
declare t text;
begin
  foreach t in array array['vault_loans','vault_moves']
  loop
    execute format('alter table public.%I enable row level security', t);
    if not exists (select 1 from pg_policies
                   where schemaname = 'public' and tablename = t and policyname = 'owner_only') then
      execute format(
        'create policy owner_only on public.%I for all to authenticated
           using ((select auth.uid()) = public.app_owner())
           with check ((select auth.uid()) = public.app_owner())', t);
    end if;
    execute format('grant select, insert, update, delete on public.%I to authenticated', t);
  end loop;
end $$;

-- Tell the Data API about the new tables right away.
notify pgrst, 'reload schema';
