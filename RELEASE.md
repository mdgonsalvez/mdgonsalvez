# Releasing Passport Quest to the App Store

This project ships from an **iPad** using **Swift Playgrounds** — no Mac required.
Swift Playgrounds (4.1+) can build the `PassportQuest.swiftpm` App project and
upload it straight to App Store Connect. This guide covers that path end to end.

> On a Mac? There's also a generated `PassportQuest.xcodeproj` you can archive in
> Xcode — see [§A. Mac/Xcode alternative](#a-macxcode-alternative-optional) at the
> bottom. The iPad path below is the primary, supported workflow.

Budget ~half a day the first time — most of it is account setup and store
metadata, not code.

---

## 0. Prerequisites (one-time)
1. **An iPad** running a recent iPadOS (16+), with **Swift Playgrounds 4.1 or
   later** (free, App Store). Swift Playgrounds is what builds, signs and uploads
   the app — you do **not** need a Mac or Xcode.
2. **Apple Developer Program** membership — **$99/year**. Enrol at
   <https://developer.apple.com/programs/>. Approval can take 24–48 h. Sign in to
   Swift Playgrounds with **this same Apple ID** so it can upload.
3. An **App Store Connect** account (comes with the membership):
   <https://appstoreconnect.apple.com> (works in Safari on the iPad).
4. A **privacy policy URL** (required for the Kids Category). A simple page
   stating "this app collects no data" is enough — host it anywhere public
   (GitHub Pages works). Wording: see §5.

---

## 1. Get the project onto the iPad
You need `PassportQuest.swiftpm` as a local folder Swift Playgrounds can open:
- **Easiest:** use a git client like **Working Copy** (App Store) to clone this
  repo, then **share → "Open in Swift Playgrounds"** on the `PassportQuest.swiftpm`
  folder. This also lets you `pull` updates later.
- **Or:** download the repo zip in Safari, unzip in **Files**, and open
  `PassportQuest.swiftpm` from Swift Playgrounds' **App** picker (it appears as an
  app project, not a playground).

Open it and press **▶ Run** once to confirm it builds and launches.

## 2. Check App Settings (already configured in the manifest)
Most of this is set in `Package.swift`, but confirm in Swift Playgrounds'
**App Settings** panel (tap the app name/▾ in the top toolbar):
- **Name:** Passport Quest
- **App Icon:** the globe mascot (bundled at
  `Assets.xcassets/AppIcon` and wired via `appIcon: .asset("AppIcon")`). If the
  panel shows a blank/default icon, drag in
  `PassportQuest.swiftpm/Assets.xcassets/AppIcon.appiconset/AppIcon-1024.png`.
- **Bundle Identifier:** `com.mdgonsalvez.passportquest` — must be globally
  unique to your account. Change it (here and in `Package.swift`) if it's taken.
- **Version / Build:** `1.0` / `1` (`displayVersion` / `bundleVersion` in
  `Package.swift`). Bump **Build** on every upload; bump **Version** per public
  release.
- **Orientations / Devices:** portrait + landscape, iPad & iPhone (already set).

## 3. Upload to App Store Connect (from the iPad)
1. In Swift Playgrounds, open the project and tap the app-name/▾ menu in the top
   toolbar → **Upload to App Store Connect**.
2. **Sign in** with the Apple ID enrolled in the Developer Program. Swift
   Playgrounds **manages signing automatically** — no certificates to wrangle.
3. If no app record exists yet, Swift Playgrounds offers to **create the App
   Store Connect record** during upload (or create it first in §4). Pick the
   bundle ID above and the name "Passport Quest".
4. Confirm and upload. After ~5–15 min of processing, the build appears in App
   Store Connect under **TestFlight**.

> If "Upload to App Store Connect" is greyed out: confirm your Apple ID shows an
> active Developer Program membership, that the bundle ID is unique, and that a
> custom app icon is set (Apple rejects the default placeholder icon).

## 4. Create / complete the app record in App Store Connect
<https://appstoreconnect.apple.com> (Safari is fine) → **Apps → ➕ → New App**
(if not already created during upload):
- Platform **iOS**, your **Bundle ID**, **Name** "Passport Quest" (must be
  globally unique — have a backup like "Passport Quest: World Game"), primary
  language, and an **SKU** (any string, e.g. `passportquest01`).

Then fill **App Information**:
- **Category:** Primary = **Education** (Secondary optional, e.g. Games).
- **Age rating:** complete the questionnaire — all "None"; this yields **4+**.
- **Kids Category:** set the **Kids** category and age band **9–11** (best fit).
  This adds the requirements in §5.

## 5. Kids Category compliance (important)
Apple reviews kids' apps strictly. This app is already built to comply — confirm:
- ✅ **No third-party ads, no tracking, no analytics SDKs.**
- ✅ **No data collection** — declare **"Data Not Collected"** in App Privacy.
  This matches the bundled privacy manifest, which now ships **inside the
  package** at `PassportQuest.swiftpm/PrivacyInfo.xcprivacy` (declared as a
  resource in `Package.swift`). All progress is on-device.
- ✅ **No external links / no purchases** for kids → no parental gate needed.
  (If you ever add an "About" link or anything leaving the app, it must sit
  behind a parental gate.)
- ⚠️ **Privacy Policy URL is required** — paste your hosted URL. Minimal text:
  > *"Passport Quest does not collect, store, or share any personal data. All
  > game progress stays on your device. There are no ads, no tracking, no
  > accounts, and no in-app purchases."*

## 6. App Store metadata
Per the version's page:
- **Subtitle** (30 chars), **Promotional text**, **Description**, **Keywords**
  (geography, kids, countries, flags, learning, capitals…), **Support URL**.
- **Marketing asset:** the "PASSPORT QUEST" banner logo lives at
  `Marketing/PassportQuest-Logo-Banner-1024.png` if you want it for the listing.
- **Screenshots** (required): run the app on the iPad and take **screenshots**
  (top button + volume-up) on a 12.9″ iPad, or use the required sizes in §7. Save
  from Photos and upload in App Store Connect.

## 7. Required iPad screenshot sizes (App Store Connect)
- **iPad Pro 12.9″:** 2048 × 2732 (portrait) / 2732 × 2048 (landscape) — mandatory.
- **iPad 11″ / 10.x″:** 1668 × 2388 (portrait) — recommended.
- If you keep iPhone enabled: **6.7″** 1290 × 2796 and **6.5″** 1242 × 2688.

## 8. TestFlight (smoke test on a real device)
- **TestFlight** tab → enable the processed build for **internal testing** → add
  yourself → install via the TestFlight app.
- Verify: first-run difficulty pick, a few rounds (shape → clues → stamp), the
  passport pages, Daily, Settings, and that the **home-screen icon is the mascot**
  and the **onboarding welcome screen shows the mascot** (not the 🧳 emoji
  fallback). Catch anything before public review.

## 9. Submit for review
- On the version page, attach the processed **Build**.
- Set pricing to **Free** (Pricing and Availability).
- **Export Compliance** = **No** (no non-exempt encryption).
- **Add for Review → Submit.** First reviews typically take ~24–48 h. If
  rejected, Apple cites the guideline — fix and resubmit (common kids'-app notes:
  privacy policy wording, icon quality, screenshots).

## 10. Shipping updates
Bump **Build** (`bundleVersion`) — and **Version** (`displayVersion`) for
feature releases — in `PassportQuest.swiftpm/Package.swift`, then repeat §3
(Upload) and §9 (Submit).

---

### Quick checklist
- [ ] Developer account active · [ ] Project opens & runs in Swift Playgrounds
- [ ] Mascot icon shows · [ ] Unique bundle ID · [ ] Uploaded via Swift Playgrounds
- [ ] App record + Kids 9–11 + Education · [ ] Privacy policy URL · [ ] Data Not Collected
- [ ] Screenshots · [ ] TestFlight pass · [ ] Submitted

---

## A. Mac/Xcode alternative (optional)
If you have a Mac, you can archive the generated Xcode project instead:
```bash
git clone <this repo> && cd mdgonsalvez
open PassportQuest.xcodeproj
```
- The icon, mascot and privacy manifest also exist on the Xcode side
  (`PassportQuest/Assets.xcassets`, `PassportQuest/Resources/`). Bundle ID is set
  by `BUNDLE_ID` in `tools/generate_pbxproj.py`; regenerate with
  `python3 tools/generate_pbxproj.py` after file changes.
- Target → **Signing & Capabilities**: tick *Automatically manage signing*, pick
  your **Team**. Set run destination to **Any iOS Device (arm64)**, then
  **Product → Archive → Distribute App → App Store Connect → Upload**.
- Everything from §4 (App Store Connect setup) onward is identical.
