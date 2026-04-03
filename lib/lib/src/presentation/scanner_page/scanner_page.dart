import 'dart:ui';
import 'package:dq_app/src/domain/entity/store_entity.dart';
import 'package:dq_app/src/presentation/cart/cart_controller.dart';
import 'package:dq_app/src/presentation/cart/cart_page.dart';
import 'package:dq_app/src/presentation/dashBoard/dashboard_view_model.dart';
import 'package:dq_app/src/presentation/scanner_page/scanner_controller.dart';
import 'package:dq_app/src/presentation/scanner_page/widgets/scanner_overlay.dart';
import 'package:dq_app/widgets/themed_background.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

const _kScanLineColor = Color(0xFF00E676);
const _kSuccessColor = Color(0xFF00E676);
const _kErrorColor = Color(0xFFFF5252);
const _kBoxSize = 270.0;

class ScannerPage extends StatefulWidget {
  const ScannerPage({super.key});

  @override
  State<ScannerPage> createState() => _ScannerPageState();
}

class _ScannerPageState extends State<ScannerPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _scanLineController;
  late Animation<double> _scanLineAnimation;
  final MobileScannerController _mobileScannerController =
      MobileScannerController();
  bool _torchOn = false;

  @override
  void initState() {
    super.initState();
    _scanLineController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);
    _scanLineAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _scanLineController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _scanLineController.dispose();
    _mobileScannerController.dispose();
    super.dispose();
  }

  StoreEntity? _selectedStore() {
    try {
      if (Get.isRegistered<DashboardController>()) {
        final dc = Get.find<DashboardController>();
        final id = dc.selectedStoreId.value;
        return dc.stores.firstWhereOrNull((s) => s.id == id);
      }
    } catch (_) {}
    return null;
  }

  int _cartCount() {
    try {
      if (Get.isRegistered<CartController>()) {
        return Get.find<CartController>()
            .items
            .fold(0, (sum, i) => sum + i.quantity);
      }
    } catch (_) {}
    return 0;
  }

  String _badgeLabel(int count) => count > 10 ? '10+' : '$count';

  @override
  Widget build(BuildContext context) {
    final c = Get.find<ScannerController>();
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    final double scanBoxTop = (screenHeight - _kBoxSize) / 2;
    final double scanBoxBottom = scanBoxTop + _kBoxSize;

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // ── 1. Camera ─────────────────────────────────────────────────
          MobileScanner(
            controller: _mobileScannerController,
            onDetect: (capture) {
              final barcode = capture.barcodes.first.rawValue;
              if (barcode != null) c.onBarcodeDetected(barcode);
            },
          ),

          // ── 2. Dark overlay + corner brackets ─────────────────────────
          const ScannerOverlay(),

          // ── 3. Animated scan line ──────────────────────────────────────
          AnimatedBuilder(
            animation: _scanLineAnimation,
            builder: (context, _) {
              final lineY =
                  scanBoxTop + (_scanLineAnimation.value * (_kBoxSize - 10));
              return Positioned(
                top: lineY,
                left: (screenWidth - (_kBoxSize - 20)) / 2,
                child: Container(
                  width: _kBoxSize - 20,
                  height: 2.5,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [
                        Colors.transparent,
                        _kScanLineColor,
                        _kScanLineColor,
                        Colors.transparent,
                      ],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: _kScanLineColor.withValues(alpha: 0.6),
                        blurRadius: 8,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                ),
              );
            },
          ),

          // ── 4. Top section — back button + store info card ────────────
          SafeArea(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Back button row
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 10, 16, 0),
                  child: _GlassCircleButton(
                    icon: Icons.arrow_back_ios_new,
                    iconColor: Colors.white,
                    onPressed: () => Navigator.pop(context),
                  ),
                ),

                const SizedBox(height: 12),

                // Store info card
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Obx(() {
                    final store = _selectedStore();
                    final name = store?.name ??
                        (Get.isRegistered<DashboardController>()
                            ? Get.find<DashboardController>()
                                .selectedStoreName
                                .value
                            : '');
                    final address = store?.address ??
                        (Get.isRegistered<DashboardController>()
                            ? Get.find<DashboardController>()
                                .selectedStoreAddress
                                .value
                            : '');
                    final code = store?.storeCode ?? '';

                    if (name.isEmpty) return const SizedBox.shrink();

                    return ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 24, sigmaY: 24),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 14, vertical: 12),
                          decoration: BoxDecoration(
                            color: Colors.black.withValues(alpha: 0.50),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: Colors.white.withValues(alpha: 0.15),
                              width: 1,
                            ),
                          ),
                          child: Row(
                            children: [
                              // Store icon
                              Container(
                                width: 38,
                                height: 38,
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.10),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.store_rounded,
                                  color: Colors.white,
                                  size: 20,
                                ),
                              ),
                              const SizedBox(width: 10),

                              // Name + address
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      name,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    if (address.isNotEmpty) ...[
                                      const SizedBox(height: 2),
                                      Text(
                                        address,
                                        style: TextStyle(
                                          color: Colors.white
                                              .withValues(alpha: 0.60),
                                          fontSize: 11,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ],
                                  ],
                                ),
                              ),

                              // Store code badge
                              if (code.isNotEmpty) ...[
                                const SizedBox(width: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color:
                                        Colors.white.withValues(alpha: 0.12),
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(
                                      color:
                                          Colors.white.withValues(alpha: 0.20),
                                    ),
                                  ),
                                  child: Text(
                                    code,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600,
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ),
                    );
                  }),
                ),
              ],
            ),
          ),

          // ── 5. Hint text below scan box ───────────────────────────────
          Positioned(
            top: scanBoxBottom + 20,
            left: 0,
            right: 0,
            child: const Text(
              'Align QR code within the frame',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white60, fontSize: 13),
            ),
          ),

          // ── 6. Bottom — feedback card + torch/cart buttons ────────────
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Feedback card animates in above the button row
                Obx(() {
                  final feedback = c.scanFeedback.value;
                  final isVisible = feedback.isNotEmpty;
                  final isSuccess = feedback == 'success';
                  final cartCount = _cartCount();

                  return AnimatedSize(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeOutCubic,
                    child: ClipRect(
                      child: SizedBox(
                        height: isVisible ? null : 0,
                        child: ClipRRect(
                          borderRadius: const BorderRadius.vertical(
                              top: Radius.circular(20)),
                          child: BackdropFilter(
                            filter: ImageFilter.blur(sigmaX: 28, sigmaY: 28),
                            child: Container(
                              width: double.infinity,
                              padding:
                                  const EdgeInsets.fromLTRB(16, 14, 16, 14),
                              decoration: BoxDecoration(
                                color: Colors.black.withValues(alpha: 0.65),
                                borderRadius: const BorderRadius.vertical(
                                    top: Radius.circular(20)),
                                border: Border(
                                  top: BorderSide(
                                    color: (isSuccess
                                            ? _kSuccessColor
                                            : _kErrorColor)
                                        .withValues(alpha: 0.7),
                                    width: 1.5,
                                  ),
                                ),
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    width: 42,
                                    height: 42,
                                    decoration: BoxDecoration(
                                      color: (isSuccess
                                              ? _kSuccessColor
                                              : _kErrorColor)
                                          .withValues(alpha: 0.15),
                                      shape: BoxShape.circle,
                                    ),
                                    child: Icon(
                                      isSuccess
                                          ? Icons.check_circle_rounded
                                          : Icons.error_rounded,
                                      color: isSuccess
                                          ? _kSuccessColor
                                          : _kErrorColor,
                                      size: 26,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: isSuccess
                                        ? Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Text(
                                                c.scanFeedbackName.value,
                                                style: const TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 15,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                              const SizedBox(height: 3),
                                              Row(
                                                children: [
                                                  Text(
                                                    '₹${c.scanFeedbackPrice.value.toStringAsFixed(0)}',
                                                    style: TextStyle(
                                                      color: Colors.white
                                                          .withValues(
                                                              alpha: 0.65),
                                                      fontSize: 13,
                                                    ),
                                                  ),
                                                  const SizedBox(width: 10),
                                                  Container(
                                                    padding: const EdgeInsets
                                                        .symmetric(
                                                        horizontal: 8,
                                                        vertical: 2),
                                                    decoration: BoxDecoration(
                                                      color: _kSuccessColor
                                                          .withValues(
                                                              alpha: 0.15),
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              10),
                                                    ),
                                                    child: Text(
                                                      '${_badgeLabel(cartCount)} in cart',
                                                      style: const TextStyle(
                                                        color: _kSuccessColor,
                                                        fontSize: 11,
                                                        fontWeight:
                                                            FontWeight.w600,
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ],
                                          )
                                        : Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              const Text(
                                                'Product Not Found',
                                                style: TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 15,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                              const SizedBox(height: 3),
                                              Text(
                                                c.scanFeedbackMessage.value,
                                                style: TextStyle(
                                                  color: Colors.white
                                                      .withValues(alpha: 0.65),
                                                  fontSize: 13,
                                                ),
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ],
                                          ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                }),

                // ── Button row — torch (left) + cart (right) ───────────
                SafeArea(
                  top: false,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(24, 14, 24, 24),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Torch toggle
                        _GlassCircleButton(
                          icon: _torchOn ? Icons.flash_off : Icons.flash_on,
                          iconColor: _torchOn
                              ? const Color(0xFFFFD54F)
                              : Colors.white,
                          onPressed: () {
                            setState(() => _torchOn = !_torchOn);
                            _mobileScannerController.toggleTorch();
                          },
                        ),

                        // Cart button with badge
                        Obx(() {
                          final count = _cartCount();
                          return SizedBox(
                            width: 52,
                            height: 52,
                            child: Stack(
                              clipBehavior: Clip.none,
                              children: [
                                _GlassCircleButton(
                                  icon: Icons.shopping_cart_outlined,
                                  iconColor: Colors.white,
                                  onPressed: () => Get.to(() => const ThemedBackground(child: CartPage())),
                                ),
                                if (count > 0)
                                  Positioned(
                                    top: -5,
                                    right: -5,
                                    child: Container(
                                      constraints: const BoxConstraints(
                                          minWidth: 20, minHeight: 20),
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 4, vertical: 2),
                                      decoration: const BoxDecoration(
                                        color: Colors.red,
                                        shape: BoxShape.circle,
                                      ),
                                      child: Text(
                                        _badgeLabel(count),
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 9,
                                          fontWeight: FontWeight.bold,
                                        ),
                                        textAlign: TextAlign.center,
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          );
                        }),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
// Glass circle button
// ─────────────────────────────────────────────
class _GlassCircleButton extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final VoidCallback onPressed;

  const _GlassCircleButton({
    required this.icon,
    required this.iconColor,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: ClipOval(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
          child: Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.38),
              shape: BoxShape.circle,
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.22),
                width: 1,
              ),
            ),
            child: Icon(icon, color: iconColor, size: 22),
          ),
        ),
      ),
    );
  }
}
