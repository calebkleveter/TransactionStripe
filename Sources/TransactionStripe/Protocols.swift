import Stripe
import Core

public protocol PaymentStructure: class {
    associatedtype OrderID
    associatedtype ID: Codable
    
    var id: ID? { get }
    var orderID: OrderID { get }
    var externalID: String? { get }
    var amount: Int { get }
    var currency: StripeCurrency? { get }
}



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
