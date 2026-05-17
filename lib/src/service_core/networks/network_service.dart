import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';

class NetworkService extends GetxService {
  final _isConnected = true.obs;

  bool get isConnected => _isConnected.value;

  @override
  void onInit() {
    super.onInit();
    _init();
  }

  Future<void> _init() async {
    // Set initial state
    final result = await Connectivity().checkConnectivity();
    _isConnected.value = _hasConnection(result);

    // Listen for changes throughout app lifetime
    Connectivity().onConnectivityChanged.listen((result) {
      final connected = _hasConnection(result);
      if (!connected && _isConnected.value) {
        _showToast('No internet connection', Colors.red.shade700);
      } else if (connected && !_isConnected.value) {
        _showToast('Back online', Colors.green.shade600);
      }
      _isConnected.value = connected;
    });
  }

  bool _hasConnection(List<ConnectivityResult> results) {
    return results.any((r) => r != ConnectivityResult.none);
  }

  /// Call before every API request.
  /// Shows a toast and returns false if offline.
  bool checkAndWarn() {
    if (!_isConnected.value) {
      _showToast('No internet connection', Colors.red.shade700);
      return false;
    }
    return true;
  }

  static void _showToast(String msg, Color color) {
    Fluttertoast.showToast(
      msg: msg,
      backgroundColor: color,
      textColor: Colors.white,
      gravity: ToastGravity.BOTTOM,
      toastLength: Toast.LENGTH_LONG,
    );
  }

  /// Shows a "slow connection" warning toast (call after a delay if still loading).
  static void warnSlowNetwork() {
    _showToast('Slow connection, please wait…', Colors.orange.shade700);
  }

  /// Shows a "request timed out" toast.
  static void warnTimeout() {
    _showToast('Request timed out. Check your connection.', Colors.red.shade700);
  }
}
