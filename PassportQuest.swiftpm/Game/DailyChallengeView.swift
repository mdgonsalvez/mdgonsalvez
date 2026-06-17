//
//  DailyChallengeView.swift
//  PassportQuest
//
//  The daily featured-country flow. The country is chosen by a deterministic
//  seed derived from the local calendar date (spec rule #9), so the same
//  country appears all day on every device without a server. A correct answer
//  awards a special "gold wax seal" stamp variant and bonus tokens.
//

import SwiftUI

// MARK: - Daily seed

enum DailyChallenge {
    /// A stable yyyy-MM-dd key for "today" in the device's local timezone.
    static func dayKey(for date: Date = Date(), calendar: Calendar = .current) -> String {
        let c = calendar.dateComponents([.year, .month, .day], from: date)
        return String(format: "%04d-%02d-%02d", c.year ?? 0, c.month ?? 0, c.day ?? 0)
    }

    /// Deterministically maps the day key to one country from the database.
    static func country(for date: Date = Date(), calendar: Calendar = .current) -> Country {
        let key = dayKey(for: date, calendar: calendar)
        // Simple stable string hash (FNV-1a) so it's identical across devices.
        var hash: UInt64 = 1469598103934665603
        for byte in key.utf8 {
            hash ^= UInt64(byte)
            hash = hash &* 1099511628211
        }
        let index = Int(hash % UInt64(CountryDatabase.all.count))
        return CountryDatabase.all[index]
    }
}

// MARK: - View

struct DailyChallengeView: View {
    @EnvironmentObject private var settings: GameSettings
    @EnvironmentObject private var store: PlayerProgressStore

    @State private var revealedTiers: [ClueTier] = []
    @State private var activeTier: ClueTier = .silhouette
    @State private var choiceOptions: [Country] = []
    @State private var typed: String = ""
    @State private var solved = false
    @State private var wrongShake = false
    @State private var tokenAward = 0
    @State private var encouragement: String?

    private var difficulty: DifficultyMode { settings.activeDifficulty }
    private var country: Country { DailyChallenge.country() }
    private var dayKey: String { DailyChallenge.dayKey() }
    private var alreadyDone: Bool { store.isDailyCompleted(dayKey: dayKey) }

    var body: some View {
        ZStack {
            PQTheme.paper.ignoresSafeArea()
            ScrollView {
                VStack(spacing: 20) {
                    titleBlock

                    if alreadyDone || solved {
                        completedCard
                    } else {
                        ClueView(country: country,
                                 activeTier: activeTier,
                                 availableTiers: difficulty.mysteryAvailableClues,
                                 revealedTiers: revealedTiers,
                                 factSeed: dayKey.hashValue,
                                 revealCost: difficulty.hintTokenCost,
                                 canAffordReveal: difficulty.hintTokenCost == 0
                                     || store.progress.hintTokens >= difficulty.hintTokenCost,
                                 onTapTier: { tier in dailyTapTier(tier) })
                        answerArea
                        if let encouragement {
                            Text(encouragement)
                                .font(.subheadline.weight(.medium))
                                .foregroundColor(PQTheme.inkSoft)
                                .multilineTextAlignment(.center)
                        }
                    }
                }
                .padding(20)
                .frame(maxWidth: 700)
            }
        }
        .onAppear(perform: setup)
    }

    // MARK: Setup

    private func setup() {
        guard revealedTiers.isEmpty else { return }
        let start = difficulty.startingClueTier
        revealedTiers = difficulty.mysteryAvailableClues.filter { $0 <= start }
        if revealedTiers.isEmpty { revealedTiers = [difficulty.mysteryAvailableClues.first ?? .silhouette] }
        activeTier = revealedTiers.max() ?? start
        rebuildOptions()
    }

    private func rebuildOptions() {
        guard difficulty.supportsMultipleChoice else { choiceOptions = []; return }
        let count = difficulty.multipleChoiceOptionCount
        var source = difficulty.multipleChoiceSameContinent
            ? CountryDatabase.countries(in: country.continent)
            : CountryDatabase.all
        source.removeAll { $0.id == country.id }
        let distractors = Array(source.shuffled().prefix(max(0, count - 1)))
        choiceOptions = (distractors + [country]).shuffled()
    }

    // MARK: Header

    private var titleBlock: some View {
        VStack(spacing: 8) {
            Text("📅 Daily Challenge")
                .font(.largeTitle.weight(.heavy))
                .foregroundColor(PQTheme.ink)
            Text("A special mystery country, every single day!")
                .font(.subheadline)
                .foregroundColor(PQTheme.inkSoft)
                .multilineTextAlignment(.center)
        }
    }

    // MARK: Reveal

    /// Tap a clue chip: reveal a locked tier (spending tokens) or switch to a
    /// revealed one.
    private func dailyTapTier(_ tier: ClueTier) {
        if revealedTiers.contains(tier) { activeTier = tier; return }
        guard difficulty.allowsManualReveal else { return }
        guard store.spendTokens(difficulty.hintTokenCost) else { return }
        animateRespectingMotion(settings) { reveal(tier) }
    }

    private var nextRevealable: ClueTier? {
        difficulty.mysteryAvailableClues.filter { !revealedTiers.contains($0) }.min()
    }

    private func reveal(_ tier: ClueTier) {
        if !revealedTiers.contains(tier) { revealedTiers.append(tier); revealedTiers.sort() }
        activeTier = tier
    }

    // MARK: Answer

    @ViewBuilder
    private var answerArea: some View {
        if difficulty.forcesTypeInput || (!difficulty.supportsMultipleChoice) {
            typeArea
        } else {
            VStack(spacing: 12) {
                ForEach(choiceOptions) { option in
                    Button { check(option.name) } label: {
                        Text(option.name)
                            .font(.title3.weight(.semibold))
                            .foregroundColor(PQTheme.ink)
                            .frame(maxWidth: .infinity, minHeight: PQTheme.minTap + 8)
                            .background(RoundedRectangle(cornerRadius: 16).fill(PQTheme.paperDeep))
                            .overlay(RoundedRectangle(cornerRadius: 16).stroke(PQTheme.ink.opacity(0.18), lineWidth: 1))
                    }
                    .accessibilityLabel("Guess \(option.name)")
                }
            }
            .modifier(ShakeEffect(animatableData: wrongShake ? 1 : 0))
        }
    }

    private var typeArea: some View {
        VStack(spacing: 10) {
            TextField("Type the country name…", text: $typed)
                .autocorrectionDisabled()
                .textInputAutocapitalization(.words)
                .font(.title3)
                .padding(.horizontal, 16)
                .frame(minHeight: PQTheme.minTap + 8)
                .background(RoundedRectangle(cornerRadius: 16).fill(PQTheme.paperDeep))
                .overlay(RoundedRectangle(cornerRadius: 16).stroke(PQTheme.ink.opacity(0.2), lineWidth: 1))
                .onSubmit { check(typed) }
            Button { check(typed) } label: {
                Text("Guess")
                    .font(.headline)
                    .frame(maxWidth: .infinity, minHeight: PQTheme.minTap)
                    .background(RoundedRectangle(cornerRadius: 14).fill(PQTheme.ink))
                    .foregroundColor(.white)
            }
            .disabled(typed.trimmingCharacters(in: .whitespaces).isEmpty)
        }
        .modifier(ShakeEffect(animatableData: wrongShake ? 1 : 0))
    }

    private func check(_ guess: String) {
        if FuzzyMatcher.matches(input: guess, country: country) {
            award()
        } else {
            encouragement = "Not quite — try another clue or guess!"
            if let next = nextRevealable { reveal(next) }
            if !motionIsReduced(settings) {
                withAnimation(.default) { wrongShake.toggle() }
            }
        }
    }

    private func award() {
        // Capture the streak status BEFORE touching the play date (which would
        // otherwise always read "active").
        let streakActive = store.dailyStreakActive()
        store.touchPlayDate()
        // Daily always grants a Gold "wax seal" stamp.
        store.recordStamp(countryID: country.id, rating: .gold, mode: difficulty)
        store.markDailyCompleted(dayKey: dayKey)
        // Daily bonus uses the per-continent earn rate as a generous reward.
        tokenAward = store.awardTokens(difficulty.tokenPerContinent, mode: difficulty, streakActive: streakActive)
        animateRespectingMotion(settings) { solved = true }
    }

    // MARK: Completed

    private var completedCard: some View {
        VStack(spacing: 18) {
            waxSeal
            Text(solved ? "Daily stamp earned!" : "Today's daily is done!")
                .font(.title2.weight(.bold))
                .foregroundColor(PQTheme.positive)
            Text("\(country.emojiFlag) \(country.name)")
                .font(.title3.weight(.semibold))
                .foregroundColor(PQTheme.ink)
            if solved && tokenAward > 0 {
                Label("+\(tokenAward) bonus Hint \(tokenAward == 1 ? "Coin" : "Coins")", systemImage: "ticket.fill")
                    .font(.headline).foregroundColor(PQTheme.ink)
            }
            Text("Come back tomorrow for a brand-new country!")
                .font(.subheadline).foregroundColor(PQTheme.inkSoft)
                .multilineTextAlignment(.center)
        }
        .padding(24)
        .frame(maxWidth: .infinity)
        .background(RoundedRectangle(cornerRadius: 24).fill(PQTheme.paperDeep))
        // Confetti falls across the whole card when the daily is solved.
        .overlay {
            if solved && !motionIsReduced(settings) {
                ConfettiView(duration: 2.0)
                    .allowsHitTesting(false)
            }
        }
        .clipShape(RoundedRectangle(cornerRadius: 24))
    }

    /// The special gold wax seal variant.
    private var waxSeal: some View {
        ZStack {
            Circle().fill(PQTheme.gold).frame(width: 150, height: 150)
            Circle().stroke(Color(hex: "#B8860B"), lineWidth: 5).frame(width: 130, height: 130)
            VStack(spacing: 2) {
                Text(country.emojiFlag).font(.system(size: 44))
                Image(systemName: "rosette").font(.title2).foregroundColor(Color(hex: "#7a5c00"))
            }
        }
        .rotationEffect(.degrees(-6))
        .accessibilityLabel("Gold wax seal for \(country.name)")
    }
}

/// A small horizontal shake used for wrong answers.
struct ShakeEffect: GeometryEffect {
    var animatableData: CGFloat
    func effectValue(size: CGSize) -> ProjectionTransform {
        let translation = 8 * sin(animatableData * .pi * 4)
        return ProjectionTransform(CGAffineTransform(translationX: translation, y: 0))
    }
}
