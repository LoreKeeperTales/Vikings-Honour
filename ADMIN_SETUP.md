# Viking's Honour V1.3.6 — One-time administrator setup

1. Your Supabase SQL was already run successfully; do not need to run it again.
2. Open `supabase-config.js` in a text editor.
3. Replace `PASTE_YOUR_SB_PUBLISHABLE_KEY_HERE` with the **Publishable key** from Supabase → Project Settings → API Keys. Never use a secret/service_role key.
4. Upload **index.html**, **multiplayer.js**, **supabase-config.js** and other package files together to the root of your GitHub Pages repository.
5. Enable GitHub Pages (Settings → Pages) and open the published URL over HTTPS.
6. Players click Online Campaigns, sign up/sign in, then join with the invitation code. No Supabase settings required on player devices.
7. If email confirmation is enabled in Supabase Auth, users must confirm their emails before signing in. Configure Site URL and Redirect URLs in Supabase Authentication → URL Configuration to match your GitHub Pages site.

## Testing
- Owner signs up, creates a campaign and copies the invitation code.
- Friend signs up separately and joins using that code.
- Owner publishes the town; friend loads it. Town updates are currently manual.
- Each player saves their character online and downloads JSON at session end.

## Security
The publishable key and project URL are public and safe in browser code only when database Row Level Security is properly configured. Never upload database passwords or Supabase secret/service_role keys.

## Limitations
This is an integration test build, not a verified live multiplayer deployment. The site still requires the administrator to add the publishable key, deploy files, and test sign-in and sharing.
