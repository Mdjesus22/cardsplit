-- =====================================================================
-- CardSplit — Money tab (household income vs expenses)
-- Run ONCE in Supabase → SQL Editor → New query → paste → Run.
-- Only ADDS things. It never drops, deletes or changes existing data.
-- Safe to run again (it skips anything that already exists).
-- =====================================================================

-- Mark a person as part of the household (e.g. your partner).
alter table public.people add column if not exists household boolean not null default false;

create table if not exists public.categories (
  id              bigint generated always as identity primary key,
  kind            text not null check (kind in ('income','expense')),
  name            text not null,
  monthly_budget  numeric(12,2),
  sort            int  not null default 0,
  active          boolean not null default true,
  created_at      timestamptz not null default now(),
  unique (kind, name)
);

-- Templates like "Salary on the 3rd and 18th" or "Meralco every 20th".
create table if not exists public.recurring (
  id               bigint generated always as identity primary key,
  kind             text not null check (kind in ('income','expense')),
  description      text not null,
  amount           numeric(12,2) not null check (amount > 0),
  category_id      bigint references public.categories(id),
  person_id        bigint references public.people(id),
  method           text,
  days             int[] not null,
  start_date       date not null default current_date,
  generated_until  date,
  active           boolean not null default true,
  created_at       timestamptz not null default now()
);

-- Every income or non-card expense.
create table if not exists public.entries (
  id            bigint generated always as identity primary key,
  kind          text not null check (kind in ('income','expense')),
  entry_date    date not null,
  amount        numeric(12,2) not null check (amount > 0),
  category_id   bigint references public.categories(id),
  person_id     bigint references public.people(id),
  method        text,                       -- Cash, GCash, Debit, Bank transfer…
  planned       boolean not null default true,   -- false = unplanned / surprise expense
  description   text,
  note          text,
  recurring_id  bigint references public.recurring(id) on delete set null,
  created_at    timestamptz not null default now()
);
create index if not exists entries_date on public.entries (entry_date);
create unique index if not exists entries_recurring_date on public.entries (recurring_id, entry_date) where recurring_id is not null;

-- Same owner-only security as the other tables.
do $$
declare t text;
begin
  foreach t in array array['categories','recurring','entries']
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
