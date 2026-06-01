import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

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
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('Welcome to Onboarding Flow!'),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                context.push('/profile-setup');
              },
              child: const Text('Setup Profile'),
            ),
          ],
        ),
      ),
    );
  }
}
