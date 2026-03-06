import 'package:graphql_flutter/graphql_flutter.dart';
import 'graphql_logging_link.dart';

class GraphQLClientProvider {
  static GraphQLClient? _client;

  static Future<void> init({required String baseUrl, String? token}) async {
    final HttpLink httpLink = HttpLink(baseUrl);

    final AuthLink authLink = AuthLink(
      getToken: () async => token != null ? "Bearer $token" : null,
    );

    final Link link = Link.from([LoggingLink(), authLink, httpLink]);

    _client = GraphQLClient(
      cache: GraphQLCache(store: InMemoryStore()),
      link: link,
    );
  }

  static GraphQLClient get client {
    if (_client == null) {
      throw Exception("GraphQLClient not initialized. Call init() first.");
    }
    return _client!;
  }
}
