import Stripe

public protocol PaymentStructure: class {
    associatedtype OrderID
    associatedtype ID: Codable
    
    var id: ID { get }
    var orderID: OrderID { get }
    var externalID: String { get }
    var amount: Int { get }
    var currency: StripeCurrency? { get }
}
