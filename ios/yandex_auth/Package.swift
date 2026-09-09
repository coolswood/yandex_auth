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
                // Privacy manifest: плагин не собирает данные и не использует
                // required-reason API, но манифест поставляется явно, чтобы
                // соответствовать требованиям App Store для сторонних SDK.
                .process("PrivacyInfo.xcprivacy"),
            ]
        )
    ]
)
