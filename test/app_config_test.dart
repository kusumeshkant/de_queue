import 'package:dq_app/src/constants/app_config.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  // Run without --dart-define: the default flavor is prod and the production
  // backend must be selected. (A GRAPHQL_ENDPOINT override is ignored for prod.)
  test('default build is prod and targets the production backend', () {
    expect(AppConfig.isProd, isTrue);
    expect(AppConfig.graphqlEndpoint, 'https://de-backend-iota.vercel.app/graphql');
  });
}
