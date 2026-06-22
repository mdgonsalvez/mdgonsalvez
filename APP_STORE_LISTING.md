# Passport Quest — App Store Listing Copy

Ready-to-paste metadata for App Store Connect → **App Information** and the
**Version 1.0** product page. Character limits noted; all drafts are within them.

---

## App Information (applies to all versions)

**Name** (30 max): `Passport Quest`

**Subtitle** (30 max): `Kids' world geography game`

**Category:** Primary = **Education** · Secondary (optional) = **Games**

**Kids Category:** turn on **Made for Kids** → age band **9–11**.

**Age Rating:** open the questionnaire and answer **all "None / No"** → results
in **4+**.

**Content Rights:** "No, it does not contain, show, or access third-party content."

---

## Version 1.0 product page

### Promotional text (170 max)
```
Guess mystery countries from fun clues, collect passport stamps for 195+ nations, and become a world geography explorer. No ads, no tracking — just learning.
```

### Keywords (100 max, comma-separated, no spaces)
```
geography,countries,kids,flags,capitals,world,learning,quiz,maps,educational,stamps,atlas,travel
```

### Description (4000 max)
```
Passport Quest turns world geography into a friendly adventure for curious kids (ages 8–11).

A mystery country is hiding every round. Look at its shape, peek at the clues — the flag, a fun fact, a famous place — then make your guess. Get it right and you earn a stamp for your very own passport. Collect stamps for all 195+ countries and fill your passport, continent by continent!

WHY PARENTS LOVE IT
• Built for the Kids Category: no ads, no tracking, no analytics, no social features.
• No in-app purchases and no links that leave the app.
• No accounts and no internet needed — everything works offline, and all progress is saved on the device.

HOW KIDS PLAY
• Guess the mystery country from its silhouette and clues.
• Tap an answer, or type the country's name on the harder modes.
• Earn Bronze, Silver or Gold stamps — the fewer clues you use, the shinier the stamp.
• Three difficulty modes that grow with your child, from gentle Explorer to challenging Cartographer.
• A brand-new Daily Challenge country every day.
• Bonus rounds: Traveller's Trivia and timed Continent Sprints.

LEARNING THAT STICKS
Kids pick up country shapes, flags, capitals, fun facts, and where places are in the world — all through play, at their own pace.

Safe, screen-smart fun that helps young explorers fall in love with the world. Start your Passport Quest today!
```

### URLs (you must host these)
- **Support URL** (required): a simple web page (GitHub Pages works). Even a one-liner
  "Questions? Email …" page is fine.
- **Marketing URL** (optional): can be the same page.
- **Privacy Policy URL** (required for Kids): host the text below.

### Privacy policy text (host on any public page)
```
Passport Quest does not collect, store, or share any personal data. All game
progress stays on your device. There are no ads, no tracking, no accounts, and
no in-app purchases. The app does not require an internet connection.
Questions? Contact: <your email>.
```

---

## App Privacy (left nav → App Privacy)
- **Data Collection:** select **"Data is not collected."** (Matches the bundled
  `PrivacyInfo.xcprivacy`.) That's the whole questionnaire — nothing else to declare.

## Pricing and Availability
- Price: **Free**. Availability: all territories (or your choice).

## Build
- Upload from **Swift Playgrounds → app menu → Upload to App Store Connect**
  (auto-signs with your Developer Apple ID). After ~5–15 min processing it
  appears under **TestFlight** and can be attached here in the **Build** section.
- **Export Compliance:** **No** (no non-exempt encryption).

---

## Screenshots (this page → Previews and Screenshots)
The app is **universal** (`supportedDeviceFamilies: [.pad, .phone]`), so App Store
Connect requires **both** an **iPad 13"** set and an **iPhone 6.5"** set. The first
3 of each show on the install sheet.

Capture each key screen: the difficulty pick, a clue/guess screen, a Gold stamp
reveal, a filled passport page, the Daily.

Required sizes:
- **iPad 13":** 2064 × 2752 or 2048 × 2732 px. (An 11" iPad captures at
  1668 × 2420; resize to 2048 × 2732, which is accepted.)
- **iPhone 6.5":** 1242 × 2688 or 1284 × 2778 px. Best captured on a real
  iPhone — now that the app is on the store, install it on an iPhone and take
  native screenshots (sharper than resizing iPad shots).

---

## Submit
Once the build is attached, screenshots are in, and the sections above are green:
**Add for Review → Submit.** First review is typically ~24–48 h.
