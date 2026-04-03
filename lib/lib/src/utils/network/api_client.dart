import 'package:dio/dio.dart';
import 'package:dq_app/src/utils/network/api_result.dart';
import 'package:dq_app/src/utils/network/graphql_request.dart';
import 'package:dq_app/src/utils/services/app_toast.dart';
import 'package:dq_app/src/utils/services/network_connectivity.dart';

class ApiClient {
  final Dio _dio;

  ApiClient(this._dio);

  Future<ApiResult<T>> execute<T>({
    required GraphQLRequest request,
    required T Function(dynamic json) parser,
    bool showSuccessToast = false,
  }) async {
    final isConnected = await NetworkConnectivity.isConnected();
    if (!isConnected) {
      AppToast.error('No internet connection');
      return ApiFailure<T>('No internet connection'); // ✅ FIX
    }

    try {
      final response = await _dio.post(
        '',
        data: request.toJson(),
      );

      if (response.data['errors'] != null) {
        final message = response.data['errors'][0]['message'];
        AppToast.error(message);
        return ApiFailure<T>(message); // ✅ FIX
      }

      if (showSuccessToast) {
        AppToast.success('Request successful');
      }

      return ApiSuccess<T>(parser(response.data['data'])); // ✅ GOOD
    } on DioException catch (e) {
      final failure = _handleDioException<T>(e); // ✅ FIX
      AppToast.error(failure.message);
      return failure;
    } catch (_) {
      AppToast.error('Something went wrong');
      return ApiFailure<T>('Unexpected error'); // ✅ FIX
    }
  }

  ApiFailure<T> _handleDioException<T>(DioException e) {
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
        return ApiFailure<T>('Connection timeout');

      case DioExceptionType.receiveTimeout:
        return ApiFailure<T>('Response timeout');

      case DioExceptionType.sendTimeout:
        return ApiFailure<T>('Request timeout');

      case DioExceptionType.badResponse:
        return ApiFailure<T>(
          e.response?.data?['message'] ?? 'Server error',
          statusCode: e.response?.statusCode,
        );

      case DioExceptionType.cancel:
        return ApiFailure<T>('Request cancelled');

      default:
        return ApiFailure<T>('No internet connection');
    }
  }
}
