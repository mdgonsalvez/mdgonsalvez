//
//  LandmarkArt.swift
//  PassportQuest
//
//  Picks a colourful emoji "image" AND a spoiler-free description for the Famous
//  Place clue. The landmark's real NAME often gives away the country (e.g.
//  "Sydney Opera House" → Sydney → Australia), so the clue shows a generic
//  phrase ("a famous opera house") instead; the real name is revealed on the
//  stamp card after a correct guess. Per-country overrides handle the most
//  iconic landmarks; everything else is matched by keywords in the name.
//
//  Real photographs can't be bundled (Kids-Category + no networking +
//  licensing). Drop production art into Assets.xcassets/Landmarks (see README).
//

import Foundation

enum LandmarkArt {

    /// (emoji, spoiler-free phrase) per country for uniquely iconic landmarks.
    private static let overrides: [String: (String, String)] = [
        "US": ("🗽", "a famous statue on an island"),
        "FR": ("🗼", "a famous iron tower"),
        "CN": ("🧱", "a wall thousands of miles long"),
        "JP": ("🗻", "a snow-capped sacred mountain"),
        "EG": ("🔺", "ancient giant pyramids"),
        "CL": ("🗿", "giant carved stone heads"),
        "AU": ("🎭", "a famous opera house on the harbour"),
        "NL": ("🌷", "fields full of tulips"),
        "CU": ("🚗", "colourful classic 1950s cars"),
        "IN": ("🕌", "a white marble palace of love"),
        "GB": ("🕰️", "a famous clock tower"),
        "RU": ("⛪", "a cathedral with colourful onion domes"),
        "BR": ("⛰️", "a giant statue on a mountain"),
        "SA": ("🕋", "a holy black cube building"),
        "AE": ("🏙️", "the world's tallest skyscraper"),
        "MY": ("🏙️", "famous twin towers"),
        "SG": ("🏙️", "a city of giant 'supertrees'"),
        "GR": ("🏛️", "ancient marble temples on a hill"),
        "IT": ("🏛️", "a giant ancient arena"),
        "BE": ("🍫", "a grand old market square"),
        "PE": ("⛰️", "a lost city high in the mountains"),
        "KR": ("🏯", "a grand royal palace"),
        "KH": ("🛕", "a huge ancient temple"),
        "MX": ("🛕", "a step-pyramid temple"),
        "JO": ("🏜️", "a city carved into pink rock"),
        "KE": ("🦁", "a savanna full of wild animals"),
        "TZ": ("🏔️", "the tallest mountain in Africa"),
        "ZA": ("⛰️", "a famous flat-topped mountain"),
        "NP": ("🏔️", "the world's tallest mountain"),
        "CH": ("🏔️", "a pointed snowy peak"),
        "PT": ("🗼", "an old riverside watchtower"),
        "TH": ("🛕", "a glittering royal palace"),
        "ID": ("🛕", "a huge ancient stone temple"),
        "TR": ("🕌", "a giant domed cathedral-mosque"),
    ]

    /// (keyword, emoji, phrase) rules applied to the landmark name, in order.
    private static let keywordRules: [(String, String, String)] = [
        ("pyramid", "🔺", "ancient pyramids"),
        ("wall", "🧱", "a great long wall"),
        ("statue", "🗽", "a famous statue"),
        ("opera", "🎭", "a grand opera house"),
        ("tower", "🗼", "a famous tower"),
        ("bridge", "🌉", "a famous bridge"),
        ("mosque", "🕌", "a beautiful mosque"),
        ("temple", "🛕", "an ancient temple"),
        ("pagoda", "🛕", "a golden pagoda"),
        ("wat", "🛕", "a huge temple complex"),
        ("cathedral", "⛪", "a grand cathedral"),
        ("church", "⛪", "a historic church"),
        ("basilica", "⛪", "a grand basilica"),
        ("monastery", "⛪", "an old cliffside monastery"),
        ("castle", "🏰", "a grand castle"),
        ("fortress", "🏰", "an old fortress"),
        ("palace", "🏰", "a grand palace"),
        ("citadel", "🏰", "a hilltop citadel"),
        ("volcano", "🌋", "a smoking volcano"),
        ("crater", "🌋", "a giant crater"),
        ("falls", "💧", "a mighty waterfall"),
        ("waterfall", "💧", "a mighty waterfall"),
        ("mountain", "🏔️", "a famous mountain"),
        ("mount ", "🏔️", "a famous mountain"),
        ("everest", "🏔️", "a towering mountain"),
        ("peak", "🏔️", "a high mountain peak"),
        ("glacier", "🧊", "a giant glacier"),
        ("desert", "🏜️", "vast desert sands"),
        ("dunes", "🏜️", "giant sand dunes"),
        ("sahara", "🏜️", "vast desert sands"),
        ("island", "🏝️", "beautiful islands"),
        ("atoll", "🏝️", "ring-shaped coral islands"),
        ("cays", "🏝️", "tiny tropical islands"),
        ("archipelago", "🏝️", "a chain of islands"),
        ("lagoon", "🏝️", "a turquoise lagoon"),
        ("reef", "🐠", "a colourful coral reef"),
        ("bay", "⛵", "a scenic bay"),
        ("fjord", "⛵", "a deep, steep fjord"),
        ("lake", "🏞️", "a beautiful lake"),
        ("delta", "🏞️", "a watery wildlife delta"),
        ("forest", "🌳", "a wild rainforest"),
        ("park", "🌳", "a wild national park"),
        ("reserve", "🌳", "a wildlife reserve"),
        ("sanctuary", "🐒", "a wildlife sanctuary"),
        ("rock", "🪨", "a giant rock"),
        ("cave", "🕳️", "amazing caves"),
        ("market", "🛍️", "a busy market"),
        ("city", "🏙️", "a famous old city"),
        ("dam", "🌊", "a huge dam"),
        ("ruins", "🏛️", "ancient ruins"),
        ("plateau", "⛰️", "a dramatic plateau"),
    ]

    private static func resolve(_ country: Country) -> (String, String) {
        if let override = overrides[country.id] { return override }
        let name = country.landmarkName.lowercased()
        for (keyword, emoji, phrase) in keywordRules where name.contains(keyword) {
            return (emoji, phrase)
        }
        // Fallback by continent.
        switch country.continent {
        case .europe:   return ("🏛️", "a famous old landmark")
        case .americas: return ("⛰️", "a famous natural wonder")
        case .asia:     return ("🛕", "a famous temple or palace")
        case .africa:   return ("🦒", "amazing wildlife and scenery")
        case .oceania:  return ("🏝️", "a beautiful island sight")
        case .polar:    return ("❄️", "a frozen, remote wonder")
        }
    }

    /// The best emoji for a country's Famous Place clue.
    static func emoji(for country: Country) -> String { resolve(country).0 }

    /// A spoiler-free description of the country's famous place.
    static func phrase(for country: Country) -> String { resolve(country).1 }
}
