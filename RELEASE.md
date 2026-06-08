# Releasing Passport Quest to the App Store

A start-to-finish guide. Everything from "Archive" onward **must be done on a Mac
with Xcode** — it can't happen in this cloud container. Budget ~half a day the
first time (most of it is account setup and metadata, not code).

---

## 0. Prerequisites (one-time)
1. **A Mac** with the latest **Xcode** (App Store → Xcode).
2. **Apple Developer Program** membership — **$99/year**.
   Enrol at <https://developer.apple.com/programs/>. Approval can take 24–48 h.
3. An **App Store Connect** account (comes with the membership):
   <https://appstoreconnect.apple.com>.
4. A **privacy policy URL** (required for the Kids Category). A simple page
   stating "this app collects no data" is enough — host it anywhere public
   (GitHub Pages works). Wording: see §6.

---

## 1. Open the project on your Mac
```bash
git clone <this repo>
cd mdgonsalvez
open PassportQuest.xcodeproj      # the generated Xcode project
```
> The repo also has `PassportQuest.swiftpm` (Swift Playgrounds). For App Store
> submission use the **`.xcodeproj`** — it's the one set up for signing/archiving.

If you ever change the bundle ID, version, or add/remove files, regenerate the
project: `python3 tools/generate_pbxproj.py`.

## 2. Two remaining blockers to clear first
1. **App icon (required).** `PassportQuest/Assets.xcassets/AppIcon.appiconset`
   currently has no image. In Xcode, select `Assets` → `AppIcon` and drag in a
   **1024×1024 PNG** (no transparency, no rounded corners — Apple rounds it).
   A single 1024 image fills all slots with the modern "single size" icon.
   *(I can generate a placeholder passport-themed icon to unblock TestFlight if
   you want — just ask.)*
2. **Bundle ID.** It's set to `com.mdgonsalvez.passportquest`. If you want a
   different one, edit `BUNDLE_ID` in `tools/generate_pbxproj.py`, re-run it, or
   change it in Xcode → target → **Signing & Capabilities**.

## 3. Signing
Xcode → select the **PassportQuest** target → **Signing & Capabilities**:
- Tick **Automatically manage signing**.
- Choose your **Team** (your Developer account).
- Confirm the **Bundle Identifier** matches what you'll register in App Store
  Connect (next step). Xcode will create the signing certificate/profile for you.

## 4. Set version & build
Target → **General**:
- **Version** (Marketing) = `1.0`  ·  **Build** = `1`.
  (Bump **Build** every upload; bump **Version** for each public release.)

## 5. Create the app record in App Store Connect
<https://appstoreconnect.apple.com> → **Apps → ➕ → New App**:
- Platform **iOS**, your **Bundle ID**, a **Name** ("Passport Quest" — must be
  globally unique; have a backup like "Passport Quest: World Game"), primary
  language, and an **SKU** (any string, e.g. `passportquest01`).

Then fill **App Information**:
- **Category:** Primary = **Education** (Secondary optional, e.g. Games).
- **Age rating:** complete the questionnaire — all "None"; this yields **4+**.
- **Kids Category:** in App Information, set the **Kids** category and the age
  band **9–11** (best fit for this game). This adds the requirements in §6.

## 6. Kids Category compliance (important)
Apple reviews kids' apps strictly. This app is already built to comply — confirm:
- ✅ **No third-party ads, no tracking, no analytics SDKs.**
- ✅ **No data collection** — declare **"Data Not Collected"** in App Privacy
  (matches the bundled `PrivacyInfo.xcprivacy`). All progress is on-device.
- ✅ **No external links / no purchases** for kids → no parental gate needed.
  (If you ever add an "About" link or anything leaving the app, it must sit
  behind a parental gate.)
- ⚠️ **Privacy Policy URL is required** — paste your hosted URL. Minimal text:
  > *"Passport Quest does not collect, store, or share any personal data. All
  > game progress stays on your device. There are no ads, no tracking, no
  > accounts, and no in-app purchases."*

## 7. App Store metadata
Per the version's page:
- **Subtitle** (30 chars), **Promotional text**, **Description**, **Keywords**
  (geography, kids, countries, flags, learning, capitals…), **Support URL**.
- **Screenshots** (required): use the iOS **Simulator** (iPad Pro 12.9" and
  iPhone 6.7") → run the app → `Cmd-S` to save each shot. Provide the required
  sizes for iPad (this is iPad-first) and iPhone if you keep iPhone enabled.

## 8. Archive & upload
1. In Xcode's toolbar set the run destination to **Any iOS Device (arm64)**
   (you cannot archive against a Simulator).
2. **Product → Archive**. Wait for the build.
3. In the **Organizer** that opens → select the archive → **Distribute App** →
   **App Store Connect** → **Upload** → accept the defaults → **Upload**.
4. The build appears in App Store Connect under **TestFlight** after ~5–15 min
   of processing.

## 9. TestFlight (smoke test on a real device)
- **TestFlight** tab → enable the processed build for **internal testing** →
  add yourself as a tester → install via the TestFlight app on an iPad/iPhone.
- Verify: first-run difficulty pick, a few rounds (shape→clues→stamp), the
  passport pages, Daily, Settings. Catch anything before public review.

## 10. Submit for review
- Back on the **version page**, attach the processed **Build**.
- Set pricing to **Free** (App Store Connect → Pricing and Availability).
- Answer **Export Compliance** = **No** (no non-exempt encryption).
- **Add for Review → Submit.** First reviews typically take ~24–48 h. If
  rejected, Apple cites the guideline — fix and resubmit (common kids'-app notes:
  privacy policy wording, icon quality, screenshots).

## 11. After approval
- Release manually or automatically. To ship updates: bump **Build** (and
  **Version** for features), re-archive, upload, submit.

---

### Quick checklist
- [ ] Developer account active · [ ] Icon added · [ ] Real bundle ID · [ ] Signing team
- [ ] App record + Kids 9–11 + Education · [ ] Privacy policy URL · [ ] Data Not Collected
- [ ] Screenshots · [ ] Archive uploaded · [ ] TestFlight pass · [ ] Submitted
