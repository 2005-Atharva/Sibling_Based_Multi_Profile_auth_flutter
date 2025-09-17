import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:student_app_task/core/constants.dart';
import '../models/student.dart';
import '../models/student_model.dart';

class RemoteDataSource {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<List<Student>> findByContact(String contact) async {
    final q = await _firestore
        .collection(Constants.studentCollection)
        .where('contactNo', isEqualTo: contact)
        .get();
    return q.docs.map((d) => StudentModel.fromMap(d.id, d.data())).toList();
  }

  Future<List<Student>> findByEmail(String email) async {
    final q = await _firestore
        .collection(Constants.studentCollection)
        .where('email', isEqualTo: email)
        .get();
    return q.docs.map((d) => StudentModel.fromMap(d.id, d.data())).toList();
  }
}
