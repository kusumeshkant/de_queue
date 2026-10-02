// Picks the platform gateway at compile time. Mobile/desktop builds compile
// gateway_mobile.dart (razorpay_flutter); web builds compile gateway_web.dart
// (checkout.js) and never see razorpay_flutter at all.
import 'payment_gateway.dart';
import 'gateway_stub.dart'
    if (dart.library.io) 'gateway_mobile.dart'
    if (dart.library.js_interop) 'gateway_web.dart' as platform;

PaymentGateway createPaymentGateway() => platform.createPlatformPaymentGateway();
