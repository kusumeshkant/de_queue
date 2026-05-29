import 'package:dq_app/src/constants/app_config.dart';
import 'package:dq_app/src/service_core/auth/session_manager.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:dq_app/core/observability/app_logger.dart';
import 'graphql_logging_link.dart';
import 'graphql_observability_link.dart';

class GraphQLClientProvider {
  static GraphQLClient? _client;

  // Legacy entry-point kept for main.dart cold-start init.
  // Prefer reinitWithToken() after login/logout.
  static Future<void> init({required String baseUrl}) async {
    _client = _buildClient(baseUrl);
  }

  // Rebuilds the client (clears in-memory cache) and re-reads the current
  // Firebase ID token via AuthLink on the very next request.
  // Call this immediately after Firebase login or whenever the token changes.
  static Future<void> reinitWithToken() async {
    _client = _buildClient(AppConfig.graphqlEndpoint);
  }

  // Drops the client entirely. Call this on logout so that any in-flight
  // requests after signOut cannot piggy-back on a stale client instance.
  static void reset() => _client = null;

  static GraphQLClient _buildClient(String baseUrl) {
    final HttpLink httpLink = HttpLink(baseUrl);

    // Dynamically fetch a fresh Firebase ID token on every request.
    // Firebase SDK returns a cached token when valid and auto-refreshes
    // transparently when it is close to expiry.
    final AuthLink authLink = AuthLink(
      getToken: () async {
        final user = FirebaseAuth.instance.currentUser;
        if (user == null) {
          AppLogger.logGraphQLAuth(tokenAttached: false);
          return null;
        }
        final token = await user.getIdToken();
        AppLogger.logGraphQLAuth(tokenAttached: token != null, uid: user.uid);
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
          await SessionManager.expireSession();
          return;
        }

        try {
          await user.getIdToken(true); // force server-side refresh
        } catch (_) {
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
            await SessionManager.expireSession();
            return;
          }
          yield result;
        }
      },
    );

    return GraphQLClient(
      cache: GraphQLCache(store: InMemoryStore()),
      link: Link.from([GraphQLObservabilityLink(), LoggingLink(), errorLink, authLink, httpLink]),
    );
  }

  static GraphQLClient get client {
    if (_client == null) {
      throw Exception('GraphQLClient not initialized. Call init() first.');
    }
    return _client!;
  }

  // Minimal client without ErrorLink — used during auth mutations (login,
  // registerAsCustomer) so that an UNAUTHENTICATED backend response does not
  // trigger SessionManager.expireSession() mid-flow while the user is actively
  // trying to authenticate.
  static GraphQLClient buildLoginClient() {
    final HttpLink httpLink = HttpLink(AppConfig.graphqlEndpoint);
    final AuthLink authLink = AuthLink(
      getToken: () async {
        final user = FirebaseAuth.instance.currentUser;
        if (user == null) return null;
        final token = await user.getIdToken();
        return token != null ? 'Bearer $token' : null;
      },
    );
    return GraphQLClient(
      cache: GraphQLCache(store: InMemoryStore()),
      link: authLink.concat(httpLink),
    );
  }
}
