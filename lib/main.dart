import 'package:flutter/material.dart';

import 'app/theme.dart';
import 'features/auth/presentation/registration_screen.dart';

void main() {
  runApp(const TrvlEzApp());
}

class TrvlEzApp extends StatelessWidget {
  const TrvlEzApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'TrvlEz',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      home: const RegistrationScreen(),
    );
  }
}
