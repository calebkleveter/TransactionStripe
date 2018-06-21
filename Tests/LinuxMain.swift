import XCTest

import TransactionStripeTests

var tests = [XCTestCaseEntry]()
tests += TransactionStripeTests.allTests()
XCTMain(tests)