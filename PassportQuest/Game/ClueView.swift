//
//  ClueView.swift
//  PassportQuest
//
//  Renders the active clue and a row of clue "chips". Every round opens on the
//  Mystery Shape; the other clues appear as chips the player can tap to reveal
//  (locked chips show their token cost). The active continent is shown next to
//  the clue so the player always has a sense of place.
//

import SwiftUI

struct ClueView: View {
    let country: Country
    let activeTier: ClueTier
    /// Every clue tier offered in this mode (for the chip row).
    let availableTiers: [ClueTier]
    /// Tiers already revealed.
    let revealedTiers: [ClueTier]
    /// A stable seed so the random fact stays constant for this round.
    let factSeed: Int
    /// Token cost to reveal one more clue (0 = free).
    let revealCost: Int
    /// Whether the player can currently afford a reveal.
    let canAffordReveal: Bool
    /// Tap handler for a chip: reveals a locked tier or switches to a revealed one.
    var onTapTier: (ClueTier) -> Void = { _ in }

    var body: some View {
        VStack(spacing: 14) {
            // The active clue stage.
            clueStage
                .frame(maxWidth: .infinity)
                .frame(height: 240)
                .background(RoundedRectangle(cornerRadius: 24).fill(PQTheme.paperDeep))
                .overlay(RoundedRectangle(cornerRadius: 24).stroke(PQTheme.ink.opacity(0.15), lineWidth: 1))

            // Continent label, shown next to every clue.
            Label(country.continent.displayName, systemImage: "globe.europe.africa")
                .font(.subheadline.weight(.semibold))
                .foregroundColor(PQTheme.ink)
                .padding(.horizontal, 14).padding(.vertical, 6)
                .background(Capsule().fill(PQTheme.paperDeep))
                .overlay(Capsule().stroke(PQTheme.ink.opacity(0.15), lineWidth: 1))
                .accessibilityLabel("Continent: \(country.continent.displayName)")

            // Clue chips: all available tiers, tap to reveal/switch.
            HStack(spacing: 8) {
                ForEach(availableTiers) { tier in
                    tierChip(tier)
                }
            }
        }
    }

    @ViewBuilder
    private var clueStage: some View {
        switch activeTier {
        case .silhouette:
            SilhouetteView(country: country)
                .padding(24)
        case .flag:
            Text(country.emojiFlag)
                .font(.system(size: 140))
                .accessibilityLabel("Flag clue")
        case .fact:
            VStack(spacing: 12) {
                Image(systemName: "lightbulb.fill")
                    .font(.largeTitle)
                    .foregroundColor(PQTheme.gold)
                Text(country.clueFact(seed: factSeed))
                    .font(.title3.weight(.medium))
                    .multilineTextAlignment(.center)
                    .foregroundColor(PQTheme.ink)
                    .padding(.horizontal, 24)
            }
            .accessibilityElement(children: .combine)
            .accessibilityLabel("Fun fact: \(country.clueFact(seed: factSeed))")
        case .photo:
            VStack(spacing: 12) {
                Text(LandmarkArt.emoji(for: country))
                    .font(.system(size: 104))
                Text(Country.redactingOwnName(in: country.landmarkName, country: country))
                    .font(.title2.weight(.bold))
                    .foregroundColor(PQTheme.ink)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 16)
                Text("Famous Place")
                    .font(.caption.weight(.semibold))
                    .foregroundColor(.secondary)
            }
            .accessibilityElement(children: .combine)
            .accessibilityLabel("Famous place clue")
        }
    }

    private func tierChip(_ tier: ClueTier) -> some View {
        let revealed = revealedTiers.contains(tier)
        let isActive = tier == activeTier
        let affordable = revealed || canAffordReveal

        return Button { onTapTier(tier) } label: {
            VStack(spacing: 4) {
                Image(systemName: revealed ? tier.symbolName : "eye.fill")
                    .font(.subheadline)
                Text(tier.title)
                    .font(.caption2.weight(.semibold))
                    .lineLimit(1)
                if !revealed && revealCost > 0 {
                    Label("\(revealCost)", systemImage: "ticket.fill")
                        .font(.system(size: 9, weight: .bold))
                        .labelStyle(.titleAndIcon)
                }
            }
            .frame(maxWidth: .infinity, minHeight: PQTheme.minTap)
            .padding(.vertical, 8).padding(.horizontal, 6)
            .background(
                RoundedRectangle(cornerRadius: 14)
                    .fill(isActive ? PQTheme.ink : (revealed ? PQTheme.paper : PQTheme.paperDeep))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 14)
                    .strokeBorder(style: StrokeStyle(lineWidth: 1.5,
                                                     dash: revealed ? [] : [4, 3]))
                    .foregroundColor(PQTheme.ink.opacity(revealed ? 0.25 : 0.4))
            )
            .foregroundColor(isActive ? .white : PQTheme.ink)
            .opacity(affordable ? 1 : 0.45)
        }
        .disabled(!affordable)
        .accessibilityLabel(revealed
            ? "\(tier.title) clue\(isActive ? ", showing" : "")"
            : (revealCost > 0 ? "Reveal \(tier.title) clue, costs \(revealCost) tokens"
                              : "Reveal \(tier.title) clue"))
    }
}
