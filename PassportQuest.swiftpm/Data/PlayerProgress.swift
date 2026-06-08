//
//  PlayerProgress.swift
//  PassportQuest
//
//  The player's saved game state. Implemented as a Codable value type with a
//  UserDefaults-backed `PlayerProgressStore` observable wrapper. Codable +
//  UserDefaults is chosen over SwiftData to guarantee iOS 16 support and
//  dead-simple, dependency-free persistence (spec rule #6: must survive
//  termination and restart).
//

import SwiftUI
import Combine

/// The serialisable snapshot of everything the player has accomplished.
struct PlayerProgress: Codable, Equatable {
    /// Country id → best stamp rating earned.
    var stampsEarned: [String: StampRating] = [:]
    /// Country id → difficulty mode active when the stamp was earned.
    /// The Cartographer's Seal is derived from this == .hard at render time.
    var stampDifficulty: [String: DifficultyMode] = [:]
    /// Countries seen but not yet stamped (re-queued positively).
    var visitedUnstamped: [String] = []
    /// Hint token balance.
    var hintTokens: Int = 0
    /// Lifetime count of correct answers (gates Type It In unlock).
    var totalCorrect: Int = 0
    /// Current consecutive correct-answer streak (resets on hint use / wrong).
    var currentStreak: Int = 0
    /// Last calendar day the player answered anything (for daily streak bonus).
    var lastPlayDate: Date?
    /// Continents whose Sprint has been mastered.
    var masteryBadges: [Continent] = []
    /// Difficulty recorded into the save (mirrors GameSettings; kept for export).
    var activeDifficulty: DifficultyMode = .easy
    /// Daily challenge completion keyed by yyyy-MM-dd day key.
    var dailyChallengeCompleted: [String: Bool] = [:]
    /// Whether the seed-token grant for the current difficulty has been issued.
    /// Keyed by difficulty raw value so switching modes can top up appropriately.
    var seededStartingTokens: [String: Bool] = [:]

    // MARK: Derived helpers

    var stampedCount: Int { stampsEarned.count }

    func isStamped(_ countryID: String) -> Bool { stampsEarned[countryID] != nil }

    func rating(for countryID: String) -> StampRating? { stampsEarned[countryID] }

    /// Was this stamp earned on Hard? Drives the Cartographer's Seal border.
    func wasEarnedOnHard(_ countryID: String) -> Bool {
        stampDifficulty[countryID] == .hard
    }

    func stampedCount(in continent: Continent, database: [Country]) -> Int {
        database.filter { $0.continent == continent && isStamped($0.id) }.count
    }
}

/// Observable, UserDefaults-backed store that owns the live `PlayerProgress`.
/// Saves automatically (debounced) whenever progress mutates.
final class PlayerProgressStore: ObservableObject {

    private static let storageKey = "pq.playerProgress.v1"
    private let defaults: UserDefaults
    private var saveCancellable: AnyCancellable?

    @Published var progress: PlayerProgress {
        didSet { scheduleSave() }
    }

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
        if let data = defaults.data(forKey: Self.storageKey),
           let decoded = try? JSONDecoder().decode(PlayerProgress.self, from: data) {
            self.progress = decoded
        } else {
            self.progress = PlayerProgress()
        }
    }

    // MARK: Saving

    private func scheduleSave() {
        // Debounce rapid mutations into a single write.
        saveCancellable?.cancel()
        saveCancellable = Just(())
            .delay(for: .milliseconds(150), scheduler: RunLoop.main)
            .sink { [weak self] in self?.saveNow() }
    }

    func saveNow() {
        guard let data = try? JSONEncoder().encode(progress) else { return }
        defaults.set(data, forKey: Self.storageKey)
    }

    // MARK: Token economy

    /// Ensures the player has at least the starting token grant for `mode`.
    /// Issued once per difficulty so switching modes tops up to that floor
    /// without ever reducing an existing balance (spec rule #13).
    func grantStartingTokensIfNeeded(for mode: DifficultyMode) {
        if progress.seededStartingTokens[mode.rawValue] == true { return }
        progress.seededStartingTokens[mode.rawValue] = true
        if progress.hintTokens < mode.startingTokens {
            progress.hintTokens = mode.startingTokens
        }
    }

    /// Awards tokens, applying the daily-streak multiplier when appropriate.
    @discardableResult
    func awardTokens(_ base: Int, mode: DifficultyMode, streakActive: Bool) -> Int {
        let multiplier = streakActive ? mode.dailyStreakTokenMultiplier : 1
        let total = base * multiplier
        progress.hintTokens += total
        return total
    }

    /// Attempts to spend `cost` tokens. Returns false (and spends nothing) if
    /// the player can't afford it. Free reveals (cost 0) always succeed.
    @discardableResult
    func spendTokens(_ cost: Int) -> Bool {
        guard cost > 0 else { return true }
        guard progress.hintTokens >= cost else { return false }
        progress.hintTokens -= cost
        return true
    }

    // MARK: Stamping

    /// Records a stamp for a country, keeping the best rating ever earned and
    /// recording the difficulty at time of stamping.
    func recordStamp(countryID: String, rating: StampRating, mode: DifficultyMode) {
        let existing = progress.stampsEarned[countryID]
        if existing == nil || rating > existing! {
            progress.stampsEarned[countryID] = rating
            // Only (re)record difficulty when this is an improvement or first
            // stamp, so a later easy re-stamp can't erase a Hard seal unless it
            // genuinely beats the rating.
            progress.stampDifficulty[countryID] = mode
        }
        progress.visitedUnstamped.removeAll { $0 == countryID }
    }

    /// Upgrades a stamp's rating (used by Traveller's Trivia) without changing
    /// the recorded difficulty.
    func upgradeStamp(countryID: String, to rating: StampRating) {
        guard let current = progress.stampsEarned[countryID], rating > current else { return }
        progress.stampsEarned[countryID] = rating
    }

    func recordVisitedUnstamped(countryID: String) {
        guard !progress.isStamped(countryID) else { return }
        if !progress.visitedUnstamped.contains(countryID) {
            progress.visitedUnstamped.append(countryID)
        }
    }

    func addMasteryBadge(_ continent: Continent) {
        if !progress.masteryBadges.contains(continent) {
            progress.masteryBadges.append(continent)
        }
    }

    // MARK: Streaks & dates

    /// Returns true if the player has played today already (local timezone).
    func hasPlayedToday(calendar: Calendar = .current, now: Date = Date()) -> Bool {
        guard let last = progress.lastPlayDate else { return false }
        return calendar.isDate(last, inSameDayAs: now)
    }

    /// Returns true if a daily streak is "active" — i.e. the player played
    /// yesterday or today (so today's first award keeps the chain alive).
    func dailyStreakActive(calendar: Calendar = .current, now: Date = Date()) -> Bool {
        guard let last = progress.lastPlayDate else { return false }
        if calendar.isDate(last, inSameDayAs: now) { return true }
        if let yesterday = calendar.date(byAdding: .day, value: -1, to: now) {
            return calendar.isDate(last, inSameDayAs: yesterday)
        }
        return false
    }

    func touchPlayDate(now: Date = Date()) {
        progress.lastPlayDate = now
    }

    func incrementStreak() { progress.currentStreak += 1 }
    func resetStreak() { progress.currentStreak = 0 }

    func incrementTotalCorrect() { progress.totalCorrect += 1 }

    // MARK: Daily challenge

    func isDailyCompleted(dayKey: String) -> Bool {
        progress.dailyChallengeCompleted[dayKey] == true
    }

    func markDailyCompleted(dayKey: String) {
        progress.dailyChallengeCompleted[dayKey] = true
    }

    // MARK: Reset

    /// Wipes all progress back to a fresh save (used by Settings → Reset).
    func resetAll() {
        progress = PlayerProgress()
        saveNow()
    }
}
