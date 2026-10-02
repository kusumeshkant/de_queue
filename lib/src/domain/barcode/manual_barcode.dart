/// Validation for barcodes typed in by the customer.
///
/// The catalogue holds two shapes of barcode:
///  * retail EAN/UPC/GTIN codes — all digits, 8, 12, 13 or 14 long
///    (e.g. 8901030870011);
///  * store-assigned codes — letters, digits and hyphens
///    (e.g. ZUD0000000001 in production, UAT-0001 in UAT).
/// So an all-digit entry must be a valid EAN/UPC/GTIN length, and anything
/// else may only use A–Z, 0–9 and '-', 4–32 characters. Input is trimmed and
/// upper-cased (stored barcodes are upper-case).
class ManualBarcodeValidation {
  final String? barcode; // normalised, when valid
  final String? error; // user-facing message, when invalid

  const ManualBarcodeValidation._(this.barcode, this.error);
  const ManualBarcodeValidation.valid(String barcode) : this._(barcode, null);
  const ManualBarcodeValidation.invalid(String error) : this._(null, error);

  bool get isValid => barcode != null;
}

const _retailDigitLengths = {8, 12, 13, 14};
const _minLength = 4;
const _maxLength = 32;
final _digitsOnly = RegExp(r'^[0-9]+$');
final _allowed = RegExp(r'^[A-Z0-9-]+$');

ManualBarcodeValidation validateManualBarcode(String raw) {
  final code = raw.trim().toUpperCase();
  if (code.isEmpty) {
    return const ManualBarcodeValidation.invalid('Enter the barcode printed under the bars.');
  }
  if (_digitsOnly.hasMatch(code)) {
    if (!_retailDigitLengths.contains(code.length)) {
      return const ManualBarcodeValidation.invalid(
          'A numeric barcode has 8, 12, 13 or 14 digits — check the number and try again.');
    }
    return ManualBarcodeValidation.valid(code);
  }
  if (!_allowed.hasMatch(code)) {
    return const ManualBarcodeValidation.invalid('Use only letters, numbers and hyphens (no spaces).');
  }
  if (code.length < _minLength || code.length > _maxLength) {
    return const ManualBarcodeValidation.invalid('That barcode is too short or too long.');
  }
  return ManualBarcodeValidation.valid(code);
}
