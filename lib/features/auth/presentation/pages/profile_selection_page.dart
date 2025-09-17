import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:student_app_task/features/auth/presentation/Menu_ChangeProfileBloc/bloc/profile_selection_event.dart';
import 'package:student_app_task/features/auth/presentation/Menu_ChangeProfileBloc/bloc/profile_selection_state.dart';
import 'package:student_app_task/features/auth/presentation/pages/dashboard_page.dart';
import '../../data/models/student.dart';
import '../Menu_ChangeProfileBloc/bloc/profile_selection_bloc.dart';

class ProfileSelectionPage extends StatefulWidget {
  final List<Student> profiles;
  const ProfileSelectionPage({super.key, required this.profiles});

  @override
  State<ProfileSelectionPage> createState() => _ProfileSelectionPageState();
}

class _ProfileSelectionPageState extends State<ProfileSelectionPage> {
  final _passwordController = TextEditingController();
  List<Student> _profiles = [];

  @override
  void initState() {
    super.initState();
    context.read<ProfileSelectionBloc>().add(LoadProfiles(widget.profiles));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Select profile')),
      body: BlocConsumer<ProfileSelectionBloc, ProfileState>(
        listener: (context, state) {
          if (state is ProfileAuthSuccess) {
            Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(
                builder: (_) => DashboardPage(student: state.active),
              ),
              (route) => false,
            );
          } else if (state is ProfileError) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(state.message)));
          }
        },
        builder: (context, state) {
          if (state is ProfileLoaded) {
            _profiles = state.profiles;
          }
          if (_profiles.isEmpty)
            return const Center(child: Text('No profiles'));
          return GridView.builder(
            padding: const EdgeInsets.all(12),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 3 / 4,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
            ),
            itemCount: _profiles.length,
            itemBuilder: (context, idx) {
              final s = _profiles[idx];
              return GestureDetector(
                onTap: () async {
                  await _showPasswordAndSignIn(context, s);
                },
                child: Card(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircleAvatar(
                        radius: 36,
                        child: Text(s.name.isNotEmpty ? s.name[0] : '?'),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        s.name,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 4),
                      Text(s.email, style: const TextStyle(fontSize: 12)),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  Future<void> _showPasswordAndSignIn(
    BuildContext context,
    Student student,
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
            onPressed: () {
              Navigator.of(context).pop();
              context.read<ProfileSelectionBloc>().add(
                SelectProfile(student, _passwordController.text.trim()),
              );
            },
            child: const Text('Sign in'),
          ),
        ],
      ),
    );
  }
}
