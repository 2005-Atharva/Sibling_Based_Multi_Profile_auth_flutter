import '../data/repositories/auth_repository_impl.dart';
import '../data/models/student.dart';

class FindStudentsByInput {
  final AuthRepositoryImpl repository;
  FindStudentsByInput(this.repository);

  Future<List<Student>> call(String input) async {
    final isEmail = RegExp(r"^[\w\-.]+@([\w-]+\.)+[\w-]{2,4}").hasMatch(input);
    return await repository.findStudentsByInput(input, isEmail: isEmail);
  }
}
