// swift-tools-version:4.2

import PackageDescription

let package = Package(
    name: "TransactionStripe",
    products: [
        .library(name: "TransactionStripe", targets: ["TransactionStripe"]),
    ],
    dependencies: [
        
    ],
    targets: [
        .target(name: "TransactionStripe", dependencies: []),
        .testTarget(name: "TransactionStripeTests", dependencies: ["TransactionStripe"]),
    ]
)
