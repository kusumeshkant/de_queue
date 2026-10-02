import 'package:get/get.dart';

import '../presentation/auth/login/login_binding.dart';
import '../presentation/auth/login/login_page.dart';
import '../presentation/auth/signup/signup_binding.dart';
import '../presentation/auth/signup/signup_page.dart';
import '../presentation/dashBoard/bottom_navigation.dart';
import '../presentation/order/order_binding.dart';
import '../presentation/order/order_page.dart';
import '../presentation/profile/profile_binding.dart';
import '../presentation/profile/profile_page.dart';
import 'app_routes.dart';
import 'auth_middleware.dart';

abstract class AppPages {
  static final routes = <GetPage>[
    GetPage(
      name: AppRoutes.login,
      page: () => const LoginPage(),
      binding: LoginBinding(),
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: AppRoutes.signup,
      page: () => const SignUpPage(),
      binding: SignupBinding(),
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: AppRoutes.home,
      page: () => const Bottomnavigation(),
      middlewares: [AuthMiddleware()],
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: AppRoutes.orders,
      page: () => const OrderPage(),
      binding: OrderBinding(),
      middlewares: [AuthMiddleware()],
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: AppRoutes.profile,
      page: () => const ProfilePage(),
      binding: ProfileBinding(),
      middlewares: [AuthMiddleware()],
      transition: Transition.rightToLeft,
    ),
  ];
}
