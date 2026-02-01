enum DbTable {
  users,
  auth,
}





extension DbTableExt on DbTable {
  String get name {
    switch (this) {
      case DbTable.users:
        return 'users';
      case DbTable.auth:
        return 'auth';
    }
  }
}
