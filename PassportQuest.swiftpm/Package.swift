// swift-tools-version: 5.9

// This is the Swift Playgrounds "App" manifest. It tells Swift Playgrounds (and
// Xcode 15+) to treat this folder as a runnable iOS app. It is the no-Mac way to
// build Passport Quest: open this .swiftpm package in the free Swift Playgrounds
// app on iPad and press Run.
//
// The `AppleProductTypes` module and `.iOSApplication` product are provided by
// Swift Playgrounds / Xcode — that's what lets a Swift Package build as an app.
//
// The same Swift source files are shared with the Xcode project version.

import PackageDescription
import AppleProductTypes

let package = Package(
    name: "PassportQuest",
    platforms: [
        .iOS("16.0")
    ],
    products: [
        .iOSApplication(
            name: "PassportQuest",
            targets: ["AppModule"],
            bundleIdentifier: "com.example.passportquest",
            teamIdentifier: "",
            displayVersion: "1.0",
            bundleVersion: "1",
            // A friendly placeholder icon/accent so no asset catalog is needed.
            // (Swap for a custom icon before any App Store submission.)
            appIcon: .placeholder(icon: .globe),
            accentColor: .presetColor(.indigo),
            supportedDeviceFamilies: [
                .pad,
                .phone
            ],
            supportedInterfaceOrientations: [
                .portrait,
                .landscapeRight,
                .landscapeLeft
            ]
        )
    ],
    targets: [
        .executableTarget(
            name: "AppModule",
            path: ".",
            // The English copy table (the app also runs without it, falling
            // back to the literal strings in the UI).
            resources: [
                .process("Resources")
            ]
        )
    ]
)
