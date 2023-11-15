import 'package:flutter/material.dart';
import 'package:odd_job_app/auth/auth_page.dart';
import 'package:odd_job_app/pages/home_page.dart';
import 'package:firebase_auth/firebase_auth.dart';

class MainPage extends StatelessWidget {
  const MainPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: StreamBuilder<User?>(
            stream: FirebaseAuth.instance.authStateChanges(),
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                return const HomePage();
              } else {
                return const AuthPage();
              }
            }
          )
        );
  }
}