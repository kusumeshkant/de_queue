enum DbTable {
  users,
  auth,
  settings,
}

extension DbTableExt on DbTable {
  String get name {
    switch (this) {
      case DbTable.users:
        return 'users';
      case DbTable.auth:
        return 'auth';
      case DbTable.settings:
        return 'settings';
    }
  }
}
