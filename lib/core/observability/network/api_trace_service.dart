import 'package:firebase_performance/firebase_performance.dart';

import '../../../src/constants/app_config.dart';

/// Thin facade over [FirebasePerformance.newHttpMetric] for Dio requests.
///
/// Returns null in dev so there is zero Firebase SDK overhead during local
/// development. Firebase Performance's own collection toggle handles the
/// UAT → prod transition automatically.
abstract final class ApiTraceService {
  /// Starts an [HttpMetric] for the given [url] and HTTP [method].
  /// Returns null in dev builds. Caller must call [HttpMetric.stop] when done.
  static Future<HttpMetric?> startHttpMetric(
    String url,
    HttpMethod method,
  ) async {
    if (AppConfig.isDev) return null;
    final metric =
        FirebasePerformance.instance.newHttpMetric(url, method);
    await metric.start();
    return metric;
  }

  /// Maps a Dio/http method string to [HttpMethod].
  static HttpMethod methodFromString(String method) {
    return switch (method.toUpperCase()) {
      'GET'     => HttpMethod.Get,
      'HEAD'    => HttpMethod.Head,
      'POST'    => HttpMethod.Post,
      'PUT'     => HttpMethod.Put,
      'PATCH'   => HttpMethod.Patch,
      'DELETE'  => HttpMethod.Delete,
      'OPTIONS' => HttpMethod.Options,
      'CONNECT' => HttpMethod.Connect,
      'TRACE'   => HttpMethod.Trace,
      _         => HttpMethod.Get,
    };
  }
}
