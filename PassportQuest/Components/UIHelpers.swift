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

/// True when an image asset named `name` is present in the bundle. Lets shared
/// views use real artwork when it ships (the Xcode app) and fall back to an
/// emoji in builds that don't bundle the asset (the Swift Playgrounds package).
@MainActor
func assetExists(_ name: String) -> Bool {
    UIImage(named: name) != nil
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
    /// Muted slate-navy for secondary/body text. Replaces the system `.secondary`
    /// grey, which is too light to read comfortably on the parchment background
    /// (this hits WCAG-AA on `paper`).
    static let inkSoft = Color(red: 0.28, green: 0.32, blue: 0.40)
    /// Accent gold for seals and highlights (use as a FILL / on dark ink).
    static let gold = Color(hex: "#F1C40F")
    /// Darker gold for gold-coloured TEXT or ICONS on the light paper, where the
    /// bright gold fails WCAG contrast.
    static let goldDeep = Color(hex: "#B8860B")
    static let positive = Color(red: 0.16, green: 0.52, blue: 0.32)
    /// Bright "sky" accent echoing the app icon. Use as a FILL, dot, or
    /// decorative tint only — too light for text/thin icons on paper.
    static let sky = Color(hex: "#3FA9E0")
    /// Very soft sky tint for backgrounds (e.g. behind onboarding art) so the
    /// icon's bright sky carries into the first in-app screen.
    static let skySoft = Color(hex: "#E3F1FB")

    /// Minimum accessible tap target (spec: 48×48 pt).
    static let minTap: CGFloat = 48
}

// MARK: - Design-system scales (Sprint 3 #5)

/// Spacing scale (points) — use instead of ad-hoc literals for consistent rhythm.
enum PQSpace {
    static let xs: CGFloat = 4
    static let sm: CGFloat = 8
    static let md: CGFloat = 12
    static let lg: CGFloat = 16
    static let xl: CGFloat = 20
    static let xxl: CGFloat = 28
}

/// Corner-radius scale for chips, buttons, cards and full-width panels.
enum PQRadius {
    static let chip: CGFloat = 12
    static let button: CGFloat = 14
    static let card: CGFloat = 16
    static let panel: CGFloat = 24
}

/// Typography. `display` is the rounded, heavy family used for headings; the
/// stamp's faux date uses a monospaced face; `body` is the system text face.
enum PQFont {
    /// Rounded, heavy display face at an explicit size (page/headline titles).
    static func display(_ size: CGFloat) -> Font { .system(size: size, weight: .heavy, design: .rounded) }
    static let heading = Font.system(size: 30, weight: .heavy, design: .rounded)
    static let title = Font.title2.weight(.bold)
    static let body = Font.body
    static let caption = Font.caption
}
