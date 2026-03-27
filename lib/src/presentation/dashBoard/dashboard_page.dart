import 'dart:ui';

import 'package:dq_app/src/domain/entity/store_entity.dart';
import 'package:dq_app/src/l10n/translation_keys.dart';
import 'package:dq_app/src/presentation/cart/cart_controller.dart';
import 'package:dq_app/src/presentation/dashBoard/dashboard_view_model.dart';
import 'package:dq_app/src/presentation/store/store_selection_page.dart';
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

  // ── Open full store selection page ─────────────────────────────────────────

  void _openStoreSelection() {
    Get.to(
      () => StoreSelectionPage(
        stores: _c.stores,
        onStoreSelected: (store) {
          Get.back(); // close StoreSelectionPage
          _trySelectStore(store);
        },
      ),
      transition: Transition.rightToLeft,
    );
  }

  // ── Store selection bottom sheet (shown on app open) ──────────────────────

  void _showStoreConfirmation() {
    Get.bottomSheet(
      isDismissible: true,
      enableDrag: true,
      isScrollControlled: true,
      _StoreSelectionSheet(
        stores: _c.stores,
        onStoreTapped: (store) {
          Get.back();
          _trySelectStore(store);
        },
        onClose: () {
          _c.confirmCurrentStore();
          Get.back();
        },
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
                  storeCode: _c.stores
                      .where((s) => s.id == _c.selectedStoreId.value)
                      .firstOrNull
                      ?.storeCode,
                  onChangeTapped: _openStoreSelection,
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

// ── Store selection bottom sheet widget ───────────────────────────────────────

class _StoreSelectionSheet extends StatefulWidget {
  final List stores;
  final void Function(dynamic store) onStoreTapped;
  final VoidCallback onClose;

  const _StoreSelectionSheet({
    required this.stores,
    required this.onStoreTapped,
    required this.onClose,
  });

  @override
  State<_StoreSelectionSheet> createState() => _StoreSelectionSheetState();
}

class _StoreSelectionSheetState extends State<_StoreSelectionSheet> {
  final TextEditingController _searchController = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List get _filtered {
    if (_query.isEmpty) return widget.stores;
    final q = _query.toLowerCase();
    return widget.stores.where((s) {
      final nameMatch = (s.name as String).toLowerCase().contains(q);
      final codeMatch =
          ((s.storeCode as String?) ?? '').toLowerCase().contains(q);
      return nameMatch || codeMatch;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final tc = Get.find<ThemeController>();

    return Obx(() {
      final isGreen = tc.isGreenTheme.value;
      return ClipRRect(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
          child: Container(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.80,
            ),
            decoration: BoxDecoration(
              color: isGreen
                  ? Colors.black.withValues(alpha: 0.82)
                  : Colors.white.withValues(alpha: 0.95),
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
                // ── Header ──────────────────────────────────────────────
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 16, 12, 0),
                  child: Row(
                    children: [
                      Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: tc.primary.withValues(alpha: 0.12),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(Icons.store_rounded,
                            color: tc.primary, size: 18),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Select a Store',
                              style: TextStyle(
                                color: tc.textPrimary,
                                fontSize: 17,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              'Choose where you are shopping today',
                              style: TextStyle(
                                  color: tc.textSecondary, fontSize: 12),
                            ),
                          ],
                        ),
                      ),
                      Semantics(
                        identifier: 'close_button',
                        child: IconButton(
                          onPressed: widget.onClose,
                          icon: Icon(Icons.close_rounded,
                              color: tc.textSecondary, size: 22),
                          tooltip: 'Explore without selecting',
                        ),
                      ),
                    ],
                  ),
                ),

                // ── Search box ───────────────────────────────────────────
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
                  child: Container(
                    decoration: BoxDecoration(
                      color: tc.cardSurface,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: tc.cardBorder),
                    ),
                    child: TextField(
                      controller: _searchController,
                      onChanged: (v) => setState(() => _query = v.trim()),
                      style: TextStyle(color: tc.textPrimary, fontSize: 14),
                      decoration: InputDecoration(
                        hintText: 'Search by store name or code…',
                        hintStyle:
                            TextStyle(color: tc.textSecondary, fontSize: 13),
                        prefixIcon: Icon(Icons.search_rounded,
                            color: tc.textSecondary, size: 20),
                        suffixIcon: _query.isNotEmpty
                            ? IconButton(
                                icon: Icon(Icons.clear_rounded,
                                    color: tc.textSecondary, size: 18),
                                onPressed: () {
                                  _searchController.clear();
                                  setState(() => _query = '');
                                },
                              )
                            : null,
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(
                            vertical: 12, horizontal: 4),
                      ),
                    ),
                  ),
                ),

                // ── Result count hint ────────────────────────────────────
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 18, vertical: 6),
                  child: Row(
                    children: [
                      Icon(Icons.storefront_rounded,
                          size: 13, color: tc.textSecondary),
                      const SizedBox(width: 5),
                      Text(
                        _filtered.isEmpty
                            ? 'No stores match your search'
                            : '${_filtered.length} store${_filtered.length == 1 ? '' : 's'} available',
                        style:
                            TextStyle(color: tc.textSecondary, fontSize: 12),
                      ),
                    ],
                  ),
                ),

                Divider(
                    color: tc.cardBorder.withValues(alpha: 0.4), height: 1),

                // ── Store list ───────────────────────────────────────────
                Flexible(
                  child: _filtered.isEmpty
                      ? Padding(
                          padding: const EdgeInsets.all(32),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.search_off_rounded,
                                  size: 40,
                                  color: tc.textSecondary
                                      .withValues(alpha: 0.4)),
                              const SizedBox(height: 10),
                              Text(
                                'Try a different name or store code',
                                style: TextStyle(
                                    color: tc.textSecondary, fontSize: 13),
                              ),
                            ],
                          ),
                        )
                      : ListView.builder(
                          shrinkWrap: true,
                          padding: const EdgeInsets.fromLTRB(16, 8, 16, 28),
                          itemCount: _filtered.length,
                          itemBuilder: (context, index) {
                            final store = _filtered[index];
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 10),
                              child: GestureDetector(
                                onTap: () => widget.onStoreTapped(store),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 14, vertical: 12),
                                  decoration: BoxDecoration(
                                    color: tc.cardSurface,
                                    borderRadius: BorderRadius.circular(14),
                                    border:
                                        Border.all(color: tc.cardBorder),
                                  ),
                                  child: Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      // Store icon
                                      Container(
                                        width: 40,
                                        height: 40,
                                        decoration: BoxDecoration(
                                          color: tc.primary
                                              .withValues(alpha: 0.10),
                                          shape: BoxShape.circle,
                                        ),
                                        child: Icon(Icons.storefront_rounded,
                                            color: tc.primary, size: 20),
                                      ),
                                      const SizedBox(width: 12),

                                      // Store info
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            // Name + code badge
                                            Row(
                                              children: [
                                                Expanded(
                                                  child: Text(
                                                    store.name as String,
                                                    style: TextStyle(
                                                      color: tc.textPrimary,
                                                      fontSize: 14,
                                                      fontWeight:
                                                          FontWeight.w600,
                                                    ),
                                                  ),
                                                ),
                                                if ((store.storeCode as String?) !=
                                                    null) ...[
                                                  const SizedBox(width: 6),
                                                  Container(
                                                    padding: const EdgeInsets
                                                        .symmetric(
                                                        horizontal: 6,
                                                        vertical: 2),
                                                    decoration: BoxDecoration(
                                                      color: tc.primary
                                                          .withValues(
                                                              alpha: 0.10),
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              5),
                                                      border: Border.all(
                                                          color: tc.primary
                                                              .withValues(
                                                                  alpha: 0.25)),
                                                    ),
                                                    child: Text(
                                                      store.storeCode as String,
                                                      style: TextStyle(
                                                        color: tc.primary,
                                                        fontSize: 10,
                                                        fontWeight:
                                                            FontWeight.w700,
                                                        letterSpacing: 0.4,
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ],
                                            ),

                                            // Address — 2 lines
                                            if (((store.address as String?) ??
                                                    '')
                                                .isNotEmpty) ...[
                                              const SizedBox(height: 4),
                                              Text(
                                                store.address as String,
                                                style: TextStyle(
                                                    color: tc.textSecondary,
                                                    fontSize: 12),
                                                maxLines: 2,
                                                overflow:
                                                    TextOverflow.ellipsis,
                                              ),
                                            ],
                                          ],
                                        ),
                                      ),

                                      const SizedBox(width: 6),
                                      Padding(
                                        padding:
                                            const EdgeInsets.only(top: 2),
                                        child: Icon(
                                            Icons.chevron_right_rounded,
                                            color: tc.textSecondary
                                                .withValues(alpha: 0.4),
                                            size: 18),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                ),
              ],
            ),
          ),
        ),
      );
    });
  }
}
