import 'dart:developer';

class AppLogger {
  static void logRequest({
    required String operationName,
    required String query,
    Map<String, dynamic>? variables,
  }) {
    log("🚀 GRAPHQL REQUEST");
    log("Operation: $operationName");
    log("Query: $query");
    log("Variables: ${variables ?? {}}");
  }

  static void logResponse(dynamic data) {
    log("✅ GRAPHQL RESPONSE");
    log("Data: $data");
  }

  static void logError(dynamic error) {
    log("❌ GRAPHQL ERROR");
    log("Error: $error");
  }
}