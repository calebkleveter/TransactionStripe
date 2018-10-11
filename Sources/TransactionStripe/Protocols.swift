import Transaction
import Stripe
import Core

// MARK: - Protocols

public protocol PaymentStructure: class {
    associatedtype OrderID
    associatedtype ID: Codable
    
    var id: ID? { get }
    var amount: Int { get }
    var orderID: OrderID { get }
    var currency: CurrencyType { get }
    
    var externalID: String? { get set }
}

extension StripeCurrency: CurrencyProtocol {}

// MARK: - Internal Helpers

fileprivate class TSKeyedStore {
    var dict: [String: String]
    
    init(_ dict: [String: String]) {
        self.dict = dict
    }
}

fileprivate struct Storage {
    static var _failureMessage: ThreadSpecificVariable<TSKeyedStore> = ThreadSpecificVariable<TSKeyedStore>.init(value: .init([:]))
}

extension PaymentStructure {
    private typealias Store = Storage
    
    internal var failureMessage: String? {
        get {
            var this = self
            let address = UnsafeMutablePointer<Self>(&this).debugDescription
            return Store._failureMessage.currentValue?.dict[address]
        }
        set {
            var this = self
            let address = UnsafeMutablePointer<Self>(&this).debugDescription
            if let new = newValue {
                Store._failureMessage.currentValue?.dict[address] = new
            }
        }
    }
}
