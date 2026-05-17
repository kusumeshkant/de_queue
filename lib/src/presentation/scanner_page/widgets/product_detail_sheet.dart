import 'package:dq_app/design_system/design_system.dart';
import 'package:dq_app/src/domain/entity/product_entity.dart';
import 'package:dq_app/src/presentation/scanner_page/product_detail_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

const _kGreen = Color(0xFF00E676);
const _kTag = 'product_detail';

class ProductDetailSheet extends StatefulWidget {
  final ProductEntity product;

  const ProductDetailSheet({super.key, required this.product});

  @override
  State<ProductDetailSheet> createState() => _ProductDetailSheetState();
}

class _ProductDetailSheetState extends State<ProductDetailSheet> {
  late final ProductDetailController _c;

  @override
  void initState() {
    super.initState();
    _c = Get.put(ProductDetailController(), tag: _kTag);
  }

  @override
  void dispose() {
    Get.delete<ProductDetailController>(tag: _kTag, force: true);
    super.dispose();
  }

  ProductEntity get product => widget.product;

  bool get _outOfStock => product.stock <= 0;
  bool get _hasMrpDiscount =>
      product.mrp != null && product.mrp! > product.price;
  int get _discountPct =>
      (((product.mrp! - product.price) / product.mrp!) * 100).round();

  Future<void> _handleAddToCart() async {
    final added = await _c.addToCart(product);
    if (!mounted) return;

    if (added > 0) {
      Get.back();
      Get.snackbar(
        '',
        '',
        titleText: Row(
          children: [
            const Icon(Icons.check_circle_rounded, color: _kGreen, size: 18),
            const SizedBox(width: 6),
            Expanded(
              child: Text(
                '${product.name} added',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        messageText: Text(
          '$added× · ₹${(product.price * added).toStringAsFixed(0)}',
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.65),
            fontSize: 12,
          ),
        ),
        backgroundColor: AppColors.scannerSnackSurface,
        snackPosition: SnackPosition.BOTTOM,
        margin: const EdgeInsets.all(16),
        borderRadius: 12,
        duration: const Duration(seconds: 2),
        isDismissible: true,
      );
    } else {
      Get.snackbar(
        'Stock limit reached',
        'Cannot add more ${product.name}',
        backgroundColor: AppColors.warning,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
        margin: const EdgeInsets.all(16),
        borderRadius: 12,
        duration: const Duration(seconds: 2),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final mq = MediaQuery.of(context);

    return Container(
      constraints: BoxConstraints(maxHeight: mq.size.height * 0.88),
      decoration: BoxDecoration(
        color: AppColors.scannerSheetSurface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // ── Drag handle ───────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.only(top: 12, bottom: 4),
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.28),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),

          // ── Scrollable content ────────────────────────────────────────
          Flexible(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Product image
                  _ProductImage(imageUrl: product.imageUrl),
                  const SizedBox(height: 20),

                  // Name row + stock badge
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          product.name,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            height: 1.25,
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      _StockBadge(stock: product.stock),
                    ],
                  ),

                  const SizedBox(height: 12),

                  // Price row
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.alphabetic,
                    children: [
                      Text(
                        '₹${product.price.toStringAsFixed(0)}',
                        style: const TextStyle(
                          color: _kGreen,
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (_hasMrpDiscount) ...[
                        const SizedBox(width: 10),
                        Text(
                          '₹${product.mrp!.toStringAsFixed(0)}',
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.38),
                            fontSize: 16,
                            decoration: TextDecoration.lineThrough,
                            decorationColor:
                                Colors.white.withValues(alpha: 0.38),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 7, vertical: 3),
                          decoration: BoxDecoration(
                            color: AppColors.warningSubtle,
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(
                                color: AppColors.warningBorder),
                          ),
                          child: Text(
                            '$_discountPct% off',
                            style: const TextStyle(
                              color: AppColors.warning,
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),

                  // SKU
                  if (product.sku != null && product.sku!.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      'SKU: ${product.sku}',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.35),
                        fontSize: 11,
                      ),
                    ),
                  ],

                  // Description
                  if (product.description != null &&
                      product.description!.isNotEmpty) ...[
                    const SizedBox(height: 14),
                    Text(
                      product.description!,
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.65),
                        fontSize: 14,
                        height: 1.55,
                      ),
                      maxLines: 4,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],

                  const SizedBox(height: 24),
                  const Divider(color: Colors.white12),
                  const SizedBox(height: 16),

                  // Quantity selector (hidden when out of stock)
                  if (!_outOfStock)
                    Obx(
                      () => Row(
                        children: [
                          Text(
                            'Quantity',
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.8),
                              fontSize: 15,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const Spacer(),
                          _QuantitySelector(
                            quantity: _c.quantity,
                            maxStock: product.stock,
                            onDecrement: _c.decrement,
                            onIncrement: () => _c.increment(product.stock),
                          ),
                        ],
                      ),
                    ),

                  const SizedBox(height: 8),
                ],
              ),
            ),
          ),

          // ── Action buttons ────────────────────────────────────────────
          Padding(
            padding: EdgeInsets.fromLTRB(
              20,
              8,
              20,
              mq.viewInsets.bottom + mq.padding.bottom + 20,
            ),
            child: Row(
              children: [
                // Cancel
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Get.back(),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.white,
                      side: BorderSide(
                          color: Colors.white.withValues(alpha: 0.28)),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14)),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: const Text(
                      'Cancel',
                      style: TextStyle(
                          fontSize: 15, fontWeight: FontWeight.w600),
                    ),
                  ),
                ),
                const SizedBox(width: 12),

                // Add to Cart
                Expanded(
                  flex: 2,
                  child: Obx(() {
                    final adding = _c.isAdding;
                    return AnimatedScale(
                      scale: adding ? 0.96 : 1.0,
                      duration: const Duration(milliseconds: 100),
                      child: ElevatedButton(
                        onPressed: _outOfStock
                            ? null
                            : (adding ? null : _handleAddToCart),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _kGreen,
                          foregroundColor: Colors.black,
                          disabledBackgroundColor: AppColors.scannerDisabled,
                          disabledForegroundColor:
                              Colors.white.withValues(alpha: 0.4),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14)),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          elevation: 0,
                        ),
                        child: adding
                            ? const SizedBox(
                                width: 22,
                                height: 22,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2.5,
                                  color: Colors.black87,
                                ),
                              )
                            : Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(
                                      Icons.add_shopping_cart_rounded,
                                      size: 18),
                                  const SizedBox(width: 6),
                                  Text(
                                    _outOfStock
                                        ? 'Out of Stock'
                                        : 'Add to Cart',
                                    style: const TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                      ),
                    );
                  }),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Product image with fallback
// ─────────────────────────────────────────────────────────────────────────────
class _ProductImage extends StatelessWidget {
  final String? imageUrl;
  const _ProductImage({this.imageUrl});

  @override
  Widget build(BuildContext context) {
    final bool hasImage =
        imageUrl != null && imageUrl!.isNotEmpty;

    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: SizedBox(
        height: 180,
        width: double.infinity,
        child: hasImage
            ? Image.network(
                imageUrl!,
                fit: BoxFit.cover,
                loadingBuilder: (_, child, progress) {
                  if (progress == null) return child;
                  return const _ImagePlaceholder();
                },
                errorBuilder: (_, __, ___) => const _ImagePlaceholder(),
              )
            : const _ImagePlaceholder(),
      ),
    );
  }
}

class _ImagePlaceholder extends StatelessWidget {
  const _ImagePlaceholder();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white.withValues(alpha: 0.06),
      child: Icon(
        Icons.inventory_2_rounded,
        size: 64,
        color: Colors.white.withValues(alpha: 0.18),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Stock badge
// ─────────────────────────────────────────────────────────────────────────────
class _StockBadge extends StatelessWidget {
  final int stock;
  const _StockBadge({required this.stock});

  @override
  Widget build(BuildContext context) {
    final bool outOfStock = stock <= 0;
    final bool lowStock = stock > 0 && stock <= 5;

    final Color color = outOfStock
        ? AppColors.error
        : lowStock
            ? AppColors.warning
            : _kGreen;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.4)),
      ),
      child: Text(
        outOfStock
            ? 'Out of stock'
            : lowStock
                ? 'Only $stock left'
                : '$stock in stock',
        style: TextStyle(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Quantity selector  [–] count [+]
// ─────────────────────────────────────────────────────────────────────────────
class _QuantitySelector extends StatelessWidget {
  final int quantity;
  final int maxStock;
  final VoidCallback onDecrement;
  final VoidCallback onIncrement;

  const _QuantitySelector({
    required this.quantity,
    required this.maxStock,
    required this.onDecrement,
    required this.onIncrement,
  });

  @override
  Widget build(BuildContext context) {
    final bool atMin = quantity <= 1;
    final bool atMax = maxStock > 0 && quantity >= maxStock;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.07),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _QtyButton(
            icon: Icons.remove,
            enabled: !atMin,
            onTap: onDecrement,
          ),
          SizedBox(
            width: 38,
            child: Text(
              '$quantity',
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          _QtyButton(
            icon: Icons.add,
            enabled: !atMax,
            onTap: onIncrement,
          ),
        ],
      ),
    );
  }
}

class _QtyButton extends StatelessWidget {
  final IconData icon;
  final bool enabled;
  final VoidCallback onTap;

  const _QtyButton({
    required this.icon,
    required this.enabled,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: enabled ? onTap : null,
      child: Container(
        width: 40,
        height: 40,
        alignment: Alignment.center,
        child: Icon(
          icon,
          size: 18,
          color: enabled
              ? Colors.white
              : Colors.white.withValues(alpha: 0.25),
        ),
      ),
    );
  }
}
