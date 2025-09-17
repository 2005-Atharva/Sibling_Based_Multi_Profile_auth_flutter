import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:student_app_task/features/auth/presentation/loginBloc/bloc/login_bloc_event.dart';
import 'package:student_app_task/features/auth/presentation/loginBloc/bloc/login_bloc_state.dart';
import '../../../domain/find_students_by_input.dart';

class LoginBloc extends Bloc<LoginEvent, LoginState> {
  final FindStudentsByInput findStudents;
  LoginBloc({required this.findStudents}) : super(LoginInitial()) {
    on<LoginInputSubmitted>(_onInputSubmitted);
  }

  Future<void> _onInputSubmitted(
    LoginInputSubmitted event,
    Emitter<LoginState> emit,
  ) async {
    emit(LoginLoading());
    try {
      final list = await findStudents.call(event.input);
      final count = list.length;
      if (count == 0) {
        emit(LoginError('No account found for this input.'));
      } else if (count == 1) {
        emit(LoginSingleFound(list.first));
      } else if (count <= 5) {
        emit(LoginMultipleFound(list));
      } else {
        emit(LoginTooManySiblings());
      }
    } catch (e) {
      emit(LoginError('Something went wrong: ${e.toString()}'));
    }
  }
}
