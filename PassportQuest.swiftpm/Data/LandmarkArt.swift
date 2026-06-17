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
        // v1.1: purpose-written clues for countries that previously fell back to
        // a generic continent phrase.
        "ES": ("⛪", "a giant fairy-tale church still being built"),
        "DK": ("🧜", "a little mermaid statue by the harbour"),
        "DE": ("🏛️", "a grand columned city gate"),
        "IE": ("🌊", "towering sea cliffs"),
        "IS": ("⛪", "a soaring rocket-shaped church"),
        "HR": ("🏰", "a walled seaside old town"),
        "EE": ("🏰", "a medieval old town full of towers"),
        "HU": ("🏛️", "a vast riverside parliament palace"),
        "LV": ("🏛️", "an ornate guild house on the town square"),
        "LU": ("🏰", "tunnels carved into a fortress cliff"),
        "MD": ("🍇", "the world's largest underground wine cellars"),
        "MC": ("🎰", "a glamorous grand casino"),
        "AD": ("🏛️", "a historic stone parliament house in the mountains"),
        "DZ": ("🏜️", "ancient rock art in the desert"),
        "BJ": ("🛖", "a village of houses on stilts over water"),
        "CV": ("🌋", "an island volcano"),
        "GQ": ("🌋", "a tall volcanic peak"),
        "LY": ("🏛️", "grand ancient Roman ruins"),
        "MG": ("🌳", "a road lined with giant baobab trees"),
        "MU": ("⛰️", "a dramatic mountain by the sea"),
        "MA": ("🛍️", "a huge bustling market square"),
        "SN": ("🗽", "a giant bronze monument of a family"),
        "SC": ("🏝️", "a beach with giant granite boulders"),
        "ST": ("⛰️", "a towering needle-shaped rock peak"),
        "TG": ("🛖", "traditional mud tower-houses"),
        "AG": ("⛵", "a historic harbour and dockyard"),
        "BZ": ("🕳️", "a giant deep-blue ocean sinkhole"),
        "BO": ("🧂", "a vast white salt flat"),
        "CO": ("🏞️", "a river that runs five colours"),
        "DO": ("🏛️", "the oldest colonial old town in the Americas"),
        "GT": ("🛕", "ancient pyramid temples in the jungle"),
        "PA": ("🚢", "a famous canal joining two oceans"),
        "LC": ("⛰️", "two pointed volcanic peaks by the sea"),
        "UY": ("🏖️", "a beach resort with a giant hand sculpture"),
        "BH": ("🌳", "a lone tree surviving in the desert"),
        "BD": ("🐅", "a vast mangrove forest home to tigers"),
        "IR": ("🏛️", "ancient ceremonial ruins of a great empire"),
        "LB": ("🌲", "an ancient grove of cedar trees"),
        "PH": ("⛰️", "hundreds of round green hills"),
        "QA": ("🕌", "a striking modern museum of Islamic art"),
        "SY": ("🏛️", "ancient desert ruins of a caravan city"),
        "TL": ("🗽", "a tall hilltop statue overlooking the sea"),
        "UZ": ("🕌", "grand tiled domes and towers on an old square"),
        "FM": ("🛕", "an ancient stone city built on water"),
        "NZ": ("🏔️", "a stunning fjord between steep cliffs"),
        "PG": ("🥾", "a rugged jungle mountain trail"),
        "WS": ("🏝️", "a deep turquoise swimming hole"),
        "TO": ("🗿", "an ancient giant stone archway"),
        "AQ": ("❄️", "a research base at the bottom of the world"),
        "GS": ("🐧", "an old whaling station among penguins"),
        "SJ": ("🌱", "a vault storing the world's seeds in the ice"),
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
