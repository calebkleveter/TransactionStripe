@_exported import Transaction
import Stripe
import Service

public final class StripeCreditCard<Prc, Pay>: PaymentMethod where Prc: PaymentRepresentable, Prc.Payment == Pay, Pay: PaymentStructure {
    
    // MARK: - Types
    public typealias Purchase = Prc
    public typealias Payment = Pay
    public typealias ExecutionData = String
    public typealias ExecutionResponse = PaymentResponse<Pay.ID>
    
    
    // MARK: - Properties
    public static var name: String {
        return "StripeCC"
    }
    
    public static var slug: String {
        return "stripe-cc"
    }
    
    public var container: Container
    
    
    // MARK: - Methods
    public init(container: Container) {
        self.container = container
    }
    
    public func payment(for purchase: Prc) -> EventLoopFuture<Pay> {
        return purchase.payment(on: self.container, with: self)
    }
    
    public func execute(payment: Pay, with data: String) -> EventLoopFuture<PaymentResponse<Payment.ID>> {
        return Future.flatMap(on: self.container) { () -> Future<StripeCharge> in
            let stripe = try self.container.make(StripeClient.self)
            let charge = try stripe.charge.create(
                amount: payment.amount,
                currency: payment.currency ?? .usd,
                description: "Order \(payment.orderID)",
                source: data
            )
            
            return charge
        }.map { charge in
            if charge.captured && charge.amount == payment.amount {
                return PaymentResponse(
                    success: true,
                    message: "All Good",
                    redirectUrl: nil,
                    data: nil,
                    transactionId: payment.id
                )
            } else {
                return PaymentResponse(
                    success: false,
                    message: "Charge failed",
                    redirectUrl: nil,
                    data: charge.failureMessage,
                    transactionId: payment.id
                )
            }
        }
    }
    
    public func refund(payment: Pay, amount: Int?) -> EventLoopFuture<Pay> {
        return Future.flatMap(on: self.container) {
            let stripe = try self.container.make(StripeClient.self)
            let refund = try stripe.refund.create(charge: payment.externalID, amount: amount)
            return refund.transform(to: payment)
        }
    }
}
