import 'package:dio/dio.dart';
import 'package:firebase_performance/firebase_performance.dart';
import 'package:get/get.dart' hide Response;

import '../app_logger.dart';
import '../crashlytics_service.dart';
import '../models/crash_category.dart';
import 'api_trace_service.dart';
import 'correlation_id_service.dart';
import 'request_context.dart';

const _cidHeader = 'x-correlation-id';
const _metricKey = '_dq_metric';

/// Production-grade Dio interceptor providing:
///   • Correlation ID injection (x-correlation-id header)
///   • Firebase Performance HttpMetric per request
///   • Structured request/response breadcrumbs
///   • Automatic error classification and Crashlytics reporting
///   • Payload size recording
///
/// Add as the FIRST interceptor so timing starts before auth headers are added:
///   dio.interceptors
///     ..add(DioObservabilityInterceptor())
///     ..add(AppDioInterceptor());
class DioObservabilityInterceptor extends Interceptor {
  @override
  void onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final ctx = RequestContext(
      correlationId: CorrelationIdService.generate(),
      method: options.method,
      path: options.path,
      startMs: DateTime.now().millisecondsSinceEpoch,
    );
    ctx.storeIn(options.extra);
    options.headers[_cidHeader] = ctx.correlationId;

    AppLogger.info(
      'HTTP',
      '→ ${ctx.method} ${ctx.path}  cid=${ctx.correlationId}',
    );

    final metric = await ApiTraceService.startHttpMetric(
      options.uri.toString(),
      ApiTraceService.methodFromString(options.method),
    );
    if (metric != null) options.extra[_metricKey] = metric;

    handler.next(options);
  }

  @override
  void onResponse(
    Response<dynamic> response,
    ResponseInterceptorHandler handler,
  ) async {
    final ctx = RequestContext.fromExtra(response.requestOptions.extra);
    final elapsed = ctx?.elapsedMs ?? 0;
    final status = response.statusCode ?? 0;

    AppLogger.info(
      'HTTP',
      '← $status  ${ctx?.path}  ${elapsed}ms  cid=${ctx?.correlationId}',
    );
    _breadcrumb('http_ok: ${ctx?.path} $status ${elapsed}ms');

    final metric =
        response.requestOptions.extra[_metricKey] as HttpMetric?;
    if (metric != null) {
      metric.httpResponseCode = status;
      final responseBodySize = _responseBodySize(response.data);
      if (responseBodySize != null) {
        metric.responsePayloadSize = responseBodySize;
      }
      await metric.stop();
    }

    handler.next(response);
  }

  @override
  void onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    final ctx = RequestContext.fromExtra(err.requestOptions.extra);
    final elapsed = ctx?.elapsedMs ?? 0;
    final errorClass = _classify(err);
    final status = err.response?.statusCode;

    AppLogger.error('HTTP', err, err.stackTrace);
    _breadcrumb(
      'http_err: ${ctx?.path} '
      '${status != null ? "$status " : ""}'
      '${errorClass.label}  ${elapsed}ms  cid=${ctx?.correlationId}',
    );

    if (Get.isRegistered<CrashlyticsService>()) {
      await Get.find<CrashlyticsService>().recordError(
        err,
        err.stackTrace,
        category: CrashCategory.api,
        reason: 'http_${errorClass.label}: ${ctx?.path} cid=${ctx?.correlationId}',
      );
    }

    final metric = err.requestOptions.extra[_metricKey] as HttpMetric?;
    if (metric != null) {
      if (status != null) metric.httpResponseCode = status;
      await metric.stop();
    }

    handler.next(err);
  }

  // ── Helpers ──────────────────────────────────────────────────────────────────

  ApiErrorClass _classify(DioException e) {
    return switch (e.type) {
      DioExceptionType.connectionTimeout ||
      DioExceptionType.sendTimeout ||
      DioExceptionType.receiveTimeout =>
        ApiErrorClass.timeout,
      DioExceptionType.badResponse
          when e.response?.statusCode == 401 =>
        ApiErrorClass.authFailure,
      DioExceptionType.badResponse
          when (e.response?.statusCode ?? 0) >= 500 =>
        ApiErrorClass.backendFailure,
      DioExceptionType.badResponse => ApiErrorClass.malformedResponse,
      DioExceptionType.cancel => ApiErrorClass.cancelled,
      _ => ApiErrorClass.networkUnavailable,
    };
  }

  int? _responseBodySize(dynamic data) {
    if (data is String) return data.length;
    if (data is List<int>) return data.length;
    if (data is Map) return data.toString().length;
    return null;
  }

  void _breadcrumb(String message) {
    if (!Get.isRegistered<CrashlyticsService>()) return;
    Get.find<CrashlyticsService>().log(message);
  }
}
