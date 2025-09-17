import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:student_app_task/features/auth/data/datasources/remote_datasource.dart';
import 'package:student_app_task/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:student_app_task/features/auth/domain/find_students_by_input.dart';
import 'package:student_app_task/features/auth/presentation/loginBloc/bloc/login_bloc.dart';
import 'package:student_app_task/features/auth/presentation/Menu_ChangeProfileBloc/bloc/profile_selection_bloc.dart';
import 'package:student_app_task/features/auth/presentation/pages/dashboard_page.dart';
import 'package:student_app_task/features/auth/presentation/pages/login_page.dart';
import 'package:student_app_task/utils/shared_prefs.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await SharedPrefs.init();
  final remote = RemoteDataSource();
  final repo = AuthRepositoryImpl(remote: remote);
  final findStudents = FindStudentsByInput(repo);

  Widget initialWidget = const LoginPage();

  try {
    final fb.User? restoredUser = await fb.FirebaseAuth.instance
        .authStateChanges()
        .first;
    if (restoredUser != null) {
      final savedEmail = SharedPrefs.getActiveEmail();
      final emailToCheck = (savedEmail != null && savedEmail.isNotEmpty)
          ? savedEmail
          : restoredUser.email;
      if (emailToCheck != null && emailToCheck.isNotEmpty) {
        final list = await findStudents.call(emailToCheck);
        if (list.isNotEmpty) {
          initialWidget = DashboardPage(student: list.first);
        }
      }
    }
  } catch (e) {
    debugPrint('error: $e');
  }

  runApp(
    MultiBlocProvider(
      providers: [
        BlocProvider<LoginBloc>(
          create: (_) => LoginBloc(findStudents: findStudents),
        ),
        BlocProvider<ProfileSelectionBloc>(
          create: (_) => ProfileSelectionBloc(),
        ),
      ],
      child: MyApp(initialScreen: initialWidget),
    ),
  );
}

class MyApp extends StatelessWidget {
  final Widget initialScreen;
  const MyApp({super.key, required this.initialScreen});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter App',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: initialScreen,
    );
  }
}
