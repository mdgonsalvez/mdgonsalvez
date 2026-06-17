//
//  AnswerInputView.swift
//  PassportQuest
//
//  The answer area. Renders multiple choice or Type It In depending on the
//  active input mode (which the view model derives from DifficultyMode + the
//  player's preference + the 10-correct unlock). Includes a capped autocomplete
//  dropdown for typing (spec: max 5 suggestions).
//

import SwiftUI

struct AnswerInputView: View {
    @ObservedObject var game: GameViewModel
    @FocusState private var typingFocused: Bool
    @State private var typed: String = ""

    var body: some View {
        Group {
            switch game.effectiveInputMode {
            case .multipleChoice: multipleChoice
            case .typeItIn:       typeItIn
            }
        }
    }

    // MARK: Multiple choice

    private var multipleChoice: some View {
        VStack(spacing: 12) {
            ForEach(game.choiceOptions) { option in
                Button {
                    game.submitChoice(option)
                } label: {
                    HStack {
                        Text(option.name)
                            .font(.title3.weight(.semibold))
                            .foregroundColor(PQTheme.ink)
                        Spacer()
                        if game.selectedChoiceID == option.id {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundColor(PQTheme.positive)
                        }
                    }
                    .padding(.horizontal, 20)
                    .frame(maxWidth: .infinity, minHeight: PQTheme.minTap + 8, alignment: .leading)
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(PQTheme.paperDeep)
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(PQTheme.ink.opacity(0.18), lineWidth: 1)
                    )
                }
                .accessibilityLabel("Guess \(option.name)")
            }
        }
    }

    // MARK: Type it in

    private var typeItIn: some View {
        VStack(spacing: 10) {
            HStack {
                Image(systemName: "magnifyingglass").foregroundColor(PQTheme.inkSoft)
                TextField("Type the country name…", text: $typed)
                    .focused($typingFocused)
                    .autocorrectionDisabled()
                    .textInputAutocapitalization(.words)
                    .font(.title3)
                    .submitLabel(.done)
                    .onSubmit(submitTyped)
                if !typed.isEmpty {
                    Button { typed = "" } label: {
                        Image(systemName: "xmark.circle.fill").foregroundColor(PQTheme.inkSoft)
                    }
                    .accessibilityLabel("Clear text")
                }
            }
            .padding(.horizontal, 16)
            .frame(minHeight: PQTheme.minTap + 8)
            .background(RoundedRectangle(cornerRadius: 16).fill(PQTheme.paperDeep))
            .overlay(RoundedRectangle(cornerRadius: 16).stroke(PQTheme.ink.opacity(0.2), lineWidth: 1))

            // Autocomplete dropdown (capped at 5).
            let suggestions = game.suggestions(for: typed)
            if !suggestions.isEmpty && typingFocused {
                VStack(spacing: 0) {
                    ForEach(suggestions) { country in
                        Button {
                            typed = country.name
                            submitTyped()
                        } label: {
                            HStack {
                                Text(country.emojiFlag)
                                Text(country.name).foregroundColor(PQTheme.ink)
                                Spacer()
                            }
                            .padding(.horizontal, 16)
                            .frame(maxWidth: .infinity, minHeight: PQTheme.minTap, alignment: .leading)
                        }
                        .accessibilityLabel("Suggestion: \(country.name)")
                        Divider()
                    }
                }
                .background(RoundedRectangle(cornerRadius: 12).fill(PQTheme.paper))
                .overlay(RoundedRectangle(cornerRadius: 12).stroke(PQTheme.ink.opacity(0.15), lineWidth: 1))
            }

            Button(action: submitTyped) {
                Text("Guess")
                    .font(.headline)
                    .frame(maxWidth: .infinity, minHeight: PQTheme.minTap)
                    .background(RoundedRectangle(cornerRadius: 14).fill(PQTheme.ink))
                    .foregroundColor(.white)
            }
            .disabled(typed.trimmingCharacters(in: .whitespaces).isEmpty)
            .opacity(typed.trimmingCharacters(in: .whitespaces).isEmpty ? 0.5 : 1)
            .accessibilityLabel("Submit your guess")
        }
        .onChange(of: game.currentCountry?.id) { _ in
            typed = "" // clear the field when a new country loads
        }
    }

    private func submitTyped() {
        let answer = typed
        guard !answer.trimmingCharacters(in: .whitespaces).isEmpty else { return }
        game.submitTypedAnswer(answer)
    }
}
