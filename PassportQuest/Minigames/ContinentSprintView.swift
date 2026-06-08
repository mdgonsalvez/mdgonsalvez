//
//  ContinentSprintView.swift
//  PassportQuest
//
//  A timed lightning round unlocked once a whole section is stamped. It replays
//  10 random countries from that section. Timer duration and clue tier come
//  from DifficultyMode (sprintDuration / sprintClueTier). Finishing awards a
//  "section mastery" badge. This is the ONLY place a countdown appears, and it
//  is clearly framed as an optional bonus (spec accessibility note).
//

import SwiftUI

struct ContinentSprintView: View {
    @EnvironmentObject private var settings: GameSettings
    @EnvironmentObject private var store: PlayerProgressStore
    @Environment(\.dismiss) private var dismiss

    let continent: Continent

    @State private var phase: Phase = .intro
    @State private var queue: [Country] = []
    @State private var index = 0
    @State private var options: [Country] = []
    @State private var typed = ""
    @State private var score = 0
    @State private var timeRemaining: TimeInterval = 0
    @State private var timer: Timer?

    private enum Phase { case intro, playing, finished }
    private var difficulty: DifficultyMode { settings.activeDifficulty }
    private let questionCount = 10

    var body: some View {
        ZStack {
            PQTheme.paper.ignoresSafeArea()
            VStack(spacing: 20) {
                switch phase {
                case .intro:    introCard
                case .playing:  playingContent
                case .finished: finishedCard
                }
            }
            .padding(24)
            .frame(maxWidth: 700)
        }
        .onDisappear { timer?.invalidate() }
    }

    // MARK: Intro

    private var introCard: some View {
        VStack(spacing: 18) {
            Text("⚡️").font(.system(size: 72))
            Text("\(continent.displayName) Sprint")
                .font(.largeTitle.weight(.heavy)).foregroundColor(PQTheme.ink)
            Text("A fun bonus round! Name \(questionCount) countries before the timer runs out. No pressure — it's just for the badge and bragging rights.")
                .font(.body).multilineTextAlignment(.center).foregroundColor(.secondary)
            Label("\(Int(difficulty.sprintDuration)) seconds", systemImage: "timer")
                .font(.headline).foregroundColor(PQTheme.ink)
            Button(action: start) {
                Text("Start Sprint")
                    .font(.headline)
                    .frame(maxWidth: .infinity, minHeight: PQTheme.minTap)
                    .background(RoundedRectangle(cornerRadius: 14).fill(PQTheme.ink))
                    .foregroundColor(.white)
            }
            Button("Maybe later") { dismiss() }
                .foregroundColor(.secondary)
                .frame(minHeight: PQTheme.minTap)
        }
    }

    // MARK: Playing

    @ViewBuilder
    private var playingContent: some View {
        if index < queue.count {
            let country = queue[index]
            VStack(spacing: 18) {
                HStack {
                    Label("\(Int(ceil(timeRemaining)))s", systemImage: "timer")
                        .font(.title3.weight(.bold).monospacedDigit())
                        .foregroundColor(timeRemaining < 10 ? .red : PQTheme.ink)
                    Spacer()
                    Text("\(index + 1) / \(questionCount)")
                        .font(.headline.monospacedDigit()).foregroundColor(.secondary)
                    Spacer()
                    Label("\(score)", systemImage: "star.fill").foregroundColor(PQTheme.goldDeep)
                }
                ProgressView(value: max(0, timeRemaining), total: difficulty.sprintDuration)
                    .tint(timeRemaining < 10 ? .red : PQTheme.positive)

                clueStage(country)
                    .frame(height: 200)
                    .frame(maxWidth: .infinity)
                    .background(RoundedRectangle(cornerRadius: 20).fill(PQTheme.paperDeep))

                if difficulty.supportsMultipleChoice {
                    sprintOptions(country)
                } else {
                    sprintTypeField(country)
                }
            }
        }
    }

    @ViewBuilder
    private func clueStage(_ country: Country) -> some View {
        switch difficulty.sprintClueTier {
        case .silhouette:
            SilhouetteView(country: country).padding(16)
        case .flag:
            Text(country.emojiFlag).font(.system(size: 120))
        case .fact:
            Text(country.fact(seed: index)).font(.title3).padding().multilineTextAlignment(.center)
        case .photo:
            Text(country.landmarkName).font(.title2.weight(.bold)).padding()
        }
    }

    private func sprintOptions(_ country: Country) -> some View {
        VStack(spacing: 10) {
            ForEach(options) { option in
                Button { answer(option.name, country: country) } label: {
                    Text(option.name)
                        .font(.title3.weight(.semibold)).foregroundColor(PQTheme.ink)
                        .frame(maxWidth: .infinity, minHeight: PQTheme.minTap + 4)
                        .background(RoundedRectangle(cornerRadius: 14).fill(PQTheme.paper))
                        .overlay(RoundedRectangle(cornerRadius: 14).stroke(PQTheme.ink.opacity(0.18), lineWidth: 1))
                }
                .accessibilityLabel("Guess \(option.name)")
            }
        }
    }

    private func sprintTypeField(_ country: Country) -> some View {
        HStack {
            TextField("Type the country…", text: $typed)
                .autocorrectionDisabled()
                .textInputAutocapitalization(.words)
                .font(.title3)
                .onSubmit { answer(typed, country: country) }
            Button { answer(typed, country: country) } label: {
                Image(systemName: "arrow.right.circle.fill").font(.title)
            }
            .disabled(typed.trimmingCharacters(in: .whitespaces).isEmpty)
        }
        .padding(.horizontal, 16)
        .frame(minHeight: PQTheme.minTap + 6)
        .background(RoundedRectangle(cornerRadius: 14).fill(PQTheme.paperDeep))
        .overlay(RoundedRectangle(cornerRadius: 14).stroke(PQTheme.ink.opacity(0.2), lineWidth: 1))
    }

    // MARK: Finished

    private var finishedCard: some View {
        VStack(spacing: 18) {
            Text(score >= questionCount / 2 ? "🏅" : "🧭").font(.system(size: 72))
            Text("Sprint complete!")
                .font(.largeTitle.weight(.heavy)).foregroundColor(PQTheme.ink)
            Text("You named \(score) out of \(questionCount) countries.")
                .font(.title3).foregroundColor(.secondary)
            if store.progress.masteryBadges.contains(continent) {
                Label("\(continent.displayName) Mastery Badge earned!", systemImage: "rosette")
                    .font(.headline).foregroundColor(PQTheme.goldDeep)
            }
            Button { dismiss() } label: {
                Text("Done")
                    .font(.headline)
                    .frame(maxWidth: .infinity, minHeight: PQTheme.minTap)
                    .background(RoundedRectangle(cornerRadius: 14).fill(PQTheme.ink))
                    .foregroundColor(.white)
            }
        }
    }

    // MARK: Logic

    private func start() {
        let pool = CountryDatabase.countries(in: continent).shuffled()
        queue = Array(pool.prefix(questionCount))
        // If a section has fewer than 10 countries, loop to fill.
        while queue.count < questionCount && !pool.isEmpty {
            queue.append(contentsOf: pool.prefix(questionCount - queue.count))
        }
        index = 0
        score = 0
        timeRemaining = difficulty.sprintDuration
        phase = .playing
        buildOptions()
        startTimer()
    }

    private func startTimer() {
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { _ in
            timeRemaining -= 0.1
            if timeRemaining <= 0 { finish() }
        }
    }

    private func buildOptions() {
        guard difficulty.supportsMultipleChoice, index < queue.count else { options = []; return }
        let country = queue[index]
        var source = CountryDatabase.countries(in: continent)
        source.removeAll { $0.id == country.id }
        let distractors = Array(source.shuffled().prefix(max(0, difficulty.multipleChoiceOptionCount - 1)))
        options = (distractors + [country]).shuffled()
    }

    private func answer(_ guess: String, country: Country) {
        if FuzzyMatcher.matches(input: guess, country: country) {
            score += 1
        }
        typed = ""
        advance()
    }

    private func advance() {
        index += 1
        if index >= queue.count {
            finish()
        } else {
            buildOptions()
        }
    }

    private func finish() {
        timer?.invalidate()
        store.addMasteryBadge(continent)
        animateRespectingMotion(settings) { phase = .finished }
    }
}
