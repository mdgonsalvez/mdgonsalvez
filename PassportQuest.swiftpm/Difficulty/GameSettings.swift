//
//  GameSettings.swift
//  PassportQuest
//
//  App-wide observable settings injected through the SwiftUI environment.
//  Owns the active difficulty (the single value every game system reads),
//  the player's ink colour, preferred input mode, and first-launch flag.
//  All values persist to UserDefaults so they survive termination/restart.
//

import SwiftUI
import Combine

/// Available "ink colours" the player can stamp their passport with.
enum InkColour: String, Codable, CaseIterable, Identifiable {
    case royalBlue
    case forestGreen
    case crimson
    case violet
    case tangerine
    case teal

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .royalBlue:   return "Royal Blue"
        case .forestGreen: return "Forest Green"
        case .crimson:     return "Crimson"
        case .violet:      return "Violet"
        case .tangerine:   return "Tangerine"
        case .teal:        return "Teal"
        }
    }

    /// WCAG-AA-contrast-safe colours against the light passport background.
    var color: Color {
        switch self {
        case .royalBlue:   return Color(red: 0.13, green: 0.29, blue: 0.62)
        case .forestGreen: return Color(red: 0.11, green: 0.43, blue: 0.20)
        case .crimson:     return Color(red: 0.66, green: 0.10, blue: 0.16)
        case .violet:      return Color(red: 0.42, green: 0.18, blue: 0.56)
        case .tangerine:   return Color(red: 0.78, green: 0.36, blue: 0.04)
        case .teal:        return Color(red: 0.04, green: 0.40, blue: 0.44)
        }
    }
}

/// The player's preferred answer-input style where the mode permits a choice.
enum PreferredInputMode: String, Codable, CaseIterable, Identifiable {
    case multipleChoice
    case typeItIn

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .multipleChoice: return "Multiple Choice"
        case .typeItIn:       return "Type It In"
        }
    }
}

/// Observable, persisted app settings. Injected once at the app root.
final class GameSettings: ObservableObject {

    // MARK: Persistence keys
    private enum Keys {
        static let difficulty       = "pq.activeDifficulty"
        static let hasLaunched      = "pq.hasCompletedFirstLaunch"
        static let inkColour        = "pq.inkColour"
        static let preferredInput   = "pq.preferredInput"
        static let reduceMotionUser = "pq.reduceMotionPreferred"
        static let hasSeenIntro     = "pq.hasSeenIntro"
        static let hasSeenClueTip   = "pq.hasSeenClueTip"
        static let hasSeenTrivia    = "pq.hasSeenTriviaIntro"
    }

    private let defaults: UserDefaults

    // MARK: Published state

    /// The active difficulty — the single value every game rule reads from.
    @Published var activeDifficulty: DifficultyMode {
        didSet { defaults.set(activeDifficulty.rawValue, forKey: Keys.difficulty) }
    }

    /// True once the (non-skippable) difficulty selection screen has been seen.
    @Published var hasCompletedFirstLaunch: Bool {
        didSet { defaults.set(hasCompletedFirstLaunch, forKey: Keys.hasLaunched) }
    }

    @Published var inkColour: InkColour {
        didSet { defaults.set(inkColour.rawValue, forKey: Keys.inkColour) }
    }

    /// Preferred input where the difficulty allows a choice (Easy/Medium).
    @Published var preferredInput: PreferredInputMode {
        didSet { defaults.set(preferredInput.rawValue, forKey: Keys.preferredInput) }
    }

    /// Optional user-forced reduce-motion preference layered on top of the
    /// system setting (the system setting always wins if it is enabled).
    @Published var prefersReducedMotion: Bool {
        didSet { defaults.set(prefersReducedMotion, forKey: Keys.reduceMotionUser) }
    }

    /// True once the player has seen the first-run "How to play" intro.
    @Published var hasSeenIntro: Bool {
        didSet { defaults.set(hasSeenIntro, forKey: Keys.hasSeenIntro) }
    }

    /// True once the one-time "tap a clue costs Hint Coins" tip has been shown.
    @Published var hasSeenClueTip: Bool {
        didSet { defaults.set(hasSeenClueTip, forKey: Keys.hasSeenClueTip) }
    }

    /// True once the one-time Traveller's Trivia explainer has been shown.
    @Published var hasSeenTriviaIntro: Bool {
        didSet { defaults.set(hasSeenTriviaIntro, forKey: Keys.hasSeenTrivia) }
    }

    // MARK: Init

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults

        if let raw = defaults.string(forKey: Keys.difficulty),
           let mode = DifficultyMode(rawValue: raw) {
            self.activeDifficulty = mode
        } else {
            self.activeDifficulty = .easy
        }

        self.hasCompletedFirstLaunch = defaults.bool(forKey: Keys.hasLaunched)

        if let raw = defaults.string(forKey: Keys.inkColour),
           let ink = InkColour(rawValue: raw) {
            self.inkColour = ink
        } else {
            self.inkColour = .royalBlue
        }

        if let raw = defaults.string(forKey: Keys.preferredInput),
           let input = PreferredInputMode(rawValue: raw) {
            self.preferredInput = input
        } else {
            self.preferredInput = .multipleChoice
        }

        self.prefersReducedMotion = defaults.bool(forKey: Keys.reduceMotionUser)
        self.hasSeenIntro = defaults.bool(forKey: Keys.hasSeenIntro)
        self.hasSeenClueTip = defaults.bool(forKey: Keys.hasSeenClueTip)
        self.hasSeenTriviaIntro = defaults.bool(forKey: Keys.hasSeenTrivia)
    }

    // MARK: Convenience

    /// Completes first launch and records the chosen difficulty in one step.
    func completeFirstLaunch(with mode: DifficultyMode) {
        activeDifficulty = mode
        hasCompletedFirstLaunch = true
    }
}
