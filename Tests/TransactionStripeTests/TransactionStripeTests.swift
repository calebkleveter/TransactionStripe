import XCTest
@testable import TransactionStripe

final class TransactionStripeTests: XCTestCase {
    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct
        // results.
        XCTAssertEqual(TransactionStripe().text, "Hello, World!")
    }


    static var allTests = [
        ("testExample", testExample),
    ]
}
