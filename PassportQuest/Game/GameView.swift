//
//  GameView.swift
//  PassportQuest
//
//  The assembled "Play" screen: clue area, reveal control, answer input, and
//  result feedback, with the persistent difficulty badge, token balance and
//  streak indicator. Hosts the Hot Streak overlay and Traveller's Trivia sheet.
//  All gameplay rules come from GameViewModel (which reads DifficultyMode).
//

import SwiftUI

struct GameView: View {
    @EnvironmentObject private var settings: GameSettings
    @EnvironmentObject private var store: PlayerProgressStore
    @StateObject private var game = GameViewModel()
    /// Routes the difficulty badge tap to the Settings tab.
    var onOpenSettings: () -> Void = {}

    @State private var configured = false

    var body: some View {
        ZStack {
            PQTheme.paper.ignoresSafeArea()

            // Content is only built once the view model has been wired to the
            // environment (avoids touching the store before `configure`).
            if configured {
                VStack(spacing: 16) {
                    header

                    if game.isJourneyComplete && game.currentCountry == nil {
                        journeyCompleteCard
                    } else if let country = game.currentCountry {
                        roundContent(country: country)
                    } else {
                        sectionCompleteCard
                    }
                }
                .padding(20)
                .frame(maxWidth: 700)

                if game.showHotStreak {
                    HotStreakOverlay(inkColour: settings.inkColour.color)
                        .ignoresSafeArea()
                        .transition(.opacity)
                }
            } else {
                ProgressView()
            }
        }
        .onAppear {
            if !configured {
                game.configure(settings: settings, store: store)
                game.startSession()
                configured = true
            }
        }
        .sheet(item: $game.pendingTrivia) { question in
            TravellersTriviaView(game: game, question: question)
                .environmentObject(settings)
        }
    }

    // MARK: Header

    private var header: some View {
        HStack {
            TokenBadgeView(tokens: game.tokenBalance,
                           unlimited: settings.activeDifficulty.hintTokenCost == 0)
            StreakIndicatorView(streak: game.currentStreak)
            Spacer()
            DifficultyBadgeView(onTap: onOpenSettings)
        }
    }

    // MARK: Round content

    @ViewBuilder
    private func roundContent(country: Country) -> some View {
        ScrollView {
            VStack(spacing: 18) {
                ClueView(country: country,
                         activeTier: game.activeTier,
                         availableTiers: game.availableTiers,
                         revealedTiers: game.revealedTiers,
                         factSeed: country.id.hashValue,
                         revealCost: game.revealCost,
                         canAffordReveal: game.canAffordReveal,
                         onTapTier: { tier in
                             animateRespectingMotion(settings) { _ = game.tapTier(tier) }
                         })

                // One-time tip the first time clues cost Hint Coins (Medium/Hard).
                if settings.activeDifficulty.hintTokenCost > 0 && !settings.hasSeenClueTip {
                    clueCoinTip
                }

                if let nudge = game.wrongNudge {
                    Label(nudge, systemImage: "sparkles")
                        .font(.subheadline.weight(.semibold))
                        .foregroundColor(PQTheme.ink)
                        .padding(.horizontal, 16).padding(.vertical, 10)
                        .frame(maxWidth: .infinity)
                        .background(RoundedRectangle(cornerRadius: 12).fill(PQTheme.gold.opacity(0.18)))
                        .transition(.opacity)
                        .accessibilityLabel(nudge)
                }

                switch game.phase {
                case .guessing, .wrong:
                    AnswerInputView(game: game)
                case .correct, .revealedAnswer:
                    ResultView(country: country,
                               phase: game.phase,
                               tokenAward: game.lastTokenAward,
                               earnedOnHard: store.progress.wasEarnedOnHard(country.id),
                               onNext: { advance() })
                    .environmentObject(settings)
                }
            }
            .padding(.bottom, 24)
        }
    }

    private func advance() {
        animateRespectingMotion(settings) { game.loadNextCountry() }
    }

    /// First-time explainer for the Hint Coin cost of revealing clues.
    private var clueCoinTip: some View {
        HStack(alignment: .top, spacing: 10) {
            Image(systemName: "ticket.fill").foregroundColor(PQTheme.goldDeep)
            VStack(alignment: .leading, spacing: 4) {
                Text("Tap a clue to reveal it")
                    .font(.subheadline.weight(.bold)).foregroundColor(PQTheme.ink)
                Text("On this mode each reveal costs a Hint Coin. Earn more by stamping countries — and on Explorer mode clues are free!")
                    .font(.caption).foregroundColor(PQTheme.inkSoft)
                    .fixedSize(horizontal: false, vertical: true)
            }
            Spacer(minLength: 0)
            Button {
                animateRespectingMotion(settings) { settings.hasSeenClueTip = true }
            } label: {
                Text("Got it!")
                    .font(.caption.weight(.bold))
                    .foregroundColor(PQTheme.paper)
                    .padding(.horizontal, 14)
                    .frame(minHeight: 44)
                    .background(Capsule().fill(PQTheme.ink))
            }
        }
        .padding(14)
        .background(RoundedRectangle(cornerRadius: 14).fill(PQTheme.gold.opacity(0.16)))
        .overlay(RoundedRectangle(cornerRadius: 14).stroke(PQTheme.goldDeep.opacity(0.4), lineWidth: 1))
        .transition(.opacity)
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Tip: tap a clue to reveal it. On this mode each reveal costs a Hint Coin. Earn more by stamping countries.")
    }

    // MARK: Completion cards

    private var sectionCompleteCard: some View {
        VStack(spacing: 16) {
            Spacer()
            Text("🎉").font(.system(size: 72))
            Text("Section complete!")
                .font(.title.weight(.bold)).foregroundColor(PQTheme.ink)
            Text("You've stamped every country here. A new part of the world is unlocked on your passport!")
                .multilineTextAlignment(.center)
                .foregroundColor(PQTheme.inkSoft)
                .padding(.horizontal)
            Button { advance() } label: {
                Text("Continue the Journey")
                    .font(.headline)
                    .frame(maxWidth: .infinity, minHeight: PQTheme.minTap)
                    .background(RoundedRectangle(cornerRadius: 14).fill(PQTheme.ink))
                    .foregroundColor(.white)
            }
            Spacer()
        }
        .padding()
    }

    private var journeyCompleteCard: some View {
        VStack(spacing: 16) {
            Spacer()
            Text("🌍").font(.system(size: 80))
            Text("World Traveller!")
                .font(.largeTitle.weight(.heavy)).foregroundColor(PQTheme.ink)
            Text("You've stamped every country in your passport. What an explorer! Try a harder difficulty for a brand-new challenge.")
                .multilineTextAlignment(.center)
                .foregroundColor(PQTheme.inkSoft)
                .padding(.horizontal)
            Button(action: onOpenSettings) {
                Text("Open Settings")
                    .font(.headline)
                    .frame(maxWidth: .infinity, minHeight: PQTheme.minTap)
                    .background(RoundedRectangle(cornerRadius: 14).fill(PQTheme.ink))
                    .foregroundColor(.white)
            }
            Spacer()
        }
        .padding()
    }
}
