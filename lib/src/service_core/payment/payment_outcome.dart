// Pure-Dart outcome logic shared by both gateways, kept free of platform
// imports so it can be unit-tested on the VM.
import 'payment_gateway.dart';

/// Turns a stream of SDK events into exactly ONE call on [PaymentCallbacks].
///
/// Razorpay Standard Checkout (web) reports a failed attempt with
/// `payment.failed` but keeps the sheet open so the customer can retry; the
/// final outcome is either the success `handler` or the sheet being dismissed.
/// So a failure is only *recorded* ([attemptFailed]); [dismissed] then resolves
/// it — as that failure if an attempt failed, otherwise as a cancellation.
/// Mobile reports terminal events directly ([succeeded] / [failed] / [cancelled]).
/// Whatever arrives first wins; every later event is ignored.
class PaymentOutcomeGuard {
  final PaymentCallbacks _callbacks;
  bool _resolved = false;
  PaymentFailure? _lastFailure;

  PaymentOutcomeGuard(this._callbacks);

  bool get isResolved => _resolved;

  void succeeded(PaymentSuccess success) {
    if (_resolved) return;
    _resolved = true;
    _callbacks.onSuccess(success);
  }

  /// A terminal failure (mobile error, checkout.js failed to load, bad response).
  void failed(PaymentFailure failure) {
    if (_resolved) return;
    _resolved = true;
    _callbacks.onFailure(failure);
  }

  void cancelled() {
    if (_resolved) return;
    _resolved = true;
    _callbacks.onCancelled();
  }

  /// A non-terminal failed attempt (web `payment.failed`). The sheet stays open.
  void attemptFailed(PaymentFailure failure) {
    if (_resolved) return;
    _lastFailure = failure;
  }

  /// The sheet was closed without a success.
  void dismissed() {
    final failure = _lastFailure;
    if (failure != null) {
      failed(failure);
    } else {
      cancelled();
    }
  }
}

/// Maps checkout.js's success-handler argument
/// `{razorpay_payment_id, razorpay_order_id, razorpay_signature}`.
/// Returns null if any field is missing — treated as a failure, never as paid.
PaymentSuccess? paymentSuccessFromCheckout(Map<String, Object?> response) {
  final paymentId = response['razorpay_payment_id'];
  final orderId = response['razorpay_order_id'];
  final signature = response['razorpay_signature'];
  if (paymentId is! String || paymentId.isEmpty) return null;
  if (orderId is! String || orderId.isEmpty) return null;
  if (signature is! String || signature.isEmpty) return null;
  return PaymentSuccess(orderId: orderId, paymentId: paymentId, signature: signature);
}

/// Maps checkout.js's `payment.failed` argument `{error: {code, description, reason}}`.
PaymentFailure paymentFailureFromCheckout(Map<String, Object?> response) {
  final error = response['error'];
  if (error is Map) {
    final code = error['code'];
    final description = error['description'];
    final reason = error['reason'];
    final message = (description is String && description.isNotEmpty)
        ? description
        : 'Payment failed. Please try again.';
    return PaymentFailure(
      code: code is String ? code : (reason is String ? reason : null),
      message: message,
    );
  }
  return const PaymentFailure(message: 'Payment failed. Please try again.');
}
