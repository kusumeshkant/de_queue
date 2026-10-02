// Unit tests for the platform-neutral payment outcome logic shared by the
// mobile (razorpay_flutter) and web (checkout.js) gateways.
import 'package:dq_app/src/service_core/payment/payment_gateway.dart';
import 'package:dq_app/src/service_core/payment/payment_outcome.dart';
import 'package:flutter_test/flutter_test.dart';

class _Recorder {
  final successes = <PaymentSuccess>[];
  final failures = <PaymentFailure>[];
  int cancels = 0;

  PaymentCallbacks get callbacks => PaymentCallbacks(
        onSuccess: successes.add,
        onFailure: failures.add,
        onCancelled: () => cancels++,
      );

  int get total => successes.length + failures.length + cancels;
}

const _ok = PaymentSuccess(orderId: 'order_1', paymentId: 'pay_1', signature: 'sig_1');
const _declined = PaymentFailure(code: 'BAD_REQUEST_ERROR', message: 'Your card was declined');

void main() {
  group('PaymentOutcomeGuard — exactly one outcome', () {
    test('success', () {
      final r = _Recorder();
      PaymentOutcomeGuard(r.callbacks).succeeded(_ok);
      expect(r.successes.single.paymentId, 'pay_1');
      expect(r.total, 1);
    });

    test('terminal failure (mobile error / checkout.js load failure)', () {
      final r = _Recorder();
      PaymentOutcomeGuard(r.callbacks).failed(_declined);
      expect(r.failures.single.message, 'Your card was declined');
      expect(r.total, 1);
    });

    test('cancel (mobile PAYMENT_CANCELLED)', () {
      final r = _Recorder();
      PaymentOutcomeGuard(r.callbacks).cancelled();
      expect(r.cancels, 1);
      expect(r.total, 1);
    });

    test('web: dismiss without any failed attempt is a cancellation', () {
      final r = _Recorder();
      PaymentOutcomeGuard(r.callbacks).dismissed();
      expect(r.cancels, 1);
      expect(r.total, 1);
    });

    test('web: failed attempt then dismiss resolves as that failure', () {
      final r = _Recorder();
      final g = PaymentOutcomeGuard(r.callbacks)..attemptFailed(_declined);
      expect(r.total, 0, reason: 'payment.failed keeps the sheet open — not final yet');
      g.dismissed();
      expect(r.failures.single.code, 'BAD_REQUEST_ERROR');
      expect(r.total, 1);
    });

    test('web: failed attempt then a successful retry is a success', () {
      final r = _Recorder();
      PaymentOutcomeGuard(r.callbacks)
        ..attemptFailed(_declined)
        ..succeeded(_ok);
      expect(r.successes, hasLength(1));
      expect(r.failures, isEmpty);
      expect(r.total, 1);
    });

    test('two failed attempts then dismiss reports the LAST failure', () {
      final r = _Recorder();
      PaymentOutcomeGuard(r.callbacks)
        ..attemptFailed(const PaymentFailure(message: 'first'))
        ..attemptFailed(const PaymentFailure(message: 'second'))
        ..dismissed();
      expect(r.failures.single.message, 'second');
    });

    test('one-outcome guard: success followed by dismiss/failure/cancel stays a single success', () {
      final r = _Recorder();
      PaymentOutcomeGuard(r.callbacks)
        ..succeeded(_ok)
        ..dismissed()
        ..failed(_declined)
        ..cancelled()
        ..succeeded(_ok);
      expect(r.successes, hasLength(1));
      expect(r.total, 1);
    });

    test('one-outcome guard: a late success after cancel is ignored', () {
      final r = _Recorder();
      final g = PaymentOutcomeGuard(r.callbacks)..cancelled();
      g.succeeded(_ok);
      expect(r.cancels, 1);
      expect(r.successes, isEmpty);
      expect(g.isResolved, isTrue);
    });

    test('attemptFailed after resolution changes nothing', () {
      final r = _Recorder();
      PaymentOutcomeGuard(r.callbacks)
        ..succeeded(_ok)
        ..attemptFailed(_declined)
        ..dismissed();
      expect(r.total, 1);
      expect(r.failures, isEmpty);
    });
  });

  group('checkout.js response mapping', () {
    test('success handler maps the three Razorpay fields', () {
      final s = paymentSuccessFromCheckout({
        'razorpay_payment_id': 'pay_X',
        'razorpay_order_id': 'order_X',
        'razorpay_signature': 'sig_X',
      });
      expect(s, isNotNull);
      expect([s!.orderId, s.paymentId, s.signature], ['order_X', 'pay_X', 'sig_X']);
    });

    test('a success response missing any field is NOT treated as paid', () {
      expect(paymentSuccessFromCheckout({'razorpay_payment_id': 'p', 'razorpay_order_id': 'o'}), isNull);
      expect(paymentSuccessFromCheckout({'razorpay_payment_id': 'p', 'razorpay_signature': 's'}), isNull);
      expect(paymentSuccessFromCheckout({'razorpay_order_id': 'o', 'razorpay_signature': 's'}), isNull);
      expect(paymentSuccessFromCheckout({'razorpay_payment_id': '', 'razorpay_order_id': 'o', 'razorpay_signature': 's'}), isNull);
      expect(paymentSuccessFromCheckout({}), isNull);
    });

    test('payment.failed maps code and description', () {
      final f = paymentFailureFromCheckout({
        'error': {'code': 'BAD_REQUEST_ERROR', 'description': 'Payment failed', 'reason': 'payment_failed'},
      });
      expect(f.code, 'BAD_REQUEST_ERROR');
      expect(f.message, 'Payment failed');
    });

    test('payment.failed with a missing or odd error object still yields a readable failure', () {
      expect(paymentFailureFromCheckout({}).message, 'Payment failed. Please try again.');
      expect(paymentFailureFromCheckout({'error': 'x'}).message, 'Payment failed. Please try again.');
      final f = paymentFailureFromCheckout({'error': {'reason': 'payment_cancelled'}});
      expect(f.code, 'payment_cancelled');
      expect(f.message, 'Payment failed. Please try again.');
    });
  });
}
