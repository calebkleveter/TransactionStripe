public struct PaymentResponse<ID>: Codable where ID: Codable {
    public var success: Bool = true
    public var message: String = ""
    public var redirectUrl: String?
    public var data: String?
    public var transactionId: ID?
}
