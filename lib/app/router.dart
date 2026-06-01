import 'package:go_router/go_router.dart';

import '../core/storage/token_storage.dart';
import '../features/auth/presentation/login_screen.dart';
import '../features/auth/presentation/registration_screen.dart';
import '../features/onboarding/presentation/onboarding_screen.dart';

/// Central router for the TrvlEz app.
final appRouter = GoRouter(
  initialLocation: '/login',
  redirect: (context, state) async {
    const tokenStorage = TokenStorage();
    final token = await tokenStorage.getToken();
    final isAuthenticated = token != null;

    final isAuthRoute = state.matchedLocation == '/login' || state.matchedLocation == '/register';

    if (!isAuthenticated) {
      // If not authenticated and not on an auth route, redirect to login
      if (!isAuthRoute) return '/login';
    } else {
      // If authenticated and on an auth route, redirect to onboarding (or home)
      if (isAuthRoute) return '/onboarding';
    }

    return null;
  },
  routes: [
    GoRoute(
      path: '/login',
      builder: (context, state) => const LoginScreen(),
    ),
    GoRoute(
      path: '/register',
      builder: (context, state) => const RegistrationScreen(),
    ),
    GoRoute(
      path: '/onboarding',
      builder: (context, state) => const OnboardingScreen(),
    ),
  ],
);
