# Viking's Honour V1.3.4 — Online multiplayer test

## What is included
The original V1.3.3 character creation, handbook, town sheet, Compendium, and local JSON backup remain in `index.html`. `multiplayer.js` adds account sign-in, Lorekeeper campaign creation, join-by-code, member-only town reading, owner/manager town publishing, personal online character save/load, and an end-session JSON backup reminder.

## Supabase (free tier)
1. Sign up at https://supabase.com and create a project.
2. Open **SQL Editor** and run all of `supabase_setup.sql` once on a fresh project.
3. Open **Project Settings → API** (or **Connect** in newer UI) and copy the **Project URL** and **publishable** key (or legacy anon key). **NEVER use a secret/service_role key in the browser.**
4. In **Authentication → Providers → Email**, enable email/password sign-in. If email confirmation is enabled, each player must confirm their email before signing in.
5. Open the app's **Online Campaigns** tab, paste the Project URL and publishable key, and press Save connection settings.

## Hosting
GitHub Pages: upload `index.html`, `multiplayer.js` and the other package files to the same repository root, enable Pages from the main branch root. The Supabase URL and publishable key are browser-visible by design; database access is protected by RLS. Use HTTPS hosting, not a local `file://` URL, for reliable module imports and authentication.

## Test with a friend
1. Both open the same GitHub Pages URL and enter the same Supabase connection settings on their own devices.
2. Both create and sign into separate accounts.
3. Lorekeeper opens Town Sheet, optionally edits a town, then Online Campaigns → Create campaign. Share the invitation code.
4. Friend opens Online Campaigns → Join campaign, enters code, presses Refresh, then chooses the campaign.
5. Lorekeeper chooses campaign and presses **Publish my town** after making changes. Friend presses **Load shared town** to view it. This is **manual synchronization** for this first test, not automatic shared editing.
6. Each player creates/edits their own character and presses **Save character online**. They can also **Load online character** on a second device while signed into the same account.
7. At session end press **End my session**, then **Save online** and **Download JSON**.

## Known limitations of this first test
- The town view uses the existing editable Town Sheet UI; players must not publish it, and the server enforces this. The app does not yet offer a dedicated read-only player town UI.
- Town updates are published and loaded manually. Realtime notifications indicate when the shared town changed, but do not automatically replace local edits.
- A character's online record is separate from its local JSON backup. Character saves are explicit, not automatic. Keep JSON exports as additional backups.
- The existing app has one locally active character and one locally active town. Multiple character selection, campaign-specific character assignment, shared town shops, transaction-safe Daler spending, and automated cross-campaign gear upgrades are future phases.
- The invite code grants membership immediately; Lorekeeper approval is not yet implemented. Share codes only with intended players.
- There is no automatic scheduled reminder; the in-app end-session prompt reminds players to download their character.
- No account, database or GitHub Pages site is created by this ZIP. You must complete setup and publish it yourself.
