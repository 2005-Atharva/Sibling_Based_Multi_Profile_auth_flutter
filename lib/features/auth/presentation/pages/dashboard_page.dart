import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb;
import 'package:student_app_task/features/auth/presentation/pages/login_page.dart';
import 'package:student_app_task/utils/shared_prefs.dart';
import '../../data/models/student.dart';
import '../loginBloc/bloc/login_bloc.dart';
import '../pages/profile_selection_page.dart';

class DashboardPage extends StatelessWidget {
  final Student student;
  const DashboardPage({super.key, required this.student});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
        actions: [
          IconButton(
            onPressed: () async {
              final contact = student.contactNo;
              if (contact.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('No contact available for this profile'),
                  ),
                );
                return;
              }

              showDialog(
                context: context,
                barrierDismissible: false,
                builder: (_) =>
                    const Center(child: CircularProgressIndicator()),
              );

              try {
                final findStudents = context.read<LoginBloc>().findStudents;
                final list = await findStudents.call(contact);
                Navigator.of(context).pop();

                final count = list.length;
                if (count == 0) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('No profiles found for this contact.'),
                    ),
                  );
                } else if (count == 1) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Only one profile found.')),
                  );
                } else if (count <= 5) {
                  await fb.FirebaseAuth.instance.signOut();
                  await SharedPrefs.clearActiveProfile();
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => ProfileSelectionPage(profiles: list),
                    ),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                        'Too many sibling profiles for this contact.',
                      ),
                    ),
                  );
                }
              } catch (e) {
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Failed to load siblings: ${e.toString()}'),
                  ),
                );
              }
            },
            icon: const Icon(Icons.swap_horiz),
          ),
          IconButton(
            onPressed: () async {
              await fb.FirebaseAuth.instance.signOut();
              await SharedPrefs.clearActiveProfile();
              // Navigator.of(context).pushReplacement(
              //   MaterialPageRoute(
              //     builder: (_) => const Scaffold(
              //       body: Center(
              //         child: Text(
              //           'Signed out. Restart app or go back to login.',
              //         ),
              //       ),
              //     ),
              //   ),
              // );

              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (_) => const LoginPage()),
                (route) => false,
              );
            },
            icon: const Icon(Icons.exit_to_app),
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircleAvatar(
              radius: 60,
              child: ClipRRect(
                borderRadius: BorderRadiusGeometry.circular(100),
                child: Image.network(
                  student.avatar.isNotEmpty
                      ? student.avatar
                      : 'https://media.istockphoto.com/id/1495088043/vector/user-profile-icon-avatar-or-person-icon-profile-picture-portrait-symbol-default-portrait.jpg?s=612x612&w=0&k=20&c=dhV2p1JwmloBTOaGAtaA3AW1KSnjsdMt7-U_3EZElZ0=',

                  fit: BoxFit.cover,
                ),
              ),
            ),
            const SizedBox(height: 10),
            Text(
              student.name,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 6),
            Text(student.email),
          ],
        ),
      ),
    );
  }
}
