//
//  SilhouetteView.swift
//  PassportQuest
//
//  Renders a country's outline from the normalised polygon data in
//  SilhouettePaths. Coordinates are 0–1 and scaled to the view via a Shape,
//  so the silhouette is crisp at any size (spec rule #10). Countries without
//  hand-authored shapes fall back to a continent placeholder with a "?".
//

import SwiftUI

/// A `Shape` built from normalised 0–1 polygon points.
struct CountrySilhouetteShape: Shape {
    let points: [CGPoint]

    func path(in rect: CGRect) -> Path {
        var path = Path()
        guard let first = points.first else { return path }
        func scaled(_ p: CGPoint) -> CGPoint {
            CGPoint(x: rect.minX + p.x * rect.width,
                    y: rect.minY + p.y * rect.height)
        }
        path.move(to: scaled(first))
        for point in points.dropFirst() {
            path.addLine(to: scaled(point))
        }
        path.closeSubpath()
        return path
    }
}

struct SilhouetteView: View {
    let country: Country
    var fill: Color = PQTheme.ink

    var body: some View {
        GeometryReader { geo in
            let side = min(geo.size.width, geo.size.height)
            let frame = CGRect(x: (geo.size.width - side) / 2,
                               y: (geo.size.height - side) / 2,
                               width: side, height: side)
            ZStack {
                if country.silhouetteAvailable,
                   let points = SilhouettePaths.points(for: country.id) {
                    CountrySilhouetteShape(points: points)
                        .fill(fill)
                        .frame(width: frame.width, height: frame.height)
                        .position(x: geo.size.width / 2, y: geo.size.height / 2)
                } else {
                    // Continent placeholder with a question mark.
                    ZStack {
                        CountrySilhouetteShape(points: SilhouettePaths.continentPlaceholder())
                            .fill(fill.opacity(0.30))
                            .frame(width: frame.width, height: frame.height)
                            .position(x: geo.size.width / 2, y: geo.size.height / 2)
                        Text("?")
                            .font(.system(size: side * 0.4, weight: .heavy, design: .rounded))
                            .foregroundColor(fill.opacity(0.8))
                    }
                }
            }
        }
        .accessibilityElement()
        .accessibilityLabel(country.silhouetteAvailable
                            ? "Mystery country shape"
                            : "Mystery shape in \(country.continent.displayName)")
    }
}
