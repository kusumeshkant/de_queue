# Design System Audit — DQ App
**Branch**: feature/design-system-dq-app | **Date**: 2026-05-15

---

## Architecture
- **State**: GetX (GetxController, Obx, RxBool/RxInt)
- **Architecture**: Clean (domain / data / presentation)
- **Material**: Material 3 (`useMaterial3: true`, `ColorScheme.fromSeed`)
- **Theme modes**: Light (purple) + Green (dark) — persisted via Hive

---

## Existing Design System Files

| File | Status |
|------|--------|
| `lib/src/theme/app_theme.dart` | Partial — ThemeData only |
| `lib/src/theme/theme_controller.dart` | Partial — semantic color getters |
| `lib/widgets/app_glass_card.dart` | Good — theme-aware |
| `lib/widgets/dq_button.dart` (GlassButton) | Good |
| `lib/widgets/dq_input_field.dart` (GlassTextField) | Good |
| `lib/widgets/dq_glass_text.dart` (GlassText) | Good |
| `lib/widgets/dq_container.dart` (GlassContainer) | Good |
| `lib/widgets/liquid_glass.dart` (LiquidGlass*) | Good |
| `lib/widgets/themed_background.dart` | Good |

**Missing**: No `app_colors.dart`, `app_typography.dart`, `app_spacing.dart`, `app_shadows.dart`

---

## Hardcoded Colors (Critical)

### Primary/brand colors duplicated in screens
```
0xFF6C63FF — purple (light primary) — hardcoded in login, signup
0xFF00C853 — green (dark primary) — hardcoded in 8+ files
0xFF00E676 — bright green accent — hardcoded in scanner_page
0xFF1A1A2E — dark text — hardcoded in dashboard_page
0xFF1A2B3C — dialog bg — dashboard_page
0xFF4285F4 — Google blue — login_page, signup_page
0xFFFFD54F — yellow (torch) — scanner_page
```

### Status colors (not centralized)
```
Colors.orange.shade400 / .shade600   — warning/preparing status
Colors.green.shade600 / .shade700    — success/completed status
Colors.red / .shade600               — error/cancelled status
Colors.blue.shade500                 — info/ready status
Colors.grey.shade500                 — neutral/pending status
```

### Glass opacity values (scattered, 30+ alpha values)
```
Colors.white.withValues(alpha: 0.04, 0.07, 0.10, 0.15, 0.18, 0.20,
                                     0.25, 0.28, 0.42, 0.45, 0.72,
                                     0.75, 0.82, 0.85, 0.88, 0.90, 0.97)
Colors.black.withValues(alpha: 0.05, 0.06, 0.08, 0.12, 0.15, 0.30,
                                     0.32, 0.35, 0.45, 0.82)
```

---

## Hardcoded Typography (Critical)

No TextTheme extension. All TextStyle inline across 18+ files.

### Font sizes found
```
10, 11, 12, 13, 14, 15, 16, 17, 18, 20, 22, 30, 32
```

### Font weights found
```
FontWeight.normal, w500, w600, w700, bold
```

### Files with most hardcoding
- `presentation/auth/login/login_page.dart` — 15+ TextStyle
- `presentation/auth/signup/signup_page.dart` — 15+ TextStyle (duplicate)
- `presentation/cart/widgets/cart_bottom_bar.dart` — 10+ TextStyle
- `presentation/order/order_page.dart` — 8+ TextStyle
- `presentation/order/order_confirmation_page.dart` — 10+ TextStyle

---

## Hardcoded Spacing (Critical)

### SizedBox heights (magic numbers)
```
3, 4, 5, 6, 8, 10, 12, 14, 16, 20, 24, 28, 32, 40, 52
```

### Border radius values (9 distinct)
```
10, 12, 16, 18, 20, 24, 25, 28, 50
```

### EdgeInsets patterns
```
EdgeInsets.all(12, 14, 20, 24)
EdgeInsets.symmetric(horizontal: 16/18/20, vertical: 8/14/24)
EdgeInsets.fromLTRB(20, 24, 20, 24)
```

---

## Screen Inventory (13 screens)

| Screen | File | Hardcoding severity |
|--------|------|---------------------|
| LoginPage | `auth/login/login_page.dart` | HIGH |
| SignUpPage | `auth/signup/signup_page.dart` | HIGH |
| DashboardPage | `dashBoard/dashboard_page.dart` | MEDIUM |
| CartPage | `cart/cart_page.dart` | MEDIUM |
| ScannerPage | `scanner_page/scanner_page.dart` | MEDIUM |
| OrderPage | `order/order_page.dart` | MEDIUM |
| OrderDetailPage | `order/order_detail_page.dart` | LOW |
| OrderConfirmationPage | `order/order_confirmation_page.dart` | HIGH |
| ProfilePage | `profile/profile_page.dart` | LOW |
| SettingsPage | `Setting/setting_page.dart` | LOW |
| StoreSelectionPage | `store/store_selection_page.dart` | LOW |
| ProductDetailSheet | `scanner_page/widgets/product_detail_sheet.dart` | MEDIUM |
| BottomNavigation | `dashBoard/bottom_navigation.dart` | MEDIUM |

---

## Phase 2 Target Structure

```
lib/
└── design_system/
    ├── tokens/
    │   ├── app_colors.dart        # Color tokens (brand, semantic, glass)
    │   ├── app_typography.dart    # TextStyle tokens
    │   ├── app_spacing.dart       # Spacing + radius tokens
    │   └── app_shadows.dart       # Shadow + blur tokens
    ├── theme/
    │   ├── app_theme.dart         # ThemeData (replaces src/theme/app_theme.dart)
    │   └── theme_controller.dart  # (stays in src/theme — GetX controller)
    └── widgets/
        ├── ds_glass_card.dart     # Consolidated glass card
        ├── ds_button.dart         # Consolidated button
        ├── ds_input_field.dart    # Consolidated input
        ├── ds_status_badge.dart   # Centralized status badges
        ├── ds_loading.dart        # Loading states
        └── ds_empty_state.dart    # Empty states
```

---

## Migration Priority

1. **Phase 2**: Create `lib/design_system/tokens/` — colors, typography, spacing, shadows
2. **Phase 3**: Consolidate glass widgets, add ds_status_badge, ds_loading, ds_empty_state
3. **Phase 4**: Extend ThemeData with TextTheme from tokens
4. **Phase 5**: Migrate login_page, signup_page (HIGH hardcoding), then cart, orders
5. **Phase 6**: Validate no hardcoded values remain
