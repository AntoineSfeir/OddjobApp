import 'package:flutter/material.dart';
import 'package:odd_job_app/auth/auth_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:odd_job_app/pages/home_page2.dart';

class MainPage extends StatelessWidget {
  const MainPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: StreamBuilder<User?>(
            stream: FirebaseAuth.instance.authStateChanges(),
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                return const HomePage2();
              } else {
                return const AuthPage();
              }
            }));
  }
}
