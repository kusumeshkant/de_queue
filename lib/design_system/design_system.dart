/// DQ App Design System — barrel export.
///
/// Import this single file to access all design tokens and components:
/// ```dart
/// import 'package:dq_app/design_system/design_system.dart';
/// ```
/// Then use:
/// - `AppColors.success`, `AppSpacing.lg`, `AppTypography.body`
/// - `DsGlassCard(child: ...)`, `DsStatusBadge(status: order.status)`
///
/// Note: Theme-aware colors (primary, text, card) are read from
/// `ThemeController` since DQ App supports runtime theme switching.
library;

// Tokens
export 'tokens/app_colors.dart';
export 'tokens/app_typography.dart';
export 'tokens/app_spacing.dart';
export 'tokens/app_shadows.dart';

// Widgets
export 'widgets/ds_glass_card.dart';
export 'widgets/ds_status_badge.dart';
export 'widgets/ds_loading.dart';
export 'widgets/ds_empty_state.dart';
