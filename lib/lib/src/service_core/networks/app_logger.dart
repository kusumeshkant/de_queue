import 'dart:developer' as dev;

class AppLogger {
  // ANSI color codes (visible in Android Studio / VS Code terminal)
  static const _reset = '\x1B[0m';
  static const _green = '\x1B[32m';
  static const _red = '\x1B[31m';
  static const _cyan = '\x1B[36m';

  static void logRequest({
    required String operationName,
    required String query,
    Map<String, dynamic>? variables,
  }) {
    dev.log(
      '$_cyan🚀 GRAPHQL REQUEST\n'
      'Operation: $operationName\n'
      'Query: $query\n'
      'Variables: ${variables ?? {}}$_reset',
      name: 'GQL:REQUEST',
      level: 500,
    );
  }

  static void logResponse(dynamic data) {
    dev.log(
      '$_green✅ GRAPHQL RESPONSE\n'
      'Data: $data$_reset',
      name: 'GQL:SUCCESS',
      level: 500,
    );
  }

  static void logError(dynamic error) {
    dev.log(
      '$_red❌ GRAPHQL ERROR\n'
      'Error: $error$_reset',
      name: 'GQL:ERROR',
      level: 1000, // DevTools renders level >= 900 in red
    );
  }

  static void logNetwork(String msg) {
    dev.log(
      '$_red🔴 NETWORK: $msg$_reset',
      name: 'NETWORK',
      level: 1000,
    );
  }
}
