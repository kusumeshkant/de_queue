import 'package:dq_app/src/presentation/dashBoard/dashboard_view_model.dart';
import 'package:dq_app/src/presentation/dashBoard/navigation_controller.dart';
import 'package:dq_app/src/service_core/auth/session_manager.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'graphql_logging_link.dart';

class GraphQLClientProvider {
  static GraphQLClient? _client;
  static String? _baseUrl;

  static Future<void> init({required String baseUrl, String? token}) async {
    _baseUrl = baseUrl;
    _client = _buildClient(baseUrl);
  }

  static GraphQLClient _buildClient(String baseUrl) {
    final HttpLink httpLink = HttpLink(baseUrl);

    // Dynamically fetch a fresh Firebase ID token on every request.
    // Firebase SDK returns a cached token when valid and auto-refreshes
    // transparently when it is close to expiry.
    final AuthLink authLink = AuthLink(
      getToken: () async {
        final user = FirebaseAuth.instance.currentUser;
        if (user == null) return null;
        final token = await user.getIdToken();
        return token != null ? 'Bearer $token' : null;
      },
    );

    // Catches UNAUTHENTICATED errors (token truly expired server-side),
    // force-refreshes the Firebase token, then retries the original request.
    // If the retry also fails, or if there is no current user, the session
    // is expired and the user is sent back to the login screen.
    final ErrorLink errorLink = ErrorLink(
      onGraphQLError: (request, forward, response) async* {
        final hasUnauthenticated = response.errors?.any(
              (e) => e.extensions?['code'] == 'UNAUTHENTICATED',
            ) ??
            false;

        if (!hasUnauthenticated) {
          yield response;
          return;
        }

        final user = FirebaseAuth.instance.currentUser;
        if (user == null) {
          _cleanUpSessionState();
          await SessionManager.expireSession();
          return;
        }

        try {
          // Force a server-side token refresh
          await user.getIdToken(true);
        } catch (_) {
          _cleanUpSessionState();
          await SessionManager.expireSession();
          return;
        }

        // Retry the original request — AuthLink will pick up the fresh token
        await for (final result in forward(request)) {
          final retryFailed = result.errors?.any(
                (e) => e.extensions?['code'] == 'UNAUTHENTICATED',
              ) ??
              false;

          if (retryFailed) {
            _cleanUpSessionState();
            await SessionManager.expireSession();
            return;
          }
          yield result;
        }
      },
    );

    return GraphQLClient(
      cache: GraphQLCache(store: InMemoryStore()),
      link: Link.from([LoggingLink(), errorLink, authLink, httpLink]),
    );
  }

  static void _cleanUpSessionState() {
    try {
      Get.find<NavigationController>().goToHome();
    } catch (_) {}
    Get.delete<DashboardController>(force: true);
  }

  static GraphQLClient get client {
    if (_client == null) {
      throw Exception('GraphQLClient not initialized. Call init() first.');
    }
    return _client!;
  }
}
