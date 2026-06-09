//
//  StreakIndicatorView.swift
//  PassportQuest
//
//  Two pieces:
//   • `StreakIndicatorView` — a small persistent "🔥 x3" streak counter.
//   • `HotStreakOverlay` — the celebratory ink-splatter effect shown when a
//     Hot Streak fires. Respects Reduce Motion (spec rule #7).
//

import SwiftUI

struct StreakIndicatorView: View {
    let streak: Int

    var body: some View {
        if streak >= 2 {
            HStack(spacing: 4) {
                Image(systemName: "flame.fill").foregroundColor(.orange)
                Text("×\(streak)")
                    .font(.subheadline.weight(.bold).monospacedDigit())
                    .foregroundColor(PQTheme.ink)
            }
            .padding(.horizontal, 10)
            .padding(.vertical, 6)
            .background(Capsule().fill(Color.orange.opacity(0.15)))
            .accessibilityLabel("Streak: \(streak) in a row")
        }
    }
}

/// Full-screen splatter overlay for the Hot Streak moment.
struct HotStreakOverlay: View {
    @EnvironmentObject private var settings: GameSettings
    let inkColour: Color
    @State private var animate = false

    private let blobs: [(CGFloat, CGFloat, CGFloat)] = [
        (0.2, 0.3, 60), (0.8, 0.25, 48), (0.5, 0.15, 72),
        (0.3, 0.7, 54), (0.75, 0.7, 66), (0.55, 0.85, 50),
        (0.15, 0.55, 44), (0.9, 0.55, 58)
    ]

    var body: some View {
        GeometryReader { geo in
            ZStack {
                // Dimming scrim so the white celebration text pops off the page.
                Color.black.opacity(animate ? 0.32 : 0)
                    .ignoresSafeArea()
                ForEach(blobs.indices, id: \.self) { i in
                    let blob = blobs[i]
                    Circle()
                        .fill(inkColour.opacity(0.65))
                        .frame(width: blob.2, height: blob.2)
                        .position(x: geo.size.width * blob.0,
                                  y: geo.size.height * blob.1)
                        .scaleEffect(animate ? 1 : 0.1)
                        .opacity(animate ? 1 : 0)
                }
                VStack(spacing: 8) {
                    Text("🔥 Hot Streak!")
                        .font(.system(size: 40, weight: .heavy, design: .rounded))
                        .foregroundColor(.white)
                        .shadow(radius: 4)
                    Text("+ bonus Hint Coins!")
                        .font(.title3.weight(.semibold))
                        .foregroundColor(.white)
                }
                .scaleEffect(animate ? 1 : 0.6)
                .opacity(animate ? 1 : 0)
            }
        }
        .allowsHitTesting(false)
        .onAppear {
            if motionIsReduced(settings) {
                animate = true
            } else {
                withAnimation(.spring(response: 0.5, dampingFraction: 0.6)) { animate = true }
            }
        }
        .accessibilityElement()
        .accessibilityLabel("Hot streak! You earned bonus Hint Coins.")
    }
}

#Preview {
    ZStack {
        PQTheme.paper.ignoresSafeArea()
        HotStreakOverlay(inkColour: .blue)
            .environmentObject(GameSettings())
    }
}
