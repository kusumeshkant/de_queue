import 'package:dq_app/design_system/design_system.dart';
import 'package:dq_app/src/l10n/translation_keys.dart';
import 'package:dq_app/src/presentation/dashBoard/navigation_controller.dart';
import 'package:dq_app/src/data/datasources/remote/notification_remote_ds.dart';
import 'package:dq_app/src/data/datasources/remote/order_remote_ds.dart';
import 'package:dq_app/src/data/datasources/remote/store_remote_ds.dart';
import 'package:dq_app/src/data/repo_impl/order_repository_impl.dart';
import 'package:dq_app/src/data/repo_impl/store_repository_impl.dart';
import 'package:dq_app/src/data/repo_impl/notification_repository_impl.dart';
import 'package:dq_app/src/domain/repo/notification_repository.dart';
import 'package:dq_app/src/domain/repo/order_repository.dart';
import 'package:dq_app/src/domain/repo/store_repository.dart';
import 'package:dq_app/src/domain/usecase/create_order_usecase.dart';
import 'package:dq_app/src/domain/usecase/create_razorpay_order_usecase.dart';
import 'package:dq_app/src/domain/usecase/validate_cart_stock_usecase.dart';
import 'package:dq_app/src/domain/usecase/get_nearby_stores_usecase.dart';
import 'package:dq_app/src/domain/usecase/get_order_by_id_usecase.dart';
import 'package:dq_app/src/domain/usecase/get_stores_usecase.dart';
import 'package:dq_app/src/domain/usecase/update_fcm_token_usecase.dart';
import 'package:dq_app/src/presentation/Setting/setting_page.dart';
import 'package:dq_app/src/presentation/cart/cart_controller.dart';
import 'package:dq_app/src/presentation/cart/cart_page.dart';
import 'package:dq_app/src/presentation/dashBoard/dashboard_page.dart';
import 'package:dq_app/src/presentation/order/order_confirmation_page.dart';
import 'package:dq_app/src/presentation/dashBoard/dashboard_view_model.dart';
import 'package:dq_app/src/presentation/order/order_binding.dart';
import 'package:dq_app/src/presentation/order/order_page.dart';
import 'package:dq_app/src/presentation/scanner_page/scanner_binding.dart';
import 'package:dq_app/src/presentation/scanner_page/scanner_page.dart';
import 'package:dq_app/src/service_core/notifications/notification_service.dart';
import 'package:dq_app/src/service_core/payment/razorpay_service.dart';
import 'package:dq_app/src/theme/theme_controller.dart';
import 'package:dq_app/widgets/themed_background.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class Bottomnavigation extends StatefulWidget {
  const Bottomnavigation({super.key});

  @override
  State<Bottomnavigation> createState() => _BottomnavigationState();
}

class _BottomnavigationState extends State<Bottomnavigation>
    with SingleTickerProviderStateMixin {
  late final NavigationController _navController;
  late final AnimationController _pulseController;
  late final Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _navController = Get.put(NavigationController(), permanent: true);
    _registerDependencies();
    _setupNotificationHandlers();

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat(reverse: true);
    _pulseAnimation = Tween<double>(begin: 0.35, end: 1.0).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  void _setupNotificationHandlers() {
    // Handle notification taps while app is running (foreground/background)
    NotificationService.onNotificationTap = (type) {
      if (type == 'order_confirmed' || type == 'order_status_update') {
        Get.to(() => const OrderPage(), binding: OrderBinding());
      }
    };

    // Handle cold-start: app was terminated and user tapped a notification
    final pending = NotificationService.pendingNotificationType;
    if (pending != null) {
      NotificationService.pendingNotificationType = null;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (pending == 'order_confirmed' || pending == 'order_status_update') {
          Get.to(() => const OrderPage(), binding: OrderBinding());
        }
      });
    }
  }

  void _registerDependencies() {
    Get.put(StoreRemoteDataSource());
    Get.put<StoreRepository>(StoreRepositoryImpl(remote: Get.find()));
    Get.put(GetStoresUseCase(repository: Get.find()));
    Get.put(GetNearbyStoresUseCase(repository: Get.find()));
    Get.put(OrderRemoteDataSource(), permanent: true);
    Get.put<OrderRepository>(
        OrderRepositoryImpl(remote: Get.find()), permanent: true);
    Get.put(CreateRazorpayOrderUseCase(repository: Get.find()), permanent: true);
    Get.put(CreateOrderUseCase(repository: Get.find()), permanent: true);
    Get.put(ValidateCartStockUseCase(repository: Get.find()), permanent: true);
    Get.put(GetOrderByIdUseCase(repository: Get.find()), permanent: true);

    Get.put(DashboardController(
      getStoresUseCase: Get.find(),
      getNearbyStoresUseCase: Get.find(),
      getOrderByIdUseCase: Get.find(),
    ));
    Get.put(RazorpayService(), permanent: true);
    Get.put(
      CartController(
        createRazorpayOrderUseCase: Get.find(),
        createOrderUseCase: Get.find(),
        validateCartStockUseCase: Get.find(),
        razorpayService: Get.find(),
      ),
      permanent: true,
    );

    // FCM token registration
    Get.put(NotificationRemoteDataSource(), permanent: true);
    Get.put<NotificationRepository>(
        NotificationRepositoryImpl(remote: Get.find()), permanent: true);
    Get.put(UpdateFcmTokenUseCase(repository: Get.find()), permanent: true);
    _registerFcmToken();
  }

  Future<void> _registerFcmToken() async {
    try {
      final token = await NotificationService.getToken();
      if (token != null) {
        await Get.find<UpdateFcmTokenUseCase>().execute(token);
      }
      // Re-register if token rotates
      NotificationService.onTokenRefresh.listen((newToken) {
        Get.find<UpdateFcmTokenUseCase>().execute(newToken);
      });
    } catch (_) {}
  }

  final List<Widget> _screens = const [
    DashboardPage(),
    CartPage(),
    SettingsPage(),
  ];

  void _onTabTap(int index) => _navController.selectedIndex.value = index;

  @override
  Widget build(BuildContext context) {
    final tc = Get.find<ThemeController>();

    return ThemedBackground(
      child: Scaffold(
        body: Obx(() => Stack(
          children: [
            IndexedStack(
              index: _navController.selectedIndex.value,
              children: _screens,
            ),
            if (_navController.selectedIndex.value == 0)
              Positioned(
                bottom: 15,
                left: 0,
                right: 0,
                child: Center(
                  child: Semantics(
                    identifier: 'scanner_fab',
                    child: FloatingActionButton(
                      backgroundColor: tc.primary.withValues(alpha: 0.85),
                      elevation: 12,
                      onPressed: () => Get.to(
                        () => const ScannerPage(),
                        binding: ScannerBinding(),
                      ),
                      child: const Icon(Icons.qr_code_scanner,
                          size: 28, color: Colors.white),
                    ),
                  ),
                ),
              ),

            // ── Active Order FAB ──────────────────────────────────────────
            if (_navController.selectedIndex.value == 0)
              Obx(() {
                final dc = Get.find<DashboardController>();
                if (!dc.hasActiveOrder) return const SizedBox.shrink();
                return Positioned(
                  bottom: 85,
                  right: 16,
                  child: GestureDetector(
                    onTap: () {
                      final order = dc.activeOrder.value;
                      if (order != null) {
                        Get.to(
                          () => OrderConfirmationPage(order: order),
                          transition: Transition.upToDown,
                        );
                      }
                    },
                    child: AnimatedBuilder(
                      animation: _pulseAnimation,
                      builder: (context, child) {
                        return Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 14, vertical: 10),
                          decoration: BoxDecoration(
                            color: tc.isGreenTheme.value
                                ? AppColorsDark.floatSurface
                                : AppColorsLight.floatSurface,
                            borderRadius: BorderRadius.circular(30),
                            border: Border.all(
                              color: AppColors.warningBorder,
                              width: 1.2,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.warning.withValues(
                                    alpha: 0.25 * _pulseAnimation.value),
                                blurRadius: 14,
                                spreadRadius: 2,
                              ),
                            ],
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                width: 10,
                                height: 10,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: AppColors.warning.withValues(
                                      alpha: _pulseAnimation.value),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'Awaiting Confirmation',
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.warning,
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                );
              }),
          ],
        )),
        bottomNavigationBar: Obx(() => Container(
              height: 58,
              decoration: BoxDecoration(
                color: tc.isGreenTheme.value
                    ? AppColorsDark.navBarSurface
                    : AppColorsLight.navBarSurface,
                border: Border(
                  top: BorderSide(color: tc.cardBorder, width: 0.8),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.12),
                    blurRadius: 12,
                    offset: const Offset(0, -3),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Expanded(child: _navItem(icon: Icons.home, label: AppKeys.home.tr, index: 0)),
                  Expanded(child: _navItem(icon: Icons.shopping_cart, label: AppKeys.cart.tr, index: 1)),
                  Expanded(child: _navItem(icon: Icons.settings, label: AppKeys.settings.tr, index: 2)),
                ],
              ),
            )),
      ),
    );
  }

  Widget _navItem(
      {required IconData icon, required String label, required int index}) {
    final tc = Get.find<ThemeController>();
    return GestureDetector(
      onTap: () => _onTabTap(index),
      behavior: HitTestBehavior.opaque,
      child: Obx(() {
        final isSelected = _navController.selectedIndex.value == index;
        return Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon,
                size: 22,
                color: isSelected ? tc.primary : tc.textSecondary),
            const SizedBox(height: 2),
            Text(label,
                style: TextStyle(
                    fontSize: 11,
                    color: isSelected ? tc.primary : tc.textSecondary)),
          ],
        );
      }),
    );
  }
}
