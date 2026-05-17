import 'package:dio/dio.dart';
import 'package:dq_app/src/utils/services/local_storage.dart';
import 'api_logger.dart';

class AppDioInterceptor extends Interceptor {
  @override
  void onRequest(
      RequestOptions options, RequestInterceptorHandler handler) async {

    final token = await LocalStorage.getAccessToken();

    if (token != null) {
      options.headers['Authorization'] = 'Bearer $token';
    }

    ApiLogger.logRequest(
      method: options.method,
      url: options.uri.toString(),
      headers: options.headers,
      body: options.data,
    );

    super.onRequest(options, handler);
  }

  @override
  void onResponse(
      Response response, ResponseInterceptorHandler handler) {

    ApiLogger.logResponse(
      url: response.requestOptions.uri.toString(),
      statusCode: response.statusCode ?? 0,
      data: response.data,
    );

    super.onResponse(response, handler);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {

    ApiLogger.logError(
      url: err.requestOptions.uri.toString(),
      statusCode: err.response?.statusCode,
      error: err.response?.data ?? err.message,
    );

    super.onError(err, handler);
  }
}
