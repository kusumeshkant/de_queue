import 'package:dq_app/core/enums/db_tables_enums.dart';
import 'package:hive_flutter/hive_flutter.dart';

class HiveManager {
  HiveManager._();

  static Future<void> init() async {
    await Hive.initFlutter();

    for (final table in DbTable.values) {
      await Hive.openBox(table.name);
    }
  }

  static Box box(DbTable table) {
    return Hive.box(table.name);
  }

  // CREATE / UPDATE
  static Future<void> put(
    DbTable table,
    String key,
    Map<String, dynamic> value,
  ) async {
    await box(table).put(key, value);
  }

  // READ ONE
  static Map<String, dynamic>? get(
    DbTable table,
    String key,
  ) {
    final data = box(table).get(key);
    return data != null ? Map<String, dynamic>.from(data) : null;
  }

  // READ ALL
  static List<Map<String, dynamic>> getAll(DbTable table) {
    return box(table)
        .values
        .map((e) => Map<String, dynamic>.from(e))
        .toList();
  }

  // DELETE ONE
  static Future<void> delete(DbTable table, String key) async {
    await box(table).delete(key);
  }

  // DELETE ALL
  static Future<void> clear(DbTable table) async {
    await box(table).clear();
  }
}
