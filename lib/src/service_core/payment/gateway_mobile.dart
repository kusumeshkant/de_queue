// Mobile gateway — the ONLY file that imports razorpay_flutter. Web builds
// never compile it (see payment_gateway_factory.dart).
import 'package:razorpay_flutter/razorpay_flutter.dart';

import 'payment_gateway.dart';
import 'payment_outcome.dart';

PaymentGateway createPlatformPaymentGateway() => MobilePaymentGateway();

class MobilePaymentGateway implements PaymentGateway {
  Razorpay? _razorpay;
  PaymentOutcomeGuard? _current;

  Razorpay _sdk() {
    final sdk = _razorpay;
    if (sdk != null) return sdk;
    final created = Razorpay()
      ..on(Razorpay.EVENT_PAYMENT_SUCCESS, _onSuccess)
      ..on(Razorpay.EVENT_PAYMENT_ERROR, _onError)
      ..on(Razorpay.EVENT_EXTERNAL_WALLET, _onExternalWallet);
    _razorpay = created;
    return created;
  }

  @override
  Future<void> open(PaymentRequest request, PaymentCallbacks callbacks) async {
    final guard = PaymentOutcomeGuard(callbacks);
    _current = guard;
    try {
      _sdk().open({
        'key': request.keyId,
        'amount': request.amountInPaise,
        'currency': request.currency,
        'order_id': request.orderId,
        'name': request.name,
        'description': request.description,
        'prefill': {'contact': request.contact, 'email': request.email},
        'theme': {'color': '#6C63FF'},
      });
    } catch (e) {
      guard.failed(PaymentFailure(message: 'Could not open payment: $e'));
    }
  }

  void _onSuccess(PaymentSuccessResponse r) {
    final orderId = r.orderId, paymentId = r.paymentId, signature = r.signature;
    if (orderId == null || paymentId == null || signature == null) {
      _current?.failed(const PaymentFailure(message: 'Payment response was incomplete. Please contact support.'));
      return;
    }
    _current?.succeeded(PaymentSuccess(orderId: orderId, paymentId: paymentId, signature: signature));
  }

  void _onError(PaymentFailureResponse r) {
    if (r.code == Razorpay.PAYMENT_CANCELLED) {
      _current?.cancelled();
    } else {
      _current?.failed(PaymentFailure(
        code: r.code?.toString(),
        message: r.message ?? 'Payment failed. Please try again.',
      ));
    }
  }

  void _onExternalWallet(ExternalWalletResponse r) {
    _current?.failed(const PaymentFailure(
      code: 'EXTERNAL_WALLET',
      message: 'External wallet payment is not supported. Please use a card or UPI.',
    ));
  }

  @override
  void dispose() {
    _razorpay?.clear();
    _razorpay = null;
  }
}
