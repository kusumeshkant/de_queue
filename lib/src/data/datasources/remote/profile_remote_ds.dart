import 'package:dq_app/src/data/model/user_model.dart';
import 'package:dq_app/src/service_core/networks/graphql_service.dart';

class ProfileRemoteDataSource {
  Future<UserModel> getProfile() async {
    const query = '''
      query {
        me {
          id
          phone
          name
          email
        }
      }
    ''';

    final result = await GraphQLService.performQuery(query: query);
    final data = result.data?['me'];
    if (data == null) throw Exception('Profile not found');

    // Silently ensure customer role exists on backend (handles admin/staff using DQ App)
    _ensureCustomerRole();

    return UserModel.fromJson(data);
  }

  void _ensureCustomerRole() {
    const mutation = '''
      mutation {
        ensureCustomerRole
      }
    ''';
    GraphQLService.performMutation(mutation: mutation, variables: {}).catchError((_) {});
  }

  Future<UserModel> updateProfile({required String name}) async {
    const mutation = '''
      mutation UpdateProfile(\$name: String!) {
        updateProfile(name: \$name) {
          id
          phone
          name
          email
        }
      }
    ''';

    final result = await GraphQLService.performMutation(
      mutation: mutation,
      variables: {'name': name},
    );
    final data = result.data?['updateProfile'];
    if (data == null) throw Exception('Failed to update profile');
    return UserModel.fromJson(data);
  }
}
