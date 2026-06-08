//
//  TravellersTriviaView.swift
//  PassportQuest
//
//  The bonus question presented every 5th correct answer. A correct answer
//  upgrades the just-earned stamp one rank (bronze→silver, silver→gold).
//  Question format follows the difficulty matrix: Easy 4 options, Medium 3,
//  Hard type-the-answer (fuzzy matched). All read from DifficultyMode via the
//  question the view model built.
//

import SwiftUI

struct TravellersTriviaView: View {
    @EnvironmentObject private var settings: GameSettings
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var game: GameViewModel
    let question: TriviaQuestion

    @State private var typed: String = ""
    @State private var result: Bool?
    /// Shows the one-time explainer for this presentation (captured on appear so
    /// flipping the persisted flag doesn't hide it mid-view).
    @State private var showIntro = false

    var body: some View {
        ZStack {
            PQTheme.paper.ignoresSafeArea()
            VStack(spacing: 22) {
                header

                if let result {
                    resultCard(correct: result)
                } else {
                    if showIntro { introBanner }
                    questionCard
                    if question.options.isEmpty {
                        typeArea
                    } else {
                        optionsArea
                    }
                }
            }
            .padding(24)
            .frame(maxWidth: 600)
        }
        .onAppear {
            if !settings.hasSeenTriviaIntro {
                showIntro = true
                settings.hasSeenTriviaIntro = true
            }
        }
    }

    private var introBanner: some View {
        Text("Bonus round! Get this right and your new stamp jumps up a level — Bronze → Silver, Silver → Gold. ✨")
            .font(.subheadline.weight(.medium))
            .foregroundColor(PQTheme.ink)
            .multilineTextAlignment(.center)
            .fixedSize(horizontal: false, vertical: true)
            .padding(14)
            .frame(maxWidth: .infinity)
            .background(RoundedRectangle(cornerRadius: 14).fill(PQTheme.gold.opacity(0.18)))
            .overlay(RoundedRectangle(cornerRadius: 14).stroke(PQTheme.goldDeep.opacity(0.35), lineWidth: 1))
            .accessibilityLabel("Bonus round! Answer correctly to upgrade your new stamp one level, Bronze to Silver, or Silver to Gold.")
    }

    private var header: some View {
        VStack(spacing: 6) {
            Text("✨ Traveller's Trivia")
                .font(.title.weight(.heavy))
                .foregroundColor(PQTheme.ink)
            Text("Answer to upgrade your \(question.country.name) stamp!")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
    }

    private var questionCard: some View {
        VStack(spacing: 12) {
            Text(question.country.emojiFlag).font(.system(size: 64))
            Text("\(question.category.prompt) \(question.country.name)?")
                .font(.title3.weight(.semibold))
                .multilineTextAlignment(.center)
                .foregroundColor(PQTheme.ink)
        }
        .padding(20)
        .frame(maxWidth: .infinity)
        .background(RoundedRectangle(cornerRadius: 20).fill(PQTheme.paperDeep))
    }

    private var optionsArea: some View {
        VStack(spacing: 12) {
            ForEach(question.options, id: \.self) { option in
                Button { resolve(option) } label: {
                    Text(option)
                        .font(.title3.weight(.semibold))
                        .foregroundColor(PQTheme.ink)
                        .frame(maxWidth: .infinity, minHeight: PQTheme.minTap + 6)
                        .background(RoundedRectangle(cornerRadius: 16).fill(PQTheme.paper))
                        .overlay(RoundedRectangle(cornerRadius: 16).stroke(PQTheme.ink.opacity(0.18), lineWidth: 1))
                }
                .accessibilityLabel("Answer: \(option)")
            }
        }
    }

    private var typeArea: some View {
        VStack(spacing: 12) {
            TextField("Type your answer…", text: $typed)
                .autocorrectionDisabled()
                .textInputAutocapitalization(.words)
                .font(.title3)
                .padding(.horizontal, 16)
                .frame(minHeight: PQTheme.minTap + 6)
                .background(RoundedRectangle(cornerRadius: 16).fill(PQTheme.paperDeep))
                .overlay(RoundedRectangle(cornerRadius: 16).stroke(PQTheme.ink.opacity(0.2), lineWidth: 1))
                .onSubmit { resolve(typed) }
            Button { resolve(typed) } label: {
                Text("Answer")
                    .font(.headline)
                    .frame(maxWidth: .infinity, minHeight: PQTheme.minTap)
                    .background(RoundedRectangle(cornerRadius: 14).fill(PQTheme.ink))
                    .foregroundColor(.white)
            }
            .disabled(typed.trimmingCharacters(in: .whitespaces).isEmpty)
        }
    }

    private func resolve(_ answer: String) {
        let correct = game.resolveTrivia(question, answer: answer)
        animateRespectingMotion(settings) { result = correct }
    }

    private func resultCard(correct: Bool) -> some View {
        VStack(spacing: 16) {
            Text(correct ? "🌟" : "🧭").font(.system(size: 72))
            Text(correct ? "Upgraded! Your stamp shines brighter." : "Good try! Your stamp keeps its rating.")
                .font(.title3.weight(.bold))
                .multilineTextAlignment(.center)
                .foregroundColor(correct ? PQTheme.positive : PQTheme.ink)
            if !correct {
                Text("The answer was \(question.correctAnswer).")
                    .font(.subheadline).foregroundColor(.secondary)
            }
            Button { dismiss() } label: {
                Text("Continue")
                    .font(.headline)
                    .frame(maxWidth: .infinity, minHeight: PQTheme.minTap)
                    .background(RoundedRectangle(cornerRadius: 14).fill(PQTheme.ink))
                    .foregroundColor(.white)
            }
        }
        .padding(20)
        .frame(maxWidth: .infinity)
        .background(RoundedRectangle(cornerRadius: 20).fill(PQTheme.paperDeep))
    }
}
