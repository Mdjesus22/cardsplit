# CardSplit — setup guide (about 30 minutes, all free)

You will make 2 free accounts:
- **Supabase**: your database and login.
- **GitHub**: hosts the website and runs a daily "keep awake" ping.

## What's in this folder

| File | What it is | Goes where |
|---|---|---|
| `database/1-schema.sql` | Creates the tables and security rules | Supabase SQL Editor (run once) |
| `../cardsplit-PRIVATE/2-seed-PRIVATE.sql` | Your Jan 2025 – Feb 2026 data from Sheet20. Kept **outside** this repo on purpose. | Supabase SQL Editor (run once). **Never upload to GitHub.** |
| `index.html` | The app | GitHub (this repo) |
| `.github/workflows/keep-alive.yml` | Daily ping so Supabase never pauses | GitHub (this repo) |

Both SQL files only **add** things. They never drop or delete anything. If you run one twice, it either skips what already exists (schema) or stops with a message and changes nothing (seed).

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

1. On **Home**, tap **📄 Upload statement PDF**, then choose the e-statement PDF.
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
