// swift-tools-version: 5.7

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
            bundleIdentifier: "com.mdgonsalvez.passportquest",
            teamIdentifier: "",
            displayVersion: "1.0",
            bundleVersion: "1",
            // App icon: the globe-mascot art, supplied via the bundled asset
            // catalog (Assets.xcassets/AppIcon).
            appIcon: .asset("AppIcon"),
            supportedDeviceFamilies: [
                .pad
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
            resources: [
                // Bundle the icon/mascot art and the App Store privacy manifest
                // so a Swift Playgrounds (iPad) release carries them.
                .process("Assets.xcassets"),
                .copy("PrivacyInfo.xcprivacy")
            ]
        )
    ]
)
