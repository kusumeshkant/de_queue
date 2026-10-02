/// Money for display. Amounts the customer sees must equal what the server
/// computes and charges, so everything here works in whole paise and mirrors
/// the backend (razorpayService.createRazorpayOrderFromCart and
/// discountService._calcDiscount). The server remains the only source of what
/// is charged; these numbers are for showing it.
library;

const double gstRate = 0.18;

/// Rupees → whole paise, rounding like the server's `Math.round(rupees * 100)`.
int toPaise(num rupees) => (rupees * 100).round();

/// "₹249" for whole rupees, otherwise exact paise: "₹44.82", "₹293.82".
/// Negative amounts get a leading minus; callers that show a "−₹" savings
/// label pass the positive amount.
String formatRupees(num rupees) => formatPaise(toPaise(rupees));

String formatPaise(int paise) {
  final sign = paise < 0 ? '-' : '';
  final abs = paise.abs();
  final whole = abs ~/ 100;
  final cents = abs % 100;
  return cents == 0 ? '$sign₹$whole' : '$sign₹$whole.${cents.toString().padLeft(2, '0')}';
}

/// Cart totals computed exactly as the server will compute the order:
/// subtotal → staff discount (percent of the pre-tax subtotal) → 18% GST on
/// the discounted subtotal → grand total, all in paise.
class CartTotals {
  final int subtotalPaise;
  final int discountPaise;
  final int taxPaise;

  const CartTotals._(this.subtotalPaise, this.discountPaise, this.taxPaise);

  /// [lines] are (unit price in rupees, quantity). [discountPercent] is the
  /// validated staff discount, if one is applied.
  factory CartTotals.compute(Iterable<(num price, int quantity)> lines, {num? discountPercent}) {
    var subtotal = 0;
    for (final (price, quantity) in lines) {
      subtotal += toPaise(price) * quantity;
    }

    var discounted = subtotal;
    if (discountPercent != null && discountPercent > 0) {
      // Server: discountAmount = Math.round(subtotalRupees * percent) / 100,
      // finalAmount = max(0, subtotalRupees - discountAmount),
      // discountedPaise = min(subtotal, max(0, Math.round(finalAmount * 100))).
      final subtotalRupees = subtotal / 100;
      final discountRupees = (subtotalRupees * discountPercent).round() / 100;
      final finalRupees = subtotalRupees - discountRupees < 0 ? 0 : subtotalRupees - discountRupees;
      discounted = toPaise(finalRupees).clamp(0, subtotal);
    }

    final tax = (discounted * gstRate).round();
    return CartTotals._(subtotal, subtotal - discounted, tax);
  }

  int get discountedPaise => subtotalPaise - discountPaise;
  int get grandTotalPaise => discountedPaise + taxPaise;

  double get subtotal => subtotalPaise / 100;
  double get discount => discountPaise / 100;
  double get tax => taxPaise / 100;
  double get grandTotal => grandTotalPaise / 100;
}
