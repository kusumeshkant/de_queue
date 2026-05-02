
import 'dart:convert';
import 'package:dq_app/src/domain/entity/order_entity.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocalStorage {
  static const _accessTokenKey = 'access_token';
  static const _refreshTokenKey = 'refresh_token';
  static const _pendingOrderKey = 'pending_order';

  static Future<void> saveAccessToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_accessTokenKey, token);
  }

  static Future<String?> getAccessToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_accessTokenKey);
  }

  static Future<void> saveRefreshToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_refreshTokenKey, token);
  }

  static Future<String?> getRefreshToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_refreshTokenKey);
  }

  static Future<void> clearAll() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }

  // ── Recently Visited Stores ────────────────────────────────────────────────

  static const _recentStoresKey = 'recent_stores';
  static const _maxRecentStores = 6;

  /// Saves a visited store (id, name, address) to the recent list.
  static Future<void> addRecentStore(Map<String, String?> store) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_recentStoresKey);
    final List<dynamic> list = raw != null ? jsonDecode(raw) as List : [];
    // Remove if already present, then insert at front
    list.removeWhere((e) => e['id'] == store['id']);
    list.insert(0, store);
    if (list.length > _maxRecentStores) list.removeLast();
    await prefs.setString(_recentStoresKey, jsonEncode(list));
  }

  static Future<List<Map<String, String?>>> getRecentStores() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_recentStoresKey);
    if (raw == null) return [];
    final list = jsonDecode(raw) as List;
    return list.map((e) => Map<String, String?>.from(e as Map)).toList();
  }

  // ── Pending Order Confirmation ─────────────────────────────────────────────

  static Future<void> savePendingOrder(OrderEntity order) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _pendingOrderKey,
      jsonEncode({
        'id': order.id,
        'storeName': order.storeName,
        'total': order.total,
        'tax': order.tax,
        'grandTotal': order.grandTotal,
        'status': order.status,
        'paymentStatus': order.paymentStatus,
        'createdAt': order.createdAt,
        'items': order.items
            .map((i) => {
                  'barcode': i.barcode,
                  'name': i.name,
                  'price': i.price,
                  'quantity': i.quantity,
                  'sku': i.sku,
                  'description': i.description,
                })
            .toList(),
      }),
    );
  }

  static Future<OrderEntity?> loadPendingOrder() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_pendingOrderKey);
    if (raw == null) return null;
    try {
      final m = jsonDecode(raw) as Map<String, dynamic>;
      return OrderEntity(
        id: m['id'] as String,
        storeName: m['storeName'] as String?,
        total: (m['total'] as num).toDouble(),
        tax: (m['tax'] as num).toDouble(),
        grandTotal: (m['grandTotal'] as num).toDouble(),
        status: m['status'] as String,
        paymentStatus: m['paymentStatus'] as String? ?? 'success',
        createdAt: m['createdAt'] as String,
        items: (m['items'] as List)
            .map((i) => OrderItemEntity(
                  barcode: i['barcode'] as String,
                  name: i['name'] as String,
                  price: (i['price'] as num).toDouble(),
                  quantity: i['quantity'] as int,
                  sku: i['sku'] as String?,
                  description: i['description'] as String?,
                ))
            .toList(),
      );
    } catch (_) {
      await prefs.remove(_pendingOrderKey);
      return null;
    }
  }

  static Future<void> clearPendingOrder() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_pendingOrderKey);
  }
}
