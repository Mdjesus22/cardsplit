-- =====================================================================
-- Finance App — database setup
-- Run ONCE in Supabase → SQL Editor → New query → paste → Run.
-- Only CREATES things. It never drops, deletes or changes existing data.
-- Safe to run again (it skips anything that already exists).
-- =====================================================================

-- Owner = the first user in Authentication → Users (you).
-- Nobody else can read or change anything, even if they sign up.
create or replace function public.app_owner() returns uuid
language sql stable security definer set search_path = ''
as $$ select id from auth.users order by created_at limit 1 $$;
revoke all on function public.app_owner() from public;
grant execute on function public.app_owner() to authenticated;

-- Keep-alive ping (used by the daily GitHub Action so the free project never pauses).
create or replace function public.ping() returns text
language sql stable as $$ select 'ok'::text $$;
grant execute on function public.ping() to anon, authenticated;

-- ---------------------------------------------------------------------
-- Tables
-- ---------------------------------------------------------------------
create table if not exists public.cards (
  id          bigint generated always as identity primary key,
  code        text not null unique,                 -- e.g. RCBCBLCK
  bank        text,                                 -- e.g. RCBC Black
  last4       text check (last4 ~ '^[0-9]{4}$'),    -- last 4 digits only
  due_day     int  check (due_day between 1 and 31),
  cutoff_day  int  check (cutoff_day between 1 and 31),
  active      boolean not null default true,
  created_at  timestamptz not null default now()
);

create table if not exists public.people (
  id          bigint generated always as identity primary key,
  name        text not null unique,
  kind        text not null default 'person'
              check (kind in ('me','person','group','company','bucket')),
  active      boolean not null default true,
  created_at  timestamptz not null default now()
);

-- One row per card per statement month (due date + "paid to bank" tick).
create table if not exists public.statements (
  id            bigint generated always as identity primary key,
  card_id       bigint not null references public.cards(id),
  month         date   not null check (extract(day from month) = 1),
  due_date      date,
  total_due     numeric(12,2),
  min_due       numeric(12,2),
  paid_to_bank  boolean not null default false,
  paid_on       date,
  note          text,
  unique (card_id, month)
);

create table if not exists public.installments (
  id               bigint generated always as identity primary key,
  card_id          bigint not null references public.cards(id),
  item             text not null,
  reason           text,
  original_amount  numeric(12,2),
  monthly_amount   numeric(12,2) not null check (monthly_amount > 0),
  months           int  not null check (months > 0),
  first_month      date not null check (extract(day from first_month) = 1),
  status           text not null default 'active' check (status in ('active','ended_early')),
  ended_month      date,
  notes            text,
  created_at       timestamptz not null default now()
);

-- Default monthly split of an installment (used to create each new month).
create table if not exists public.installment_shares (
  id              bigint generated always as identity primary key,
  installment_id  bigint not null references public.installments(id) on delete cascade,
  person_id       bigint not null references public.people(id),
  monthly_share   numeric(12,2) not null check (monthly_share >= 0),
  unique (installment_id, person_id)
);

-- One row per statement line (an installment month is also one row).
create table if not exists public.transactions (
  id              bigint generated always as identity primary key,
  card_id         bigint not null references public.cards(id),
  month           date   not null check (extract(day from month) = 1),  -- statement month
  txn_date        date,
  description     text   not null,
  category        text,
  amount          numeric(12,2) not null,
  installment_id  bigint references public.installments(id) on delete cascade,
  installment_no  int check (installment_no > 0),
  source          text not null default 'manual' check (source in ('manual','pdf','import','auto')),
  created_at      timestamptz not null default now()
);
create unique index if not exists transactions_installment_month
  on public.transactions (installment_id, installment_no) where installment_id is not null;
create index if not exists transactions_month on public.transactions (month);

-- Who should pay for a transaction (a split = several rows).
create table if not exists public.charges (
  id              bigint generated always as identity primary key,
  transaction_id  bigint not null references public.transactions(id) on delete cascade,
  person_id       bigint not null references public.people(id),
  amount          numeric(12,2) not null,
  promise_date    date,          -- "remaining will be paid on this date"
  note            text,
  unique (transaction_id, person_id)
);
create index if not exists charges_person on public.charges (person_id);

-- Money received for a charge (several rows = staggered payments).
create table if not exists public.collections (
  id           bigint generated always as identity primary key,
  charge_id    bigint not null references public.charges(id) on delete cascade,
  amount       numeric(12,2) not null check (amount <> 0),   -- negative = refund you gave back
  received_on  date not null default current_date,
  note         text,
  created_at   timestamptz not null default now()
);
create index if not exists collections_charge on public.collections (charge_id);

-- ---------------------------------------------------------------------
-- Security: Row Level Security + Data API access for logged-in owner only
-- ---------------------------------------------------------------------
do $$
declare t text;
begin
  foreach t in array array['cards','people','statements','installments',
                           'installment_shares','transactions','charges','collections']
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
