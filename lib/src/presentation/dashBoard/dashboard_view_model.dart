import 'package:dq_app/src/domain/entity/store_entity.dart';
import 'package:dq_app/src/domain/usecase/get_nearby_stores_usecase.dart';
import 'package:dq_app/src/domain/usecase/get_stores_usecase.dart';
import 'package:dq_app/src/service_core/location/location_service.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class DashboardController extends GetxController {
  final GetStoresUseCase getStoresUseCase;
  final GetNearbyStoresUseCase getNearbyStoresUseCase;

  DashboardController({
    required this.getStoresUseCase,
    required this.getNearbyStoresUseCase,
  });

  final RxList<StoreEntity> stores = <StoreEntity>[].obs;
  final RxBool isLoading = false.obs;
  final RxBool isStoreConfirmed = false.obs;
  final RxString selectedStoreId = ''.obs;
  final RxString selectedStoreName = ''.obs;
  final RxString selectedStoreAddress = ''.obs;
  final TextEditingController searchController = TextEditingController();

  @override
  void onInit() {
    super.onInit();
    loadStores();
  }

  Future<void> loadStores() async {
    isLoading.value = true;
    try {
      final position = await LocationService.getCurrentPosition();

      List<StoreEntity> result;
      if (position != null) {
        result = await getNearbyStoresUseCase.execute(
            position.latitude, position.longitude);
      } else {
        result = await getStoresUseCase.execute();
      }

      stores.value = result;

      if (stores.isNotEmpty) {
        selectedStoreId.value = stores.first.id;
        selectedStoreName.value = stores.first.name;
        selectedStoreAddress.value = stores.first.address ?? '';
      }
    } catch (e) {
      debugPrint('loadStores error: $e');
    } finally {
      isLoading.value = false;
    }
  }

  /// Directly switches to the given store (no cart check — caller handles that).
  void selectStore(StoreEntity store) {
    selectedStoreId.value = store.id;
    selectedStoreName.value = store.name;
    selectedStoreAddress.value = store.address ?? '';
    isStoreConfirmed.value = true;
  }

  void confirmCurrentStore() {
    isStoreConfirmed.value = true;
  }

  List<String> get storeNames => stores.map((s) => s.name).toList();

  @override
  void onClose() {
    searchController.dispose();
    super.onClose();
  }
}
