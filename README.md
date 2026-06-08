# Passport Quest 🧳

A children's geography guessing game for ages 8–11, built in SwiftUI for iPad
(iPhone compatible), targeting iOS 16+. Players are shown clues about a mystery
country, guess the answer, and earn a passport stamp when correct — collecting
stamps for ~195 countries to fill their virtual passport.

Built for the **Apple App Store Kids Category**: no ads, no external links, no
third-party analytics, no in-app purchases, no social features, and **no runtime
network calls**. All data is bundled; all progress is saved locally.

---

## What's in the box

```
PassportQuest.xcodeproj          # Generated project (see tools/ to regenerate)
PassportQuest/
├── PassportQuestApp.swift        # App entry; injects GameSettings + progress store
├── ContentView.swift            # Root: first-launch difficulty gate → tab bar
├── Difficulty/
│   ├── DifficultyMode.swift      # Single source of truth for ALL difficulty rules
│   ├── GameSettings.swift        # Persisted difficulty, ink colour, input mode
│   └── DifficultySelectionView.swift
├── Game/
│   ├── GameViewModel.swift       # Core loop; reads every threshold from DifficultyMode
│   ├── GameView.swift            # Assembled "Play" screen
│   ├── ClueView.swift            # Renders the active clue tier + tier chips
│   ├── SilhouetteView.swift      # Shape-based country outlines (normalised Paths)
│   ├── AnswerInputView.swift     # Multiple choice / Type It In (+ autocomplete)
│   ├── ResultView.swift          # Correct/wrong feedback + stamp award
│   └── DailyChallengeView.swift  # Deterministic date-seeded daily country
├── Passport/
│   ├── PassportView.swift        # Section rings, Map/Grid switch, Sprint launch
│   ├── WorldMapView.swift        # Canvas world map with tappable stamp pins
│   ├── GridView.swift            # Continent grid of country cards
│   └── StampCardView.swift       # StampMark graphic + detail sheet
├── Minigames/
│   ├── ContinentSprintView.swift # Timed lightning round (bonus)
│   └── TravellersTriviaView.swift# Bonus upgrade question
├── Data/
│   ├── Country.swift             # Models + enums (Continent, ClueTier, StampRating)
│   ├── PlayerProgress.swift      # Codable save + observable store (UserDefaults)
│   ├── CountryDatabase.swift     # ~195 seeded countries
│   └── SilhouettePaths.swift     # Normalised 0–1 polygons for 32 countries
├── Components/
│   ├── ConfettiView.swift        # TimelineView/Canvas particle burst
│   ├── TokenBadgeView.swift      # Hint-token display
│   ├── StreakIndicatorView.swift # Streak counter + Hot Streak overlay
│   ├── DifficultyBadgeView.swift # Persistent corner mode indicator
│   └── UIHelpers.swift           # Hex colour, Reduce-Motion helpers, theme
├── Settings/
│   └── SettingsView.swift        # Difficulty change, ink, input, reset
├── Assets.xcassets/             # AppIcon (globe mascot), Mascot, AccentColor
└── Resources/
    ├── en.lproj/Localizable.strings
    └── PrivacyInfo.xcprivacy     # "No data collected" privacy manifest
PassportQuest.swiftpm/           # Swift Playgrounds App (the iPad release target)
├── Package.swift                # .iOSApplication manifest: icon, bundle id, resources
├── Assets.xcassets/             # Package-local AppIcon + Mascot (Playgrounds build)
├── PrivacyInfo.xcprivacy        # Same privacy manifest, bundled in the package
└── … mirrors the same Swift sources as PassportQuest/
tools/
└── generate_pbxproj.py           # Regenerates the .xcodeproj from the file tree
```

---

## Build & run

This project builds two ways from the **same Swift sources**. The primary,
supported path is **iPad-only via Swift Playgrounds** — see `RELEASE.md` for the
full App Store flow.

### Primary: iPad + Swift Playgrounds (no Mac)
1. Open **`PassportQuest.swiftpm`** in **Swift Playgrounds 4.1+** on an iPad
   (it appears as an *App* project). Get it onto the iPad with a git client like
   Working Copy, or via Files. See `RELEASE.md §1`.
2. Press **▶ Run**. First launch shows the non-skippable difficulty screen, then
   the four-tab game.
3. **App Settings** (name, mascot icon, bundle id `com.mdgonsalvez.passportquest`,
   version) are configured in `PassportQuest.swiftpm/Package.swift`; the icon,
   `Mascot` image and `PrivacyInfo.xcprivacy` ship in the package's
   `Assets.xcassets` / resources.

### Alternative: Mac + Xcode
1. Open **`PassportQuest.xcodeproj`** in **Xcode 15+** (iOS **16.0** target).
2. iPad is the primary form factor; iPhone is supported
   (`TARGETED_DEVICE_FAMILY = 1,2`). Pick an iPad simulator.
3. **Signing:** select your team under *Signing & Capabilities*. Bundle id is
   `com.mdgonsalvez.passportquest` (set by `BUNDLE_ID` in the generator).
4. **Capabilities:** none beyond defaults — no networking, Game Center, push or IAP.
5. **Run** (`⌘R`).

> **Regenerating the project file.** The `.xcodeproj` is produced from the
> source tree by `tools/generate_pbxproj.py`. If you add or rename Swift files
> outside Xcode, run `python3 tools/generate_pbxproj.py` from the repo root to
> rebuild `project.pbxproj`. (When working inside Xcode normally, you don't need
> the script — just add files through the IDE.)

> **Keeping the two in sync.** The `.swiftpm` mirrors the same Swift files as the
> Xcode target. Assets are maintained on both sides: the Xcode app reads
> `PassportQuest/Assets.xcassets`; the Playgrounds app reads
> `PassportQuest.swiftpm/Assets.xcassets`.

### Build settings of note (Xcode target)
- `GENERATE_INFOPLIST_FILE = YES` — no hand-maintained Info.plist; orientation,
  launch screen and display name are set via `INFOPLIST_KEY_*`.
- `SWIFT_VERSION = 5.0`, `SWIFT_EMIT_LOC_STRINGS = YES`.
- `ASSETCATALOG_COMPILER_APPICON_NAME = AppIcon`,
  `…GLOBAL_ACCENT_COLOR_NAME = AccentColor`.

---

## How difficulty works (single source of truth)

Every difficulty-dependent value — starting clue tier, available clues, wrong-
answer limit, token cost/earn rates, starting tokens, sprint duration, hot-streak
threshold, stamp-rating thresholds, trivia format, unlock strategy — lives as a
computed property on `DifficultyMode` (`Difficulty/DifficultyMode.swift`). No
threshold is hardcoded anywhere else. To rebalance the game, edit that one file.

`GameSettings.activeDifficulty` (persisted to `UserDefaults`) is injected at the
app root and read live by every system, so changing difficulty in Settings
affects future rounds immediately without touching earned stamps or tokens.

---

## App Store submission checklist

### Kids Category (ages 9–11) requirements
- [x] **No third-party advertising.** None present.
- [x] **No external links / no links out of the app** (no Safari, no mailto, no
      "rate us", no parental-gate-required links). None present.
- [x] **No third-party analytics or tracking SDKs.** None present.
- [x] **No in-app purchases or purchase prompts.** Hint tokens are earned only;
      there is no store and no StoreKit import.
- [x] **No social features / user-generated content / chat.** None present.
- [x] **No data collection.** No accounts, no network calls, no identifiers.
- [ ] **Age rating:** in App Store Connect set the age band to **9–11** and
      answer the content questionnaire as all-"None" (no violence, no mature
      themes, etc.) → results in a **4+** content rating; assign to the Kids
      Category.
- [ ] **App Privacy "Data Not Collected":** in App Store Connect → App Privacy,
      select **Data Not Collected**. This matches the bundled
      `PrivacyInfo.xcprivacy`.
- [ ] **Privacy Policy URL:** Apple requires a privacy policy URL for Kids apps
      even when no data is collected. Host a short "we collect nothing" policy
      and add the URL in App Store Connect (this is a Connect field, not an
      in-app link).

### Privacy manifest notes
`Resources/PrivacyInfo.xcprivacy` declares:
- `NSPrivacyTracking = false`, no tracking domains.
- `NSPrivacyCollectedDataTypes = []` (nothing collected).
- One required-reason API: **UserDefaults** with reason **`CA92.1`** (read/write
  app's own data, never sent off device) — used solely for local game saves.

### Required iPad screenshot sizes (App Store Connect)
Provide at least one set; the **12.9″ iPad Pro** set is mandatory and can be
reused for other iPad sizes:
- **iPad Pro 12.9″ (6th/2nd gen):** 2048 × 2732 (portrait) / 2732 × 2048
  (landscape).
- **iPad Pro 11″ / iPad 10.x″:** 1668 × 2388 (portrait) optional but recommended.
- If you also ship iPhone: **6.7″** 1290 × 2796 and **6.5″** 1242 × 2688.
Capture from the simulator with `⌘S` (File ▸ New Screen Shot) at the device's
native resolution.

### Pre-submission smoke test
- [ ] First launch shows the difficulty screen and cannot be skipped.
- [ ] Earn a stamp on each difficulty; confirm Hard stamps show the double-ring
      Cartographer's Seal in both Grid and Stamp Card.
- [ ] Reduce Motion (Settings ▸ Accessibility, or the in-app toggle) calms
      confetti/splatter.
- [ ] Force-quit and relaunch; confirm progress, tokens and difficulty persist.
- [ ] VoiceOver reads clues, options, stamps and badges.

---

## Known gaps for production

These are intentional v1 simplifications, all with a clear upgrade path.

### Asset replacement (see `Assets.xcassets/README.md`)
- **Flags:** currently Unicode emoji flags rendered large. Drop per-country
  image sets into `Flags/<ISO2>` and swap the emoji in `ClueView` (`.flag`) and
  `StampMark` for `Image("Flags/\(country.id)")`.
- **Landmarks:** the photo clue is a labelled placeholder rectangle. Add
  illustrated art to `Landmarks/<ISO2>` and replace `landmarkPlaceholder`.
- **Silhouettes:** 32 countries have hand-authored simplified `Path` polygons in
  `SilhouettePaths.swift`; the rest fall back to a continent blob with a "?".
  Extend coverage by adding normalised 0–1 polygons (or prefer
  `Silhouettes/<ISO2>` image assets) for more countries.
- **App icon:** ✅ done — the globe-mascot icon ships in both
  `PassportQuest/Assets.xcassets/AppIcon` (Xcode) and
  `PassportQuest.swiftpm/Assets.xcassets/AppIcon` (Playgrounds). The same mascot
  is reused on the onboarding welcome screen (`Mascot` image set).

### Data
- Facts, capitals, currencies and national animals are accurate to the best of
  available knowledge but should get an editorial/teacher pass for a shipping
  educational title. The Polar & Territories section uses a small curated set
  (Antarctica, Greenland, Faroe Islands, Svalbard, South Georgia) to round out
  the "world journey"; adjust to taste.

### Localisation
- English only for v1, with all visible copy keyed in
  `Resources/en.lproj/Localizable.strings`. To localise: duplicate `en.lproj`
  to e.g. `fr.lproj`, translate the values, and add the language under the
  project's *Localizations*. SwiftUI `Text` already resolves these keys.
  Country names themselves would need a parallel localised name table on
  `Country`.

### Game Center (optional future)
- There is deliberately **no** Game Center in v1 (keeps the Kids-Category
  surface minimal). If desired later: add the Game Center capability, gate it
  behind a parental gate per Apple's Kids rules, and wire leaderboards for
  total stamps / Sprint scores and achievements for continent mastery. Keep it
  strictly optional and non-blocking.

### Persistence
- Saves use `Codable` + `UserDefaults` for zero-dependency reliability on iOS 16.
  `PlayerProgress` is a value type and ports cleanly to **SwiftData** if you want
  query-driven UI or CloudKit sync later (note: any cloud sync would change the
  privacy posture and Kids-Category review).
