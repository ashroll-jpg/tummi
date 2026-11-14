# Turning on shared crews (Firebase)

Tummi keeps shared crews in a free Firebase Firestore database. Free Firebase projects don't pause. You set this up once, in a web browser, in about 5 minutes.

## 1. Create the project
1. Go to https://console.firebase.google.com and sign in with a Google account.
2. Click **Create a project** (or **Add project**). Name it e.g. `tummi`. You can turn Google Analytics off.

## 2. Create the database
1. In the left menu open **Build → Firestore Database** and click **Create database**.
2. Pick a location near you (it can't be changed later) and choose **Start in production mode**.
3. Open the **Rules** tab, delete what's there, paste everything from [`firestore.rules`](firestore.rules), and click **Publish**.

## 3. Get the two values for the app
1. Click the gear icon next to **Project Overview → Project settings**.
2. Under **Your apps**, click the **web icon `</>`**, give it a nickname (e.g. `tummi-web`), leave Hosting unticked, and click **Register app**.
3. It shows a `firebaseConfig` block. You need `apiKey` and `projectId`.

## 4. Put them in the app
In `index.html`, near the top of the script:
```js
const FIREBASE = { apiKey: 'AIza...', projectId: 'tummi-12345' };
```
Commit to `main`; GitHub Pages updates in a minute or two. (Or send the two values to Claude to do it.)

## Using it
- The first time someone opens Tummi they're asked to **join or start a crew**. Later: Crew → Profiles → Data.
- One person taps **Start new**, picks a crew name and passcode (6+ characters), and shares both with friends.
- Friends tap **Join**, then pick themselves or tap **Add a friend** to add themselves.
- Changes sync about every 15 seconds and whenever the app is reopened. Offline changes sync when back online.

## Is it safe?
- `apiKey` and `projectId` are meant to be public; they only identify the project. The security rules do the protecting.
- A crew's address is a scrambled code made from its name + passcode. Nobody can list crews, so you can only open one if you know both. Phones store that code, not the passcode itself.
- Anyone with your crew name and passcode can see and change the crew's rankings, so share it only with the crew.
- Deleting a profile removes that person's rankings for everyone.
- There's no way to change a crew's passcode; start a new crew instead (people can bring their rankings across when joining).
