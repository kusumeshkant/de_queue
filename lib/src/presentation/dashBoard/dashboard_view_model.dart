import 'dart:async';

import 'package:dq_app/src/data/datasources/remote/order_remote_ds.dart';
import 'package:dq_app/src/domain/entity/order_entity.dart';
import 'package:dq_app/src/domain/entity/store_entity.dart';
import 'package:dq_app/src/domain/usecase/get_nearby_stores_usecase.dart';
import 'package:dq_app/src/domain/usecase/get_order_by_id_usecase.dart';
import 'package:dq_app/src/domain/usecase/get_store_by_code_usecase.dart';
import 'package:dq_app/src/domain/usecase/get_stores_usecase.dart';
import 'package:dq_app/src/service_core/location/location_service.dart';
import 'package:dq_app/src/utils/services/local_storage.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class DashboardController extends GetxController {
  final GetStoresUseCase getStoresUseCase;
  final GetNearbyStoresUseCase getNearbyStoresUseCase;
  final GetOrderByIdUseCase getOrderByIdUseCase;
  final GetStoreByCodeUseCase getStoreByCodeUseCase;

  DashboardController({
    required this.getStoresUseCase,
    required this.getNearbyStoresUseCase,
    required this.getOrderByIdUseCase,
    required this.getStoreByCodeUseCase,
  });

  final RxList<StoreEntity> stores = <StoreEntity>[].obs;
  final RxList<Map<String, String?>> recentStores = <Map<String, String?>>[].obs;
  final RxBool isLoading = false.obs;
  final RxBool isStoreConfirmed = false.obs;
  // Fired once after loadStores() completes — regardless of success or failure.
  // DashboardPage watches this to show the store-selection prompt.
  final RxBool needsStoreSelection = false.obs;
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
      await refreshActiveOrder(); // don't show a stale order for 15 s
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

  Future<void> _pollOrderStatus() => refreshActiveOrder();

  /// Re-reads the saved order from the server. Once it has exited or been
  /// cancelled (or the server no longer knows it for this account), the saved
  /// copy is dropped; otherwise it is refreshed so the exit QR stays current.
  Future<void> refreshActiveOrder() async {
    final current = activeOrder.value;
    if (current == null) {
      _pollingTimer?.cancel();
      return;
    }
    try {
      final updated = await getOrderByIdUseCase.execute(current.id);
      if (!updated.canExit) {
        await _dropActiveOrder();
      } else {
        activeOrder.value = updated;
        await LocalStorage.savePendingOrder(updated);
      }
    } on OrderNotFoundException {
      await _dropActiveOrder();
    } catch (_) {
      // Network or server hiccup — keep the saved order and try again later.
    }
  }

  Future<void> _dropActiveOrder() async {
    await LocalStorage.clearPendingOrder();
    activeOrder.value = null;
    _pollingTimer?.cancel();
  }

  // ── Store code lookup (web primary, mobile fallback) ──────────────────────

  final RxBool isLookingUpCode = false.obs;
  final RxString codeLookupError = ''.obs;

  /// Looks up a store by its code and selects it if found.
  /// Returns true on success, false on not-found or error.
  Future<bool> lookupStoreByCode(String code) async {
    final trimmed = code.trim();
    if (trimmed.isEmpty) {
      codeLookupError.value = 'Please enter a store code.';
      return false;
    }
    isLookingUpCode.value = true;
    codeLookupError.value = '';
    try {
      final store = await getStoreByCodeUseCase.execute(trimmed);
      if (store == null) {
        codeLookupError.value = 'Store not found. Please check the code and try again.';
        return false;
      }
      selectStore(store);
      return true;
    } catch (_) {
      codeLookupError.value = 'Could not reach server. Check your connection and try again.';
      return false;
    } finally {
      isLookingUpCode.value = false;
    }
  }

  // ── Stores ─────────────────────────────────────────────────────────────────

  Future<void> loadStores() async {
    // On web, GPS and store list are unavailable. Store is set lazily via
    // code entry when the customer taps the scanner.
    if (kIsWeb) return;


    isLoading.value = true;
    try {
      List<StoreEntity> result;
      try {
        final position = await LocationService.getCurrentPosition();
        if (position != null) {
          result = await getNearbyStoresUseCase.execute(
              position.latitude, position.longitude);
        } else {
          result = await getStoresUseCase.execute();
        }
      } catch (_) {
        // GPS timeout / error → fall through to all-stores fetch
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
      // Always signal the view — even if stores failed to load.
      // The view decides what to show (list vs code entry).
      if (!isStoreConfirmed.value) needsStoreSelection.value = true;
    }
  }

  /// Directly switches to the given store (no cart check — caller handles that).
  void selectStore(StoreEntity store) {
    selectedStoreId.value = store.id;
    selectedStoreName.value = store.name;
    selectedStoreAddress.value = store.address ?? '';
    isStoreConfirmed.value = true;
    needsStoreSelection.value = false;
    _saveRecentStore(store);
  }

  void _saveRecentStore(StoreEntity store) {
    final entry = {'id': store.id, 'name': store.name, 'address': store.address};
    LocalStorage.addRecentStore(entry).then((_) => _loadRecentStores());
  }

  void confirmCurrentStore() {
    isStoreConfirmed.value = true;
    needsStoreSelection.value = false;
  }

  List<String> get storeNames => stores.map((s) => s.name).toList();

  @override
  void onClose() {
    _pollingTimer?.cancel();
    searchController.dispose();
    super.onClose();
  }
}
