// swift-tools-version:4.2

import PackageDescription

let package = Package(
    name: "TransactionStripe",
    products: [
        .library(name: "TransactionStripe", targets: ["TransactionStripe"]),
    ],
    dependencies: [
        .package(url: "https://github.com/vapor/service.git", from: "1.0.0"),
        .package(url: "https://github.com/skelpo/Transaction.git", from: "0.3.0"),
        .package(url: "https://github.com/vapor-community/stripe-provider.git", from: "2.0.0")
    ],
    targets: [
        .target(name: "TransactionStripe", dependencies: ["Transaction", "Stripe", "Service"]),
        .testTarget(name: "TransactionStripeTests", dependencies: ["TransactionStripe", "Transaction", "Stripe"]),
    ]
)
