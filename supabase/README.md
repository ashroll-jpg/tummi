# Turning on shared crews

Tummi stores shared crews in a free Supabase database. You set this up once (about 5 minutes) and everyone in your crew uses it.

1. Create a free account at https://supabase.com and click **New project**. Any name, region near you, and save the database password somewhere (Tummi doesn't need it).
2. In the project, open **SQL Editor → New query**, paste everything in [`setup.sql`](setup.sql), and click **Run**. It should say "Success. No rows returned".
3. Open **Project Settings → API** (or **Data API** / **API Keys**). Copy:
   - the **Project URL**, like `https://abcdefgh.supabase.co`
   - the **anon** (or **publishable**) key. Not the `service_role` / secret key.
4. Put both in `index.html`, near the top of the script:
   ```js
   const SUPABASE_URL = 'https://abcdefgh.supabase.co';
   const SUPABASE_KEY = 'your-anon-or-publishable-key';
   ```
5. Commit to `main`. GitHub Pages updates in a minute or two.

## Using it

- The first time someone opens Tummi they're asked to **join or start a crew**. Later: Crew → Profiles → Data.
- One person taps **Start new**, picks a crew name and passcode (6+ characters), and shares both with friends.
- Friends tap **Join**, then pick themselves or tap **Add a friend** to add themselves.
- Changes sync about every 15 seconds and whenever the app is reopened. Offline changes sync when you're back online.

## Is it safe?

- The URL and anon key are meant to be public. The tables are locked; the only way in is through functions that check the crew name and passcode (stored hashed).
- Anyone with your crew name and passcode can see and change the crew's rankings, so share it only with the crew.
- Deleting a profile deletes that person's rankings for everyone.
- Supabase pauses free projects after about a week with no use. Open the Supabase dashboard and click **Restore** if that happens; data is kept.
