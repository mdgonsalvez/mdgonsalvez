//
//  PassportQuestApp.swift
//  PassportQuest
//
//  App entry point. Creates the shared GameSettings and PlayerProgressStore and
//  injects them into the SwiftUI environment so every screen reads the active
//  difficulty and saved progress from a single source of truth.
//
//  Persistence is Codable + UserDefaults (see PlayerProgress.swift), chosen for
//  guaranteed iOS 16 support and zero dependencies. No SwiftData container is
//  required, but the model is value-type and trivially portable to SwiftData
//  later if desired.
//

import SwiftUI
import UIKit

@main
struct PassportQuestApp: App {
    @StateObject private var settings = GameSettings()
    @StateObject private var store = PlayerProgressStore()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(settings)
                .environmentObject(store)
                // Keep the persisted difficulty mirror on the save in sync.
                .onChange(of: settings.activeDifficulty) { newValue in
                    store.progress.activeDifficulty = newValue
                }
                // Save promptly when the app is about to background/terminate.
                .onReceive(NotificationCenter.default.publisher(
                    for: UIApplication.willResignActiveNotification)) { _ in
                    store.saveNow()
                }
        }
    }
}
