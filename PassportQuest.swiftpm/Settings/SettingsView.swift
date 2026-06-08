//
//  SettingsView.swift
//  PassportQuest
//
//  Player-facing settings: change difficulty (with a confirmation alert that
//  warns it affects future rounds only — never earned stamps or tokens, per
//  spec rules #12/#13), preferred input mode (where the difficulty allows a
//  choice), ink colour, a Reduce Motion override, and a guarded progress reset.
//

import SwiftUI

struct SettingsView: View {
    @EnvironmentObject private var settings: GameSettings
    @EnvironmentObject private var store: PlayerProgressStore

    @State private var showDifficultySheet = false
    @State private var pendingDifficulty: DifficultyMode?
    @State private var showResetConfirm = false

    /// Notifies the host that difficulty changed (so the game can top up tokens).
    var onDifficultyChanged: () -> Void = {}

    var body: some View {
        NavigationStack {
            Form {
                difficultySection
                inputSection
                inkSection
                accessibilitySection
                progressSection
                aboutSection
            }
            .navigationTitle("Settings")
            .background(PQTheme.paper.ignoresSafeArea())
        }
        // Difficulty picker presented full-screen.
        .sheet(isPresented: $showDifficultySheet) {
            DifficultySelectionView(isFirstLaunch: false, onConfirm: { mode in
                showDifficultySheet = false
                onDifficultyChanged()
            })
            .environmentObject(settings)
        }
        // Confirmation before applying an inline difficulty change.
        .alert("Change difficulty?", isPresented: Binding(
            get: { pendingDifficulty != nil },
            set: { if !$0 { pendingDifficulty = nil } }
        )) {
            Button("Cancel", role: .cancel) { pendingDifficulty = nil }
            Button("Change") {
                if let mode = pendingDifficulty {
                    settings.activeDifficulty = mode
                    onDifficultyChanged()
                }
                pendingDifficulty = nil
            }
        } message: {
            Text("This only changes how future rounds work. Every stamp you've already earned and all your hint tokens stay exactly as they are.")
        }
        // Guarded reset.
        .alert("Reset all progress?", isPresented: $showResetConfirm) {
            Button("Cancel", role: .cancel) {}
            Button("Reset Everything", role: .destructive) {
                store.resetAll()
                settings.hasCompletedFirstLaunch = false
            }
        } message: {
            Text("This permanently erases every stamp, badge and hint token, and starts your passport over. This can't be undone.")
        }
    }

    // MARK: Difficulty

    private var difficultySection: some View {
        Section {
            HStack {
                Text(settings.activeDifficulty.icon).font(.title)
                VStack(alignment: .leading) {
                    Text(settings.activeDifficulty.personaName).font(.headline)
                    Text(settings.activeDifficulty.tagline)
                        .font(.caption).foregroundColor(.secondary)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
            // Quick inline switches (each confirms via alert).
            ForEach(DifficultyMode.allCases) { mode in
                if mode != settings.activeDifficulty {
                    Button {
                        pendingDifficulty = mode
                    } label: {
                        Label("Switch to \(mode.icon) \(mode.personaName)", systemImage: "arrow.left.arrow.right")
                    }
                    .frame(minHeight: PQTheme.minTap)
                }
            }
            Button {
                showDifficultySheet = true
            } label: {
                Label("Open full difficulty chooser", systemImage: "square.grid.3x1.below.line.grid.1x2")
            }
            .frame(minHeight: PQTheme.minTap)
        } header: {
            Text("Difficulty")
        } footer: {
            Text("Changing difficulty only affects future rounds. Your stamps and tokens are never reset.")
        }
    }

    // MARK: Input

    private var inputSection: some View {
        Section {
            if settings.activeDifficulty.supportsMultipleChoice {
                Picker("Answer style", selection: $settings.preferredInput) {
                    ForEach(PreferredInputMode.allCases) { mode in
                        Text(mode.displayName).tag(mode)
                    }
                }
                .pickerStyle(.segmented)
                if settings.preferredInput == .typeItIn {
                    let unlocked = store.progress.totalCorrect >= settings.activeDifficulty.typeInputUnlockThreshold
                    Text(unlocked
                         ? "Type It In is unlocked — nice work!"
                         : "Type It In unlocks after \(settings.activeDifficulty.typeInputUnlockThreshold) correct answers (you have \(store.progress.totalCorrect)). Until then, you'll use Multiple Choice.")
                        .font(.caption).foregroundColor(.secondary)
                }
            } else {
                Label("This mode always uses Type It In.", systemImage: "keyboard")
                    .foregroundColor(.secondary)
            }
        } header: {
            Text("Answering")
        }
    }

    // MARK: Ink colour

    private var inkSection: some View {
        Section {
            LazyVGrid(columns: [GridItem(.adaptive(minimum: 60), spacing: 12)], spacing: 12) {
                ForEach(InkColour.allCases) { ink in
                    Button {
                        settings.inkColour = ink
                    } label: {
                        VStack(spacing: 6) {
                            Circle()
                                .fill(ink.color)
                                .frame(width: 44, height: 44)
                                .overlay(
                                    Circle().stroke(PQTheme.ink,
                                                    lineWidth: settings.inkColour == ink ? 3 : 0)
                                )
                            if settings.inkColour == ink {
                                Image(systemName: "checkmark").font(.caption.bold())
                            }
                        }
                    }
                    .frame(minHeight: PQTheme.minTap)
                    .accessibilityLabel("\(ink.displayName) ink\(settings.inkColour == ink ? ", selected" : "")")
                }
            }
            .padding(.vertical, 4)
        } header: {
            Text("Passport Ink Colour")
        } footer: {
            Text("Your stamps and world map fill in with this colour.")
        }
    }

    // MARK: Accessibility

    private var accessibilitySection: some View {
        Section {
            Toggle("Reduce animations", isOn: $settings.prefersReducedMotion)
                .frame(minHeight: PQTheme.minTap)
        } header: {
            Text("Accessibility")
        } footer: {
            Text("Confetti and splatter effects become calm and still. The system's Reduce Motion setting also turns these off.")
        }
    }

    // MARK: Progress

    private var progressSection: some View {
        Section {
            LabeledContent("Stamps earned", value: "\(store.progress.stampedCount) / \(CountryDatabase.all.count)")
            LabeledContent("Hint tokens", value: "\(store.progress.hintTokens)")
            LabeledContent("Best section badges", value: "\(store.progress.masteryBadges.count)")
            Button(role: .destructive) {
                showResetConfirm = true
            } label: {
                Label("Reset all progress", systemImage: "trash")
            }
            .frame(minHeight: PQTheme.minTap)
        } header: {
            Text("Progress")
        }
    }

    // MARK: About

    private var aboutSection: some View {
        Section {
            LabeledContent("Countries", value: "\(CountryDatabase.all.count)")
            Text("Passport Quest is made just for explorers — no ads, no links, no sign-ups. Have fun discovering the world! 🌍")
                .font(.footnote).foregroundColor(.secondary)
        } header: {
            Text("About")
        }
    }
}
