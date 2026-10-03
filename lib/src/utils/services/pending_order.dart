import 'package:dq_app/src/data/datasources/remote/order_remote_ds.dart';
import 'package:dq_app/src/domain/entity/order_entity.dart';
import 'package:dq_app/src/utils/services/local_storage.dart';

/// Checks the order saved on the device against the server.
///
/// Returns the order to keep showing — the server's fresh copy, saved over the
/// old one — or null when it should no longer be shown because it has exited,
/// been cancelled, or is unknown to this account; the saved copy is then
/// cleared. Offline or slow: keeps the saved copy, so a customer at the door
/// without signal can still show their exit QR.
Future<OrderEntity?> reconcilePendingOrder(
  OrderEntity saved,
  Future<OrderEntity> Function(String orderId) fetch, {
  Duration timeout = const Duration(seconds: 5),
}) async {
  try {
    final fresh = await fetch(saved.id).timeout(timeout);
    if (!fresh.canExit) {
      await LocalStorage.clearPendingOrder();
      return null;
    }
    await LocalStorage.savePendingOrder(fresh);
    return fresh;
  } on OrderNotFoundException {
    await LocalStorage.clearPendingOrder();
    return null;
  } catch (_) {
    return saved;
  }
}
