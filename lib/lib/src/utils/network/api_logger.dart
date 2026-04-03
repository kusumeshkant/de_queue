import 'dart:developer';

class ApiLogger {
  static void logRequest({
    required String method,
    required String url,
    required Map<String, dynamic>? headers,
    required dynamic body,
  }) {
    log("➡️ REQUEST [$method]");
    log("URL: $url");
    log("HEADERS: $headers");
    log("BODY: $body");
  }

  static void logResponse({
    required String url,
    required int statusCode,
    required dynamic data,
  }) {
    log("✅ RESPONSE [$statusCode]");
    log("URL: $url");
    log("DATA: $data");
  }

  static void logError({
    required String url,
    required int? statusCode,
    required dynamic error,
  }) {
    log("❌ ERROR [$statusCode]");
    log("URL: $url");
    log("ERROR: $error");
  }
}
