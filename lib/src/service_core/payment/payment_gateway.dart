// Platform-neutral payment gateway used by checkout.
//
// Mobile pays through razorpay_flutter (gateway_mobile.dart), web through
// Razorpay Standard Checkout / checkout.js (gateway_web.dart). The cart never
// imports either SDK: it opens a PaymentRequest and receives exactly one of
// three outcomes. Card, UPI and netbanking details are entered inside
// Razorpay's own UI — DQ code only ever sees the three ids below (SAQ-A).

/// What to pay for. [orderId], [amountInPaise] and [keyId] come from the
/// server's createRazorpayOrder response — never computed on the client.
class PaymentRequest {
  final String orderId;
  final int amountInPaise;
  final String keyId;
  final String currency;
  final String name;
  final String description;
  final String contact;
  final String email;

  const PaymentRequest({
    required this.orderId,
    required this.amountInPaise,
    required this.keyId,
    this.currency = 'INR',
    this.name = 'DQ App',
    this.description = 'Cart Checkout',
    this.contact = '',
    this.email = '',
  });
}

/// Razorpay's proof of payment. The server verifies [signature] (HMAC over
/// "orderId|paymentId") before it creates the order.
class PaymentSuccess {
  final String orderId;
  final String paymentId;
  final String signature;

  const PaymentSuccess({required this.orderId, required this.paymentId, required this.signature});
}

class PaymentFailure {
  final String? code;
  final String message;

  const PaymentFailure({this.code, required this.message});

  @override
  String toString() => 'PaymentFailure($code, $message)';
}

/// Exactly one of these is called per [PaymentGateway.open].
class PaymentCallbacks {
  final void Function(PaymentSuccess success) onSuccess;
  final void Function(PaymentFailure failure) onFailure;

  /// The customer closed the payment sheet without paying.
  final void Function() onCancelled;

  const PaymentCallbacks({required this.onSuccess, required this.onFailure, required this.onCancelled});
}

abstract class PaymentGateway {
  /// Opens the payment sheet. Errors (e.g. checkout.js failing to load) are
  /// reported through [PaymentCallbacks.onFailure], never thrown.
  Future<void> open(PaymentRequest request, PaymentCallbacks callbacks);

  void dispose();
}
