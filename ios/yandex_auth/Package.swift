// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "yandex_auth",
    platforms: [
        .iOS("13.0")
    ],
    products: [
        .library(name: "yandex-auth", targets: ["yandex_auth"])
    ],
    dependencies: [
        .package(url: "https://github.com/yandexmobile/yandex-login-sdk-ios.git", exact: "3.1.1")
    ],
    targets: [
        .target(
            name: "yandex_auth",
            dependencies: [
                .product(name: "YandexLoginSDK", package: "yandex-login-sdk-ios")
            ],
            path: "Sources/yandex_auth",
            resources: [
                // If your plugin requires a privacy manifest, for example if it uses any required
                // reason APIs, update the PrivacyInfo.xcprivacy file to describe your plugin's
                // privacy impact, and then uncomment these lines. For more information, see
                // https://developer.apple.com/documentation/bundleresources/privacy_manifest_files
                // .process("PrivacyInfo.xcprivacy"),
            ]
        )
    ]
)
