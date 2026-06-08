//
//  PassportView.swift
//  PassportQuest
//
//  The passport "book": a header of section progress rings, a World Map / Grid
//  view switcher, and entry points to the Continent Sprint for mastered
//  sections. Tapping a stamped country opens its StampCardView detail sheet.
//

import SwiftUI

struct PassportView: View {
    @EnvironmentObject private var settings: GameSettings
    @EnvironmentObject private var store: PlayerProgressStore
    var onOpenSettings: () -> Void = {}

    @State private var mode: ViewMode = .map
    @State private var selectedCountry: Country?
    @State private var sprintContinent: Continent?

    private enum ViewMode: String, CaseIterable { case map = "Map", grid = "Grid" }

    /// Unlocked sections, derived from sequential progress + difficulty.
    private var unlockedSections: Set<Continent> {
        if settings.activeDifficulty.unlockStrategy == .globalRandom {
            return Set(Continent.allCases)
        }
        var unlocked: Set<Continent> = []
        for section in Continent.journeyOrdered {
            unlocked.insert(section)
            let allStamped = CountryDatabase.countries(in: section)
                .allSatisfy { store.progress.isStamped($0.id) }
            if !allStamped { break }
        }
        return unlocked
    }

    var body: some View {
        VStack(spacing: 0) {
            header
            sectionRings
            Picker("View", selection: $mode) {
                ForEach(ViewMode.allCases, id: \.self) { Text($0.rawValue).tag($0) }
            }
            .pickerStyle(.segmented)
            .padding(.horizontal)
            .padding(.bottom, 8)

            switch mode {
            case .map:
                ScrollView {
                    WorldMapView(onSelectCountry: { selectedCountry = $0 })
                        .padding(.horizontal)
                    masteredSprintSection
                }
            case .grid:
                PassportGridView(unlockedSections: unlockedSections,
                                 onSelectCountry: { selectedCountry = $0 })
            }
        }
        .background(PQTheme.paper.ignoresSafeArea())
        .sheet(item: $selectedCountry) { country in
            if let rating = store.progress.rating(for: country.id) {
                StampCardView(country: country,
                              rating: rating,
                              earnedOnHard: store.progress.wasEarnedOnHard(country.id),
                              unlockedFact: country.fact(seed: country.id.hashValue))
            }
        }
        .sheet(item: $sprintContinent) { continent in
            ContinentSprintView(continent: continent)
                .environmentObject(settings)
                .environmentObject(store)
        }
    }

    // MARK: Header

    private var header: some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                Text("My Passport").font(.largeTitle.weight(.heavy)).foregroundColor(PQTheme.ink)
                Text("\(store.progress.stampedCount) of \(CountryDatabase.all.count) stamps")
                    .font(.subheadline).foregroundColor(.secondary)
            }
            Spacer()
            DifficultyBadgeView(onTap: onOpenSettings)
        }
        .padding(.horizontal)
        .padding(.top, 8)
    }

    // MARK: Section progress rings

    private var sectionRings: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 16) {
                ForEach(Continent.journeyOrdered) { continent in
                    sectionRing(continent)
                }
            }
            .padding(.horizontal)
            .padding(.vertical, 12)
        }
    }

    private func sectionRing(_ continent: Continent) -> some View {
        let countries = CountryDatabase.countries(in: continent)
        let stamped = countries.filter { store.progress.isStamped($0.id) }.count
        let fraction = countries.isEmpty ? 0 : Double(stamped) / Double(countries.count)
        let unlocked = unlockedSections.contains(continent)
        let mastered = store.progress.masteryBadges.contains(continent)

        return VStack(spacing: 6) {
            ZStack {
                Circle().stroke(PQTheme.ink.opacity(0.12), lineWidth: 6)
                    .frame(width: 56, height: 56)
                Circle().trim(from: 0, to: CGFloat(fraction))
                    .stroke(settings.inkColour.color, style: StrokeStyle(lineWidth: 6, lineCap: .round))
                    .rotationEffect(.degrees(-90))
                    .frame(width: 56, height: 56)
                if unlocked {
                    Image(systemName: mastered ? "rosette" : continent.symbolName)
                        .foregroundColor(mastered ? PQTheme.gold : PQTheme.ink)
                } else {
                    Image(systemName: "lock.fill").foregroundColor(.secondary)
                }
            }
            Text(continent.displayName)
                .font(.caption2.weight(.semibold))
                .foregroundColor(.secondary)
                .lineLimit(1)
                .frame(width: 70)
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("\(continent.displayName): \(stamped) of \(countries.count) stamped\(mastered ? ", mastered" : "")\(unlocked ? "" : ", locked")")
    }

    // MARK: Sprint section

    private var masteredSprintSection: some View {
        let eligible = Continent.journeyOrdered.filter { continent in
            let countries = CountryDatabase.countries(in: continent)
            return !countries.isEmpty && countries.allSatisfy { store.progress.isStamped($0.id) }
        }
        return Group {
            if !eligible.isEmpty {
                VStack(alignment: .leading, spacing: 12) {
                    Text("⚡️ Continent Sprints")
                        .font(.title3.weight(.bold)).foregroundColor(PQTheme.ink)
                    Text("You've stamped these whole sections — try a bonus lightning round!")
                        .font(.subheadline).foregroundColor(.secondary)
                    ForEach(eligible) { continent in
                        Button { sprintContinent = continent } label: {
                            HStack {
                                Image(systemName: continent.symbolName)
                                Text("\(continent.displayName) Sprint")
                                    .font(.headline)
                                Spacer()
                                if store.progress.masteryBadges.contains(continent) {
                                    Image(systemName: "rosette").foregroundColor(PQTheme.gold)
                                }
                                Image(systemName: "chevron.right").foregroundColor(.secondary)
                            }
                            .foregroundColor(PQTheme.ink)
                            .padding()
                            .frame(maxWidth: .infinity, minHeight: PQTheme.minTap)
                            .background(RoundedRectangle(cornerRadius: 14).fill(PQTheme.paperDeep))
                        }
                        .accessibilityLabel("Start \(continent.displayName) Sprint bonus round")
                    }
                }
                .padding()
            }
        }
    }
}
