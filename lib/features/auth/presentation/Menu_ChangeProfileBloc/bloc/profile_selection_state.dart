import 'package:student_app_task/features/auth/data/models/student.dart';

abstract class ProfileState {}

class ProfileInitial extends ProfileState {}

class ProfileLoading extends ProfileState {}

class ProfileLoaded extends ProfileState {
  final List<Student> profiles;
  ProfileLoaded(this.profiles);
}

class ProfileAuthSuccess extends ProfileState {
  final Student active;
  ProfileAuthSuccess(this.active);
}

class ProfileError extends ProfileState {
  final String message;
  ProfileError(this.message);
}
