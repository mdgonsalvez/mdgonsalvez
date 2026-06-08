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
    /// Whether to render the Cartographer's Seal (Hard) double ring.
    let isHard: Bool
    var size: CGFloat = 120
    /// Optional ink tint; defaults to a classic passport navy.
    var ink: Color = PQTheme.ink

    var body: some View {
        ZStack {
            // Outer ring(s).
            Circle()
                .stroke(ink, lineWidth: size * 0.03)
                .frame(width: size, height: size)
            if isHard {
                // Cartographer's Seal: a second concentric ring.
                Circle()
                    .stroke(ink, lineWidth: size * 0.02)
                    .frame(width: size * 0.86, height: size * 0.86)
            }

            VStack(spacing: size * 0.03) {
                Text(country.emojiFlag)
                    .font(.system(size: size * 0.34))
                Text(country.name.uppercased())
                    .font(.system(size: size * 0.11, weight: .heavy, design: .rounded))
                    .foregroundColor(ink)
                    .lineLimit(1)
                    .minimumScaleFactor(0.5)
                    .padding(.horizontal, size * 0.12)
                stars
            }
            .frame(width: size * (isHard ? 0.78 : 0.86))
        }
        .rotationEffect(.degrees(-8)) // jaunty "stamped by hand" tilt
        .frame(width: size, height: size)
        .accessibilityElement()
        .accessibilityLabel("\(country.name) stamp, \(rating.displayName)\(isHard ? ", Cartographer's Seal" : "")")
    }

    private var stars: some View {
        HStack(spacing: size * 0.02) {
            ForEach(0..<3, id: \.self) { i in
                Image(systemName: i < rating.starCount ? "star.fill" : "star")
                    .font(.system(size: size * 0.1))
                    .foregroundColor(i < rating.starCount ? Color(hex: rating.tintHex) : ink.opacity(0.3))
            }
        }
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
                    .foregroundColor(.secondary)
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
                        .foregroundColor(PQTheme.gold)
                }
            }

            VStack(alignment: .leading, spacing: 8) {
                Label("Fun fact", systemImage: "lightbulb.fill")
                    .font(.subheadline.weight(.semibold))
                    .foregroundColor(.secondary)
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
