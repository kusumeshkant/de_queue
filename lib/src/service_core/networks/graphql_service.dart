import 'dart:async';

import 'package:dq_app/src/service_core/auth/session_manager.dart';
import 'package:get/get.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:dq_app/core/observability/app_logger.dart';
import 'graphql_client_provider.dart';
import 'network_service.dart';

/// How long to wait before showing a "slow connection" toast.
const _kSlowWarningDuration = Duration(seconds: 6);

/// Hard timeout — request is abandoned after this.
const _kTimeoutDuration = Duration(seconds: 20);

class GraphQLService {
  /// GLOBAL QUERY METHOD
  static Future<QueryResult> performQuery({
    required String query,
    Map<String, dynamic>? variables,
    FetchPolicy fetchPolicy = FetchPolicy.networkOnly,
  }) async {
    _assertNetwork();

    final options = QueryOptions(
      document: gql(query),
      variables: variables ?? {},
      fetchPolicy: fetchPolicy,
    );

    return _withSlowNetworkGuard(
      () => GraphQLClientProvider.client.query(options),
    ).then((result) async {
      await _handleException(result);
      return result;
    });
  }

  /// GLOBAL MUTATION METHOD
  static Future<QueryResult> performMutation({
    required String mutation,
    Map<String, dynamic>? variables,
  }) async {
    _assertNetwork();

    final options = MutationOptions(
      document: gql(mutation),
      variables: variables ?? {},
    );

    return _withSlowNetworkGuard(
      () => GraphQLClientProvider.client.mutate(options),
    ).then((result) async {
      await _handleException(result);
      return result;
    });
  }

  // ---------------------------------------------------------------------------
  // Helpers
  // ---------------------------------------------------------------------------

  /// Checks network connectivity and throws immediately if offline.
  static void _assertNetwork() {
    final network = Get.find<NetworkService>();
    if (!network.checkAndWarn()) {
      AppLogger.logNetwork('Request blocked — no internet connection');
      throw Exception('NO_NETWORK');
    }
  }

  /// Wraps a GraphQL call with:
  ///  - a "slow connection" toast after [_kSlowWarningDuration]
  ///  - a hard timeout after [_kTimeoutDuration]
  static Future<QueryResult> _withSlowNetworkGuard(
    Future<QueryResult> Function() call,
  ) async {
    Timer? slowTimer;

    try {
      slowTimer = Timer(_kSlowWarningDuration, NetworkService.warnSlowNetwork);

      return await call().timeout(
        _kTimeoutDuration,
        onTimeout: () {
          NetworkService.warnTimeout();
          AppLogger.logNetwork('Request timed out after ${_kTimeoutDuration.inSeconds}s');
          throw Exception('TIMEOUT');
        },
      );
    } finally {
      slowTimer?.cancel();
    }
  }

  static Future<void> _handleException(QueryResult result) async {
    if (!result.hasException) return;

    // UNAUTHENTICATED GraphQL errors are handled by ErrorLink inside
    // GraphQLClientProvider (force-refresh → retry → expireSession).
    // By the time a result reaches here, ErrorLink has already resolved any
    // token expiry. We only need to handle the HTTP-level 401 path that
    // ErrorLink cannot intercept (a raw 401 is a linkException, not a
    // GraphQL error, so onGraphQLError never fires for it).
    final linkEx = result.exception?.linkException;
    if (linkEx is HttpLinkServerException && linkEx.response.statusCode == 401) {
      await SessionManager.expireSession();
      throw Exception('SESSION_EXPIRED');
    }

    // Any other error — throw normally so callers can handle it.
    throw Exception(result.exception.toString());
  }
}
