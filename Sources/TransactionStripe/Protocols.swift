import Transaction
import Stripe
import Core

// MARK: - Protocols

public protocol PaymentStructure: class {
    associatedtype OrderID
    associatedtype ID
    
    var id: ID? { get }
    var total: Int { get }
    var orderID: OrderID { get }
    var currency: String { get }
    
    var externalID: String? { get set }
}

extension StripeCurrency: CurrencyProtocol {}

extension StripeCurrency: AmountConverter {
    public func amount(for amount: Int, as currency: StripeCurrency) -> Int {
        return amount
    }
    
    public func amount(for amount: Int) -> Int {
        return self.amount(for: amount, as: self)
    }
}

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
            let id = ObjectIdentifier(self).debugDescription
            return Store._failureMessage.currentValue?.dict[id]
        }
        set {
            if let new = newValue {
                let id = ObjectIdentifier(self).debugDescription
                Store._failureMessage.currentValue?.dict[id] = new
            }
        }
    }
}
