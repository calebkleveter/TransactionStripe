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


fileprivate struct Storage {
    static var _failureMessage: [String: String] = [:]
}

extension PaymentStructure {
    private typealias Store = Storage
    
    internal var failureMessage: String? {
        get {
            var this = self
            let address = UnsafeMutablePointer<Self>(&this).debugDescription
            return Store._failureMessage[address]
        }
        set {
            var this = self
            let address = UnsafeMutablePointer<Self>(&this).debugDescription
            if let new = newValue {
                Store._failureMessage[address] = new
            }
        }
    }
}
