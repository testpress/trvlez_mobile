import 'package:go_router/go_router.dart';

import '../core/auth/auth_notifier.dart';
import '../features/auth/data/auth_repository.dart';
import '../features/auth/presentation/login_screen.dart';
import '../features/auth/presentation/registration_screen.dart';
import '../features/home/presentation/home_screen.dart';
import '../features/onboarding/presentation/onboarding_screen.dart';
import '../features/profile/data/profile_repository.dart';
import '../features/profile/presentation/profile_notifier.dart';
import '../features/profile/presentation/profile_setup_screen.dart';

import '../features/verification/presentation/passport_capture_screen.dart';
import '../features/verification/presentation/passport_review_screen.dart';
import '../features/verification/presentation/selfie_capture_screen.dart';
import '../features/verification/presentation/selfie_review_screen.dart';
import '../features/verification/presentation/verification_notifier.dart';
import '../features/verification/presentation/verification_status_screen.dart';

/// Central router configuration for the TrvlEz app.
///
/// Redirect logic:
/// - Not authenticated → `/login`
GoRouter createRouter(
  AuthNotifier authNotifier,
  AuthRepository authRepository,
  ProfileRepository profileRepository,
) {
  final verificationNotifier = VerificationNotifier();

  return GoRouter(
    initialLocation: '/login',
    refreshListenable: authNotifier,
    redirect: (context, state) {
      final isAuthenticated = authNotifier.isAuthenticated;
      final location = state.matchedLocation;
      final isAuthRoute = location == '/login' || location == '/register';

      if (!isAuthenticated) {
        // Not authenticated → force to login (unless already there)
        if (!isAuthRoute) return '/login';
        return null;
      }

      // Authenticated — redirect away from auth routes
      if (isAuthRoute) {
        return '/home';
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
        builder: (context, state) =>
            RegistrationScreen(authRepository: authRepository),
      ),
      GoRoute(
        path: '/onboarding',
        builder: (context, state) => OnboardingScreen(
          authNotifier: authNotifier,
          profileRepository: profileRepository,
        ),
      ),
      GoRoute(
        path: '/home',
        builder: (context, state) => HomeScreen(
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
      GoRoute(
        path: '/verification/passport-capture',
        builder: (context, state) =>
            PassportCaptureScreen(notifier: verificationNotifier),
      ),
      GoRoute(
        path: '/verification/passport-review',
        builder: (context, state) =>
            PassportReviewScreen(notifier: verificationNotifier),
      ),
      GoRoute(
        path: '/verification/selfie-capture',
        builder: (context, state) =>
            SelfieCaptureScreen(notifier: verificationNotifier),
      ),
      GoRoute(
        path: '/verification/selfie-review',
        builder: (context, state) =>
            SelfieReviewScreen(notifier: verificationNotifier),
      ),
      GoRoute(
        path: '/verification/status',
        builder: (context, state) {
          // Extract optional job ID from navigation extras
          final extras = state.extra as Map<String, dynamic>?;
          final jobId = extras?['jobId'] as String?;

          return VerificationStatusScreen(
            profileRepository: profileRepository,
            authNotifier: authNotifier,
            verificationJobId: jobId,
            verificationNotifier: verificationNotifier,
          );
        },
      ),
    ],
  );
}
