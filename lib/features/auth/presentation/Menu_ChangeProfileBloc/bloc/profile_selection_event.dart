import 'package:student_app_task/features/auth/data/models/student.dart';

abstract class ProfileEvent {}

class LoadProfiles extends ProfileEvent {
  final List<Student> profiles;
  LoadProfiles(this.profiles);
}

class SelectProfile extends ProfileEvent {
  final Student student;
  final String password;
  SelectProfile(this.student, this.password);
}
