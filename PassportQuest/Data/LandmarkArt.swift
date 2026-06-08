//
//  LandmarkArt.swift
//  PassportQuest
//
//  Picks a colourful, recognisable emoji "image" for the Famous Place clue.
//  Real photographs can't be bundled (Kids-Category rules + no networking +
//  licensing), so we render an emoji illustration instead. A small per-country
//  override table handles the most iconic landmarks; everything else is matched
//  by keywords in the landmark name. Drop real art into Assets.xcassets/Landmarks
//  for a production build (see that folder's README).
//

import Foundation

enum LandmarkArt {

    /// Per-country overrides for landmarks with a uniquely fitting emoji.
    private static let overrides: [String: String] = [
        "US": "🗽", "FR": "🗼", "CN": "🧱", "JP": "🗻", "EG": "🔺",
        "CL": "🗿", "AU": "🎭", "NL": "🌷", "CU": "🚗", "IN": "🕌",
        "GB": "🕰️", "RU": "⛪", "BR": "⛰️", "SA": "🕋", "AE": "🏙️",
        "MY": "🏙️", "SG": "🏙️", "GR": "🏛️", "IT": "🏛️", "BE": "🍫",
        "PE": "⛰️", "KR": "🏯", "KH": "🛕", "MX": "🛕", "JO": "🏜️",
        "KE": "🦁", "TZ": "🏔️", "ZA": "⛰️", "NP": "🏔️", "CH": "🏔️",
    ]

    /// Keyword rules applied to the landmark name (checked in order).
    private static let keywordRules: [(String, String)] = [
        ("pyramid", "🔺"), ("wall", "🧱"), ("statue", "🗽"),
        ("opera", "🎭"), ("tower", "🗼"), ("bridge", "🌉"),
        ("mosque", "🕌"), ("temple", "🛕"), ("pagoda", "🛕"), ("wat", "🛕"),
        ("cathedral", "⛪"), ("church", "⛪"), ("basilica", "⛪"),
        ("monastery", "⛪"), ("chapel", "⛪"),
        ("castle", "🏰"), ("fortress", "🏰"), ("palace", "🏰"), ("citadel", "🏰"),
        ("volcano", "🌋"), ("crater", "🌋"),
        ("falls", "💧"), ("waterfall", "💧"),
        ("mountain", "🏔️"), ("mount ", "🏔️"), ("everest", "🏔️"),
        ("matterhorn", "🏔️"), ("kilimanjaro", "🏔️"), ("peak", "🏔️"),
        ("glacier", "🧊"),
        ("desert", "🏜️"), ("dunes", "🏜️"), ("sahara", "🏜️"), ("sand", "🏜️"),
        ("island", "🏝️"), ("islands", "🏝️"), ("atoll", "🏝️"),
        ("cays", "🏝️"), ("archipelago", "🏝️"), ("lagoon", "🏝️"),
        ("reef", "🐠"), ("bay", "⛵"), ("fjord", "⛵"),
        ("lake", "🏞️"), ("delta", "🏞️"),
        ("forest", "🌳"), ("park", "🌳"), ("reserve", "🌳"),
        ("sanctuary", "🐒"), ("falls", "💧"),
        ("rock", "🪨"), ("cave", "🕳️"), ("caves", "🕳️"),
        ("market", "🛍️"), ("city", "🏙️"), ("dam", "🌊"),
    ]

    /// The best emoji for a country's Famous Place clue.
    static func emoji(for country: Country) -> String {
        if let override = overrides[country.id] { return override }
        let name = country.landmarkName.lowercased()
        for (keyword, emoji) in keywordRules where name.contains(keyword) {
            return emoji
        }
        // Fallback by continent so it still feels placed.
        switch country.continent {
        case .europe:   return "🏛️"
        case .americas: return "⛰️"
        case .asia:     return "🛕"
        case .africa:   return "🦒"
        case .oceania:  return "🏝️"
        case .polar:    return "❄️"
        }
    }
}
