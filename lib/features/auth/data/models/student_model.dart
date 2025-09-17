import 'student.dart';

class StudentModel extends Student {
  StudentModel({
    required super.studentId,
    required super.name,
    required super.email,
    required super.contactNo,
    required super.avatar,
    required super.isSiblingOf,
  });

  factory StudentModel.fromMap(String id, Map<String, dynamic> map) {
    return StudentModel(
      studentId: id,
      name: map['name'] ?? '',
      email: map['email'] ?? '',
      contactNo: map['contactNo'] ?? '',
      avatar: map['avatar'] ?? '',
      isSiblingOf: map['isSiblingOf'] ?? '',
    );
  }
}
