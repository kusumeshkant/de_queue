import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dq_app/core/enums/db_tables_enums.dart';

class FirebaseManager {
  FirebaseManager._();

  static final _firestore = FirebaseFirestore.instance;

  // CREATE / UPDATE
  static Future<void> set(
    DbTable table,
    String docId,
    Map<String, dynamic> data,
  ) async {
    await _firestore
        .collection(table.name)
        .doc(docId)
        .set(data, SetOptions(merge: true));
  }

  // READ ONE
  static Future<Map<String, dynamic>?> get(
    DbTable table,
    String docId,
  ) async {
    final doc =
        await _firestore.collection(table.name).doc(docId).get();

    return doc.exists ? doc.data() : null;
  }

  // READ ALL
  static Future<List<Map<String, dynamic>>> getAll(
    DbTable table,
  ) async {
    final snapshot =
        await _firestore.collection(table.name).get();

    return snapshot.docs.map((e) => e.data()).toList();
  }

  // DELETE ONE
  static Future<void> delete(
    DbTable table,
    String docId,
  ) async {
    await _firestore.collection(table.name).doc(docId).delete();
  }
}
