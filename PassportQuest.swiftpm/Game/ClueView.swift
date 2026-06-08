//
//  ClueView.swift
//  PassportQuest
//
//  Renders whichever clue tier is currently active for a country, plus a row
//  of tier "chips" so the player can flick between clues they have already
//  revealed. Pure presentation — all reveal logic lives in GameViewModel.
//

import SwiftUI

struct ClueView: View {
    let country: Country
    let activeTier: ClueTier
    let revealedTiers: [ClueTier]
    /// A stable seed so the random fact stays constant for this round.
    let factSeed: Int
    /// Called when the player taps an already-revealed tier chip.
    var onSelectTier: (ClueTier) -> Void = { _ in }

    var body: some View {
        VStack(spacing: 16) {
            // The active clue stage.
            clueStage
                .frame(maxWidth: .infinity)
                .frame(height: 240)
                .background(
                    RoundedRectangle(cornerRadius: 24)
                        .fill(PQTheme.paperDeep)
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 24)
                        .stroke(PQTheme.ink.opacity(0.15), lineWidth: 1)
                )

            // Tier chips for revealed clues.
            if revealedTiers.count > 1 {
                HStack(spacing: 10) {
                    ForEach(revealedTiers) { tier in
                        tierChip(tier)
                    }
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
            landmarkPlaceholder
        }
    }

    /// Labelled placeholder for the landmark/photo clue. Production swaps in an
    /// illustrated asset (see Assets.xcassets/README).
    private var landmarkPlaceholder: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 16)
                .fill(
                    LinearGradient(colors: [Color(red: 0.55, green: 0.7, blue: 0.85),
                                            Color(red: 0.75, green: 0.85, blue: 0.95)],
                                   startPoint: .top, endPoint: .bottom)
                )
            VStack(spacing: 12) {
                Image(systemName: "photo.artframe")
                    .font(.system(size: 48))
                    .foregroundColor(.white)
                Text(Country.redactingOwnName(in: country.landmarkName, country: country))
                    .font(.title2.weight(.bold))
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                Text("Famous Place")
                    .font(.caption.weight(.semibold))
                    .foregroundColor(.white.opacity(0.85))
            }
            .padding()
        }
        .padding(20)
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Famous place clue")
    }

    private func tierChip(_ tier: ClueTier) -> some View {
        Button { onSelectTier(tier) } label: {
            HStack(spacing: 6) {
                Image(systemName: tier.symbolName)
                Text(tier.title).font(.caption.weight(.semibold))
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 10)
            .frame(minHeight: 44)
            .background(
                Capsule().fill(tier == activeTier ? PQTheme.ink : PQTheme.paper)
            )
            .foregroundColor(tier == activeTier ? .white : PQTheme.ink)
            .overlay(Capsule().stroke(PQTheme.ink.opacity(0.2), lineWidth: 1))
        }
        .accessibilityLabel("\(tier.title) clue\(tier == activeTier ? ", showing" : "")")
    }
}
