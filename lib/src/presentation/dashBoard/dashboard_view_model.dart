import 'dart:async';

import 'package:dq_app/src/domain/entity/order_entity.dart';
import 'package:dq_app/src/domain/entity/store_entity.dart';
import 'package:dq_app/src/domain/usecase/get_nearby_stores_usecase.dart';
import 'package:dq_app/src/domain/usecase/get_order_by_id_usecase.dart';
import 'package:dq_app/src/domain/usecase/get_stores_usecase.dart';
import 'package:dq_app/src/service_core/location/location_service.dart';
import 'package:dq_app/src/utils/services/local_storage.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class DashboardController extends GetxController {
  final GetStoresUseCase getStoresUseCase;
  final GetNearbyStoresUseCase getNearbyStoresUseCase;
  final GetOrderByIdUseCase getOrderByIdUseCase;

  DashboardController({
    required this.getStoresUseCase,
    required this.getNearbyStoresUseCase,
    required this.getOrderByIdUseCase,
  });

  final RxList<StoreEntity> stores = <StoreEntity>[].obs;
  final RxList<Map<String, String?>> recentStores = <Map<String, String?>>[].obs;
  final RxBool isLoading = false.obs;
  final RxBool isStoreConfirmed = false.obs;
  final RxString selectedStoreId = ''.obs;
  final RxString selectedStoreName = ''.obs;
  final RxString selectedStoreAddress = ''.obs;
  final TextEditingController searchController = TextEditingController();

  // ── Active order (pending staff confirmation) ──────────────────────────────
  final Rx<OrderEntity?> activeOrder = Rx<OrderEntity?>(null);
  bool get hasActiveOrder => activeOrder.value != null;
  Timer? _pollingTimer;

  @override
  void onInit() {
    super.onInit();
    loadStores();
    _loadPendingOrder();
    _loadRecentStores();
  }

  Future<void> _loadRecentStores() async {
    final list = await LocalStorage.getRecentStores();
    recentStores.value = list;
  }

  Future<void> _loadPendingOrder() async {
    final order = await LocalStorage.loadPendingOrder();
    if (order != null) {
      activeOrder.value = order;
      _startPolling();
    }
  }

  /// Called by CartController immediately after a successful payment.
  void setActiveOrder(OrderEntity order) {
    activeOrder.value = order;
    _startPolling();
  }

  void _startPolling() {
    _pollingTimer?.cancel();
    _pollingTimer = Timer.periodic(
      const Duration(seconds: 15),
      (_) => _pollOrderStatus(),
    );
  }

  Future<void> _pollOrderStatus() async {
    final current = activeOrder.value;
    if (current == null) {
      _pollingTimer?.cancel();
      return;
    }
    try {
      final updated = await getOrderByIdUseCase.execute(current.id);
      activeOrder.value = updated;
      final status = updated.status.toLowerCase();
      if (status == 'completed' || status == 'cancelled') {
        await LocalStorage.clearPendingOrder();
        activeOrder.value = null;
        _pollingTimer?.cancel();
      }
    } catch (_) {
      // Silent — keep polling
    }
  }

  // ── Stores ─────────────────────────────────────────────────────────────────

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
    } catch (_) {
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
    _saveRecentStore(store);
  }

  void _saveRecentStore(StoreEntity store) {
    final entry = {'id': store.id, 'name': store.name, 'address': store.address};
    LocalStorage.addRecentStore(entry).then((_) => _loadRecentStores());
  }

  void confirmCurrentStore() {
    isStoreConfirmed.value = true;
  }

  List<String> get storeNames => stores.map((s) => s.name).toList();

  @override
  void onClose() {
    _pollingTimer?.cancel();
    searchController.dispose();
    super.onClose();
  }
}
