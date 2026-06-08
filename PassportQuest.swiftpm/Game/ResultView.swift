//
//  ResultView.swift
//  PassportQuest
//
//  Correct / wrong / revealed feedback. On a correct answer it shows the stamp
//  award (with the Cartographer's Seal double-ring when earned on Hard) plus a
//  confetti burst. Copy is warm and never punishing (spec accessibility notes).
//

import SwiftUI

struct ResultView: View {
    @EnvironmentObject private var settings: GameSettings
    let country: Country
    let phase: RoundPhase
    let tokenAward: Int
    /// True if this stamp was earned on Hard (drives the seal).
    let earnedOnHard: Bool
    var onNext: () -> Void

    var body: some View {
        VStack(spacing: 20) {
            switch phase {
            case .correct(let rating):
                correctContent(rating: rating)
            case .revealedAnswer:
                revealedContent
            case .wrong, .guessing:
                EmptyView()
            }
        }
        .padding(24)
        .frame(maxWidth: .infinity)
        .background(RoundedRectangle(cornerRadius: 24).fill(PQTheme.paper))
        .overlay(RoundedRectangle(cornerRadius: 24).stroke(PQTheme.ink.opacity(0.12), lineWidth: 1))
    }

    // MARK: Correct

    private func correctContent(rating: StampRating) -> some View {
        VStack(spacing: 16) {
            ZStack {
                if !motionIsReduced(settings) {
                    ConfettiView(duration: 2.0)
                        .frame(height: 10)
                        .allowsHitTesting(false)
                }
                StampMark(country: country, rating: rating, isHard: earnedOnHard, size: 160)
            }
            Text("Stamped! You're a world traveller!")
                .font(.title2.weight(.bold))
                .multilineTextAlignment(.center)
                .foregroundColor(PQTheme.positive)
            Text("\(country.emojiFlag) \(country.name)")
                .font(.title3.weight(.semibold))
                .foregroundColor(PQTheme.ink)
            if tokenAward > 0 {
                Label("+\(tokenAward) tokens", systemImage: "ticket.fill")
                    .font(.headline)
                    .foregroundColor(PQTheme.ink)
            }
            nextButton(title: "Next Country")
        }
    }

    // MARK: Revealed (visited but not stamped)

    private var revealedContent: some View {
        VStack(spacing: 16) {
            Text("🧳")
                .font(.system(size: 72))
            Text("Visited — we'll come back to this one!")
                .font(.title3.weight(.bold))
                .multilineTextAlignment(.center)
                .foregroundColor(PQTheme.ink)
            Text("The mystery country was")
                .font(.subheadline)
                .foregroundColor(.secondary)
            Text("\(country.emojiFlag) \(country.name)")
                .font(.title2.weight(.bold))
                .foregroundColor(PQTheme.ink)
            nextButton(title: "Keep Exploring")
        }
        .accessibilityElement(children: .combine)
    }

    private func nextButton(title: String) -> some View {
        Button(action: onNext) {
            Text(title)
                .font(.headline)
                .frame(maxWidth: .infinity, minHeight: PQTheme.minTap)
                .background(RoundedRectangle(cornerRadius: 14).fill(PQTheme.ink))
                .foregroundColor(.white)
        }
        .accessibilityLabel(title)
    }
}
