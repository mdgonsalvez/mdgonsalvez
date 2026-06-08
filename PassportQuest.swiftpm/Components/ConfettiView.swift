//
//  ConfettiView.swift
//  PassportQuest
//
//  A lightweight confetti particle system drawn with TimelineView + Canvas.
//  Shown briefly on correct answers. Respects Reduce Motion: when motion is
//  reduced it renders a single calm static burst instead of falling particles
//  (spec rule #7).
//

import SwiftUI

struct ConfettiView: View {
    @EnvironmentObject private var settings: GameSettings
    /// How long the burst lasts before it should be removed by the host.
    var duration: TimeInterval = 2.0

    private let particles: [ConfettiParticle]
    private let startDate = Date()

    init(duration: TimeInterval = 2.0, count: Int = 80) {
        self.duration = duration
        self.particles = (0..<count).map { _ in ConfettiParticle.random() }
    }

    var body: some View {
        if motionIsReduced(settings) {
            staticBurst
        } else {
            TimelineView(.animation) { timeline in
                Canvas { context, size in
                    let elapsed = timeline.date.timeIntervalSince(startDate)
                    let progress = min(elapsed / duration, 1.0)
                    for particle in particles {
                        draw(particle, in: &context, size: size, progress: progress, elapsed: elapsed)
                    }
                }
            }
            .allowsHitTesting(false)
            .accessibilityHidden(true)
        }
    }

    /// Calm, non-animated celebration for Reduce Motion users.
    private var staticBurst: some View {
        GeometryReader { geo in
            ZStack {
                ForEach(particles.indices, id: \.self) { i in
                    let particle = particles[i]
                    RoundedRectangle(cornerRadius: 2)
                        .fill(particle.color)
                        .frame(width: 8, height: 8)
                        .position(x: geo.size.width * particle.startX,
                                  y: geo.size.height * (0.2 + particle.startX * 0.4))
                        .opacity(0.8)
                }
            }
        }
        .allowsHitTesting(false)
        .accessibilityHidden(true)
    }

    private func draw(_ particle: ConfettiParticle,
                      in context: inout GraphicsContext,
                      size: CGSize,
                      progress: Double,
                      elapsed: Double) {
        let x = size.width * particle.startX
            + sin(elapsed * particle.sway + particle.phase) * 30
        let fall = progress * size.height * 1.2 * particle.speed
        let y = -20 + fall
        let rotation = Angle(radians: elapsed * particle.spin)
        let fade = 1.0 - max(0, (progress - 0.7) / 0.3)

        var rect = Path(roundedRect: CGRect(x: -4, y: -6, width: 8, height: 12), cornerRadius: 2)
        rect = rect.applying(CGAffineTransform(rotationAngle: rotation.radians))
        rect = rect.applying(CGAffineTransform(translationX: x, y: y))
        context.fill(rect, with: .color(particle.color.opacity(fade)))
    }
}

struct ConfettiParticle {
    let startX: CGFloat
    let speed: Double
    let sway: Double
    let spin: Double
    let phase: Double
    let color: Color

    static func random() -> ConfettiParticle {
        let palette: [Color] = [.red, .orange, .yellow, .green, .blue, .purple, .pink, PQTheme.gold]
        return ConfettiParticle(
            startX: CGFloat.random(in: 0...1),
            speed: Double.random(in: 0.7...1.3),
            sway: Double.random(in: 1.5...3.5),
            spin: Double.random(in: -4...4),
            phase: Double.random(in: 0...(2 * .pi)),
            color: palette.randomElement() ?? .blue
        )
    }
}
