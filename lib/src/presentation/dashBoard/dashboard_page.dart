import 'dart:ui';

import 'package:dq_app/src/domain/entity/store_entity.dart';
import 'package:dq_app/src/l10n/translation_keys.dart';
import 'package:dq_app/src/presentation/cart/cart_controller.dart';
import 'package:dq_app/src/presentation/dashBoard/dashboard_view_model.dart';
import 'package:dq_app/src/theme/theme_controller.dart';
import 'package:dq_app/src/utils/dq_widgets/nearby_store_title_tile.dart';
import 'package:dq_app/src/utils/dq_widgets/screen_brightness_overlay.dart';
import 'package:dq_app/src/utils/dq_widgets/store_card.dart';
import 'package:dq_app/src/utils/dq_widgets/title_sub_heading.dart';
import 'package:dq_app/src/presentation/dashBoard/widgets/dashboard_header_banner.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  late final DashboardController _c;
  Worker? _loadWorker;

  @override
  void initState() {
    super.initState();
    _c = Get.find<DashboardController>();

    // Show store confirmation once after stores load
    _loadWorker = ever(_c.isLoading, (bool loading) {
      if (!loading && _c.stores.isNotEmpty && !_c.isStoreConfirmed.value) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) _showStoreConfirmation();
        });
      }
    });
  }

  @override
  void dispose() {
    _loadWorker?.dispose();
    super.dispose();
  }

  // ── Store selection with cart-clear guard ──────────────────────────────────

  void _trySelectStore(StoreEntity store) {
    // Same store — no-op
    if (store.id == _c.selectedStoreId.value) return;

    final cart = Get.find<CartController>();
    if (cart.items.isNotEmpty) {
      _showCartClearDialog(store);
    } else {
      _c.selectStore(store);
    }
  }

  void _showCartClearDialog(StoreEntity store) {
    final tc = Get.find<ThemeController>();

    Get.dialog(
      AlertDialog(
        backgroundColor:
            tc.isGreenTheme.value ? const Color(0xFF1A2B3C) : Colors.white,
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: Row(
          children: [
            Icon(Icons.warning_amber_rounded,
                color: Colors.orange.shade400, size: 22),
            const SizedBox(width: 8),
            Text(
              AppKeys.changeStoreTitle.tr,
              style: TextStyle(
                color: tc.textPrimary,
                fontSize: 17,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        content: Text(
          AppKeys.changeStoreBody.tr,
          style: TextStyle(color: tc.textSecondary, fontSize: 14),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text(AppKeys.cancel.tr,
                style: TextStyle(color: tc.textSecondary)),
          ),
          ElevatedButton(
            onPressed: () {
              Get.back();
              Get.find<CartController>().clearCart();
              _c.selectStore(store);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange.shade600,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
              elevation: 0,
            ),
            child: Text(AppKeys.clearAndChange.tr),
          ),
        ],
      ),
      barrierDismissible: false,
    );
  }

  // ── Store confirmation bottom sheet ────────────────────────────────────────

  void _showStoreConfirmation() {
    final tc = Get.find<ThemeController>();

    Get.bottomSheet(
      isDismissible: false,
      enableDrag: false,
      isScrollControlled: true,
      ClipRRect(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
          child: Obx(() {
            final isGreen = tc.isGreenTheme.value;
            return Container(
              padding: const EdgeInsets.fromLTRB(24, 20, 24, 36),
              decoration: BoxDecoration(
                color: isGreen
                    ? Colors.black.withValues(alpha: 0.75)
                    : Colors.white.withValues(alpha: 0.92),
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(24)),
                border: Border(
                  top: BorderSide(
                    color: tc.primary.withValues(alpha: 0.35),
                    width: 1.2,
                  ),
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: tc.textSecondary.withValues(alpha: 0.4),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      color: tc.primary.withValues(alpha: 0.15),
                      shape: BoxShape.circle,
                    ),
                    child:
                        Icon(Icons.store_rounded, color: tc.primary, size: 28),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    AppKeys.confirmStore.tr,
                    style: TextStyle(
                      color: tc.textPrimary,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    AppKeys.youAppearNear.tr,
                    style:
                        TextStyle(color: tc.textSecondary, fontSize: 13),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    _c.selectedStoreName.value,
                    style: TextStyle(
                      color: tc.primary,
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  if (_c.selectedStoreAddress.value.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      _c.selectedStoreAddress.value,
                      style:
                          TextStyle(color: tc.textSecondary, fontSize: 12),
                      textAlign: TextAlign.center,
                    ),
                  ],
                  const SizedBox(height: 28),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        _c.confirmCurrentStore();
                        Get.back();
                      },
                      icon: const Icon(Icons.check_circle_outline,
                          color: Colors.white, size: 20),
                      label: Text(
                        AppKeys.yesImHere.tr,
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 15,
                            fontWeight: FontWeight.w600),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: tc.primary,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14)),
                        elevation: 0,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: () => Get.back(),
                      icon: Icon(Icons.swap_horiz_rounded,
                          color: tc.textSecondary, size: 20),
                      label: Text(
                        AppKeys.changeStore.tr,
                        style: TextStyle(
                          color: tc.textSecondary,
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        side: BorderSide(
                            color: tc.cardBorder.withValues(alpha: 0.6)),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14)),
                      ),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    AppKeys.selectFromList.tr,
                    style:
                        TextStyle(color: tc.textSecondary, fontSize: 11),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            );
          }),
        ),
      ),
    );
  }

  // ── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return ScreenBrightnessOverlay(
      darkness: 0.1,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: Obx(() {
          if (_c.isLoading.value) {
            return const Center(child: CircularProgressIndicator());
          }

          return CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: DashboardHeaderBanner(
                  searchController: _c.searchController,
                  storeList: _c.storeNames,
                  storeName: _c.selectedStoreName.value,
                  storeAddress: _c.selectedStoreAddress.value,
                  onSearchChanged: (value) {
                    debugPrint('Search typing: $value');
                  },
                  onStoreSelected: (name) {
                    final store = _c.stores.firstWhere(
                      (s) => s.name == name,
                      orElse: () => _c.stores.first,
                    );
                    _trySelectStore(store);
                  },
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.only(left: 10, top: 20, right: 10),
                  child: TitleSubheading(titleLabel: AppKeys.nearStores.tr),
                ),
              ),
              SliverToBoxAdapter(
                child: _c.stores.isEmpty
                    ? Padding(
                        padding: const EdgeInsets.all(16),
                        child: Text(AppKeys.noNearbyStores.tr),
                      )
                    : SizedBox(
                        height: 110,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          padding: const EdgeInsets.only(left: 10),
                          itemCount: _c.stores.length,
                          itemBuilder: (context, index) {
                            final store = _c.stores[index];
                            return SizedBox(
                              width: 260,
                              child: Padding(
                                padding: const EdgeInsets.only(right: 10),
                                child: NearbyStoreTitleTile(
                                  title: store.name,
                                  subTitle: store.formattedDistance != null
                                      ? '${store.formattedDistance} away'
                                      : store.address ?? 'Tap to select',
                                  onTap: () => _trySelectStore(store),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.only(left: 10, top: 20, right: 10),
                  child: TitleSubheading(titleLabel: AppKeys.recentVisit.tr),
                ),
              ),
              SliverPadding(
                padding: const EdgeInsets.all(10),
                sliver: _c.stores.isEmpty
                    ? SliverToBoxAdapter(
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Text(AppKeys.noStores.tr),
                        ),
                      )
                    : SliverGrid(
                        delegate: SliverChildBuilderDelegate(
                          (context, index) {
                            final store = _c.stores[index];
                            return StoreCard(
                              imageUrl: store.imageUrl ??
                                  'https://picsum.photos/id/1011/500/500',
                              storeName: store.name,
                              onTap: () => _trySelectStore(store),
                            );
                          },
                          childCount: _c.stores.length,
                        ),
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 12,
                          childAspectRatio: 0.75,
                        ),
                      ),
              ),
            ],
          );
        }),
      ),
    );
  }
}
