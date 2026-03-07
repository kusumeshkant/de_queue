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
    return UserModel.fromJson(data);
  }

  Future<UserModel> updateProfile({String? name, String? email}) async {
    const mutation = '''
      mutation UpdateProfile(\$name: String, \$email: String) {
        updateProfile(name: \$name, email: \$email) {
          id
          phone
          name
          email
        }
      }
    ''';

    final variables = <String, dynamic>{};
    if (name != null) variables['name'] = name;
    if (email != null) variables['email'] = email;

    final result = await GraphQLService.performMutation(
      mutation: mutation,
      variables: variables,
    );
    final data = result.data?['updateProfile'];
    if (data == null) throw Exception('Failed to update profile');
    return UserModel.fromJson(data);
  }
}
