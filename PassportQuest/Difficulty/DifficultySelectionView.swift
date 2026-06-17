//
//  DifficultySelectionView.swift
//  PassportQuest
//
//  The full-screen difficulty picker. Shown (non-skippable) on first launch
//  before any gameplay, and reachable later from Settings. Three large cards,
//  one per mode, with clear visual hierarchy. Hard is framed aspirationally,
//  never intimidatingly (spec accessibility note).
//

import SwiftUI

struct DifficultySelectionView: View {
    @EnvironmentObject private var settings: GameSettings
    /// True when shown as the first-launch gate (vs. opened from Settings).
    var isFirstLaunch: Bool
    /// Called after the player confirms a choice.
    var onConfirm: (DifficultyMode) -> Void = { _ in }

    @State private var highlighted: DifficultyMode?

    var body: some View {
        ZStack {
            LinearGradient(colors: [PQTheme.paper, PQTheme.paperDeep],
                           startPoint: .top, endPoint: .bottom)
                .ignoresSafeArea()

            ScrollView {
                VStack(spacing: 24) {
                    header
                    ForEach(DifficultyMode.allCases) { mode in
                        card(mode)
                    }
                    Text("You can change this any time in Settings. Switching never removes stamps you've already earned.")
                        .font(.footnote)
                        .foregroundColor(PQTheme.inkSoft)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                        .padding(.top, 4)
                }
                .padding(24)
                .frame(maxWidth: 640)
                .frame(maxWidth: .infinity)
            }
        }
    }

    private var header: some View {
        VStack(spacing: 10) {
            Text("🧳").font(.system(size: 64))
            Text("Passport Quest")
                .font(.system(size: 40, weight: .heavy, design: .rounded))
                .foregroundColor(PQTheme.ink)
            Text(isFirstLaunch ? "Choose how you'd like to explore the world!"
                               : "Pick a new way to explore!")
                .font(.title3)
                .foregroundColor(PQTheme.inkSoft)
                .multilineTextAlignment(.center)
        }
        .padding(.top, 12)
    }

    private func card(_ mode: DifficultyMode) -> some View {
        let isCurrent = settings.activeDifficulty == mode && !isFirstLaunch
        return Button {
            select(mode)
        } label: {
            HStack(spacing: 18) {
                Text(mode.icon).font(.system(size: 52))
                VStack(alignment: .leading, spacing: 6) {
                    HStack(spacing: 8) {
                        Text(mode.personaNameWithLevel)
                            .font(.title2.weight(.heavy))
                            .foregroundColor(PQTheme.ink)
                        if isCurrent {
                            Text("Current")
                                .font(.caption.weight(.bold))
                                .padding(.horizontal, 8).padding(.vertical, 3)
                                .background(Capsule().fill(PQTheme.positive.opacity(0.2)))
                                .foregroundColor(PQTheme.positive)
                        }
                    }
                    Text(mode.tagline)
                        .font(.subheadline)
                        .foregroundColor(PQTheme.inkSoft)
                        .fixedSize(horizontal: false, vertical: true)
                }
                Spacer(minLength: 0)
                Image(systemName: "chevron.right.circle.fill")
                    .font(.title)
                    .foregroundColor(PQTheme.ink.opacity(0.5))
            }
            .padding(20)
            .frame(maxWidth: .infinity, minHeight: 110, alignment: .leading)
            .background(RoundedRectangle(cornerRadius: 22).fill(PQTheme.paper))
            .overlay(
                RoundedRectangle(cornerRadius: 22)
                    .stroke(highlighted == mode ? PQTheme.ink : PQTheme.ink.opacity(0.15),
                            lineWidth: highlighted == mode ? 3 : 1)
            )
            .shadow(color: PQTheme.ink.opacity(0.08), radius: 6, y: 3)
        }
        .accessibilityLabel("\(mode.personaNameWithLevel) difficulty. \(mode.tagline)\(isCurrent ? " Currently selected." : "")")
    }

    private func select(_ mode: DifficultyMode) {
        animateRespectingMotion(settings) { highlighted = mode }
        // Brief highlight, then confirm.
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
            settings.activeDifficulty = mode
            if isFirstLaunch {
                settings.completeFirstLaunch(with: mode)
            }
            onConfirm(mode)
        }
    }
}

#Preview {
    DifficultySelectionView(isFirstLaunch: true)
        .environmentObject(GameSettings())
}
