import 'package:dq_app/design_system/design_system.dart';
import 'package:dq_app/src/presentation/dashBoard/dashboard_view_model.dart';
import 'package:dq_app/src/theme/theme_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// Store code entry bottom sheet — used on both web (primary) and mobile
/// (fallback when GPS / store-list fetch fails).
///
/// Calls [DashboardController.lookupStoreByCode] and closes itself on success.
class StoreCodeEntrySheet extends StatefulWidget {
  const StoreCodeEntrySheet({super.key});

  @override
  State<StoreCodeEntrySheet> createState() => _StoreCodeEntrySheetState();
}

class _StoreCodeEntrySheetState extends State<StoreCodeEntrySheet> {
  final _codeController = TextEditingController();
  late final DashboardController _dc;

  @override
  void initState() {
    super.initState();
    _dc = Get.find<DashboardController>();
  }

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final success = await _dc.lookupStoreByCode(_codeController.text);
    if (success && mounted) Get.back();
  }

  @override
  Widget build(BuildContext context) {
    final tc = Get.find<ThemeController>();

    return Obx(() {
      final isGreen = tc.isGreenTheme.value;
      final isLoading = _dc.isLookingUpCode.value;
      final error = _dc.codeLookupError.value;

      return ClipRRect(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        child: Container(
          padding: EdgeInsets.fromLTRB(
            20,
            20,
            20,
            20 + MediaQuery.of(context).viewInsets.bottom,
          ),
          decoration: BoxDecoration(
            color: isGreen
                ? AppColorsDark.sheetSurface
                : AppColorsLight.sheetSurface,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
            border: Border(
              top: BorderSide(
                color: tc.primary.withValues(alpha: 0.35),
                width: 1.2,
              ),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Handle
              Center(
                child: Container(
                  width: 36,
                  height: 4,
                  decoration: BoxDecoration(
                    color: tc.cardBorder,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Header
              Row(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: tc.primary.withValues(alpha: 0.12),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.store_rounded, color: tc.primary, size: 18),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Enter Store Code',
                          style: TextStyle(
                            color: tc.textPrimary,
                            fontSize: 17,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          'Find the code at the store entrance or on the receipt',
                          style: TextStyle(color: tc.textSecondary, fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Code input
              Container(
                decoration: BoxDecoration(
                  color: tc.cardSurface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: error.isNotEmpty ? AppColors.errorBorder : tc.cardBorder,
                  ),
                ),
                child: TextField(
                  controller: _codeController,
                  autofocus: true,
                  textCapitalization: TextCapitalization.characters,
                  style: TextStyle(
                    color: tc.textPrimary,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 1.5,
                  ),
                  decoration: InputDecoration(
                    hintText: 'e.g. MUM-FAS-1234',
                    hintStyle: TextStyle(
                      color: tc.textSecondary,
                      fontSize: 14,
                      fontWeight: FontWeight.normal,
                      letterSpacing: 0,
                    ),
                    prefixIcon: Icon(Icons.tag_rounded,
                        color: tc.textSecondary, size: 20),
                    border: InputBorder.none,
                    contentPadding:
                        const EdgeInsets.symmetric(vertical: 14, horizontal: 4),
                  ),
                  onSubmitted: (_) => _submit(),
                ),
              ),

              // Error message
              if (error.isNotEmpty) ...[
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(Icons.error_outline_rounded,
                        color: AppColors.error, size: 14),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        error,
                        style: TextStyle(color: AppColors.error, fontSize: 12),
                      ),
                    ),
                  ],
                ),
              ],
              const SizedBox(height: 20),

              // Submit button
              SizedBox(
                height: 48,
                child: ElevatedButton(
                  onPressed: isLoading ? null : _submit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: tc.primary,
                    foregroundColor: Colors.white,
                    disabledBackgroundColor: tc.primary.withValues(alpha: 0.5),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  child: isLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Text(
                          'Find Store',
                          style: TextStyle(
                              fontSize: 15, fontWeight: FontWeight.w600),
                        ),
                ),
              ),
            ],
          ),
        ),
      );
    });
  }
}
