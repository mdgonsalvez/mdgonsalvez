//
//  ContentView.swift
//  PassportQuest
//
//  App root. Shows the non-skippable DifficultySelectionView on first launch
//  (spec rule #12); thereafter presents the main tab bar:
//  Passport | Play | Daily | Settings.
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject private var settings: GameSettings
    @EnvironmentObject private var store: PlayerProgressStore

    @State private var selectedTab = 1   // open on Play

    var body: some View {
        Group {
            if settings.hasCompletedFirstLaunch {
                mainTabs
            } else if !settings.hasSeenIntro {
                // First launch: teach the game before asking for a difficulty.
                OnboardingView(isFirstRun: true, onFinish: {
                    animateRespectingMotion(settings) { settings.hasSeenIntro = true }
                })
                .transition(.opacity)
            } else {
                DifficultySelectionView(isFirstLaunch: true, onConfirm: { mode in
                    store.grantStartingTokensIfNeeded(for: mode)
                    selectedTab = 1
                })
                .transition(.opacity)
            }
        }
        .tint(PQTheme.ink)
    }

    private var mainTabs: some View {
        TabView(selection: $selectedTab) {
            PassportView(onOpenSettings: { selectedTab = 3 })
                .tabItem { Label("Passport", systemImage: "book.closed.fill") }
                .tag(0)

            GameView(onOpenSettings: { selectedTab = 3 })
                .tabItem { Label("Play", systemImage: "globe.americas.fill") }
                .tag(1)

            DailyChallengeView()
                .tabItem { Label("Daily", systemImage: "calendar") }
                .tag(2)

            SettingsView(onDifficultyChanged: {
                store.grantStartingTokensIfNeeded(for: settings.activeDifficulty)
            })
                .tabItem { Label("Settings", systemImage: "gearshape.fill") }
                .tag(3)
        }
    }
}

#Preview {
    ContentView()
        .environmentObject(GameSettings())
        .environmentObject(PlayerProgressStore())
}
