import Transaction
import Stripe
import Vapor

final class StripeCreditCard<P>: PaymentMethod where P: Buyable {
    static var pendingPossible: Bool { return false }
    static var preauthNeeded: Bool { return false }
    static var name: String { return "Credit Card (Stripe)" }
    static var slug: String { return "stripeCC" }
    
    let request: Request
    
    init(request: Request) {
        self.request = request
    }
    
    func workThroughPendingTransactions() {}
    
    func createTransaction(from purchase: P, userId: Int, amount: Int?, status: P.PaymentStatus?) -> EventLoopFuture<P.Payment> {
        let complete = status?.isComplete() ?? true
        let paid = complete ? amount ?? 0 : 0
        let refunded = complete ? 0 : amount ?? 0
        
        fatalError("\(paid) \(refunded)")
    }
    
    func pay(for order: P, userId: Int, amount: Int, params: Codable?) throws -> EventLoopFuture<PaymentResponse<P>> {
        guard let model = String(describing: P.self).split(separator: ".").last else {
            throw Abort(.internalServerError, reason: "Using a type without a name. How did you do that??!!!")
        }
        guard let id = order.id else {
            throw Abort(.internalServerError, reason: "Attempted to make payment for \(model) without an ID")
        }
        
        let stripe = try self.request.make(StripeClient.self)
        try stripe.charge.create(
            amount: amount,
            currency: .usd,
            description: model + String(describing: id),
            source: params
        ).flatMap(to: P.Payment.self) { charge in
            if charge.captured && charge.amount == amount {
                return self.createTransaction(from: order, userId: userId, amount: charge.amount, status: nil)
            } else {
                return self.request.future( PaymentResponse.self )
            }
            fatalError()
        }
        fatalError()
    }
    
    func refund(payment: P.Payment, amount: Int?) -> EventLoopFuture<P.Payment> {
        return self.request.future(payment)
    }
}
