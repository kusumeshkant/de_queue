
import 'package:connectivity_plus/connectivity_plus.dart';

class NetworkConnectivity {
  static final Connectivity _connectivity = Connectivity();

  static Future<bool> isConnected() async {
    final result = await _connectivity.checkConnectivity();
    return result.isNotEmpty && result.any((r) => r != ConnectivityResult.none);
  }
}
