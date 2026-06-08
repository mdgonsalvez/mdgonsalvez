//
//  WorldMapView.swift
//  PassportQuest
//
//  A simplified, programmatically drawn world map. Each continent is rendered
//  as a soft region (SwiftUI Canvas) that fills with the player's chosen ink
//  colour in proportion to how many of its countries are stamped. Stamped
//  countries appear as tappable flag "pins" clustered in their region; tapping
//  one opens its stamp card. No bitmap map assets are used.
//

import SwiftUI

struct WorldMapView: View {
    @EnvironmentObject private var settings: GameSettings
    @EnvironmentObject private var store: PlayerProgressStore
    var onSelectCountry: (Country) -> Void = { _ in }

    /// Normalised bounding box per continent on the stylised map.
    private static let regions: [Continent: CGRect] = [
        .americas: CGRect(x: 0.04, y: 0.12, width: 0.26, height: 0.62),
        .europe:   CGRect(x: 0.38, y: 0.08, width: 0.17, height: 0.22),
        .africa:   CGRect(x: 0.40, y: 0.34, width: 0.20, height: 0.36),
        .asia:     CGRect(x: 0.58, y: 0.08, width: 0.37, height: 0.36),
        .oceania:  CGRect(x: 0.74, y: 0.56, width: 0.21, height: 0.22),
        .polar:    CGRect(x: 0.18, y: 0.82, width: 0.64, height: 0.14),
    ]

    var body: some View {
        GeometryReader { geo in
            ZStack(alignment: .topLeading) {
                // Ocean backdrop.
                RoundedRectangle(cornerRadius: 20)
                    .fill(LinearGradient(colors: [Color(red: 0.80, green: 0.90, blue: 0.96),
                                                  Color(red: 0.69, green: 0.84, blue: 0.93)],
                                         startPoint: .top, endPoint: .bottom))

                // Continent regions tinted by completion.
                Canvas { context, size in
                    for (continent, rect) in Self.regions {
                        let frame = scaled(rect, in: size)
                        let total = CountryDatabase.countries(in: continent).count
                        let stamped = store.progress.stampedCount(in: continent, database: CountryDatabase.all)
                        let fraction = total == 0 ? 0 : Double(stamped) / Double(total)
                        let blob = Path(roundedRect: frame, cornerRadius: min(frame.width, frame.height) * 0.28)
                        context.fill(blob, with: .color(Color(red: 0.86, green: 0.88, blue: 0.80)))
                        context.fill(blob, with: .color(settings.inkColour.color.opacity(0.18 + 0.62 * fraction)))
                        context.stroke(blob, with: .color(PQTheme.ink.opacity(0.3)), lineWidth: 1.5)
                    }
                }

                // Region labels.
                ForEach(Continent.journeyOrdered) { continent in
                    if let rect = Self.regions[continent] {
                        let frame = scaled(rect, in: geo.size)
                        Text(continent.emoji)
                            .font(.title2)
                            .position(x: frame.midX, y: frame.minY + 14)
                            .accessibilityHidden(true)
                    }
                }

                // Stamped-country pins.
                ForEach(stampedPins(in: geo.size), id: \.country.id) { pin in
                    Button { onSelectCountry(pin.country) } label: {
                        Text(pin.country.emojiFlag)
                            .font(.system(size: 20))
                            .padding(3)
                            .background(Circle().fill(PQTheme.paper))
                            .overlay(Circle().stroke(settings.inkColour.color, lineWidth: store.progress.wasEarnedOnHard(pin.country.id) ? 2 : 1))
                    }
                    .position(pin.point)
                    .accessibilityLabel("\(pin.country.name) stamp. Double tap for details.")
                }
            }
        }
        .aspectRatio(1.7, contentMode: .fit)
        .padding(8)
    }

    private func scaled(_ rect: CGRect, in size: CGSize) -> CGRect {
        CGRect(x: rect.minX * size.width, y: rect.minY * size.height,
               width: rect.width * size.width, height: rect.height * size.height)
    }

    private struct Pin { let country: Country; let point: CGPoint }

    /// Positions stamped countries in a small grid inside their region.
    private func stampedPins(in size: CGSize) -> [Pin] {
        var pins: [Pin] = []
        for continent in Continent.allCases {
            guard let rect = Self.regions[continent] else { continue }
            let frame = scaled(rect, in: size).insetBy(dx: 14, dy: 22)
            let stamped = CountryDatabase.countries(in: continent)
                .filter { store.progress.isStamped($0.id) }
            guard !stamped.isEmpty else { continue }
            let perRow = max(1, Int((frame.width / 30).rounded(.down)))
            for (i, country) in stamped.enumerated() {
                let row = i / perRow
                let col = i % perRow
                let x = frame.minX + (CGFloat(col) + 0.5) * (frame.width / CGFloat(perRow))
                let y = frame.minY + (CGFloat(row) + 0.5) * 28
                guard y < frame.maxY else { continue } // overflow safety
                pins.append(Pin(country: country, point: CGPoint(x: x, y: y)))
            }
        }
        return pins
    }
}
