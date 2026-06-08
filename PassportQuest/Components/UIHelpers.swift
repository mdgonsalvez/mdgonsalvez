//
//  UIHelpers.swift
//  PassportQuest
//
//  Small cross-cutting helpers: hex colour parsing and a Reduce-Motion-aware
//  animation wrapper (spec rule #7). Kept tiny and dependency-free.
//

import SwiftUI
import UIKit

extension Color {
    /// Creates a colour from a "#RRGGBB" hex string. Falls back to grey.
    init(hex: String) {
        let cleaned = hex.trimmingCharacters(in: CharacterSet(charactersIn: "#"))
        var value: UInt64 = 0
        Scanner(string: cleaned).scanHexInt64(&value)
        let r, g, b: Double
        if cleaned.count == 6 {
            r = Double((value & 0xFF0000) >> 16) / 255.0
            g = Double((value & 0x00FF00) >> 8) / 255.0
            b = Double(value & 0x0000FF) / 255.0
        } else {
            r = 0.5; g = 0.5; b = 0.5
        }
        self.init(red: r, green: g, blue: b)
    }
}

/// Whether motion should be reduced, combining the system setting with the
/// app's optional user override.
@MainActor
func motionIsReduced(_ settings: GameSettings) -> Bool {
    UIAccessibility.isReduceMotionEnabled || settings.prefersReducedMotion
}

/// Runs `body` inside `withAnimation(animation)` unless motion is reduced, in
/// which case it applies the change instantly. Spec rule #7.
@MainActor
func animateRespectingMotion(_ settings: GameSettings,
                             _ animation: Animation = .spring(response: 0.4, dampingFraction: 0.8),
                             _ body: () -> Void) {
    if motionIsReduced(settings) {
        body()
    } else {
        withAnimation(animation, body)
    }
}

// MARK: - Shared visual constants

enum PQTheme {
    /// Warm "passport paper" background.
    static let paper = Color(red: 0.97, green: 0.95, blue: 0.90)
    static let paperDeep = Color(red: 0.93, green: 0.89, blue: 0.81)
    /// Deep navy used for ink, borders and primary text.
    static let ink = Color(red: 0.11, green: 0.16, blue: 0.30)
    /// Accent gold for seals and highlights (use as a FILL / on dark ink).
    static let gold = Color(hex: "#F1C40F")
    /// Darker gold for gold-coloured TEXT or ICONS on the light paper, where the
    /// bright gold fails WCAG contrast.
    static let goldDeep = Color(hex: "#B8860B")
    static let positive = Color(red: 0.16, green: 0.52, blue: 0.32)

    /// Minimum accessible tap target (spec: 48×48 pt).
    static let minTap: CGFloat = 48
}
