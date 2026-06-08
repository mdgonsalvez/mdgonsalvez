//
//  DifficultyMode.swift
//  PassportQuest
//
//  The single source of truth for every difficulty-dependent rule value.
//  Per spec rule #11, NO threshold may be hardcoded anywhere else in the
//  codebase — all game systems read from these computed properties.
//

import Foundation

/// The three difficulty modes the player chooses between.
enum DifficultyMode: String, Codable, CaseIterable, Identifiable {
    case easy
    case medium
    case hard

    var id: String { rawValue }

    // MARK: Presentation

    /// In-game persona name shown on the selection cards and badge.
    var personaName: String {
        switch self {
        case .easy:   return "Explorer"
        case .medium: return "Navigator"
        case .hard:   return "Cartographer"
        }
    }

    /// Plain difficulty word, shown in brackets for clarity.
    var levelName: String {
        switch self {
        case .easy:   return "Easy"
        case .medium: return "Medium"
        case .hard:   return "Hard"
        }
    }

    /// Persona plus level, e.g. "Explorer (Easy)".
    var personaNameWithLevel: String { "\(personaName) (\(levelName))" }

    /// Emoji icon for the mode.
    var icon: String {
        switch self {
        case .easy:   return "🌍"
        case .medium: return "🧭"
        case .hard:   return "🔭"
        }
    }

    /// One-line, age-appropriate description for the selection card.
    var tagline: String {
        switch self {
        case .easy:
            return "Flags, photos and lots of hints. Perfect for starting your adventure!"
        case .medium:
            return "Silhouettes, flags and a few clues. For curious world travellers."
        case .hard:
            return "Shape only. No flags, no hints. Only the bravest explorers attempt this!"
        }
    }

    /// Compact label for the persistent corner badge, e.g. "🌍 Explorer".
    var badgeLabel: String { "\(icon) \(personaName)" }

    // MARK: Clue rules

    /// Every round opens on the Mystery Shape (silhouette); the player can then
    /// reveal the other clues by tapping them.
    var startingClueTier: ClueTier { .silhouette }

    /// All four clue tiers are available to reveal in every mode. Difficulty is
    /// expressed through the hint-token cost of revealing them, not by hiding
    /// them, so every question starts on the shape and the rest can be clicked.
    var availableClues: [ClueTier] { [.silhouette, .flag, .fact, .photo] }

    /// The player may always reveal further clues (the token cost varies by mode).
    var allowsManualReveal: Bool { true }

    // MARK: Answer input rules

    /// Wrong answers permitted on one country before the answer auto-reveals.
    var wrongAnswerLimit: Int {
        switch self {
        case .easy:   return 5
        case .medium: return 3
        case .hard:   return 2
        }
    }

    /// Number of multiple-choice options (irrelevant on Hard which is type-only).
    var multipleChoiceOptionCount: Int {
        switch self {
        case .easy:   return 4
        case .medium: return 4
        case .hard:   return 0
        }
    }

    /// Whether multiple choice is offered as an input mode in this difficulty.
    var supportsMultipleChoice: Bool {
        switch self {
        case .easy, .medium: return true
        case .hard:          return false
        }
    }

    /// Whether "Type It In" is the only available input from the start.
    var forcesTypeInput: Bool { self == .hard }

    /// How many correct answers unlock the optional Type It In mode.
    /// On Easy/Medium MC stays available; Hard ignores this (always typing).
    var typeInputUnlockThreshold: Int { 10 }

    /// On Easy, MC distractors are drawn from the same continent for gentler play.
    var multipleChoiceSameContinent: Bool {
        switch self {
        case .easy:          return true
        case .medium, .hard: return false
        }
    }

    // MARK: Hint token economy

    /// Token cost to voluntarily reveal one extra clue.
    var hintTokenCost: Int {
        switch self {
        case .easy:   return 0      // free, unlimited
        case .medium: return 1
        case .hard:   return 2
        }
    }

    var startingTokens: Int {
        switch self {
        case .easy:   return 20
        case .medium: return 10
        case .hard:   return 5
        }
    }

    var tokenPerStamp: Int {
        switch self {
        case .easy:   return 2
        case .medium: return 1
        case .hard:   return 1
        }
    }

    var tokenPerContinent: Int {
        switch self {
        case .easy:   return 8
        case .medium: return 5
        case .hard:   return 3
        }
    }

    /// Easy doubles all token awards while a daily streak is active.
    var dailyStreakTokenMultiplier: Int {
        switch self {
        case .easy:          return 2
        case .medium, .hard: return 1
        }
    }

    // MARK: Minigame tuning

    /// Continent Sprint timer duration.
    var sprintDuration: TimeInterval {
        switch self {
        case .easy:   return 90
        case .medium: return 60
        case .hard:   return 45
        }
    }

    /// Clue tier shown during the Continent Sprint.
    var sprintClueTier: ClueTier {
        switch self {
        case .easy, .medium: return .flag
        case .hard:          return .silhouette
        }
    }

    /// Correct answers in a row required to trigger a Hot Streak effect.
    var hotStreakThreshold: Int {
        switch self {
        case .easy, .medium: return 3
        case .hard:          return 5
        }
    }

    /// Flat token bonus granted when a Hot Streak fires.
    var hotStreakBonusTokens: Int { 2 }

    /// Number of options in a Traveller's Trivia question (0 == type the answer).
    var triviaOptionCount: Int {
        switch self {
        case .easy:   return 4
        case .medium: return 3
        case .hard:   return 0      // type the answer, fuzzy matched
        }
    }

    /// Clue tiers pre-loaded for the Mystery Country envelope.
    var mysteryAvailableClues: [ClueTier] { availableClues }

    // MARK: Country unlock strategy

    /// How the country queue is ordered.
    enum UnlockStrategy { case curatedThenAll, continentByContinent, globalRandom }

    var unlockStrategy: UnlockStrategy {
        switch self {
        case .easy:   return .curatedThenAll
        case .medium: return .continentByContinent
        case .hard:   return .globalRandom
        }
    }

    // MARK: Stamp rating

    /// Maps the clue tier a player answered on to a stamp rating for this mode.
    /// Every mode now opens on the silhouette and can reveal all four tiers, so
    /// the rating reflects how early the player guessed; harder modes are stricter:
    ///   Easy   — any correct answer is Gold (generous, for young players).
    ///   Medium — silhouette/flag Gold, fact Silver, photo Bronze.
    ///   Hard   — silhouette Gold, flag Silver, fact/photo Bronze (shape is king).
    func stampRating(forAnsweredTier tier: ClueTier) -> StampRating {
        switch self {
        case .easy:
            return .gold
        case .medium:
            switch tier {
            case .silhouette, .flag: return .gold
            case .fact:              return .silver
            case .photo:             return .bronze
            }
        case .hard:
            switch tier {
            case .silhouette:   return .gold
            case .flag:         return .silver
            case .fact, .photo: return .bronze
            }
        }
    }
}
