//
//  GridView.swift
//  PassportQuest
//
//  A scrollable grid of country cards grouped by continent section. Unstamped
//  countries appear as faded silhouettes; stamped ones show full colour with a
//  star overlay and the Cartographer's Seal border when earned on Hard. Locked
//  sections (not yet reached in the sequential journey) are clearly marked.
//

import SwiftUI

struct PassportGridView: View {
    @EnvironmentObject private var settings: GameSettings
    @EnvironmentObject private var store: PlayerProgressStore
    let unlockedSections: Set<Continent>
    /// Tapping a stamped country opens its stamp card.
    var onSelectCountry: (Country) -> Void = { _ in }

    private let columns = [GridItem(.adaptive(minimum: 110, maximum: 160), spacing: 14)]

    var body: some View {
        ScrollView {
            LazyVStack(alignment: .leading, spacing: 28, pinnedViews: [.sectionHeaders]) {
                ForEach(Continent.journeyOrdered) { continent in
                    Section {
                        if unlockedSections.contains(continent) {
                            LazyVGrid(columns: columns, spacing: 14) {
                                ForEach(CountryDatabase.countries(in: continent)) { country in
                                    card(for: country)
                                }
                            }
                        } else {
                            lockedSection(continent)
                        }
                    } header: {
                        sectionHeader(continent)
                    }
                }
            }
            .padding(16)
        }
        .background(PQTheme.paper)
    }

    // MARK: Section header

    private func sectionHeader(_ continent: Continent) -> some View {
        let countries = CountryDatabase.countries(in: continent)
        let stamped = countries.filter { store.progress.isStamped($0.id) }.count
        return HStack(spacing: 10) {
            Image(systemName: continent.symbolName).foregroundColor(PQTheme.ink)
            Text(continent.displayName).font(.title3.weight(.bold)).foregroundColor(PQTheme.ink)
            Spacer()
            if store.progress.masteryBadges.contains(continent) {
                Image(systemName: "rosette").foregroundColor(PQTheme.gold)
                    .accessibilityLabel("Mastery badge")
            }
            Text("\(stamped)/\(countries.count)")
                .font(.subheadline.weight(.semibold).monospacedDigit())
                .foregroundColor(.secondary)
        }
        .padding(.vertical, 8)
        .padding(.horizontal, 4)
        .background(PQTheme.paper)
    }

    private func lockedSection(_ continent: Continent) -> some View {
        HStack(spacing: 10) {
            Image(systemName: "lock.fill").foregroundColor(.secondary)
            Text("Stamp the earlier sections to unlock \(continent.displayName)!")
                .font(.subheadline).foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(RoundedRectangle(cornerRadius: 14).fill(PQTheme.paperDeep))
    }

    // MARK: Card

    @ViewBuilder
    private func card(for country: Country) -> some View {
        let stamped = store.progress.isStamped(country.id)
        let rating = store.progress.rating(for: country.id)
        let hard = store.progress.wasEarnedOnHard(country.id)

        Button {
            if stamped { onSelectCountry(country) }
        } label: {
            VStack(spacing: 8) {
                ZStack {
                    if stamped {
                        Text(country.emojiFlag).font(.system(size: 46))
                    } else {
                        SilhouetteView(country: country, fill: PQTheme.ink.opacity(0.35))
                            .frame(height: 56)
                    }
                }
                .frame(height: 56)

                Text(stamped ? country.name : "? ? ?")
                    .font(.caption.weight(.semibold))
                    .foregroundColor(stamped ? PQTheme.ink : .secondary)
                    .lineLimit(1).minimumScaleFactor(0.7)

                if stamped, let rating {
                    HStack(spacing: 2) {
                        ForEach(0..<rating.starCount, id: \.self) { _ in
                            Image(systemName: "star.fill")
                                .font(.system(size: 9))
                                .foregroundColor(Color(hex: rating.tintHex))
                        }
                    }
                } else {
                    Spacer().frame(height: 11)
                }
            }
            .padding(10)
            .frame(maxWidth: .infinity, minHeight: 110)
            .background(
                RoundedRectangle(cornerRadius: 14)
                    .fill(stamped ? PQTheme.paperDeep : PQTheme.paper)
            )
            .overlay(cardBorder(stamped: stamped, hard: hard))
        }
        .accessibilityLabel(stamped
            ? "\(country.name), stamped, \(rating?.displayName ?? "")\(hard ? ", Cartographer's Seal" : "")"
            : "Unstamped mystery country in \(country.continent.displayName)")
    }

    /// Double-ring Cartographer's Seal border for Hard stamps; single otherwise.
    @ViewBuilder
    private func cardBorder(stamped: Bool, hard: Bool) -> some View {
        if stamped && hard {
            ZStack {
                RoundedRectangle(cornerRadius: 14).stroke(PQTheme.ink, lineWidth: 2)
                RoundedRectangle(cornerRadius: 10).stroke(PQTheme.ink, lineWidth: 1).padding(4)
            }
        } else {
            RoundedRectangle(cornerRadius: 14)
                .stroke(PQTheme.ink.opacity(stamped ? 0.4 : 0.12), lineWidth: 1)
        }
    }
}
