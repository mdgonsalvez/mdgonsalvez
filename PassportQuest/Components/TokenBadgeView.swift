//
//  TokenBadgeView.swift
//  PassportQuest
//
//  Displays the player's hint-token balance. On Easy mode (free, unlimited
//  reveals) it shows an "∞" so children aren't worried about running out.
//

import SwiftUI

struct TokenBadgeView: View {
    let tokens: Int
    /// When true (Easy mode) reveals are free, so show infinity.
    var unlimited: Bool = false

    var body: some View {
        HStack(spacing: 6) {
            Image(systemName: "ticket.fill")
                .foregroundColor(PQTheme.goldDeep)
            Text(unlimited ? "∞" : "\(tokens)")
                .font(.subheadline.weight(.bold).monospacedDigit())
                .foregroundColor(PQTheme.ink)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .frame(minHeight: 36)
        .background(Capsule().fill(PQTheme.paperDeep))
        .overlay(Capsule().stroke(PQTheme.ink.opacity(0.2), lineWidth: 1))
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(unlimited ? "Hint Coins: unlimited" : "Hint Coins: \(tokens)")
    }
}

#Preview {
    VStack {
        TokenBadgeView(tokens: 12)
        TokenBadgeView(tokens: 0, unlimited: true)
    }
    .padding()
}
