import 'package:dq_app/src/constants/images_path_const.dart';
import 'package:dq_app/src/l10n/translation_keys.dart';
import 'package:dq_app/src/utils/dq_widgets/custom_search_text_field.dart';
import 'package:dq_app/src/utils/dq_widgets/darkened_image_banner.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class DashboardHeaderBanner extends StatelessWidget {
  final TextEditingController searchController;
  final List<String> storeList;
  final String storeName;
  final String storeAddress;
  final String? storeCode;
  final VoidCallback? onChangeTapped;
  final ValueChanged<String>? onSearchChanged;
  final ValueChanged<String>? onStoreSelected;

  const DashboardHeaderBanner({
    super.key,
    required this.searchController,
    required this.storeList,
    required this.storeName,
    required this.storeAddress,
    this.storeCode,
    this.onChangeTapped,
    this.onSearchChanged,
    this.onStoreSelected,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: MediaQuery.of(context).size.height * .4,
      child: Stack(
        children: [
          /// 🔹 Background banner
          DarkenedImageBanner(
            imagePath: ImagesPathConst.image_1,
            height: double.infinity,
            darkness: 0.55, // 🔥 darker for contrast
            borderRadius: const BorderRadius.only(
              bottomLeft: Radius.circular(14),
              bottomRight: Radius.circular(14),
            ),
          ),

          /// 🔹 Foreground UI
          SafeArea(
            bottom: false,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 16),

                  /// 🔍 SEARCH BOX (GLASS EFFECT)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.35),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.9),
                        width: 2.5,
                      ),
                    ),
                    child: CustomSearchTextField<String>(
                      controller: searchController,
                      hintText: AppKeys.searchHint.tr,
                      showDropdown: true,
                      items: storeList,
                      itemLabel: (item) => item,
                      onChanged: onSearchChanged,
                      onItemSelected: onStoreSelected,
                      prefixIcon: const Icon(
                        Icons.search,
                        color: Colors.white,
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  /// ⬇️ STORE INFO
                  Expanded(
                    child: Align(
                      alignment: Alignment.bottomLeft,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          /// 🔥 Bigger & visible
                          Text(
                            AppKeys.youAreIn.tr,
                            style: Theme.of(context)
                                .textTheme
                                .titleMedium
                                ?.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                  shadows: const [
                                    Shadow(
                                      color: Colors.black45,
                                      blurRadius: 4,
                                      offset: Offset(0, 1),
                                    ),
                                  ],
                                ),
                          ),

                          const SizedBox(height: 6),

                          Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Expanded(
                                child: Text(
                                  storeName,
                                  style: Theme.of(context)
                                      .textTheme
                                      .headlineSmall
                                      ?.copyWith(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        shadows: const [
                                          Shadow(
                                            color: Colors.black54,
                                            blurRadius: 6,
                                            offset: Offset(0, 2),
                                          ),
                                        ],
                                      ),
                                ),
                              ),
                              if (onChangeTapped != null) ...[
                                const SizedBox(width: 8),
                                GestureDetector(
                                  onTap: onChangeTapped,
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 10, vertical: 4),
                                    decoration: BoxDecoration(
                                      color:
                                          Colors.white.withValues(alpha: 0.2),
                                      borderRadius: BorderRadius.circular(20),
                                      border: Border.all(
                                          color: Colors.white
                                              .withValues(alpha: 0.5)),
                                    ),
                                    child: const Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(Icons.swap_horiz_rounded,
                                            color: Colors.white, size: 14),
                                        SizedBox(width: 4),
                                        Text('Change',
                                            style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 12,
                                                fontWeight: FontWeight.w600)),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          ),

                          if (storeCode != null) ...[
                            const SizedBox(height: 4),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(6),
                                border: Border.all(
                                    color:
                                        Colors.white.withValues(alpha: 0.35)),
                              ),
                              child: Text(
                                'ID: $storeCode',
                                style: const TextStyle(
                                  color: Colors.white70,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ),
                            const SizedBox(height: 2),
                          ] else
                            const SizedBox(height: 4),

                          Text(
                            storeAddress,
                            style: Theme.of(context)
                                .textTheme
                                .bodyLarge
                                ?.copyWith(
                                  color: Colors.white70,
                                  shadows: const [
                                    Shadow(
                                      color: Colors.black38,
                                      blurRadius: 4,
                                      offset: Offset(0, 1),
                                    ),
                                  ],
                                ),
                          ),

                          const SizedBox(height: 20),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
