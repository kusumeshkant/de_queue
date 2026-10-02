import 'package:dq_app/src/constants/app_config.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:get/get.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';

class RazorpayService {
  // Null on web — razorpay_flutter has no web implementation.
  Razorpay? _razorpay;

  RazorpayService() {
    if (!kIsWeb) _razorpay = Razorpay();
  }

  void registerCallbacks({
    required void Function(PaymentSuccessResponse) onSuccess,
    required void Function(PaymentFailureResponse) onError,
    required void Function(ExternalWalletResponse) onExternalWallet,
  }) {
    if (kIsWeb) return;
    _razorpay!.on(Razorpay.EVENT_PAYMENT_SUCCESS, onSuccess);
    _razorpay!.on(Razorpay.EVENT_PAYMENT_ERROR, onError);
    _razorpay!.on(Razorpay.EVENT_EXTERNAL_WALLET, onExternalWallet);
  }

  void openPaymentSheet({
    required String razorpayOrderId,
    required int amountInPaise,
    String contact = '',
    String description = 'Cart Checkout',
  }) {
    if (kIsWeb) {
      Get.snackbar(
        'Mobile Only',
        'Payment is only supported on the mobile app. Please use the DQ mobile app to complete checkout.',
        duration: const Duration(seconds: 5),
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }
    final options = {
      'key': AppConfig.razorpayKeyId,
      'amount': amountInPaise,
      'order_id': razorpayOrderId,
      'name': 'DQ App',
      'description': description,
      'prefill': {'contact': contact, 'email': ''},
      'theme': {'color': '#6C63FF'},
    };
    _razorpay!.open(options);
  }

  void dispose() {
    if (kIsWeb) return;
    _razorpay!.clear();
  }
}
