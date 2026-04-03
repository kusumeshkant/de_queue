import 'dart:ui';

import 'package:dq_app/src/domain/entity/store_entity.dart';
import 'package:dq_app/src/theme/theme_controller.dart';
import 'package:dq_app/widgets/themed_background.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class StoreSelectionPage extends StatefulWidget {
  final List<StoreEntity> stores;
  final void Function(StoreEntity) onStoreSelected;

  const StoreSelectionPage({
    super.key,
    required this.stores,
    required this.onStoreSelected,
  });

  @override
  State<StoreSelectionPage> createState() => _StoreSelectionPageState();
}

class _StoreSelectionPageState extends State<StoreSelectionPage> {
  late final TextEditingController _searchController;
  String _query = '';

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<StoreEntity> get _filtered {
    if (_query.isEmpty) return widget.stores;
    final q = _query.toLowerCase();
    return widget.stores.where((s) {
      final nameMatch = s.name.toLowerCase().contains(q);
      final codeMatch = (s.storeCode ?? '').toLowerCase().contains(q);
      return nameMatch || codeMatch;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final tc = Get.find<ThemeController>();

    return ThemedBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: Icon(Icons.arrow_back_ios_new_rounded,
                color: tc.textPrimary, size: 20),
            onPressed: () => Get.back(),
          ),
          title: Text(
            'Select Store',
            style: TextStyle(
              color: tc.textPrimary,
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
          centerTitle: true,
        ),
        body: Column(
          children: [
            // ── Search bar ────────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(14),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                  child: Container(
                    decoration: BoxDecoration(
                      color: tc.cardSurface,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: tc.cardBorder),
                    ),
                    child: TextField(
                      controller: _searchController,
                      onChanged: (v) => setState(() => _query = v.trim()),
                      style: TextStyle(color: tc.textPrimary, fontSize: 15),
                      decoration: InputDecoration(
                        hintText: 'Search by name or store code…',
                        hintStyle:
                            TextStyle(color: tc.textSecondary, fontSize: 14),
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
                            vertical: 14, horizontal: 4),
                      ),
                    ),
                  ),
                ),
              ),
            ),

            // ── Section header ────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              child: Row(
                children: [
                  Icon(Icons.near_me_rounded,
                      size: 15, color: tc.primary),
                  const SizedBox(width: 6),
                  Text(
                    _filtered.isEmpty
                        ? 'No stores found'
                        : '${_filtered.length} store${_filtered.length == 1 ? '' : 's'} nearby',
                    style: TextStyle(
                      color: tc.textSecondary,
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),

            // ── Store list ────────────────────────────────────────────────
            Expanded(
              child: _filtered.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.store_mall_directory_outlined,
                              size: 48,
                              color: tc.textSecondary.withValues(alpha: 0.4)),
                          const SizedBox(height: 12),
                          Text(
                            'No stores match your search',
                            style: TextStyle(
                                color: tc.textSecondary, fontSize: 14),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: _filtered.length,
                      itemBuilder: (context, index) {
                        return _StoreTile(
                          store: _filtered[index],
                          onTap: () {
                            widget.onStoreSelected(_filtered[index]);
                          },
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StoreTile extends StatelessWidget {
  final StoreEntity store;
  final VoidCallback onTap;

  const _StoreTile({required this.store, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final tc = Get.find<ThemeController>();

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: GestureDetector(
        onTap: onTap,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: BoxDecoration(
                color: tc.cardSurface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: tc.cardBorder),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Store icon
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: tc.primary.withValues(alpha: 0.12),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.store_rounded,
                        color: tc.primary, size: 22),
                  ),
                  const SizedBox(width: 12),

                  // Store info
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Name + storeCode badge
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                store.name,
                                style: TextStyle(
                                  color: tc.textPrimary,
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            if (store.storeCode != null) ...[
                              const SizedBox(width: 8),
                              _CodeBadge(code: store.storeCode!, tc: tc),
                            ],
                          ],
                        ),
                        // Address
                        if ((store.address ?? '').isNotEmpty) ...[
                          const SizedBox(height: 4),
                          Text(
                            store.address!,
                            style: TextStyle(
                              color: tc.textSecondary,
                              fontSize: 12,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                        // Distance
                        if (store.formattedDistance != null) ...[
                          const SizedBox(height: 6),
                          Row(
                            children: [
                              Icon(Icons.place_rounded,
                                  size: 12,
                                  color: tc.primary.withValues(alpha: 0.7)),
                              const SizedBox(width: 3),
                              Text(
                                '${store.formattedDistance} away',
                                style: TextStyle(
                                  color: tc.primary,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),

                  // Chevron
                  const SizedBox(width: 4),
                  Icon(Icons.chevron_right_rounded,
                      color: tc.textSecondary.withValues(alpha: 0.5), size: 20),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _CodeBadge extends StatelessWidget {
  final String code;
  final ThemeController tc;

  const _CodeBadge({required this.code, required this.tc});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
      decoration: BoxDecoration(
        color: tc.primary.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: tc.primary.withValues(alpha: 0.3)),
      ),
      child: Text(
        code,
        style: TextStyle(
          color: tc.primary,
          fontSize: 10,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}
