import Transaction
import Vapor

public struct PaymentResponse: Content {
    public var success: Bool = true
    public var message: String = ""
    public var redirectUrl: String?
    public var data: String?
    public var transactionId: String?
}

public struct ChargeID: Content, Identifiable {
    public let id: String
}
