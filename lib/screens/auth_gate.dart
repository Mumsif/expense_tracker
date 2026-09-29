import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:expense_tracker/services/auth_service.dart';
import 'package:expense_tracker/screens/home_screen.dart';
import 'package:expense_tracker/screens/auth_screen.dart';

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: AuthService().demoModeNotifier,
      builder: (context, isDemo, _) {
        if (isDemo) {
          return const HomeScreen();
        }

        return StreamBuilder<User?>(
          stream: AuthService().authStateChanges,
          builder: (context, snapshot) {

            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Scaffold(
                body: Center(
                  child: CircularProgressIndicator(),
                ),
              );
            }

            if (snapshot.hasData && snapshot.data != null) {
              return const HomeScreen();
            }

            return const AuthScreen();
          },
        );
      },
    );
  }
}
