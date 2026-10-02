// Fallback for platforms with neither dart:io nor dart:js_interop.
import 'payment_gateway.dart';

PaymentGateway createPlatformPaymentGateway() =>
    throw UnsupportedError('Payments are not supported on this platform');
