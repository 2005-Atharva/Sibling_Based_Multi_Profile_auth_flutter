import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb;
import 'package:student_app_task/features/auth/presentation/Menu_ChangeProfileBloc/bloc/profile_selection_event.dart';
import 'package:student_app_task/features/auth/presentation/loginBloc/bloc/login_bloc_event.dart';
import 'package:student_app_task/features/auth/presentation/loginBloc/bloc/login_bloc_state.dart';
import 'package:student_app_task/features/auth/presentation/pages/dashboard_page.dart';
import 'package:student_app_task/features/auth/presentation/pages/profile_selection_page.dart';
import 'package:student_app_task/utils/shared_prefs.dart';
import '../loginBloc/bloc/login_bloc.dart';
import '../Menu_ChangeProfileBloc/bloc/profile_selection_bloc.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _controller = TextEditingController();
  final _passwordController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Login')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _controller,
              decoration: const InputDecoration(
                hintText: 'Email or Contact number',
              ),
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: () => context.read<LoginBloc>().add(
                LoginInputSubmitted(_controller.text.trim()),
              ),
              child: const Text('Continue'),
            ),
            const SizedBox(height: 12),
            BlocConsumer<LoginBloc, LoginState>(
              listener: (context, state) async {
                if (state is LoginSingleFound) {
                  await _showPasswordDialog(context, state.student);
                } else if (state is LoginMultipleFound) {
                  // dispatch to profile bloc and navigate
                  context.read<ProfileSelectionBloc>().add(
                    LoadProfiles(state.siblings),
                  );
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) =>
                          ProfileSelectionPage(profiles: state.siblings),
                    ),
                  );
                } else if (state is LoginError) {
                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(SnackBar(content: Text(state.message)));
                } else if (state is LoginTooManySiblings) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                        'Too many sibling profiles for this contact.',
                      ),
                    ),
                  );
                }
              },
              builder: (context, state) {
                if (state is LoginLoading)
                  return const CircularProgressIndicator();
                return const SizedBox.shrink();
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showPasswordDialog(
    BuildContext context,
    dynamic student,
  ) async {
    _passwordController.clear();
    await showDialog(
      context: context,
      builder: (c) => AlertDialog(
        title: Text('Sign in as ${student.name}'),
        content: TextField(
          controller: _passwordController,
          decoration: const InputDecoration(hintText: 'Password'),
          obscureText: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.of(context).pop();
              await _signInWithEmail(
                student.email,
                _passwordController.text.trim(),
              );
            },
            child: const Text('Sign in'),
          ),
        ],
      ),
    );
  }

  Future<void> _signInWithEmail(String email, String password) async {
    try {
      final cred = await fb.FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      if (cred.user != null) {
        final loginBloc = context.read<LoginBloc>();
        final list = await loginBloc.findStudents.call(email);
        if (list.isNotEmpty) {
          final s = list.first;
          await SharedPrefs.saveActiveProfile(
            id: s.studentId,
            email: s.email,
            name: s.name,
            contact: s.contactNo,
            avatar: s.avatar,
          );
          if (!mounted) return;
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (_) => DashboardPage(student: s)),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Profile exists in Auth but missing in Firestore'),
            ),
          );
        }
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Sign in failed: ${e.toString()}')),
      );
    }
  }
}
