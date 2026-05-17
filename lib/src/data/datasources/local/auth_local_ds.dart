import 'package:dq_app/core/enums/db_tables_enums.dart';
import 'package:dq_app/core/manager/hive_manager.dart';
import 'package:dq_app/src/domain/entity/auth_entity.dart';

class AuthLocalDataSource {
  Future<void> save(AuthEntity auth) async {
    await HiveManager.put(
      DbTable.auth,
      'current',
      // Do NOT persist the Firebase ID token — it expires in 1 hour and is
      // fetched dynamically by AuthLink on every GraphQL request. Storing it
      // here would leave a stale token in Hive that is never read for auth.
      {'isLoggedIn': auth.isLoggedIn},
    );
  }

  AuthEntity? get() {
    final data = HiveManager.get(DbTable.auth, 'current');
    if (data == null) return null;

    return AuthEntity(
      token:  data['token'],
      isLoggedIn:   data['isLoggedIn'],
    );
  }

  Future<void> clear() async {
    await HiveManager.clear(DbTable.auth);
  }
}
