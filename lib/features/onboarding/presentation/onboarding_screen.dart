import 'package:flutter/material.dart';

import '../../../core/auth/auth_notifier.dart';

class OnboardingScreen extends StatelessWidget {
  final AuthNotifier authNotifier;

  const OnboardingScreen({super.key, required this.authNotifier});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Onboarding'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              authNotifier.logout();
            },
          ),
        ],
      ),
      body: const Center(
        child: Text('Welcome to Onboarding Flow!'),
      ),
    );
  }
}
