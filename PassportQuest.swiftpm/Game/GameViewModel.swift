//
//  GameViewModel.swift
//  PassportQuest
//
//  The observable engine that drives the core guessing loop. EVERY rule
//  threshold here is read from `settings.activeDifficulty`'s computed
//  properties (spec rule #11) — there are no hardcoded gameplay numbers.
//
//  Responsibilities:
//   • Build the playable country pool from the difficulty unlock strategy and
//     the player's sequential section progress.
//   • Track the active clue tier, manual reveals, and the wrong-answer count.
//   • Validate answers (multiple choice + fuzzy type-in) and award stamps,
//     tokens, streaks, Hot Streaks and Traveller's Trivia.
//

import SwiftUI
import Combine

// MARK: - Round phase

/// Where the current round is in its lifecycle.
enum RoundPhase: Equatable {
    case guessing
    case correct(StampRating)
    case wrong
    case revealedAnswer      // hit the wrong-answer limit; "visited, not stamped"
}

// MARK: - Trivia

enum TriviaCategory: String, CaseIterable {
    case capital, currency, nationalAnimal

    var prompt: String {
        switch self {
        case .capital:        return "What is the capital city of"
        case .currency:       return "What money do people use in"
        case .nationalAnimal: return "What is the national animal of"
        }
    }
}

/// A bonus question used to upgrade a stamp's rating.
struct TriviaQuestion: Identifiable {
    let id = UUID()
    let country: Country
    let category: TriviaCategory
    let correctAnswer: String
    /// Multiple-choice options (empty when the difficulty wants a typed answer).
    let options: [String]
    /// The stamp this question can upgrade.
    let targetCountryID: String
}

// MARK: - GameViewModel

final class GameViewModel: ObservableObject {

    // Injected dependencies (set once via `configure`).
    private var settings: GameSettings!
    private var store: PlayerProgressStore!

    private var difficulty: DifficultyMode { settings.activeDifficulty }

    // MARK: Published round state

    @Published private(set) var currentCountry: Country?
    /// Clue tiers currently visible to the player, in reveal order.
    @Published private(set) var revealedTiers: [ClueTier] = []
    /// The tier currently shown as the "front" clue (the latest revealed).
    @Published private(set) var activeTier: ClueTier = .silhouette
    @Published private(set) var wrongCount: Int = 0
    @Published private(set) var phase: RoundPhase = .guessing
    /// Multiple-choice options for the current round (empty in type-only modes).
    @Published private(set) var choiceOptions: [Country] = []
    /// Set true briefly to drive the Hot Streak animation.
    @Published var showHotStreak: Bool = false
    /// When non-nil, the UI should present a Traveller's Trivia bonus.
    @Published var pendingTrivia: TriviaQuestion?
    /// True once the answer for the current country has been revealed/handled
    /// and the player can advance to the next country.
    @Published private(set) var awaitingNext: Bool = false
    /// Whether a hint was used on the current country (blocks Hot Streak/Gold-feel).
    @Published private(set) var usedHintThisRound: Bool = false
    /// Most recent token award message for light feedback ("+2 tokens!").
    @Published var lastTokenAward: Int = 0
    /// A short, encouraging nudge shown after a non-final wrong answer.
    @Published var wrongNudge: String?

    /// The id most recently selected by the player (for highlighting MC).
    @Published var selectedChoiceID: String?

    private var lastCountryID: String?
    private var seenThisSession: Set<String> = []

    // MARK: Configuration

    /// Wires up environment dependencies. Call once from the host view.
    func configure(settings: GameSettings, store: PlayerProgressStore) {
        guard self.settings == nil else { return }
        self.settings = settings
        self.store = store
        store.grantStartingTokensIfNeeded(for: settings.activeDifficulty)
    }

    /// Re-grants the starting-token floor when difficulty changes.
    func difficultyDidChange() {
        store.grantStartingTokensIfNeeded(for: settings.activeDifficulty)
    }

    // MARK: Section unlocking

    /// All countries in journey order honouring the difficulty unlock strategy.
    private func playablePool() -> [Country] {
        switch difficulty.unlockStrategy {
        case .globalRandom:
            // Hard: everything unlocked from the start, random globally.
            return CountryDatabase.all.filter { !store.progress.isStamped($0.id) }

        case .continentByContinent, .curatedThenAll:
            guard let section = currentFocusSection() else { return [] }
            var pool = CountryDatabase.countries(in: section)
                .filter { !store.progress.isStamped($0.id) }

            if difficulty.unlockStrategy == .curatedThenAll {
                // Easy: surface the curated subset until it is fully stamped.
                let curated = pool.filter { $0.isCuratedEasyUnlock }
                let curatedRemaining = curated.contains { !store.progress.isStamped($0.id) }
                if !curated.isEmpty && curatedRemaining {
                    pool = curated
                }
            }
            return pool
        }
    }

    /// The first journey section that is not yet fully stamped (the section the
    /// player is currently working through). Sequential unlock: a section is
    /// only reached once every earlier section is complete.
    func currentFocusSection() -> Continent? {
        for section in Continent.journeyOrdered {
            let countries = CountryDatabase.countries(in: section)
            let allStamped = countries.allSatisfy { store.progress.isStamped($0.id) }
            if !allStamped { return section }
        }
        return nil // everything stamped!
    }

    /// Sections currently unlocked for the player (for passport UI gating).
    func unlockedSections() -> Set<Continent> {
        if difficulty.unlockStrategy == .globalRandom {
            return Set(Continent.allCases)
        }
        var unlocked: Set<Continent> = []
        for section in Continent.journeyOrdered {
            unlocked.insert(section)
            let countries = CountryDatabase.countries(in: section)
            let allStamped = countries.allSatisfy { store.progress.isStamped($0.id) }
            if !allStamped { break } // stop at the first incomplete section
        }
        return unlocked
    }

    // MARK: Round lifecycle

    /// Whether a daily streak was active at the start of this session. Captured
    /// BEFORE touching the play date, which would otherwise always read true and
    /// make the streak bonus always-on.
    private var dailyStreakWasActive = false

    /// Begins (or resumes) play by loading the next country.
    func startSession() {
        dailyStreakWasActive = store.dailyStreakActive()
        store.touchPlayDate()
        loadNextCountry()
    }

    /// Loads a fresh country from the pool and resets per-round state.
    func loadNextCountry() {
        var pool = playablePool()
        // Avoid immediately repeating the same country where possible.
        if pool.count > 1, let last = lastCountryID {
            pool.removeAll { $0.id == last }
        }

        guard let next = pool.randomElement() else {
            currentCountry = nil // section / game complete
            return
        }

        lastCountryID = next.id
        seenThisSession.insert(next.id)
        currentCountry = next
        wrongCount = 0
        usedHintThisRound = false
        phase = .guessing
        awaitingNext = false
        selectedChoiceID = nil
        lastTokenAward = 0

        // Open on the difficulty's starting tier and reveal everything up to it.
        let start = difficulty.startingClueTier
        revealedTiers = difficulty.availableClues.filter { $0 <= start }
        if revealedTiers.isEmpty { revealedTiers = [difficulty.availableClues.first ?? .silhouette] }
        activeTier = revealedTiers.max() ?? start

        rebuildChoiceOptions(for: next)
    }

    // MARK: Clue reveals

    /// The next tier that could be revealed, if any remain available.
    var nextRevealableTier: ClueTier? {
        difficulty.availableClues
            .filter { !revealedTiers.contains($0) }
            .min()
    }

    var revealCost: Int { difficulty.hintTokenCost }

    /// Auto-reveals the next clue without cost (after a wrong answer).
    private func autoRevealNextClue() {
        guard let tier = nextRevealableTier else { return }
        reveal(tier)
    }

    private func reveal(_ tier: ClueTier) {
        if !revealedTiers.contains(tier) {
            revealedTiers.append(tier)
            revealedTiers.sort()
        }
        activeTier = tier
    }

    /// Lets the player flick back/forth between already-revealed clues.
    func showTier(_ tier: ClueTier) {
        guard revealedTiers.contains(tier) else { return }
        activeTier = tier
    }

    // MARK: Clue chips (start-on-shape, tap-to-reveal UX)

    /// All clue tiers offered in this mode, for the chip row.
    var availableTiers: [ClueTier] { difficulty.availableClues }

    func isRevealed(_ tier: ClueTier) -> Bool { revealedTiers.contains(tier) }

    /// Can the player afford to reveal one more clue right now?
    var canAffordReveal: Bool {
        difficulty.hintTokenCost == 0 || tokenBalance >= difficulty.hintTokenCost
    }

    /// Player tapped a clue chip. If it's already revealed, just switch to it;
    /// otherwise reveal it (spending tokens where the mode charges for hints).
    /// Returns false if the reveal couldn't be afforded.
    @discardableResult
    func tapTier(_ tier: ClueTier) -> Bool {
        if revealedTiers.contains(tier) {
            activeTier = tier
            return true
        }
        guard difficulty.allowsManualReveal else { return false }
        guard store.spendTokens(difficulty.hintTokenCost) else { return false }
        if difficulty.hintTokenCost > 0 {
            usedHintThisRound = true // recorded for stats, but no longer breaks the streak
        }
        reveal(tier)
        return true
    }

    // MARK: Input mode

    /// Whether the optional Type It In mode is unlocked (Easy/Medium gate).
    var isTypeInputUnlocked: Bool {
        store.progress.totalCorrect >= difficulty.typeInputUnlockThreshold
    }

    /// The input mode in force for the current round.
    var effectiveInputMode: PreferredInputMode {
        if difficulty.forcesTypeInput { return .typeItIn }
        if !difficulty.supportsMultipleChoice { return .typeItIn }
        // Easy/Medium: honour the player's preference, but Type It In only once
        // unlocked. Multiple choice is always available.
        if settings.preferredInput == .typeItIn && isTypeInputUnlocked { return .typeItIn }
        return .multipleChoice
    }

    // MARK: Multiple choice

    private func rebuildChoiceOptions(for country: Country) {
        guard difficulty.supportsMultipleChoice else { choiceOptions = []; return }
        let count = difficulty.multipleChoiceOptionCount
        var distractorSource: [Country]
        if difficulty.multipleChoiceSameContinent {
            distractorSource = CountryDatabase.countries(in: country.continent)
        } else {
            distractorSource = CountryDatabase.all
        }
        distractorSource.removeAll { $0.id == country.id }
        let distractors = Array(distractorSource.shuffled().prefix(max(0, count - 1)))
        choiceOptions = (distractors + [country]).shuffled()
    }

    // MARK: Answering

    /// Handle a multiple-choice selection.
    func submitChoice(_ country: Country) {
        guard phase == .guessing, let current = currentCountry else { return }
        wrongNudge = nil
        selectedChoiceID = country.id
        if country.id == current.id {
            handleCorrect(on: current)
        } else {
            handleWrong(on: current)
        }
    }

    /// Handle a typed answer with fuzzy matching.
    func submitTypedAnswer(_ raw: String) {
        guard phase == .guessing, let current = currentCountry else { return }
        wrongNudge = nil
        if FuzzyMatcher.matches(input: raw, country: current) {
            handleCorrect(on: current)
        } else {
            handleWrong(on: current)
        }
    }

    private func handleCorrect(on country: Country) {
        let rating = difficulty.stampRating(forAnsweredTier: activeTier)
        store.recordStamp(countryID: country.id, rating: rating, mode: difficulty)
        store.incrementTotalCorrect()

        // The streak grows with every correct answer; only a WRONG answer breaks
        // it. Revealing clues no longer punishes the streak — exploring clues to
        // learn is exactly what we want kids to do.
        store.incrementStreak()

        awardTokensForStamp(country: country)
        maybeAwardContinentBonus(for: country.continent)
        maybeTriggerHotStreak()
        maybeTriggerTrivia()

        phase = .correct(rating)
        awaitingNext = true
    }

    private func handleWrong(on country: Country) {
        wrongCount += 1
        store.resetStreak()
        store.recordVisitedUnstamped(countryID: country.id)

        if wrongCount >= difficulty.wrongAnswerLimit {
            // "Visited but not stamped" — positive re-queue, no penalty.
            phase = .revealedAnswer
            awaitingNext = true
        } else {
            phase = .wrong
            autoRevealNextClue() // the wrong tier locks, next clue appears
            selectedChoiceID = nil
            wrongNudge = nextRevealableTier == nil
                ? "Not quite — give it another try!"
                : "Not quite — here's another clue!"
            // Return to guessing so the player can try again on the new clue.
            phase = .guessing
        }
    }

    // MARK: Token awards

    private func awardTokensForStamp(country: Country) {
        let award = store.awardTokens(difficulty.tokenPerStamp, mode: difficulty, streakActive: dailyStreakWasActive)
        lastTokenAward = award
    }

    private func maybeAwardContinentBonus(for continent: Continent) {
        let countries = CountryDatabase.countries(in: continent)
        let complete = countries.allSatisfy { store.progress.isStamped($0.id) }
        guard complete else { return }
        // Award the continent bonus once: track via mastery — but continent
        // completion bonus is distinct from Sprint mastery, so guard on a
        // sentinel using visitedUnstamped-free completeness check + token flag.
        let key = "continentBonus.\(continent.rawValue)"
        if store.progress.seededStartingTokens[key] != true {
            store.progress.seededStartingTokens[key] = true
            let bonus = store.awardTokens(difficulty.tokenPerContinent, mode: difficulty, streakActive: dailyStreakWasActive)
            lastTokenAward += bonus
        }
    }

    private func maybeTriggerHotStreak() {
        if store.progress.currentStreak > 0,
           store.progress.currentStreak % difficulty.hotStreakThreshold == 0 {
            let bonus = store.awardTokens(difficulty.hotStreakBonusTokens, mode: difficulty, streakActive: dailyStreakWasActive)
            lastTokenAward += bonus
            triggerHotStreakVisual()
        }
    }

    private func triggerHotStreakVisual() {
        showHotStreak = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.2) { [weak self] in
            self?.showHotStreak = false
        }
    }

    // MARK: Traveller's Trivia (every 5th correct)

    private func maybeTriggerTrivia() {
        guard store.progress.totalCorrect % 5 == 0 else { return }
        // Trivia upgrades a stamp, so it only makes sense when the player has a
        // sub-Gold stamp to improve. (On Easy every stamp is Gold, so it simply
        // doesn't fire — there's nothing to upgrade.) Pick one such stamp.
        let upgradeable = store.progress.stampsEarned
            .filter { $0.value < .gold }
            .map { $0.key }
        guard let targetID = upgradeable.randomElement(),
              let country = CountryDatabase.country(id: targetID) else { return }
        pendingTrivia = makeTriviaQuestion(for: country)
    }

    private func makeTriviaQuestion(for country: Country) -> TriviaQuestion {
        let category = TriviaCategory.allCases.randomElement() ?? .capital
        let correct: String
        switch category {
        case .capital:        correct = country.capital
        case .currency:       correct = country.currency
        case .nationalAnimal: correct = country.nationalAnimal
        }

        let optionCount = difficulty.triviaOptionCount
        var options: [String] = []
        if optionCount > 0 {
            var pool: [String] = CountryDatabase.all
                .filter { $0.id != country.id }
                .map { c in
                    switch category {
                    case .capital:        return c.capital
                    case .currency:       return c.currency
                    case .nationalAnimal: return c.nationalAnimal
                    }
                }
            pool = Array(Set(pool)).filter { $0 != correct }
            let distractors = Array(pool.shuffled().prefix(max(0, optionCount - 1)))
            options = (distractors + [correct]).shuffled()
        }

        return TriviaQuestion(country: country,
                              category: category,
                              correctAnswer: correct,
                              options: options,
                              targetCountryID: country.id)
    }

    /// Resolve a trivia answer: a correct answer upgrades the stamp one rank.
    @discardableResult
    func resolveTrivia(_ question: TriviaQuestion, answer: String) -> Bool {
        let correct: Bool
        if question.options.isEmpty {
            correct = FuzzyMatcher.normalize(answer) == FuzzyMatcher.normalize(question.correctAnswer)
        } else {
            correct = answer == question.correctAnswer
        }
        if correct, let current = store.progress.rating(for: question.targetCountryID) {
            let upgraded = StampRating(rawValue: min(StampRating.gold.rawValue, current.rawValue + 1)) ?? current
            store.upgradeStamp(countryID: question.targetCountryID, to: upgraded)
        }
        // NOTE: we intentionally do NOT clear `pendingTrivia` here — the trivia
        // sheet shows its own result card and dismisses via the environment
        // `dismiss` (which clears the item binding). Clearing it now would close
        // the sheet before the player sees whether they upgraded their stamp.
        return correct
    }

    func dismissTrivia() { pendingTrivia = nil }

    // MARK: Autocomplete

    /// Up to 5 country-name suggestions for the Type It In dropdown.
    func suggestions(for input: String) -> [Country] {
        let needle = FuzzyMatcher.normalize(input)
        guard !needle.isEmpty else { return [] }
        let matches = CountryDatabase.all.filter { country in
            let candidates = [country.name] + country.alternateNames
            return candidates.contains { FuzzyMatcher.normalize($0).hasPrefix(needle) }
        }
        // Prefer prefix matches; fall back to contains if few results.
        if matches.count >= 1 { return Array(matches.prefix(5)) }
        let contains = CountryDatabase.all.filter {
            FuzzyMatcher.normalize($0.name).contains(needle)
        }
        return Array(contains.prefix(5))
    }

    // MARK: Convenience for the UI

    var tokenBalance: Int { store.progress.hintTokens }
    var currentStreak: Int { store.progress.currentStreak }

    /// Whether the whole game (every section) is complete.
    var isJourneyComplete: Bool { currentFocusSection() == nil }
}

// MARK: - FuzzyMatcher

/// Tolerant string matching for Type It In mode (spec rule #8): case-insensitive,
/// whitespace-trimmed, diacritics stripped, punctuation-flexible, alternate
/// names honoured, plus a one-edit typo tolerance for longer words.
enum FuzzyMatcher {

    /// Normalises a string for comparison.
    static func normalize(_ s: String) -> String {
        let folded = s.folding(options: [.diacriticInsensitive, .caseInsensitive],
                               locale: Locale(identifier: "en_US"))
        let allowed = folded.lowercased().unicodeScalars.filter { scalar in
            CharacterSet.alphanumerics.contains(scalar) || scalar == " "
        }
        let collapsed = String(String.UnicodeScalarView(allowed))
            .split(separator: " ")
            .joined(separator: " ")
        return collapsed.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    /// True if `input` is an acceptable answer for `country`.
    static func matches(input: String, country: Country) -> Bool {
        let needle = normalize(input)
        guard !needle.isEmpty else { return false }
        let candidates = ([country.name] + country.alternateNames).map(normalize)
        for candidate in candidates {
            if candidate == needle { return true }
            // Allow a tiny typo for longer names (e.g. "Brasil" vs "Brazil").
            if candidate.count > 4 && levenshtein(needle, candidate) <= 1 { return true }
        }
        return false
    }

    /// Classic Levenshtein edit distance.
    static func levenshtein(_ a: String, _ b: String) -> Int {
        let aChars = Array(a), bChars = Array(b)
        if aChars.isEmpty { return bChars.count }
        if bChars.isEmpty { return aChars.count }
        var prev = Array(0...bChars.count)
        var curr = [Int](repeating: 0, count: bChars.count + 1)
        for i in 1...aChars.count {
            curr[0] = i
            for j in 1...bChars.count {
                let cost = aChars[i - 1] == bChars[j - 1] ? 0 : 1
                curr[j] = Swift.min(prev[j] + 1, curr[j - 1] + 1, prev[j - 1] + cost)
            }
            swap(&prev, &curr)
        }
        return prev[bChars.count]
    }
}
