//
//  StampCardView.swift
//  PassportQuest
//
//  Two parts:
//   • `StampMark` — the reusable passport-stamp graphic. Renders a single-ring
//     stamp normally and a double-ring "Cartographer's Seal" when the stamp was
//     earned on Hard. The Hard treatment is derived from the difficulty at
//     render time (spec rule #14), never stored as a separate flag.
//   • `StampCardView` — the detail sheet shown when tapping a stamped country.
//

import SwiftUI

// MARK: - StampMark

struct StampMark: View {
    let country: Country
    let rating: StampRating
    /// Whether to render the Cartographer's Seal (Hard) gold medallion.
    let isHard: Bool
    var size: CGFloat = 120
    /// Optional ink tint; defaults to a classic passport navy.
    var ink: Color = PQTheme.ink

    /// Hard stamps are inked in gold to read as a premium seal.
    private var accent: Color { isHard ? PQTheme.goldDeep : ink }

    var body: some View {
        ZStack {
            // Gold medallion sheen behind the Hard seal.
            if isHard {
                Circle()
                    .fill(RadialGradient(colors: [PQTheme.gold.opacity(0.30), PQTheme.gold.opacity(0.04)],
                                         center: .center, startRadius: 0, endRadius: size * 0.5))
                    .frame(width: size * 0.95, height: size * 0.95)
            }

            // Outer rim.
            Circle()
                .stroke(accent, lineWidth: size * 0.035)
                .frame(width: size, height: size)

            // Serrated "rubber stamp" tick ring just inside the rim.
            TickRing(diameter: size * 0.9,
                     color: accent.opacity(0.55),
                     ticks: 60,
                     length: size * (isHard ? 0.05 : 0.032),
                     thickness: size * 0.008)

            // Inner ring (tighter on the Hard medallion).
            Circle()
                .stroke(accent, lineWidth: size * 0.014)
                .frame(width: size * (isHard ? 0.82 : 0.78),
                       height: size * (isHard ? 0.82 : 0.78))

            // Curved brand text arcing along the top.
            ArcText(text: "PASSPORT QUEST",
                    diameter: size * 0.79,
                    font: .system(size: size * 0.082, weight: .bold, design: .rounded),
                    color: accent,
                    arc: 150)

            // Centre identity: flag, country, stars and a faux travel date.
            VStack(spacing: size * 0.02) {
                Text(country.emojiFlag)
                    .font(.system(size: size * 0.3))
                Text(country.name.uppercased())
                    .font(.system(size: size * 0.105, weight: .heavy, design: .rounded))
                    .foregroundColor(ink)
                    .lineLimit(1)
                    .minimumScaleFactor(0.5)
                    .padding(.horizontal, size * 0.14)
                stars
                Text(stampDate)
                    .font(.system(size: size * 0.064, weight: .semibold, design: .monospaced))
                    .foregroundColor(accent.opacity(0.85))
                    .padding(.top, size * 0.008)
            }
            .frame(width: size * 0.62)
            .offset(y: size * 0.045)
        }
        .rotationEffect(.degrees(tilt)) // per-country "stamped by hand" tilt
        .frame(width: size, height: size)
        .accessibilityElement()
        .accessibilityLabel("\(country.name) stamp, \(rating.displayName)\(isHard ? ", Cartographer's Seal" : "")")
    }

    private var stars: some View {
        HStack(spacing: size * 0.02) {
            ForEach(0..<3, id: \.self) { i in
                Image(systemName: i < rating.starCount ? "star.fill" : "star")
                    .font(.system(size: size * 0.092))
                    .foregroundColor(i < rating.starCount ? Color(hex: rating.tintHex) : ink.opacity(0.3))
            }
        }
    }

    // MARK: Deterministic per-country flourishes (stable across launches)

    private var idSeed: Int {
        country.id.unicodeScalars.reduce(0) { $0 &+ Int($1.value) }
    }
    /// Slight tilt in roughly -9°…+7°, constant for a given country.
    private var tilt: Double { Double((idSeed % 17) - 9) }
    /// A stable, stamp-like "date of travel" — purely decorative.
    private var stampDate: String {
        let months = ["JAN","FEB","MAR","APR","MAY","JUN","JUL","AUG","SEP","OCT","NOV","DEC"]
        let day = (idSeed % 27) + 1
        let mon = months[(idSeed / 3) % 12]
        let year = 2024 + (idSeed % 3)
        return String(format: "%02d %@ %d", day, mon, year)
    }
}

// MARK: - Stamp building blocks

/// Lays out a string along the top arc of a circle so it reads like the curved
/// text on a real passport stamp.
private struct ArcText: View {
    let text: String
    let diameter: CGFloat
    let font: Font
    let color: Color
    /// Total arc the text spans, in degrees, centred at the top.
    var arc: Double = 150

    var body: some View {
        let chars = Array(text.enumerated())
        let n = max(text.count - 1, 1)
        return ZStack {
            ForEach(chars, id: \.offset) { idx, ch in
                let frac = Double(idx) / Double(n) - 0.5   // -0.5 … 0.5
                VStack(spacing: 0) {
                    Text(String(ch)).font(font).foregroundColor(color)
                    Spacer(minLength: 0)
                }
                .rotationEffect(.degrees(frac * arc))
            }
        }
        .frame(width: diameter, height: diameter)
    }
}

/// A ring of short radial ticks, giving the worn-rubber-stamp serration.
private struct TickRing: View {
    let diameter: CGFloat
    let color: Color
    var ticks: Int = 60
    var length: CGFloat
    var thickness: CGFloat

    var body: some View {
        ZStack {
            ForEach(0..<ticks, id: \.self) { i in
                Capsule()
                    .fill(color)
                    .frame(width: thickness, height: length)
                    .offset(y: -(diameter / 2 - length / 2))
                    .rotationEffect(.degrees(Double(i) / Double(ticks) * 360))
            }
        }
        .frame(width: diameter, height: diameter)
    }
}

// MARK: - StampCardView

struct StampCardView: View {
    @Environment(\.dismiss) private var dismiss
    let country: Country
    let rating: StampRating
    let earnedOnHard: Bool
    /// One unlocked fact to show (kept stable by the caller's seed).
    let unlockedFact: String

    var body: some View {
        VStack(spacing: 24) {
            Capsule()
                .fill(Color.secondary.opacity(0.3))
                .frame(width: 40, height: 5)
                .padding(.top, 8)

            StampMark(country: country, rating: rating, isHard: earnedOnHard, size: 180)
                .padding(.top, 8)

            VStack(spacing: 6) {
                Text(country.name)
                    .font(.largeTitle.weight(.bold))
                    .foregroundColor(PQTheme.ink)
                Text(country.continent.displayName)
                    .font(.headline)
                    .foregroundColor(PQTheme.inkSoft)
            }

            HStack(spacing: 8) {
                ForEach(0..<3, id: \.self) { i in
                    Image(systemName: i < rating.starCount ? "star.fill" : "star")
                        .foregroundColor(i < rating.starCount ? Color(hex: rating.tintHex) : .secondary.opacity(0.4))
                }
                Text(rating.displayName).font(.headline).foregroundColor(PQTheme.ink)
                if earnedOnHard {
                    Label("Cartographer's Seal", systemImage: "seal.fill")
                        .font(.subheadline.weight(.semibold))
                        .foregroundColor(PQTheme.goldDeep)
                }
            }

            VStack(alignment: .leading, spacing: 8) {
                Label("Fun fact", systemImage: "lightbulb.fill")
                    .font(.subheadline.weight(.semibold))
                    .foregroundColor(PQTheme.inkSoft)
                Text(unlockedFact)
                    .font(.body)
                    .foregroundColor(PQTheme.ink)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding()
            .background(RoundedRectangle(cornerRadius: 16).fill(PQTheme.paperDeep))

            Button { dismiss() } label: {
                Text("Close")
                    .font(.headline)
                    .frame(maxWidth: .infinity, minHeight: PQTheme.minTap)
                    .background(RoundedRectangle(cornerRadius: 14).fill(PQTheme.ink))
                    .foregroundColor(.white)
            }
            Spacer(minLength: 0)
        }
        .padding(24)
        .background(PQTheme.paper.ignoresSafeArea())
    }
}

#Preview {
    StampCardView(country: CountryDatabase.country(id: "BR")!,
                  rating: .gold,
                  earnedOnHard: true,
                  unlockedFact: CountryDatabase.country(id: "BR")!.facts[0])
}
