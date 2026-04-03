import 'package:dq_app/src/service_core/networks/graphql_client_provider.dart';
import 'package:graphql/client.dart';

class NotificationRemoteDataSource {
  static const _updateFcmTokenMutation = r'''
    mutation UpdateFcmToken($token: String!) {
      updateFcmToken(token: $token)
    }
  ''';

  Future<void> updateFcmToken(String token) async {
    final client = GraphQLClientProvider.client;
    await client.mutate(
      MutationOptions(
        document: gql(_updateFcmTokenMutation),
        variables: {'token': token},
      ),
    );
  }
}
