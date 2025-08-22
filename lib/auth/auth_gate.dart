// filename: lib/auth/auth_gate.dart
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:video_trainer_app/auth/login_page.dart';
import 'package:video_trainer_app/pages/home_page.dart';

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<AuthState>(
      stream: Supabase.instance.client.auth.onAuthStateChange,
      builder: (context, snapshot) {
        if (snapshot.hasData && snapshot.data?.session != null) {
          // User is logged in
          return const HomePage();
        } else {
          // User is not logged in
          return const LoginPage();
        }
      },
    );
  }
}
