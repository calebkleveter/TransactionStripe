@_exported import Transaction
import Vapor
import Stripe
import Service

public final class StripeCreditCard<Prc, Pay>: PaymentMethod where Prc: PaymentRepresentable, Prc.Payment == Pay, Pay: PaymentStructure {
    
    // MARK: - Types
    public typealias Purchase = Prc
    public typealias Payment = Pay
    public typealias ExecutionData = String
    public typealias ExecutionResponse = PaymentResponse
    
    
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
        return Future.flatMap(on: self.container) { () -> Future<ChargeID> in
            guard let request = self.container as? Request else {
                throw Abort(.internalServerError, reason: "Attempted to decode a Stripe type charge from a non-request container")
            }
            
            return try request.content.decode(ChargeID.self)
        }.flatMap { charge in
            return purchase.payment(on: self.container, with: self, externalID: charge.id)
        }
    }
    
    public func execute(payment: Pay, with data: String) -> EventLoopFuture<Pay> {
        return Future.flatMap(on: self.container) { () -> Future<StripeCharge> in
            let stripe = try self.container.make(StripeClient.self)
            let charge = try stripe.charge.create(
                amount: payment.amount,
                currency: (payment.currency as? StripeCurrency) ?? .usd,
                description: "Order \(payment.orderID)",
                source: data
            )
            
            return charge
        }.map { charge in
            payment.failureMessage = charge.failureMessage
            return payment
        }
    }
    
    public func refund(payment: Pay, amount: Int?) -> EventLoopFuture<Pay> {
        return Future.flatMap(on: self.container) {
            guard let external = payment.externalID else {
                throw Abort(.custom(code: 418, reasonPhrase: "I'm a Teapot"), reason: "Unable to get ID for Stripe payment to refund")
            }
            
            let stripe = try self.container.make(StripeClient.self)
            let refund = try stripe.refund.create(charge: external, amount: amount)
            return refund.transform(to: payment)
        }
    }
}

extension StripeCreditCard: Transaction.PaymentResponse where Payment: ResponseCodable {
    
    public typealias CreatedResponse = Pay
    public typealias ExecutedResponse = PaymentResponse
    
    public func created(from payment: Pay) -> Future<Pay> {
        return self.container.future(payment)
    }
    
    public func executed(from payment: Pay) -> Future<PaymentResponse> {
        let response: TransactionStripe.PaymentResponse
        
        if let message = payment.failureMessage {
            response = .init(
                success: false,
                message: "Failed to create transaction",
                redirectUrl: nil,
                data: message,
                transactionId: String(describing: payment.id)
            )
        } else {
            response = TransactionStripe.PaymentResponse(
                success: true,
                message: "Success",
                redirectUrl: nil,
                data: nil,
                transactionId: String(describing: payment.id)
            )
        }
        
        return self.container.future(response)
    }
}
