//
//  DifficultyBadgeView.swift
//  PassportQuest
//
//  The persistent mode indicator shown in the top-right of all game screens
//  (e.g. "🌍 Explorer"). Tapping it navigates to Settings.
//

import SwiftUI

struct DifficultyBadgeView: View {
    @EnvironmentObject private var settings: GameSettings
    /// Invoked when the badge is tapped (host routes to Settings).
    var onTap: () -> Void = {}

    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 6) {
                Text(settings.activeDifficulty.icon)
                    .font(.headline)
                Text(settings.activeDifficulty.personaName)
                    .font(.subheadline.weight(.semibold))
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .frame(minHeight: 36)
            .background(
                Capsule().fill(PQTheme.paperDeep)
            )
            .overlay(
                Capsule().stroke(PQTheme.ink.opacity(0.25), lineWidth: 1)
            )
            .foregroundColor(PQTheme.ink)
        }
        .accessibilityLabel("Difficulty: \(settings.activeDifficulty.personaName). Double tap to change in Settings.")
    }
}

#Preview {
    DifficultyBadgeView()
        .environmentObject(GameSettings())
        .padding()
}
