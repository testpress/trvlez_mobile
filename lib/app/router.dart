import 'package:go_router/go_router.dart';

import '../core/auth/auth_notifier.dart';
import '../features/auth/data/auth_repository.dart';
import '../features/auth/presentation/login_screen.dart';
import '../features/auth/presentation/registration_screen.dart';
import '../features/onboarding/presentation/onboarding_screen.dart';
import '../features/profile/data/profile_repository.dart';
import '../features/profile/presentation/profile_notifier.dart';
import '../features/profile/presentation/profile_setup_screen.dart';

/// Central router configuration for the TrvlEz app.
GoRouter createRouter(
  AuthNotifier authNotifier,
  AuthRepository authRepository,
  ProfileRepository profileRepository,
) {
  return GoRouter(
    initialLocation: '/login',
    refreshListenable: authNotifier,
    redirect: (context, state) {
      final isAuthenticated = authNotifier.isAuthenticated;
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
        builder: (context, state) => LoginScreen(
          authRepository: authRepository,
          authNotifier: authNotifier,
        ),
      ),
      GoRoute(
        path: '/register',
        builder: (context, state) => RegistrationScreen(authRepository: authRepository),
      ),
      GoRoute(
        path: '/onboarding',
        builder: (context, state) => OnboardingScreen(
          authNotifier: authNotifier,
          profileRepository: profileRepository,
        ),
      ),
      GoRoute(
        path: '/profile-setup',
        builder: (context, state) => ProfileSetupScreen(
          profileNotifier: ProfileNotifier(repository: profileRepository),
        ),
      ),
    ],
  );
}
