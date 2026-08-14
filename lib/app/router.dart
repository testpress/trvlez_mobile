import 'package:go_router/go_router.dart';

import 'package:trvlez_mobile/core/auth/auth_notifier.dart';
import 'package:trvlez_mobile/features/auth/data/auth_repository.dart';
import 'package:trvlez_mobile/features/auth/presentation/login_screen.dart';
import 'package:trvlez_mobile/features/auth/presentation/registration_screen.dart';
import 'package:trvlez_mobile/features/auth/presentation/welcome_screen.dart';
import 'package:trvlez_mobile/features/home/presentation/home_screen.dart';
import 'package:trvlez_mobile/features/onboarding/presentation/onboarding_screen.dart';
import 'package:trvlez_mobile/features/profile/data/profile_repository.dart';
import 'package:trvlez_mobile/features/profile/presentation/profile_notifier.dart';
import 'package:trvlez_mobile/features/profile/presentation/profile_setup_screen.dart';
import 'package:trvlez_mobile/features/verification/presentation/mrz_review_screen.dart';
import 'package:trvlez_mobile/features/verification/presentation/passport_capture_screen.dart';
import 'package:trvlez_mobile/features/verification/presentation/passport_review_screen.dart';
import 'package:trvlez_mobile/features/verification/presentation/selfie_capture_screen.dart';
import 'package:trvlez_mobile/features/verification/presentation/selfie_instruction_screen.dart';
import 'package:trvlez_mobile/features/verification/presentation/selfie_review_screen.dart';
import 'package:trvlez_mobile/features/verification/presentation/verification_notifier.dart';
import 'package:trvlez_mobile/features/verification/presentation/verification_status_screen.dart';
import 'package:trvlez_mobile/features/verification/presentation/nfc_intro_screen.dart';
import 'package:trvlez_mobile/features/verification/presentation/nfc_scan_screen.dart';
import 'package:trvlez_mobile/features/verification/presentation/nfc_result_screen.dart';
import 'package:trvlez_mobile/features/verification/data/nfc_passport_service.dart';
import 'package:flutter/material.dart';
import 'package:trvlez_mobile/features/home/presentation/main_scaffold.dart';
import 'package:trvlez_mobile/features/properties/data/properties_repository.dart';
import 'package:trvlez_mobile/features/properties/domain/property.dart';
import 'package:trvlez_mobile/features/properties/presentation/properties_listing_screen.dart';
import 'package:trvlez_mobile/features/properties/presentation/properties_notifier.dart';
import 'package:trvlez_mobile/features/properties/presentation/property_detail_screen.dart';
import 'package:trvlez_mobile/features/reservations/data/reservation_repository.dart';
import 'package:trvlez_mobile/features/reservations/domain/reservation.dart';
import 'package:trvlez_mobile/features/reservations/presentation/create_reservation_screen.dart';
import 'package:trvlez_mobile/features/reservations/presentation/my_trips_screen.dart';
import 'package:trvlez_mobile/features/reservations/presentation/qr_code_screen.dart';
import 'package:trvlez_mobile/features/reservations/presentation/reservation_detail_screen.dart';
import 'package:trvlez_mobile/features/reservations/presentation/reservations_notifier.dart';

/// Central router configuration for the TrvlEz app.
///
/// Redirect logic:
/// - Not authenticated → `/login`
GoRouter createRouter(
  AuthNotifier authNotifier,
  AuthRepository authRepository,
  ProfileRepository profileRepository,
  PropertiesRepository propertiesRepository,
  ReservationRepository reservationRepository,
) {
  final verificationNotifier = VerificationNotifier();
  final nfcPassportService = NfcPassportService();
  final propertiesNotifier = PropertiesNotifier(repository: propertiesRepository);
  final reservationsNotifier = ReservationsNotifier(repository: reservationRepository);

  return GoRouter(
    initialLocation: '/welcome',
    refreshListenable: authNotifier,
    redirect: (context, state) {
      final isAuthenticated = authNotifier.isAuthenticated;
      final location = state.matchedLocation;
      final isAuthRoute = location == '/login' || location == '/register' || location == '/welcome';

      if (!isAuthenticated) {
        // Not authenticated → force to login (unless already there)
        if (!isAuthRoute) return '/login';
        return null;
      }

      // Authenticated — redirect away from auth routes (except welcome)
      if (location == '/login' || location == '/register') {
        return '/home';
      }

      return null;
    },
    routes: [
      GoRoute(
        path: '/welcome',
        builder: (context, state) => WelcomeScreen(
          isAuthenticated: authNotifier.isAuthenticated,
        ),
      ),
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
      ShellRoute(
        builder: (context, state, child) {
          return MainScaffold(child: child);
        },
        routes: [
          GoRoute(
            path: '/home',
            builder: (context, state) => PropertiesListingScreen(
              notifier: propertiesNotifier,
            ),
          ),
          GoRoute(
            path: '/my-trips',
            builder: (context, state) => MyTripsScreen(
              notifier: reservationsNotifier,
            ),
          ),
          GoRoute(
            path: '/favorites',
            builder: (context, state) => const Scaffold(
              body: Center(child: Text('Favorites Coming Soon')),
            ),
          ),
          GoRoute(
            path: '/profile',
            builder: (context, state) => HomeScreen(
              authNotifier: authNotifier,
              profileRepository: profileRepository,
            ),
          ),
        ],
      ),
      GoRoute(
        path: '/properties/:id',
        builder: (context, state) {
          final property = state.extra as Property;
          return PropertyDetailScreen(
            property: property,
            repository: propertiesRepository,
          );
        },
      ),
      // ─── Reservation Routes ─────────────────────────────────────
      GoRoute(
        path: '/reservations/create',
        builder: (context, state) {
          final property = state.extra as Property;
          return CreateReservationScreen(
            property: property,
            notifier: reservationsNotifier,
          );
        },
      ),
      GoRoute(
        path: '/reservations/:id',
        builder: (context, state) {
          final extras = state.extra as Map<String, dynamic>;
          final reservation = extras['reservation'] as Reservation;
          return ReservationDetailScreen(
            reservation: reservation,
            notifier: reservationsNotifier,
          );
        },
      ),
      GoRoute(
        path: '/reservations/:id/qr',
        builder: (context, state) {
          final extras = state.extra as Map<String, dynamic>;
          final reservation = extras['reservation'] as Reservation;
          return QrCodeScreen(
            reservation: reservation,
            notifier: reservationsNotifier,
          );
        },
      ),
      // ─── Profile & Verification Routes ──────────────────────────
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
        path: '/verification/mrz-review',
        builder: (context, state) =>
            MrzReviewScreen(notifier: verificationNotifier),
      ),
      GoRoute(
        path: '/verification/selfie-instructions',
        builder: (context, state) =>
            SelfieInstructionScreen(notifier: verificationNotifier),
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
        path: '/verification/nfc-intro',
        builder: (context, state) =>
            NfcIntroScreen(notifier: verificationNotifier),
      ),
      GoRoute(
        path: '/verification/nfc-scan',
        builder: (context, state) =>
            NfcScanScreen(
              notifier: verificationNotifier, 
              nfcService: nfcPassportService,
            ),
      ),
      GoRoute(
        path: '/verification/nfc-result',
        builder: (context, state) =>
            NfcResultScreen(notifier: verificationNotifier),
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
