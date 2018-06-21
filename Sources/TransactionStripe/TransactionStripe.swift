@_exported import Transaction
import Stripe
import Vapor

final class StripeCreditCard<P>: PaymentMethod where P: Buyable {
    typealias Purchase = P
    
    static var pendingPossible: Bool { return false }
    static var preauthNeeded: Bool { return false }
    static var name: String { return "Credit Card (Stripe)" }
    static var slug: String { return "stripeCC" }
    
    let request: Request
    
    init(request: Request) {
        self.request = request
    }
    
    func workThroughPendingTransactions() {}
    
    func createTransaction(
        from purchase: P,
        userId: Int,
        amount: Int?,
        status: P.PaymentStatus?,
        paymentInit: @escaping (P.ID, String, Int, Int) -> (P.Payment)
    ) -> EventLoopFuture<P.Payment> {
        return Future.map(on: self.request) {
            let complete = status?.isComplete() ?? true
            let paid = complete ? amount ?? 0 : 0
            let refunded = complete ? 0 : amount ?? 0
            
            guard let model = String(describing: P.self).split(separator: ".").last else {
                throw Abort(.internalServerError, reason: "Using a type without a name. How did you do that??!!!")
            }
            guard let id = purchase.id else {
                throw Abort(.internalServerError, reason: "Attempted to make payment for \(model) without an ID")
            }
            return paymentInit(id, StripeCreditCard<P>.slug, paid, refunded)
        }
    }
    
    func pay(
        for order: P,
        userId: Int,
        amount: Int,
        params: Codable?,
        paymentInit: @escaping (P.ID, String, Int, Int) -> (P.Payment)
    ) throws -> EventLoopFuture<PaymentResponse<P>> {
        guard let model = String(describing: P.self).split(separator: ".").last else {
            throw Abort(.internalServerError, reason: "Using a type without a name. How did you do that??!!!")
        }
        guard let id = order.id else {
            throw Abort(.internalServerError, reason: "Attempted to make payment for \(model) without an ID")
        }
        let stripe = try self.request.make(StripeClient.self)
        
        return try stripe.charge.create(
            amount: amount,
            currency: .usd,
            description: model + String(describing: id),
            source: params
        ).flatMap(to: PaymentResponse<P>.self) { charge in
            if charge.captured && charge.amount == amount {
                return self.createTransaction(
                    from: order,
                    userId: userId,
                    amount: charge.amount,
                    status: P.PaymentStatus.completed(),
                    paymentInit: paymentInit
                ).map(to: PaymentResponse<P>.self) { transaction in
                    return PaymentResponse(message: "Success", transactionID: transaction.id)
                }
            } else {
                return self.request.future(PaymentResponse(success: false, message: "Failed to create transaction", data: charge.failureMessage))
            }
        }
    }
    
    func refund(payment: P.Payment, amount: Int?) -> EventLoopFuture<P.Payment> {
        return self.request.future(payment)
    }
}
