import Transaction
import Vapor

/// The response sent to the client when a Stipe payment is executed.
public struct PaymentResponse: Content {
    
    /// Whether the payment succeeded or not.
    public var success: Bool = true
    
    /// A human readable message with the status of the payment.
    public var message: String = ""
    
    /// Information about the payment returned by Stripe when the payment is executed.
    public var data: String?
    
    /// The ID of the internal model that the Stripe payment represents.
    public var transactionId: String?
}

/// The ID of a Stripe charge.
public struct Token: Content {
    
    /// The decoded token.
    let stripeToken: String
}
