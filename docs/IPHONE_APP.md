# Tummi iPhone app (TestFlight)

The iPhone app is the same Tummi, packaged with [Capacitor](https://capacitorjs.com). The iOS project lives in `ios/`. Your crew installs it through Apple's **TestFlight** app from an invite link.

You need a Mac. Steps marked **once** are only done the first time.

---

## 1. Apple Developer account (once)
1. Go to https://developer.apple.com/programs/enroll and enroll as an **Individual** ($99/year).
2. Approval is often quick but can take up to 48 hours. You'll get an email.

## 2. Tools on your Mac (once)
1. Install **Xcode** from the Mac App Store (large download). Open it once, accept the license, and let it install the **iOS** platform when asked.
2. Install **Node.js** (the LTS version) from https://nodejs.org.
3. Open **Xcode → Settings → Accounts**, click **+**, choose **Apple ID**, and sign in with your developer account.

## 3. Get the project and open it in Xcode
In **Terminal**:
```bash
git clone https://github.com/ashroll-jpg/tummi.git
cd tummi
npm install
npm run ios
```
`npm run ios` copies the app into the iOS project and opens Xcode. Next time, run `git pull` then `npm install` and `npm run ios`.

## 4. Signing (once)
1. In Xcode's left sidebar, click **App** (blue icon at the top), then the **App** target, then the **Signing & Capabilities** tab.
2. Tick **Automatically manage signing** and choose your name under **Team**.
3. **Bundle Identifier** is `com.ashrolljpg.tummi`. If Xcode says it's taken, change it to something unique like `com.yourname.tummi`. Pick it before the first upload, because it can't change later.

## 5. Try it on your own iPhone (optional, recommended)
1. Plug your iPhone into the Mac and tap **Trust** on the phone.
2. At the top of Xcode, pick your iPhone in the device menu and press **▶** (Run).
3. The first time, the phone asks you to turn on **Settings → Privacy & Security → Developer Mode** and restart.
4. Check: crew sync, the map, restaurant search, I'm here now, adding a photo, and Share on a list.

## 6. Create the app in App Store Connect (once)
1. Go to https://appstoreconnect.apple.com → **Apps** → **+** → **New App**.
2. Platform **iOS**. Name **Tummi** (if taken, try "Tummi: Rank with Friends"). Language English. Bundle ID: pick the one from step 4. SKU: `tummi`. Access: Full.

## 7. Upload a build
1. In Xcode's device menu choose **Any iOS Device (arm64)**.
2. **Product → Archive**. When it finishes, the Organizer opens.
3. Click **Distribute App** → **App Store Connect** → **Distribute**. Accept the defaults.
4. Apple processes the build in roughly 10–30 minutes and emails you when it's ready.

## 8. Invite the crew with TestFlight
1. In App Store Connect, open the app → **TestFlight** tab.
2. Under **Test Information**, fill in a short beta description and a feedback email. This is required for outside testers.
3. Under **External Testing**, click **+** to make a group (e.g. "Crew"), add your build, and **Submit for Review**. Beta review usually takes under a day.
4. Once approved, open the group and turn on **Public Link**. Send that link to your friends.
5. Friends install **TestFlight** from the App Store, tap your link, then tap **Install**.

---

## Shipping an update
1. On your Mac: `git pull`, `npm install`, `npm run ios`.
2. In Xcode, **App** target → **General** → raise **Build** by 1 (it must go up on every upload). **Version** matches `APP_VERSION` in `index.html`.
3. **Product → Archive** → **Distribute App** → **App Store Connect**.
4. Testers get the new build automatically in TestFlight. Builds expire after 90 days, so upload at least that often.

The website (GitHub Pages) still updates as soon as changes are merged. The app only updates when you upload a new build.
