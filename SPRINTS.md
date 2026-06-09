# Passport Quest — Sprint Plan

A living backlog packaging the tester-squad findings, the Designer & UX reviews,
and the gameplay-enhancement ideas into shippable sprints. Sprints are ordered
so a polished **v1.0 ships first** (Sprint 1), then teaching/polish, then new
features.

Effort key: **S** ≈ <½ day · **M** ≈ 1–2 days · **L** ≈ 3–5 days.

---

## ✅ Sprint 0 — Squad fixes (DONE)
Completed this session.
- Spoilers: redaction now blanks the **capital city**; **Famous Place** clue shows
  a spoiler-free description instead of the landmark name; 3 remaining giveaway
  facts rewritten (San Marino, Iran, Sudan).
- Logic: Hard stamp-rating ladder fixed; Traveller's Trivia now targets a real
  upgradeable stamp; daily-streak bonus no longer always-on.
- Polish: `goldDeep` token for gold text/icons on paper (contrast); streak no
  longer broken by revealing clues (only by a wrong answer); dead views removed;
  48 pt difficulty badge; clue-chip titles scale; `US` / `DRC` / `Congo` aliases.

---

## 🚀 Sprint 1 — App Store release readiness (v1.0)
**Goal:** ship a submittable, compliant build. See `RELEASE.md` for the full
step-by-step. **Code-side items done; the rest are account/store steps you do at
upload time (iPad → Swift Playgrounds → App Store Connect).**
- [x] **App icon** — globe-mascot 1024×1024 icon shipped in both targets
      (`Assets.xcassets/AppIcon`); reused on onboarding.
- [x] **Bundle ID** — `com.mdgonsalvez.passportquest` in the package + generator.
- [ ] Apple Developer Program enrolment ($99/yr) — *at release.*
- [ ] App Store Connect record: name, subtitle, description, keywords,
      **Kids 9–11 age band + Kids Category**, privacy policy URL — *at release.*
- [x] App Privacy "Data Not Collected" — `PrivacyInfo.xcprivacy` now bundled in
      the Swift Playgrounds package too.
- [ ] Screenshots (iPad 12.9" + iPhone 6.7" required sizes) — *at release.*
- [ ] Upload via Swift Playgrounds → TestFlight smoke test → submit — *at release.*

## ✅ Sprint 2 — Teaching layer & first-run (DONE)
**Goal:** an 8-year-old understands the game with no adult help.
- [x] First-run **intro** before the difficulty choice (now a numbered
      walkthrough with mock clue chips + answer buttons, mascot welcome).
- [x] One-time **coachmark** the first time a paid clue chip appears.
- [x] Rename "tokens" → **"Hint Coins"**; bigger coin-styled cost label on chips.
- [x] **Stamp-rating legend** (Bronze/Silver/Gold) on the onboarding stamps page.
- [x] Traveller's Trivia **one-line intro** the first time it appears.
- [x] "Type It In unlocks after 10" rule explained inline in Settings.
- [x] No Hint-Coin dead-end on Hard (free starting clue + free guessing + the
      answer auto-reveals after the wrong-answer limit).

## 🎨 Sprint 3 — Visual polish (Designer)  — **next**
**Goal:** make the collection feel premium and unmistakably a passport.
- [ ] **Make the stamp look stamped**: curved "PASSPORT QUEST" arc, faux date
      line, ink-bleed/tick ring, slight per-country tilt. **(M)**
- [ ] **Elevate the Cartographer's Seal** (Hard) into a gold medallion. **(S)**
- [ ] Make the **silhouette the hero** for stamped countries in the grid; flag a
      small accent. **(M)**
- [ ] On-brand **confetti palette**; let it fall across the card. **(S)**
- [ ] Central `PQFont` (display/stamp/body) + spacing/radius scale. **(M)**
- [ ] Hot-streak overlay scrim; guilloché stripes bumped to ~0.07; custom
      passport page indicator (a dot per continent, filled when complete). **(M)**

## 🔎 Sprint 4 — Discoverability & flow (UX: medium)
- [ ] Passport opens on the player's **current continent**, not always Europe. **(S)**
- [ ] **"New!" dot** on the Daily tab when today is unplayed. **(S)**
- [ ] Surface **Continent Sprint** earlier (not gated behind 100%). **(S)**
- [ ] Clear **"Continent complete!"** celebration each time one finishes. **(S)**
- [ ] Add the answer **autocomplete** to the Daily Challenge (parity). **(S)**
- [ ] A brief "Not quite!" beat before the clue swaps on a wrong answer. **(S)**

## 🗂️ Sprint 5 — Content & data quality
- [ ] Finish the spoiler tail: sweep any remaining demonyms / regional names. **(S)**
- [ ] More `alternateNames` / demonym leniency for typed answers. **(S)**
- [ ] Consistent continent rule for transcontinental countries (Turkey,
      Caucasus, Cyprus, Russia). **(S)**
- [ ] Consistent species naming (e.g. Elk vs Moose); review placeholder animals. **(S)**
- [ ] Expand real silhouette / flag-shape coverage where it strengthens art. **(L)**

## 💡 Sprint 6 — Gameplay features (the 5 ideas)
Ordered by value-to-effort; pick per release.
- [ ] **Spoken names (text-to-speech)** for country + capital on the stamp card —
      on-device `AVSpeechSynthesizer`, no network. Educational + accessible. **(S)**
- [ ] **Collectible badges / themed sets** (Island Explorer, Flag Master…). **(M)**
- [ ] **Personalised passport** — name + avatar/cover ("Passport of Maya"). **(M)**
- [ ] **Smart revision (spaced repetition)** — resurface missed/low-rated
      countries more often. **(M)**
- [ ] **"Locate it" map round** — tap where the country is for bonus. **(L)**

---

### Suggested release cadence
- **v1.0** — Sprint 1 (+ Sprint 0). Ship.
- **v1.1** — Sprint 2 (teaching layer) + TTS from Sprint 6. Biggest retention win.
- **v1.2** — Sprint 3 (visual polish) + Sprint 4 (discoverability).
- **v1.3+** — Sprint 5 content pass + remaining Sprint 6 features.
