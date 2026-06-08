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
                             body: "A secret country is hiding in every round. Look at the clues, make your guess, and win a stamp for your passport — here's how!") {
                        welcomeArt
                    }
                    infoPage(tag: 1,
                             title: "1. Look at the clues",
                             body: "First you'll see the country's shape. Tap a clue chip to reveal its flag, a fun fact or a famous place. Clues are free on Explorer mode; on harder modes each one costs a Hint Coin.") {
                        cluesPreview
                    }
                    infoPage(tag: 2,
                             title: "2. Make your guess",
                             body: "Think you know it? Tap the country you think it is — or type its name on the harder modes. Get it right and you stamp it in your passport!") {
                        guessPreview
                    }
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

    // MARK: Step-1 visual — a mini "Mystery Shape" card above the clue chips,
    // mirroring what the player actually sees in a round.
    private var cluesPreview: some View {
        VStack(spacing: 12) {
            ZStack {
                RoundedRectangle(cornerRadius: 18).fill(PQTheme.paperDeep)
                RoundedRectangle(cornerRadius: 18).stroke(PQTheme.ink.opacity(0.15), lineWidth: 1)
                Image(systemName: "map.fill")
                    .font(.system(size: 44))
                    .foregroundColor(PQTheme.ink.opacity(0.6))
            }
            .frame(width: 156, height: 98)

            HStack(spacing: 8) {
                previewChip("flag.fill", "Flag")
                previewChip("lightbulb.fill", "Fact")
                previewChip("photo.fill", "Place")
            }
        }
        .accessibilityHidden(true)
    }

    /// A single locked clue chip, styled like the real ClueView chips.
    private func previewChip(_ symbol: String, _ label: String) -> some View {
        VStack(spacing: 3) {
            Image(systemName: symbol).font(.subheadline)
            Text(label).font(.caption2.weight(.semibold))
        }
        .foregroundColor(PQTheme.ink)
        .frame(width: 58, height: 48)
        .background(RoundedRectangle(cornerRadius: 12).fill(PQTheme.paper))
        .overlay(RoundedRectangle(cornerRadius: 12)
            .strokeBorder(style: StrokeStyle(lineWidth: 1.5, dash: [CGFloat(4), 3]))
            .foregroundColor(PQTheme.ink.opacity(0.4)))
    }

    // MARK: Step-2 visual — mock answer options (the right one highlighted) plus
    // the "type it in" hint, so the child sees how guessing actually works.
    private var guessPreview: some View {
        VStack(spacing: 8) {
            answerPreview("France", picked: true)
            answerPreview("Spain", picked: false)
            HStack(spacing: 6) {
                Image(systemName: "keyboard")
                Text("…or type it in")
            }
            .font(.caption.weight(.medium))
            .foregroundColor(.secondary)
            .padding(.top, 2)
        }
        .frame(maxWidth: 250)
        .accessibilityHidden(true)
    }

    private func answerPreview(_ name: String, picked: Bool) -> some View {
        HStack {
            Text(name).font(.headline)
            Spacer()
            if picked { Image(systemName: "checkmark.circle.fill") }
        }
        .foregroundColor(picked ? .white : PQTheme.ink)
        .padding(.horizontal, 16).padding(.vertical, 11)
        .frame(maxWidth: .infinity)
        .background(RoundedRectangle(cornerRadius: 14).fill(picked ? PQTheme.positive : PQTheme.paper))
        .overlay(RoundedRectangle(cornerRadius: 14)
            .stroke(PQTheme.ink.opacity(picked ? 0 : 0.18), lineWidth: 1))
    }

    private var stampsCard: some View {
        VStack(spacing: 18) {
            Spacer(minLength: 0)
            artBubble { Text("⭐").font(.system(size: 70)) }
            Text("3. Earn shiny stamps")
                .font(.system(size: 30, weight: .heavy, design: .rounded))
                .foregroundColor(PQTheme.ink)
            Text("The fewer clues you use, the shinier your stamp!")
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

#Preview {
    OnboardingView()
        .environmentObject(GameSettings())
}
