# Assets.xcassets — Production Asset Guide

This catalogue ships with only the essentials needed to build and run
Passport Quest with **programmatic + emoji** visuals (per the v1 spec).
The empty namespaced groups below are placeholders showing exactly where a
production art pass would slot illustrated assets. **Nothing here is required
to compile or play** — the app falls back to emoji flags, SwiftUI `Path`
silhouettes, and labelled landmark placeholders.

## Groups

### `Flags/` (namespaced → `Flags/<ISO2>`)
Drop one image set per country, named by ISO 3166-1 alpha-2 id
(e.g. `Flags/FR`, `Flags/JP`). To use them, replace the emoji in
`ClueView.swift` (`.flag` case) and `StampMark` with
`Image("Flags/\(country.id)")`. Provide @1x/@2x/@3x PDFs or PNGs.
Recommended: vector PDF with "Preserve Vector Data" enabled.

### `Landmarks/` (namespaced → `Landmarks/<ISO2>`)
One illustrated landmark per country, named by ISO id
(e.g. `Landmarks/EG` for the Pyramids). Swap the placeholder rectangle in
`ClueView.swift` (`landmarkPlaceholder`) for `Image("Landmarks/\(country.id)")`.
Keep a 4:3 or 3:2 aspect, child-friendly illustration style.

### `Silhouettes/` (namespaced → `Silhouettes/<ISO2>`)
Optional high-fidelity outline images for countries whose simplified
`SilhouettePaths` polygons you want to replace with art. `SilhouetteView`
currently draws from normalised `Path` data; to prefer an asset when present,
check `UIImage(named: "Silhouettes/\(country.id)")` first and fall back to the
`Path`.

## App icon
`AppIcon.appiconset` currently has a single 1024×1024 slot (Xcode's
single-size icon). Add a child-friendly, high-contrast icon PNG (no
transparency) before submission.

## Accent colour
`AccentColor.colorset` is the deep passport navy used as the app tint.

## Notes for the Kids Category
- All illustrated assets must be original or properly licensed.
- No third-party logos, real photos of identifiable children, or ad/branding
  imagery (App Store Kids rules).
