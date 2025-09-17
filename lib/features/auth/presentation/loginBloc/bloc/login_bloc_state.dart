// States
import 'package:student_app_task/features/auth/data/models/student.dart';

abstract class LoginState {}

class LoginInitial extends LoginState {}

class LoginLoading extends LoginState {}

class LoginError extends LoginState {
  final String message;
  LoginError(this.message);
}

class LoginSingleFound extends LoginState {
  final Student student;
  LoginSingleFound(this.student);
}

class LoginMultipleFound extends LoginState {
  final List<Student> siblings;
  LoginMultipleFound(this.siblings);
}

class LoginTooManySiblings extends LoginState {}
