import 'package:get/get.dart';

class NavigationController extends GetxController {
  final RxInt selectedIndex = 0.obs;

  void goToHome() => selectedIndex.value = 0;
  void goToCart() => selectedIndex.value = 1;
  void goToSettings() => selectedIndex.value = 2;
}
