import 'package:graphql/client.dart';
import 'package:dq_app/core/observability/app_logger.dart';

class LoggingLink extends Link {
  @override
  Stream<Response> request(Request request, [NextLink? forward]) {
    if (forward == null) {
      throw Exception("NextLink is null");
    }

    AppLogger.logRequest(
      operationName: request.operation.operationName ?? "Unnamed",
      query: request.operation.document.toString(),
      variables: request.variables,
    );

    return forward(request).map((response) {
      if (response.errors != null && response.errors!.isNotEmpty) {
        AppLogger.logError(response.errors);
      } else {
        AppLogger.logResponse(response.data);
      }
      return response;
    });
  }
}