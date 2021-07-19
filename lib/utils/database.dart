import 'package:cloud_firestore/cloud_firestore.dart';

final FirebaseFirestore _firestore = FirebaseFirestore.instance;
final CollectionReference _mainCollection = _firestore.collection('hutang');

class Database {
  static String? docId;

  static Future<void> addItem({
    required String nama,
    required DateTime tanggal,
    required double jumlah,
    required bool completed,
  }) async {
    DocumentReference documentReferencer = _mainCollection.doc();

    Map<String, dynamic> data = <String, dynamic>{
      "nama": nama,
      "jumlah": jumlah,
      "tanggal": tanggal,
      "completed": completed,
    };

    await documentReferencer
        .set(data)
        .whenComplete(() => print("Note item added to the database"))
        .catchError((e) => print(e));
  }

  static Future<void> updateItem({
    required String docId,
    required String nama,
    required DateTime tanggal,
    required double jumlah,
    required bool completed,
  }) async {
    DocumentReference documentReferencer = _mainCollection.doc(docId);

    Map<String, dynamic> data = <String, dynamic>{
      "nama": nama,
      "jumlah": jumlah,
      "tanggal": tanggal,
      "completed": completed,
    };

    await documentReferencer
        .update(data)
        .whenComplete(() => print("Note item updated in the database"))
        .catchError((e) => print(e));
  }

  static Future<void> setComplete({required String docId}) async {
    DocumentReference documentReferencer = _mainCollection.doc(docId);

    Map<String, dynamic> data = <String, dynamic>{
      "completed": true,
    };

    await documentReferencer
        .update(data)
        .whenComplete(() => print("Note item updated in the database"))
        .catchError((e) => print(e));
  }

  static Stream<QuerySnapshot> readItems() {
    CollectionReference hutangCollection = _mainCollection;

    return hutangCollection.snapshots();
  }

  static Stream<QuerySnapshot> getOlder() {
    return _mainCollection
        .orderBy('tanggal')
        .where('completed', isEqualTo: false)
        .limit(1)
        .snapshots();
  }

  static Future<void> deleteItem({
    required String docId,
  }) async {
    DocumentReference documentReferencer = _mainCollection.doc(docId);

    await documentReferencer
        .delete()
        .whenComplete(() => print('Note item deleted from the database'))
        .catchError((e) => print(e));
  }
}
