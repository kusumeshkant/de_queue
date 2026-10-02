import 'package:dq_app/src/domain/entity/product_entity.dart';
import 'package:dq_app/src/presentation/scanner_page/manual_barcode_lookup.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// "Can't scan? Enter barcode" — type the number printed under the bars.
///
/// Validates and looks the barcode up in the selected store. On a match it
/// hands the product to [onFound], which opens the normal product sheet where
/// the customer must still press "Add to Cart". Nothing is added from here.
class ManualBarcodeSheet extends StatefulWidget {
  final ManualBarcodeLookup lookup;
  final String storeId;
  final String storeName;
  final void Function(ProductEntity product) onFound;
  final VoidCallback onCancel;

  const ManualBarcodeSheet({
    super.key,
    required this.lookup,
    required this.storeId,
    required this.storeName,
    required this.onFound,
    required this.onCancel,
  });

  @override
  State<ManualBarcodeSheet> createState() => _ManualBarcodeSheetState();
}

class _ManualBarcodeSheetState extends State<ManualBarcodeSheet> {
  final _field = TextEditingController();
  String? _error;
  bool _busy = false;

  @override
  void dispose() {
    _field.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_busy) return;
    setState(() {
      _busy = true;
      _error = null;
    });
    final outcome = await widget.lookup.run(
      _field.text,
      storeId: widget.storeId,
      storeName: widget.storeName,
    );
    if (!mounted) return;
    setState(() => _busy = false);
    if (outcome.isFound) {
      widget.onFound(outcome.product!);
    } else {
      setState(() => _error = outcome.message);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Container(
        decoration: const BoxDecoration(
          color: Color(0xFF16181D),
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: const EdgeInsets.fromLTRB(20, 14, 20, 24),
        child: SafeArea(
          top: false,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.white24,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Enter barcode',
                style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              Text(
                'Type the number printed under the bars on the tag.',
                style: TextStyle(color: Colors.white.withValues(alpha: 0.6), fontSize: 13),
              ),
              const SizedBox(height: 16),
              TextField(
                key: const Key('manual-barcode-field'),
                controller: _field,
                autofocus: true,
                enabled: !_busy,
                textCapitalization: TextCapitalization.characters,
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'[A-Za-z0-9-]')),
                  LengthLimitingTextInputFormatter(32),
                ],
                style: const TextStyle(color: Colors.white, fontSize: 18, letterSpacing: 1.2),
                decoration: InputDecoration(
                  hintText: 'e.g. 8901030870011',
                  hintStyle: TextStyle(color: Colors.white.withValues(alpha: 0.3)),
                  prefixIcon: const Icon(Icons.qr_code_2_rounded, color: Colors.white54),
                  filled: true,
                  fillColor: Colors.white.withValues(alpha: 0.06),
                  errorText: _error,
                  errorMaxLines: 3,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
                onSubmitted: (_) => _submit(),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: TextButton(
                      key: const Key('manual-barcode-cancel'),
                      onPressed: _busy ? null : widget.onCancel,
                      child: const Text('Cancel', style: TextStyle(color: Colors.white70)),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 2,
                    child: FilledButton(
                      key: const Key('manual-barcode-find'),
                      onPressed: _busy ? null : _submit,
                      child: _busy
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                            )
                          : const Text('Find product'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
