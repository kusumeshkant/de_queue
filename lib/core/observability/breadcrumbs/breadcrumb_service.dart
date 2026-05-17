import 'dart:collection';

import 'package:flutter/foundation.dart';
import 'package:get/get.dart';

import '../crashlytics_service.dart';
import 'breadcrumb.dart';

/// Maximum number of breadcrumbs retained in memory.
/// Old entries are evicted when the buffer is full (ring buffer behaviour).
const _kCapacity = 50;

/// Structured, bounded breadcrumb buffer.
///
/// Maintains the last [_kCapacity] events across navigation, API calls,
/// user actions, and auth state changes. On crash, call [flushToCrashlytics]
/// to write the buffer to Crashlytics as ordered breadcrumbs.
///
/// Thread-safety: Dart's single-threaded event loop makes this safe.
class BreadcrumbService extends GetxService {
  final Queue<Breadcrumb> _buffer = Queue();

  /// Adds a structured breadcrumb to the ring buffer.
  void add(
    BreadcrumbCategory category,
    String message, {
    Map<String, Object>? metadata,
  }) {
    if (_buffer.length >= _kCapacity) _buffer.removeFirst();
    _buffer.addLast(Breadcrumb(
      message: message,
      category: category,
      metadata: metadata,
    ));
    if (kDebugMode) {
      debugPrint('[Breadcrumb] ${_buffer.last.toLogString()}');
    }
  }

  // ── Typed convenience methods ────────────────────────────────────────────────

  void navigation(String screen) =>
      add(BreadcrumbCategory.navigation, 'nav→$screen');

  void apiCall(String operation, {String? correlationId}) => add(
        BreadcrumbCategory.api,
        'api: $operation',
        metadata: correlationId != null ? {'cid': correlationId} : null,
      );

  void apiError(String operation, String errorMsg, {String? correlationId}) =>
      add(
        BreadcrumbCategory.api,
        'api_err: $operation — $errorMsg',
        metadata: correlationId != null ? {'cid': correlationId} : null,
      );

  void userAction(String action, {Map<String, Object>? metadata}) =>
      add(BreadcrumbCategory.userAction, action, metadata: metadata);

  void auth(String event) => add(BreadcrumbCategory.auth, event);

  void payment(String event, {Map<String, Object>? metadata}) =>
      add(BreadcrumbCategory.payment, event, metadata: metadata);

  void scanner(String event) => add(BreadcrumbCategory.scanner, event);

  void checkout(String event, {Map<String, Object>? metadata}) =>
      add(BreadcrumbCategory.checkout, event, metadata: metadata);

  // ── Buffer access ────────────────────────────────────────────────────────────

  /// Ordered snapshot of the current buffer (oldest → newest).
  List<Breadcrumb> get snapshot => List.unmodifiable(_buffer);

  int get length => _buffer.length;

  /// Writes all buffered breadcrumbs to Crashlytics in order.
  /// Call this immediately before recording a fatal error.
  Future<void> flushToCrashlytics() async {
    if (!Get.isRegistered<CrashlyticsService>()) return;
    final svc = Get.find<CrashlyticsService>();
    for (final crumb in _buffer) {
      svc.log(crumb.toLogString());
    }
  }
}
