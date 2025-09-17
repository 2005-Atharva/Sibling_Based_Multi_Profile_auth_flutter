import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:student_app_task/features/auth/presentation/Menu_ChangeProfileBloc/bloc/profile_selection_event.dart';
import 'package:student_app_task/features/auth/presentation/Menu_ChangeProfileBloc/bloc/profile_selection_state.dart';
import '../../../../../utils/shared_prefs.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb;

class ProfileSelectionBloc extends Bloc<ProfileEvent, ProfileState> {
  ProfileSelectionBloc() : super(ProfileInitial()) {
    on<LoadProfiles>(_onLoadProfiles);
    on<SelectProfile>(_onSelectProfile);
  }

  void _onLoadProfiles(LoadProfiles event, Emitter<ProfileState> emit) async {
    emit(ProfileLoaded(event.profiles));
  }

  Future<void> _onSelectProfile(
    SelectProfile event,
    Emitter<ProfileState> emit,
  ) async {
    emit(ProfileLoading());
    try {
      final cred = await fb.FirebaseAuth.instance.signInWithEmailAndPassword(
        email: event.student.email,
        password: event.password,
      );
      if (cred.user != null) {
        await SharedPrefs.saveActiveProfile(
          id: event.student.studentId,
          email: event.student.email,
          name: event.student.name,
          contact: event.student.contactNo,
          avatar: event.student.avatar,
        );
        emit(ProfileAuthSuccess(event.student));
      } else {
        emit(ProfileError('Authentication failed'));
      }
    } catch (e) {
      emit(ProfileError('Sign in failed: ${e.toString()}'));
    }
  }
}
