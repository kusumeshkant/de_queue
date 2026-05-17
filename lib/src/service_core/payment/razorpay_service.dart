import 'package:dq_app/src/constants/app_config.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';

class RazorpayService {
  final Razorpay _razorpay = Razorpay();

  void registerCallbacks({
    required void Function(PaymentSuccessResponse) onSuccess,
    required void Function(PaymentFailureResponse) onError,
    required void Function(ExternalWalletResponse) onExternalWallet,
  }) {
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, onSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, onError);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, onExternalWallet);
  }

  void openPaymentSheet({
    required String razorpayOrderId,
    required int amountInPaise,
    String contact = '',
    String description = 'Cart Checkout',
  }) {
    final options = {
      'key': AppConfig.razorpayKeyId,
      'amount': amountInPaise,
      'order_id': razorpayOrderId,
      'name': 'DQ App',
      'description': description,
      'prefill': {'contact': contact, 'email': ''},
      'theme': {'color': '#6C63FF'},
    };
    _razorpay.open(options);
  }

  void dispose() {
    _razorpay.clear();
  }
}
