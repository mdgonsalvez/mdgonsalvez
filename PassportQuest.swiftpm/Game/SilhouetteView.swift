//
//  SilhouetteView.swift
//  PassportQuest
//
//  Renders a country's outline from the normalised polygon data in
//  SilhouettePaths (generated from real Natural Earth boundaries). Coordinates
//  are 0–1 and scaled to a square so the shape keeps correct proportions at any
//  size (spec rule #10). Countries without boundary data fall back to a
//  continent placeholder with a "?".
//

import SwiftUI

/// A `Shape` built from one or more normalised 0–1 polygons (islands etc.).
struct CountrySilhouetteShape: Shape {
    let polygons: [[CGPoint]]

    func path(in rect: CGRect) -> Path {
        var path = Path()
        func scaled(_ p: CGPoint) -> CGPoint {
            CGPoint(x: rect.minX + p.x * rect.width,
                    y: rect.minY + p.y * rect.height)
        }
        for ring in polygons {
            guard let first = ring.first else { continue }
            path.move(to: scaled(first))
            for point in ring.dropFirst() {
                path.addLine(to: scaled(point))
            }
            path.closeSubpath()
        }
        return path
    }
}

struct SilhouetteView: View {
    let country: Country
    var fill: Color = PQTheme.ink

    /// Whether we have real boundary data for this country.
    private var shape: [[CGPoint]]? { SilhouettePaths.shape(for: country.id) }

    var body: some View {
        GeometryReader { geo in
            let side = min(geo.size.width, geo.size.height)
            ZStack {
                if let shape {
                    CountrySilhouetteShape(polygons: shape)
                        .fill(fill)
                        .frame(width: side, height: side)
                        .position(x: geo.size.width / 2, y: geo.size.height / 2)
                } else {
                    // Continent placeholder with a question mark.
                    ZStack {
                        CountrySilhouetteShape(polygons: SilhouettePaths.continentPlaceholder())
                            .fill(fill.opacity(0.30))
                            .frame(width: side, height: side)
                            .position(x: geo.size.width / 2, y: geo.size.height / 2)
                        Text("?")
                            .font(.system(size: side * 0.4, weight: .heavy, design: .rounded))
                            .foregroundColor(fill.opacity(0.8))
                    }
                }
            }
        }
        .accessibilityElement()
        .accessibilityLabel(shape != nil
                            ? "Mystery country shape"
                            : "Mystery shape in \(country.continent.displayName)")
    }
}
