//
//  PassportView.swift
//  PassportQuest
//
//  The passport "book": a swipeable, paged view with one page per continent
//  (in journey order). Each page is styled like a passport page — a header band
//  showing the continent's emblem and name, a progress count and mastery badge,
//  then a grid of country stamps. Swipe left/right (or tap the dots) to flip to
//  the next continent. Tapping a stamped country opens its stamp card.
//

import SwiftUI

struct PassportView: View {
    @EnvironmentObject private var settings: GameSettings
    @EnvironmentObject private var store: PlayerProgressStore
    var onOpenSettings: () -> Void = {}

    @State private var page: Continent = .europe
    @State private var selectedCountry: Country?
    @State private var sprintContinent: Continent?

    private var continents: [Continent] { Continent.journeyOrdered }

    /// Sections currently unlocked, from sequential progress + difficulty.
    private var unlockedSections: Set<Continent> {
        if settings.activeDifficulty.unlockStrategy == .globalRandom {
            return Set(Continent.allCases)
        }
        var unlocked: Set<Continent> = []
        for section in continents {
            unlocked.insert(section)
            let allStamped = CountryDatabase.countries(in: section)
                .allSatisfy { store.progress.isStamped($0.id) }
            if !allStamped { break }
        }
        return unlocked
    }

    var body: some View {
        VStack(spacing: 0) {
            topBar
            TabView(selection: $page) {
                ForEach(continents) { continent in
                    PassportPage(continent: continent,
                                 unlocked: unlockedSections.contains(continent),
                                 onSelectCountry: { selectedCountry = $0 },
                                 onStartSprint: { sprintContinent = continent })
                        .environmentObject(settings)
                        .environmentObject(store)
                        .tag(continent)
                        .padding(.horizontal, 12)
                        .padding(.bottom, 12)
                }
            }
            .tabViewStyle(.page(indexDisplayMode: .always))
            .indexViewStyle(.page(backgroundDisplayMode: .always))
        }
        .background(passportCover.ignoresSafeArea())
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

    // MARK: Cover / top bar

    /// A deep passport-cover colour behind the pages.
    private var passportCover: some View {
        LinearGradient(colors: [Color(red: 0.18, green: 0.22, blue: 0.36),
                                Color(red: 0.10, green: 0.13, blue: 0.24)],
                       startPoint: .top, endPoint: .bottom)
    }

    private var topBar: some View {
        HStack(alignment: .center) {
            VStack(alignment: .leading, spacing: 2) {
                Text("My Passport")
                    .font(.title.weight(.heavy)).foregroundColor(.white)
                Text("\(store.progress.stampedCount) of \(CountryDatabase.all.count) stamps")
                    .font(.subheadline).foregroundColor(.white.opacity(0.8))
            }
            Spacer()
            DifficultyBadgeView(onTap: onOpenSettings)
        }
        .padding(.horizontal)
        .padding(.top, 8)
        .padding(.bottom, 10)
    }
}

// MARK: - PassportPage

private struct PassportPage: View {
    @EnvironmentObject private var settings: GameSettings
    @EnvironmentObject private var store: PlayerProgressStore
    let continent: Continent
    let unlocked: Bool
    var onSelectCountry: (Country) -> Void
    var onStartSprint: () -> Void

    private let columns = [GridItem(.adaptive(minimum: 96, maximum: 150), spacing: 12)]

    private var countries: [Country] { CountryDatabase.countries(in: continent) }
    private var stampedCount: Int { countries.filter { store.progress.isStamped($0.id) }.count }
    private var mastered: Bool { store.progress.masteryBadges.contains(continent) }
    private var fullyStamped: Bool { !countries.isEmpty && stampedCount == countries.count }

    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                header
                if unlocked {
                    LazyVGrid(columns: columns, spacing: 12) {
                        ForEach(countries) { country in
                            card(for: country)
                        }
                    }
                    if fullyStamped {
                        sprintButton
                    }
                } else {
                    lockedNotice
                }
            }
            .padding(18)
        }
        .background(pageBackground)
        .clipShape(RoundedRectangle(cornerRadius: 22))
        .overlay(RoundedRectangle(cornerRadius: 22).stroke(Color.white.opacity(0.25), lineWidth: 1))
    }

    // MARK: Page header (emblem + continent name, as requested)

    private var header: some View {
        HStack(spacing: 14) {
            Text(continent.emoji)
                .font(.system(size: 50))
                .frame(width: 64, height: 64)
                .background(Circle().fill(PQTheme.paperDeep))
                .overlay(Circle().stroke(PQTheme.ink.opacity(0.2), lineWidth: 1))
            VStack(alignment: .leading, spacing: 4) {
                Text(continent.displayName)
                    .font(.title2.weight(.heavy))
                    .foregroundColor(PQTheme.ink)
                    .minimumScaleFactor(0.7).lineLimit(1)
                HStack(spacing: 8) {
                    Text("\(stampedCount) / \(countries.count) stamped")
                        .font(.subheadline.weight(.semibold))
                        .foregroundColor(.secondary)
                    if mastered {
                        Image(systemName: "rosette").foregroundColor(PQTheme.goldDeep)
                            .accessibilityLabel("Mastery badge earned")
                    }
                }
            }
            Spacer()
            // Progress ring.
            ZStack {
                Circle().stroke(PQTheme.ink.opacity(0.12), lineWidth: 6).frame(width: 48, height: 48)
                Circle().trim(from: 0, to: countries.isEmpty ? 0 : CGFloat(stampedCount) / CGFloat(countries.count))
                    .stroke(settings.inkColour.color, style: StrokeStyle(lineWidth: 6, lineCap: .round))
                    .rotationEffect(.degrees(-90))
                    .frame(width: 48, height: 48)
            }
        }
        .padding(.bottom, 4)
        .overlay(alignment: .bottom) {
            Rectangle().fill(PQTheme.ink.opacity(0.12)).frame(height: 1)
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(continent.displayName) page. \(stampedCount) of \(countries.count) stamped\(mastered ? ", mastered" : "")")
    }

    private var lockedNotice: some View {
        VStack(spacing: 12) {
            Image(systemName: "lock.fill").font(.largeTitle).foregroundColor(.secondary)
            Text("Locked")
                .font(.title3.weight(.bold)).foregroundColor(PQTheme.ink)
            Text("Stamp the earlier sections of your journey to unlock \(continent.displayName)!")
                .font(.subheadline)
                .multilineTextAlignment(.center)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 40)
    }

    private var sprintButton: some View {
        Button(action: onStartSprint) {
            HStack {
                Image(systemName: "bolt.fill")
                Text("\(continent.displayName) Sprint")
                Spacer()
                if mastered { Image(systemName: "rosette").foregroundColor(PQTheme.goldDeep) }
                Image(systemName: "chevron.right").foregroundColor(.secondary)
            }
            .font(.headline)
            .foregroundColor(PQTheme.ink)
            .padding()
            .frame(maxWidth: .infinity, minHeight: PQTheme.minTap)
            .background(RoundedRectangle(cornerRadius: 14).fill(PQTheme.gold.opacity(0.25)))
        }
        .padding(.top, 8)
        .accessibilityLabel("Start \(continent.displayName) Sprint bonus round")
    }

    // MARK: Country card

    @ViewBuilder
    private func card(for country: Country) -> some View {
        let stamped = store.progress.isStamped(country.id)
        let rating = store.progress.rating(for: country.id)
        let hard = store.progress.wasEarnedOnHard(country.id)
        // The shape is the hero for stamped countries we have boundary data for;
        // the rest (no authored silhouette) keep the flag as the hero so we never
        // show a "?" blob for a country the player has already identified.
        let hasShape = SilhouettePaths.shape(for: country.id) != nil

        Button {
            if stamped { onSelectCountry(country) }
        } label: {
            VStack(spacing: 6) {
                ZStack(alignment: .bottomTrailing) {
                    if stamped {
                        if hasShape {
                            SilhouetteView(country: country, fill: PQTheme.ink)
                                .frame(height: 52)
                            flagAccent(country)
                        } else {
                            Text(country.emojiFlag).font(.system(size: 40))
                        }
                    } else {
                        SilhouetteView(country: country, fill: PQTheme.ink.opacity(0.30))
                            .frame(height: 48)
                    }
                }
                .frame(height: 52)

                Text(stamped ? country.name : "? ? ?")
                    .font(.caption.weight(.semibold))
                    .foregroundColor(stamped ? PQTheme.ink : .secondary)
                    .lineLimit(1).minimumScaleFactor(0.65)

                if stamped, let rating {
                    HStack(spacing: 2) {
                        ForEach(0..<rating.starCount, id: \.self) { _ in
                            Image(systemName: "star.fill").font(.system(size: 8))
                                .foregroundColor(Color(hex: rating.tintHex))
                        }
                    }
                } else {
                    Spacer().frame(height: 10)
                }
            }
            .padding(9)
            .frame(maxWidth: .infinity, minHeight: 104)
            .background(RoundedRectangle(cornerRadius: 12).fill(stamped ? PQTheme.paperDeep : PQTheme.paper.opacity(0.6)))
            .overlay(cardBorder(stamped: stamped, hard: hard))
        }
        .accessibilityLabel(stamped
            ? "\(country.name), stamped, \(rating?.displayName ?? "")\(hard ? ", Cartographer's Seal" : "")"
            : "Unstamped mystery country")
    }

    /// A small flag chip on the corner of a stamped country's silhouette hero.
    private func flagAccent(_ country: Country) -> some View {
        Text(country.emojiFlag)
            .font(.system(size: 17))
            .padding(.horizontal, 3).padding(.vertical, 1)
            .background(RoundedRectangle(cornerRadius: 4).fill(PQTheme.paper))
            .overlay(RoundedRectangle(cornerRadius: 4).stroke(PQTheme.ink.opacity(0.18), lineWidth: 0.5))
            .offset(x: 4, y: 4)
            .accessibilityHidden(true)
    }

    @ViewBuilder
    private func cardBorder(stamped: Bool, hard: Bool) -> some View {
        if stamped && hard {
            ZStack {
                RoundedRectangle(cornerRadius: 12).stroke(PQTheme.ink, lineWidth: 2)
                RoundedRectangle(cornerRadius: 8).stroke(PQTheme.ink, lineWidth: 1).padding(4)
            }
        } else {
            RoundedRectangle(cornerRadius: 12)
                .stroke(PQTheme.ink.opacity(stamped ? 0.4 : 0.12), lineWidth: 1)
        }
    }

    // MARK: Passport page background

    private var pageBackground: some View {
        ZStack {
            PQTheme.paper
            // Subtle "security" guilloché stripes for a passport-page feel.
            GeometryReader { geo in
                Path { p in
                    let step: CGFloat = 26
                    var y: CGFloat = 0
                    while y < geo.size.height {
                        p.move(to: CGPoint(x: 0, y: y))
                        p.addLine(to: CGPoint(x: geo.size.width, y: y + 12))
                        y += step
                    }
                }
                .stroke(PQTheme.ink.opacity(0.04), lineWidth: 1)
            }
        }
    }
}
