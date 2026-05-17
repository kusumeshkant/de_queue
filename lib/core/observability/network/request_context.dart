/// Classifies the root cause of an HTTP/API error.
/// Used to group errors in Crashlytics and to drive analytics.
enum ApiErrorClass {
  timeout,             // connection / send / receive timeout
  authFailure,         // 401 — token expired or missing
  serializationError,  // JSON parse failure or type mismatch
  networkUnavailable,  // no internet / connection refused / DNS failure
  backendFailure,      // 5xx response from backend
  malformedResponse,   // 2xx but response shape is invalid
  cancelled,           // request explicitly cancelled by caller
  unknown;

  String get label => name;
}

/// Immutable snapshot of a single HTTP request, threaded through Dio's
/// [RequestOptions.extra] map from onRequest → onResponse / onError.
final class RequestContext {
  final String correlationId;
  final String method;
  final String path;
  final int startMs;

  const RequestContext({
    required this.correlationId,
    required this.method,
    required this.path,
    required this.startMs,
  });

  int get elapsedMs => DateTime.now().millisecondsSinceEpoch - startMs;

  static const _key = '_dq_rctx';

  void storeIn(Map<String, dynamic> extra) => extra[_key] = this;

  static RequestContext? fromExtra(Map<String, dynamic> extra) =>
      extra[_key] as RequestContext?;
}
