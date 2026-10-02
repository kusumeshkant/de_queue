import 'package:dq_app/src/domain/entity/user_entity.dart';

/// Contact details pre-filled on the Razorpay checkout so the customer is not
/// asked for them again. Empty values are fine: Razorpay then asks the customer.
class CheckoutContact {
  final String contact;
  final String email;

  const CheckoutContact({this.contact = '', this.email = ''});

  static const empty = CheckoutContact();

  /// Keeps only values Razorpay will accept, so a malformed profile field
  /// never causes a checkout validation error.
  factory CheckoutContact.fromUser(UserEntity? user) {
    if (user == null) return empty;
    final phone = (user.phone ?? '').replaceAll(RegExp(r'[\s-]'), '');
    final email = (user.email ?? '').trim();
    return CheckoutContact(
      contact: RegExp(r'^\+?\d{10,15}$').hasMatch(phone) ? phone : '',
      email: RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(email) ? email : '',
    );
  }
}

typedef ProfileLoader = Future<UserEntity?> Function();

/// Loads the logged-in customer's contact details for checkout. Never throws
/// and never waits longer than [timeout]: a slow or failed profile lookup must
/// not hold up payment.
Future<CheckoutContact> loadCheckoutContact(
  ProfileLoader loader, {
  Duration timeout = const Duration(seconds: 3),
}) async {
  try {
    return CheckoutContact.fromUser(await loader().timeout(timeout));
  } catch (_) {
    return CheckoutContact.empty;
  }
}
