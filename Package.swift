// swift-tools-version:4.2

import PackageDescription

let package = Package(
    name: "TransactionStripe",
    products: [
        .library(name: "TransactionStripe", targets: ["TransactionStripe"]),
    ],
    dependencies: [
        .package(url: "https://github.com/skelpo/Transaction.git", from: "0.1.0"),
    ],
    targets: [
        .target(name: "TransactionStripe", dependencies: ["Transaction"]),
        .testTarget(name: "TransactionStripeTests", dependencies: ["TransactionStripe", "Transaction"]),
    ]
)
