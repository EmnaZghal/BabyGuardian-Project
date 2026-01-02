import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:baby_guardian_front/app/router/app_router.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Home"),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              AppRouter.isLoggedIn = false; // réinitialiser
              context.go('/login'); // retour login
            },
          ),
        ],
      ),
      body: const Center(
        child: Text(
          "Welcome to Baby Guardian!",
          style: TextStyle(fontSize: 20),
        ),
      ),
    );
  }
}
