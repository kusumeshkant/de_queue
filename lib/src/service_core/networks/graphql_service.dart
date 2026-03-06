import 'package:dq_app/src/service_core/auth/session_manager.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'graphql_client_provider.dart';

class GraphQLService {
  /// GLOBAL QUERY METHOD
  static Future<QueryResult> performQuery({
    required String query,
    Map<String, dynamic>? variables,
    FetchPolicy fetchPolicy = FetchPolicy.networkOnly,
  }) async {
    final options = QueryOptions(
      document: gql(query),
      variables: variables ?? {},
      fetchPolicy: fetchPolicy,
    );

    final result = await GraphQLClientProvider.client.query(options);

    await _handleException(result);

    return result;
  }

  /// GLOBAL MUTATION METHOD
  static Future<QueryResult> performMutation({
    required String mutation,
    Map<String, dynamic>? variables,
  }) async {
    final options = MutationOptions(
      document: gql(mutation),
      variables: variables ?? {},
    );

    final result = await GraphQLClientProvider.client.mutate(options);

    await _handleException(result);

    return result;
  }

  static Future<void> _handleException(QueryResult result) async {
    if (!result.hasException) return;

    // Check GraphQL-level auth errors (UNAUTHENTICATED from server)
    final graphqlErrors = result.exception?.graphqlErrors ?? [];
    for (final error in graphqlErrors) {
      final code = error.extensions?['code'] as String?;
      final msg = error.message.toLowerCase();
      if (code == 'UNAUTHENTICATED' ||
          msg.contains('unauthenticated') ||
          msg.contains('unauthorized') ||
          msg.contains('jwt expired') ||
          msg.contains('token expired') ||
          msg.contains('invalid token')) {
        await SessionManager.expireSession();
        // Throw a specific error so the caller stops processing
        throw Exception('SESSION_EXPIRED');
      }
    }

    // Check HTTP-level 401 (network link error)
    final linkEx = result.exception?.linkException;
    if (linkEx is HttpLinkServerException && linkEx.response.statusCode == 401) {
      await SessionManager.expireSession();
      throw Exception('SESSION_EXPIRED');
    }

    // Any other error — throw normally
    throw Exception(result.exception.toString());
  }
}
