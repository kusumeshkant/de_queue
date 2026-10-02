// Web gateway — Razorpay Standard Checkout (checkout.js) via dart:js_interop.
// Never imports razorpay_flutter, so web builds contain no plugin channel calls.
// checkout.js is injected on the first checkout, not in index.html, so pages
// that never pay never load third-party script.
import 'dart:async';
import 'dart:js_interop';
import 'dart:js_interop_unsafe';

import 'package:web/web.dart' as web;

import 'payment_gateway.dart';
import 'payment_outcome.dart';

PaymentGateway createPlatformPaymentGateway() => WebPaymentGateway();

const _checkoutJsUrl = 'https://checkout.razorpay.com/v1/checkout.js';
const _loadTimeout = Duration(seconds: 15);

@JS('Razorpay')
extension type _RazorpayCheckout._(JSObject _) implements JSObject {
  external factory _RazorpayCheckout(JSObject options);
  external void open();
  external void on(String event, JSFunction handler);
}

Future<void>? _checkoutJsLoad;

/// Loads checkout.js once; concurrent callers share the same load. A failed
/// load is forgotten so the next checkout can retry.
Future<void> _ensureCheckoutJs() {
  if (globalContext.has('Razorpay')) return Future.value();
  return _checkoutJsLoad ??= _injectCheckoutJs().timeout(_loadTimeout).catchError((Object e) {
    _checkoutJsLoad = null;
    throw e;
  });
}

Future<void> _injectCheckoutJs() {
  final done = Completer<void>();
  final script = web.HTMLScriptElement()
    ..src = _checkoutJsUrl
    ..async = true;
  script.onload = ((web.Event _) {
    if (!done.isCompleted) done.complete();
  }).toJS;
  script.onerror = ((web.Event _) {
    if (!done.isCompleted) done.completeError(StateError('checkout.js failed to load'));
  }).toJS;
  web.document.head!.append(script);
  return done.future;
}

Map<String, Object?> _toDartMap(JSAny? value) {
  final dart = value?.dartify();
  if (dart is Map) return dart.map((k, v) => MapEntry(k.toString(), v));
  return const {};
}

class WebPaymentGateway implements PaymentGateway {
  @override
  Future<void> open(PaymentRequest request, PaymentCallbacks callbacks) async {
    final guard = PaymentOutcomeGuard(callbacks);
    try {
      await _ensureCheckoutJs();
    } catch (_) {
      guard.failed(const PaymentFailure(
        code: 'CHECKOUT_UNAVAILABLE',
        message: 'Could not load the payment page. Check your connection or disable ad blockers, then try again.',
      ));
      return;
    }

    final prefill = JSObject()
      ..['contact'] = request.contact.toJS
      ..['email'] = request.email.toJS;
    final theme = JSObject()..['color'] = '#6C63FF'.toJS;
    final modal = JSObject()
      ..['ondismiss'] = (() {
        guard.dismissed();
      }).toJS;

    final options = JSObject()
      ..['key'] = request.keyId.toJS
      ..['amount'] = request.amountInPaise.toJS
      ..['currency'] = request.currency.toJS
      ..['order_id'] = request.orderId.toJS
      ..['name'] = request.name.toJS
      ..['description'] = request.description.toJS
      ..['prefill'] = prefill
      ..['theme'] = theme
      ..['modal'] = modal
      ..['handler'] = ((JSAny? response) {
        final success = paymentSuccessFromCheckout(_toDartMap(response));
        if (success == null) {
          guard.failed(const PaymentFailure(message: 'Payment response was incomplete. Please contact support.'));
        } else {
          guard.succeeded(success);
        }
      }).toJS;

    try {
      final checkout = _RazorpayCheckout(options);
      checkout.on('payment.failed', ((JSAny? response) {
        guard.attemptFailed(paymentFailureFromCheckout(_toDartMap(response)));
      }).toJS);
      checkout.open();
    } catch (e) {
      guard.failed(PaymentFailure(code: 'CHECKOUT_ERROR', message: 'Could not open payment: $e'));
    }
  }

  @override
  void dispose() {}
}
