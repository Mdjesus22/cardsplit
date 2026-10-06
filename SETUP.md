# CardSplit — setup guide (about 30 minutes, all free)

You will make 2 free accounts:
- **Supabase**: your database and login.
- **GitHub**: hosts the website and runs a daily "keep awake" ping.

## What's in this folder

| File | What it is | Goes where |
|---|---|---|
| `database/1-schema.sql` | Creates the tables and security rules | Supabase SQL Editor (run once) |
| `../cardsplit-PRIVATE/2-seed-PRIVATE.sql` | Your Jan 2025 – Feb 2026 data from Sheet20. Kept **outside** this repo on purpose. | Supabase SQL Editor (run once). **Never upload to GitHub.** |
| `database/3-money.sql` | Money tab tables (income, expenses, recurring) | Supabase SQL Editor (run once, Part F) |
| `database/4-expected.sql` | Lets you add expected money (not received yet) | Supabase SQL Editor (run once, Part G) |
| `database/5-safety-box.sql` | Safety box: your savings and loans paid back into it | Supabase SQL Editor (run once, Part H) |
| `database/6-downpayment.sql` | Downpayment per person on an installment | Supabase SQL Editor (run once, Part I) |
| `database/7-outside-bills.sql` | Outside bills you pay in cash for someone (e.g. St. Peter) | Supabase SQL Editor (run once, Part J) |
| `index.html` | The app | GitHub (this repo) |
| `.github/workflows/keep-alive.yml` | Daily ping so Supabase never pauses | GitHub (this repo) |

All SQL files only **add** things. They never drop or delete anything. If you run one twice, it either skips what already exists (schema) or stops with a message and changes nothing (seed).

---

## Part A — Supabase (database + login)

1. Go to **supabase.com** → **Start your project** → sign in with GitHub (or email).
2. Click **New project**.
   - Name: `cardsplit`
   - Database password: click **Generate**, then save it somewhere safe. The app doesn't need it.
   - Region: **Southeast Asia (Singapore)**, the closest to you.
   - Click **Create new project** and wait about 2 minutes.
3. **Create the tables:**
   - Left menu → **SQL Editor** → **New query**.
   - Open `database/1-schema.sql`, copy everything, paste it in, then click **Run**.
   - You should see *"Success. No rows returned"*.
4. **Create your login. Do this before step 5.**
   - Left menu → **Authentication** → **Users** → **Add user** → **Create new user**.
   - Type your email and a strong password, and tick **Auto Confirm User**.
   - Click **Create user**.
   - The **first** user becomes the owner. Nobody else can see your data, even if they make an account.
5. **Turn off sign-ups (extra safety):**
   - Go to **Authentication** → **Sign In / Providers**.
   - Turn **off** "Allow new users to sign up", then click **Save**.
   - The label may be slightly different in your dashboard.
6. **Load your data:**
   - Go to **SQL Editor** → **New query**.
   - Paste everything from `cardsplit-PRIVATE/2-seed-PRIVATE.sql` (the folder next to this one), then click **Run**.
   - It may take a few seconds.
   - Check: in **Table Editor**, the `transactions` table should have **432** rows.
7. **Copy 2 values** into a notepad:
   - **Project URL**: go to **Project Settings** → **Data API**. It looks like `https://abcdefghijkl.supabase.co`.
   - **Publishable key**: go to **Project Settings** → **API Keys** → **Publishable key** → copy. It looks like `sb_publishable_...`.
   - The publishable key is safe to put on a website. Your security rules protect the data.
   - **Never** use the *secret* key in the app.

## Part B — Put your values in the app

8. Open `index.html` in Notepad or VS Code. Near the top, find this:
   ```js
   const CONFIG = {
     SUPABASE_URL: '',
     SUPABASE_KEY: '',
   };
   ```
   Paste your values between the quotes, then save:
   ```js
     SUPABASE_URL: 'https://abcdefghijkl.supabase.co',
     SUPABASE_KEY: 'sb_publishable_xxxxxxxx',
   ```

## Part C — GitHub (website + keep-alive)

9. On **github.com** (logged in as **Mdjesus22**), create an **empty public** repository named `cardsplit`. Don't add a README.
10. In this folder (`ai apps\cardsplit`) the files are already committed. Open a terminal here and run:
    ```
    git push -u origin main
    ```
11. Every time you change `index.html` (for example, after pasting your Supabase values in step 8), run:
    ```
    git add index.html
    git commit -m "Update config"
    git push
    ```
12. **Turn on the website:**
    - Go to **Settings** → **Pages**.
    - Under **Build and deployment**, set Source to **Deploy from a branch**, Branch to **main**, and Folder to **/ (root)**.
    - Click **Save**.
    - After 1–2 minutes your link appears: **`https://YOUR-USERNAME.github.io/cardsplit/`**
13. **Test the keep-alive:**
    - Go to **Actions** → **Keep Supabase awake** → **Run workflow**.
    - It should turn green ✓.
    - After that it runs by itself every day.

## Part D — First login

14. Open your link and log in with the email and password from step 4.
15. You'll see **"32 installment months added"**. These are Mar–Oct 2026 for your 4 ongoing installments:
    - 300K house loan
    - 210K termination loan
    - Octagon (Jane)
    - Ref Panasonic (Mami Pilar)

    They start as **Unpaid**. For each person who already paid you:
    - Go to **People** → tap the person → **Record a payment**.
    - The payment is applied to their oldest items first.
16. On your phone, open the link in Chrome → **⋮** → **Add to Home screen**. Now it opens like an app.

---

## Part E — Upload a statement PDF (RCBC)

1. On **Home**, tap **Upload statement PDF**, then choose the e-statement PDF.
2. If the PDF has a password, type it in. The app doesn't save it.
3. Tap **Read PDF** and check the list:
   - **Payments to the bank** (CASH PAYMENT) are skipped automatically.
   - **Lines already in the app** are unticked, so you can upload the same PDF twice safely.
   - **Installment lines** (like `VIVO 06/12`) are matched to your plan. If it's a new installment, tick **Also create this installment plan**.
   - The **due date, total due and minimum due** are filled in from the PDF. Check them.
4. Pick who pays for each line, or use **Set everyone ticked to**. Then tap **Import**.
5. To split a line between people, open it from **Transactions** afterwards.

The PDF is read on your own phone or computer. It is never uploaded anywhere.
If the app says **"No transactions found"**, tap **Copy the PDF text for Claude** and send it to me. Card numbers are hidden automatically.

## Part F — Money tab (income vs expenses)

1. In Supabase → **SQL Editor** → **New query**, paste everything from `database/3-money.sql` and click **Run**. It only adds the new tables.
2. Reload the app. The **Money** tab sets up default categories by itself.
3. On **People**, open your partner, tick **Household (partner)**, then tap **Save name**. Their income and their share of card purchases now count as "ours".
4. Add your salary as **Recurring** (Money → Recurring → e.g. days `3, 18`), so it's added automatically each payday.

What counts:
- **Expenses** = your household's share of card bills, counted in the month the bill is **due** (the Sep statement counts in Oct) + cash/GCash/debit expenses you add.
- **Not counted:** riders' shares, paying your card bill (already counted as purchases), and money riders pay back to you.
- Tag surprise spending as **Unplanned** and filter Planned/Unplanned at the top of Money.

## Part G — Expected money and Cash outlook (v1.7)

1. In Supabase → **SQL Editor** → **New query**, paste everything from `database/4-expected.sql` and click **Run**. It only adds one column. It's safe to run twice.
2. Reload the app (Ctrl+Shift+R). Go to **Money** → **Cash outlook**.
3. Type **Money you have now** (bank + cash + GCash). It's saved on that phone or laptop only, so update it when it changes.
4. Tap **＋ Expected money** for salary or other money that hasn't come in yet (pick the date you expect it). Tap **＋ Upcoming expense** for something you'll pay soon (not card bills).
5. The outlook works per round of card dues (tabs like **Oct dues**, **Nov dues**). Each round counts money coming in up to the **last card due date** of that month (e.g. Oct 19). Money after that goes to the next round's dues, and what's left (or still short) carries over. It adds expected money, recurring salary and bills, card bills you haven't ticked as paid, and **everything riders owe you** (on their promise date, or by the due date of the bill if there's none; overdue amounts count today), then tells you if you'll run short, how much to borrow, by when, and when you can pay it back.
6. When the money arrives, tap **Got it**, then update **Money you have now**.

Expected money doesn't count in the Money **Summary** until you tap **Got it**. Recurring income (salary) is added as expected too, so tap **Got it** when it arrives.

## Part H — Safety box (v2.3)

1. In Supabase → **SQL Editor** → **New query**, paste everything from `database/5-safety-box.sql` and click **Run**. It only adds two new tables. It's safe to run twice.
2. Reload the app (Ctrl+Shift+R). Go to **Money** → **Safety box** (or ☰ → Safety box).
3. Tap **＋ Put money in** and enter what's in the box now (note: "Starting balance").
4. **Card ride paid with your own money** (e.g. Mami Pilar's): open the ride on **Cards** → under her name tap **Pay this from the safety box (installments)** → set months, interest per month and first payment → **Save loan**.
   - The ride stays on its statement, marked **Safety box**. The box pays that part of the bill (it shows in the Cash outlook as money in on the due date).
   - It's no longer counted as "still owes you" for the card; People shows it as a separate safety box loan.
5. **Cash you lend** from the box: **Safety box** → **＋ Lend money**.
6. When they pay you back, open the loan → **Record a payment back into the box**. Paybacks go into the box only. They don't count in the Money summary or the Cash outlook.
7. "Money you have now" in the Cash outlook should **not** include the safety box.

## Part I — Installments: downpayment and early months (v2.6)

1. In Supabase → **SQL Editor** → **New query**, paste everything from `database/6-downpayment.sql` and click **Run**. It only adds two columns. It's safe to run twice.
2. **Downpayment:** Cards → Installments → open the plan → **Edit** → under the person, type the **Downpayment ₱** and the date you got it → **Save**.
   - It pays **their last months first** (e.g. ₱5,000 at ₱1,723.74/month = months 17–18 + ₱1,552.52 of month 16). Their monthly payments are unchanged until then.
   - Until those months come, it shows on People under **Advances you're holding** (keep it in your wallet). It's applied by itself when each of those months is added.
3. **Early months:** Cards → Installments shows "N installments start after month 1" when a plan began before your records. Tap **Add the early months** → **Add as paid** (if everyone already paid you) or **Add as unpaid**.

## Part J — Outside bills / paluwal (v2.8)

1. In Supabase → **SQL Editor** → **New query**, paste everything from `database/7-outside-bills.sql` and click **Run**. It only adds two columns. It's safe to run twice.
2. ☰ → **Outside bills** → **＋ Add outside bill** (one per account, e.g. "St. Peter – Ella (account 1)"):
   - **Amount every month**, **Due day**, **First due month to track** (e.g. this month), **Last due month**.
   - **Who pays you back** (e.g. Ella), **Their share** (blank = all of it), **They usually pay you on day** (optional).
3. Each month shows on Cards as an "Oct 2026 bill" item and on People as what they owe you. Record their payment the usual way (People → person → Record a payment).
4. Cash outlook: you pay in cash on the **due date**; their money comes in on **their usual pay day**. Each lands in the right dues round. Bills don't change your card rounds (Oct dues still end on the last *card* due date).
5. Only your own share (if any) counts in the Money summary.

## Part K — Short note on a card item (v2.9)

1. In Supabase → **SQL Editor** → **New query**, paste everything from `database/8-item-note.sql` and click **Run**. It only adds one empty column. It's safe to run twice.
2. Open any card item (Cards → tap the item) → **What is it? (short note, optional)** → type e.g. `diapers, soap` → **Save**.
3. The note shows in small grey text beside the name, e.g. **SHOPEE PH MANDALUYONG** diapers, soap. It shows on Cards, People and Money → category list.
4. The Cards search also finds notes (search `diaper` finds that Shopee item).

---

## Good to know

- **To see the app without logging in:** add `?demo` to the link. It's an empty practice copy, and nothing is saved.
- **Backup:** ☰ → **Export backup (Excel)** downloads everything. Do it once a month.
- **Free plan limits:**
  - Supabase pauses a free project after 7 days without activity. The daily ping prevents this.
  - GitHub turns off scheduled workflows in a public repository after **60 days** with no repository changes. GitHub emails you first. If that happens, go to **Actions** → **Keep Supabase awake** → **Enable workflow**.
  - Using the app regularly also keeps Supabase awake.
- **Updating the app later:** upload the new `index.html` to the same repository, replacing the old one. Your data is in Supabase, so it is not affected.
- **Changing an installment's split** only affects months the app hasn't created yet.
