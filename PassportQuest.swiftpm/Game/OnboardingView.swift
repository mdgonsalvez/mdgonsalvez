//
//  OnboardingView.swift
//  PassportQuest
//
//  A short, friendly intro shown once on first launch (before the difficulty
//  picker) and re-openable any time from Settings → "How to Play". Teaches the
//  core loop, the Hint Coins (tokens), and the stamp ratings, so a young player
//  understands the game without an adult. Kid-readable copy, short sentences.
//

import SwiftUI

struct OnboardingView: View {
    @EnvironmentObject private var settings: GameSettings

    /// When true, shows a "Skip" affordance (first-run). When false (opened from
    /// Settings) shows a Close button instead.
    var isFirstRun: Bool = true
    /// Called when the player finishes or skips.
    var onFinish: () -> Void = {}

    @State private var page = 0
    private let lastPage = 3

    var body: some View {
        ZStack {
            LinearGradient(colors: [PQTheme.paper, PQTheme.paperDeep],
                           startPoint: .top, endPoint: .bottom)
                .ignoresSafeArea()

            VStack(spacing: 0) {
                topBar
                TabView(selection: $page) {
                    infoPage(tag: 0,
                             title: "Welcome, Explorer!",
                             body: "A mystery country is hiding on every round. Guess it from its clues and earn a stamp for your passport!") {
                        welcomeArt
                    }
                    pageCard(1, emoji: "🗺️",
                             title: "Read the clues",
                             body: "Each round starts with the country's Mystery Shape. Tap the clue chips — Flag, Fun Fact and Famous Place — to reveal more help.")
                    coinsCard
                    stampsCard
                }
                .tabViewStyle(.page(indexDisplayMode: .always))
                .indexViewStyle(.page(backgroundDisplayMode: .always))
                .tint(PQTheme.sky)   // sky-blue active dot, echoing the app icon

                bottomButton
                    .padding(.horizontal, 24)
                    .padding(.bottom, 20)
            }
            .frame(maxWidth: 620)
            .frame(maxWidth: .infinity)
        }
    }

    // MARK: Bars

    private var topBar: some View {
        HStack {
            Spacer()
            if isFirstRun {
                Button("Skip") { finish() }
                    .font(.headline)
                    .foregroundColor(.secondary)
                    .frame(minHeight: PQTheme.minTap)
            } else {
                Button {
                    finish()
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .font(.title2)
                        .foregroundColor(.secondary)
                        .frame(minWidth: PQTheme.minTap, minHeight: PQTheme.minTap)
                }
                .accessibilityLabel("Close")
            }
        }
        .padding(.horizontal, 16)
        .padding(.top, 8)
    }

    private var bottomButton: some View {
        Button {
            if page < lastPage {
                animateRespectingMotion(settings) { page += 1 }
            } else {
                finish()
            }
        } label: {
            Text(page < lastPage ? "Next" : "Let's go!")
                .font(.title3.weight(.bold))
                .foregroundColor(PQTheme.paper)
                .frame(maxWidth: .infinity, minHeight: PQTheme.minTap + 6)
                .background(RoundedRectangle(cornerRadius: 16).fill(PQTheme.ink))
        }
        .accessibilityHint(page < lastPage ? "Go to the next page" : "Start playing")
    }

    // MARK: Pages

    /// A soft sky-blue circle behind a page's art — carries the icon's bright
    /// sky into the app so the icon→first-screen transition feels connected.
    private func artBubble<Content: View>(@ViewBuilder _ content: () -> Content) -> some View {
        content()
            .frame(width: 172, height: 172)
            .background(Circle().fill(PQTheme.skySoft))
            .overlay(Circle().stroke(PQTheme.sky.opacity(0.35), lineWidth: 2))
    }

    /// The welcome page's hero art: the globe mascot (the app icon) when it
    /// ships, otherwise a suitcase emoji in the asset-free Playgrounds build.
    @ViewBuilder
    private var welcomeArt: some View {
        if assetExists("Mascot") {
            Image("Mascot")
                .resizable()
                .scaledToFit()
                .frame(width: 172, height: 172)
                .clipShape(Circle())
                .overlay(Circle().stroke(PQTheme.sky.opacity(0.35), lineWidth: 2))
                .accessibilityHidden(true)
        } else {
            artBubble { Text("🧳").font(.system(size: 88)) }
        }
    }

    /// Shared layout for a simple title/body intro page with a piece of art.
    private func infoPage<Art: View>(tag: Int, title: String, body: String,
                                     @ViewBuilder art: () -> Art) -> some View {
        VStack(spacing: 20) {
            Spacer(minLength: 0)
            art()
            Text(title)
                .font(.system(size: 30, weight: .heavy, design: .rounded))
                .foregroundColor(PQTheme.ink)
                .multilineTextAlignment(.center)
            Text(body)
                .font(.title3)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .fixedSize(horizontal: false, vertical: true)
            Spacer(minLength: 0)
        }
        .padding(.horizontal, 28)
        .padding(.bottom, 30)
        .tag(tag)
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(title). \(body)")
    }

    private func pageCard(_ tag: Int, emoji: String, title: String, body: String) -> some View {
        infoPage(tag: tag, title: title, body: body) {
            artBubble { Text(emoji).font(.system(size: 88)) }
        }
    }

    private var coinsCard: some View {
        VStack(spacing: 20) {
            Spacer(minLength: 0)
            artBubble {
                Image(systemName: "ticket.fill")
                    .font(.system(size: 72))
                    .foregroundColor(PQTheme.goldDeep)
            }
            Text("Hint Coins")
                .font(.system(size: 30, weight: .heavy, design: .rounded))
                .foregroundColor(PQTheme.ink)
            Text("On the trickier modes, revealing a clue costs a Hint Coin. You earn more coins every time you stamp a country — so explore!\n\nOn Explorer mode, every clue is free.")
                .font(.title3)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .fixedSize(horizontal: false, vertical: true)
            Spacer(minLength: 0)
        }
        .padding(.horizontal, 28)
        .padding(.bottom, 30)
        .tag(2)
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Hint Coins. On trickier modes, revealing a clue costs a Hint Coin. You earn more by stamping countries. On Explorer mode every clue is free.")
    }

    private var stampsCard: some View {
        VStack(spacing: 18) {
            Spacer(minLength: 0)
            artBubble { Text("⭐").font(.system(size: 70)) }
            Text("Earn shiny stamps")
                .font(.system(size: 30, weight: .heavy, design: .rounded))
                .foregroundColor(PQTheme.ink)
            Text("The fewer clues you need, the shinier your stamp!")
                .font(.title3)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .fixedSize(horizontal: false, vertical: true)
            VStack(spacing: 10) {
                legendRow(stars: 3, colour: PQTheme.goldDeep, name: "Gold", detail: "guessed early")
                legendRow(stars: 2, colour: Color(hex: "#9AA3AD"), name: "Silver", detail: "a few clues")
                legendRow(stars: 1, colour: Color(hex: "#B87333"), name: "Bronze", detail: "lots of clues")
            }
            .padding(.top, 4)
            Spacer(minLength: 0)
        }
        .padding(.horizontal, 28)
        .padding(.bottom, 30)
        .tag(3)
    }

    private func legendRow(stars: Int, colour: Color, name: String, detail: String) -> some View {
        HStack(spacing: 12) {
            HStack(spacing: 2) {
                ForEach(0..<3) { i in
                    Image(systemName: "star.fill")
                        .font(.subheadline)
                        .foregroundColor(i < stars ? colour : PQTheme.ink.opacity(0.15))
                }
            }
            .frame(width: 76, alignment: .leading)
            Text(name).font(.headline).foregroundColor(PQTheme.ink)
                .frame(width: 70, alignment: .leading)
            Text(detail).font(.subheadline).foregroundColor(.secondary)
            Spacer(minLength: 0)
        }
        .padding(.horizontal, 16)
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(name) stamp, \(stars) stars, \(detail)")
    }

    private func finish() {
        settings.hasSeenIntro = true
        onFinish()
    }
}
