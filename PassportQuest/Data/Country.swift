//
//  Country.swift
//  PassportQuest
//
//  Core model structs and enums for the country data set.
//  This file is part of the conceptual `PassportData` module described in the
//  build spec. Everything here is pure value types with no UIKit/SwiftUI
//  dependency so it can be lifted into a Swift package later if desired.
//

import Foundation

// MARK: - Continent

/// The six "passport sections" the game groups countries into.
///
/// `unlockOrder` drives the sequential journey (Europe first, Polar last).
enum Continent: String, Codable, CaseIterable, Identifiable, Hashable {
    case europe = "Europe"
    case americas = "Americas"
    case asia = "Asia"
    case africa = "Africa"
    case oceania = "Oceania"
    case polar = "Polar & Territories"

    var id: String { rawValue }

    /// Human-readable section title shown on the passport tabs.
    var displayName: String { rawValue }

    /// Determines the sequential unlock journey for the player.
    /// Europe → Americas → Asia → Africa → Oceania → Polar & Territories.
    var unlockOrder: Int {
        switch self {
        case .europe:   return 0
        case .americas: return 1
        case .asia:     return 2
        case .africa:   return 3
        case .oceania:  return 4
        case .polar:    return 5
        }
    }

    /// SF Symbol used as a lightweight icon on section tabs and badges.
    var symbolName: String {
        switch self {
        case .europe:   return "building.columns"
        case .americas: return "mountain.2"
        case .asia:     return "sun.haze"
        case .africa:   return "tree"
        case .oceania:  return "water.waves"
        case .polar:    return "snowflake"
        }
    }

    /// A representative emoji used where an icon-free glyph is needed.
    var emoji: String {
        switch self {
        case .europe:   return "🏛️"
        case .americas: return "🏔️"
        case .asia:     return "🌅"
        case .africa:   return "🦒"
        case .oceania:  return "🌊"
        case .polar:    return "❄️"
        }
    }

    /// Sections ordered by their unlock journey.
    static var journeyOrdered: [Continent] {
        allCases.sorted { $0.unlockOrder < $1.unlockOrder }
    }
}

// MARK: - ClueTier

/// The four progressively revealable clue layers for each country.
///
/// Raw values are ordered hardest (1) → easiest (4) so that comparisons like
/// "did the player answer on tier 1 or 2?" read naturally for stamp ratings.
enum ClueTier: Int, Codable, CaseIterable, Comparable, Identifiable {
    case silhouette = 1
    case flag       = 2
    case fact       = 3
    case photo      = 4

    var id: Int { rawValue }

    static func < (lhs: ClueTier, rhs: ClueTier) -> Bool {
        lhs.rawValue < rhs.rawValue
    }

    /// Short label shown above the clue area.
    var title: String {
        switch self {
        case .silhouette: return "Mystery Shape"
        case .flag:       return "Flag"
        case .fact:       return "Fun Fact"
        case .photo:      return "Famous Place"
        }
    }

    var symbolName: String {
        switch self {
        case .silhouette: return "map"
        case .flag:       return "flag"
        case .fact:       return "lightbulb"
        case .photo:      return "photo"
        }
    }
}

// MARK: - StampRating

/// The quality of a stamp earned for a country.
///
/// Determined by the clue tier the player answered on, cross-referenced with
/// the active `DifficultyMode` thresholds (see `DifficultyMode.stampRating`).
enum StampRating: Int, Codable, CaseIterable, Comparable {
    case bronze = 1
    case silver = 2
    case gold   = 3

    static func < (lhs: StampRating, rhs: StampRating) -> Bool {
        lhs.rawValue < rhs.rawValue
    }

    /// Number of filled stars to render on the stamp card.
    var starCount: Int { rawValue }

    var displayName: String {
        switch self {
        case .bronze: return "Bronze"
        case .silver: return "Silver"
        case .gold:   return "Gold"
        }
    }

    /// Tint used for the star overlay.
    var tintHex: String {
        switch self {
        case .bronze: return "#CD7F32"
        case .silver: return "#AEB6BF"
        case .gold:   return "#F1C40F"
        }
    }
}

// MARK: - Country

/// A single country / territory entry in the seeded database.
struct Country: Identifiable, Codable, Hashable {
    /// ISO 3166-1 alpha-2 code, also used as the stable `id`.
    let id: String
    let name: String
    /// Accepted alternate spellings/names for fuzzy matching in Type It In mode.
    let alternateNames: [String]
    let continent: Continent
    /// Unicode regional-indicator flag emoji.
    let emojiFlag: String
    let capital: String
    let currency: String
    let nationalAnimal: String
    /// Exactly three age-appropriate fun facts; one is chosen at random per round.
    let facts: [String]
    /// Name of an iconic landmark used as the photo clue placeholder.
    let landmarkName: String
    /// Whether a hand-authored silhouette `Path` exists in `SilhouettePaths`.
    let silhouetteAvailable: Bool
    /// True for the ~8 most recognisable countries per continent, surfaced
    /// first on Easy mode for early wins.
    let isCuratedEasyUnlock: Bool

    init(id: String,
         name: String,
         alternateNames: [String] = [],
         continent: Continent,
         emojiFlag: String,
         capital: String,
         currency: String,
         nationalAnimal: String,
         facts: [String],
         landmarkName: String,
         silhouetteAvailable: Bool = false,
         isCuratedEasyUnlock: Bool = false) {
        self.id = id
        self.name = name
        self.alternateNames = alternateNames
        self.continent = continent
        self.emojiFlag = emojiFlag
        self.capital = capital
        self.currency = currency
        self.nationalAnimal = nationalAnimal
        self.facts = facts
        self.landmarkName = landmarkName
        self.silhouetteAvailable = silhouetteAvailable
        self.isCuratedEasyUnlock = isCuratedEasyUnlock
    }

    /// A single fact chosen deterministically from `seed` (so the same round
    /// shows the same fact). Falls back gracefully if the pool is short.
    func fact(seed: Int) -> String {
        guard !facts.isEmpty else { return "" }
        // Modulo that is always in 0..<count and safe for Int.min (abs(Int.min)
        // would trap), since `seed` may come from a String hashValue.
        let count = facts.count
        let index = ((seed % count) + count) % count
        return facts[index]
    }

    /// A fact for use as a *clue*, with the country's own name (and alternate
    /// names) blanked out so it can't give away the answer. e.g.
    /// "The UK has no single point…" → "This country has no single point…".
    func clueFact(seed: Int) -> String {
        Country.redactingOwnName(in: fact(seed: seed), country: self)
    }

    /// Blanks out the country's name, alternate names AND its capital city (the
    /// two biggest spoiler sources) in `text`, replacing them with neutral
    /// phrases. Used so fact and landmark clues don't give away the answer.
    static func redactingOwnName(in text: String, country: Country) -> String {
        var result = text
        // Redact the capital first (most specific) so e.g. "Mexico City" becomes
        // "its capital" rather than the garbled "this country City".
        let capital = country.capital
        if !capital.isEmpty && !capital.hasPrefix("No ") {
            redact(&result, term: capital, base: "its capital", possessive: "its capital's")
        }
        // Then the country names, longest first ("United Kingdom" before "Kingdom").
        let names = ([country.name] + country.alternateNames).sorted { $0.count > $1.count }
        for name in names {
            redact(&result, term: name, base: "this country", possessive: "this country's")
        }
        // Capitalise the first letter if a lowercase replacement landed at the start.
        if let first = result.first, first.isLowercase {
            result = first.uppercased() + result.dropFirst()
        }
        return result
    }

    /// Replaces `term` (with optional leading "the " and possessive "'s") with a
    /// neutral phrase, on whole-word boundaries only.
    private static func redact(_ text: inout String, term: String, base: String, possessive: String) {
        guard !term.isEmpty else { return }
        for (needle, replacement) in [
            ("the " + term + "'s", possessive),
            ("the " + term,        base),
            (term + "'s",          possessive),
            (term,                 base),
        ] {
            text = wholeWordReplace(text, needle: needle, with: replacement)
        }
    }

    /// Case-insensitive replace of `needle` with `with`, but only on whole-word
    /// boundaries so short names (e.g. "UK") don't match inside other words
    /// (e.g. "Ukraine").
    private static func wholeWordReplace(_ text: String, needle: String, with replacement: String) -> String {
        guard !needle.isEmpty else { return text }
        func isWordChar(_ c: Character) -> Bool { c.isLetter || c.isNumber }
        var result = ""
        var remainder = Substring(text)
        while let range = remainder.range(of: needle, options: [.caseInsensitive]) {
            let before = range.lowerBound > remainder.startIndex
                ? remainder[remainder.index(before: range.lowerBound)] : nil
            let after = range.upperBound < remainder.endIndex
                ? remainder[range.upperBound] : nil
            let boundaryOK = !(before.map(isWordChar) ?? false) && !(after.map(isWordChar) ?? false)
            result += remainder[remainder.startIndex..<range.lowerBound]
            if boundaryOK {
                result += replacement
            } else {
                result += remainder[range.lowerBound..<range.upperBound]
            }
            remainder = remainder[range.upperBound...]
        }
        result += remainder
        return result
    }
}
