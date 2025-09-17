import 'package:firebase_auth/firebase_auth.dart' as fb;
import '../datasources/remote_datasource.dart';
import '../models/student.dart';

class AuthRepositoryImpl {
  final RemoteDataSource remote;
  AuthRepositoryImpl({required this.remote});

  Future<List<Student>> findStudentsByInput(
    String input, {
    bool isEmail = false,
  }) async {
    if (isEmail) return remote.findByEmail(input);
    return remote.findByContact(input);
  }

  Future<fb.UserCredential> signInWithEmail(
    String email,
    String password,
  ) async {
    return await fb.FirebaseAuth.instance.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
  }
}
