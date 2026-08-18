import 'package:go_router/go_router.dart';
import 'package:trvlez_mobile/app/routes.dart';

import 'package:trvlez_mobile/core/auth/auth_notifier.dart';
import 'package:trvlez_mobile/features/auth/data/auth_repository.dart';
import 'package:trvlez_mobile/features/auth/presentation/login_screen.dart';
import 'package:trvlez_mobile/features/auth/presentation/registration_screen.dart';
import 'package:trvlez_mobile/features/auth/presentation/welcome_screen.dart';
import 'package:trvlez_mobile/features/home/presentation/home_screen.dart';
import 'package:trvlez_mobile/features/onboarding/presentation/onboarding_screen.dart';
import 'package:trvlez_mobile/features/profile/data/profile_repository.dart';
import 'package:trvlez_mobile/core/storage/settings_repository.dart';
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
import 'package:trvlez_mobile/core/device/camera_service.dart';
import 'package:flutter/material.dart';
import 'package:trvlez_mobile/features/home/presentation/main_scaffold.dart';
import 'package:trvlez_mobile/features/properties/data/properties_repository.dart';
import 'package:trvlez_mobile/features/properties/domain/property.dart';
import 'package:trvlez_mobile/features/properties/presentation/properties_listing_screen.dart';
import 'package:trvlez_mobile/features/properties/presentation/property_detail_screen.dart';
import 'package:trvlez_mobile/features/reservations/data/reservation_repository.dart';
import 'package:trvlez_mobile/features/reservations/domain/reservation.dart';
import 'package:trvlez_mobile/features/reservations/presentation/create_reservation_screen.dart';
import 'package:trvlez_mobile/features/reservations/presentation/my_trips_screen.dart';
import 'package:trvlez_mobile/features/reservations/presentation/qr_code_screen.dart';
import 'package:trvlez_mobile/features/reservations/presentation/reservation_detail_screen.dart';


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
  VerificationNotifier verificationNotifier,
  SettingsRepository settingsRepository,
) {
  final nfcPassportService = NfcPassportService();
  final cameraService = CameraService();

  return GoRouter(
    initialLocation: AppRoutes.welcome,
    refreshListenable: authNotifier,
    redirect: (context, state) {
      final isAuthenticated = authNotifier.isAuthenticated;
      final location = state.matchedLocation;
      final isAuthRoute = location == AppRoutes.login || location == AppRoutes.register || location == AppRoutes.welcome;

      if (!isAuthenticated) {
        // Not authenticated → force to login (unless already there)
        if (!isAuthRoute) return AppRoutes.login;
        return null;
      }

      // Authenticated — redirect away from auth routes (except welcome)
      if (location == AppRoutes.login || location == AppRoutes.register) {
        return AppRoutes.home;
      }

      return null;
    },
    routes: [
      GoRoute(
        path: AppRoutes.welcome,
        builder: (context, state) => WelcomeScreen(
          isAuthenticated: authNotifier.isAuthenticated,
        ),
      ),
      GoRoute(
        path: AppRoutes.login,
        builder: (context, state) => LoginScreen(
          authNotifier: authNotifier,
        ),
      ),
      GoRoute(
        path: AppRoutes.register,
        builder: (context, state) => const RegistrationScreen(),
      ),
      GoRoute(
        path: AppRoutes.onboarding,
        builder: (context, state) => const OnboardingScreen(),
      ),
      ShellRoute(
        builder: (context, state, child) {
          return MainScaffold(child: child);
        },
        routes: [
          GoRoute(
            path: AppRoutes.home,
            builder: (context, state) => const PropertiesListingScreen(),
          ),
          GoRoute(
            path: AppRoutes.myTrips,
            builder: (context, state) => const MyTripsScreen(),
          ),
          GoRoute(
            path: AppRoutes.favorites,
            builder: (context, state) => const Scaffold(
              body: Center(child: Text('Favorites Coming Soon')),
            ),
          ),
          GoRoute(
            path: AppRoutes.profile,
            builder: (context, state) => HomeScreen(
              authNotifier: authNotifier,
              profileRepository: profileRepository,
              verificationRepository: verificationNotifier.repository,
              settingsRepository: settingsRepository,
            ),
          ),
        ],
      ),
      GoRoute(
        path: AppRoutes.propertyDetail,
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
        path: AppRoutes.createReservation,
        builder: (context, state) {
          final property = state.extra as Property;
          return CreateReservationScreen(
            property: property,
          );
        },
      ),
      GoRoute(
        path: AppRoutes.reservationDetail,
        builder: (context, state) {
          final extras = state.extra as Map<String, dynamic>;
          final reservation = extras['reservation'] as Reservation;
          return ReservationDetailScreen(
            reservation: reservation,
          );
        },
      ),
      GoRoute(
        path: AppRoutes.reservationQr,
        builder: (context, state) {
          final extras = state.extra as Map<String, dynamic>;
          final reservation = extras['reservation'] as Reservation;
          return QrCodeScreen(
            reservation: reservation,
          );
        },
      ),
      // ─── Profile & Verification Routes ──────────────────────────
      GoRoute(
        path: AppRoutes.profileSetup,
        builder: (context, state) => const ProfileSetupScreen(),
      ),
      GoRoute(
        path: AppRoutes.passportCapture,
        builder: (context, state) =>
            PassportCaptureScreen(
              notifier: verificationNotifier,
              cameraService: cameraService,
            ),
      ),
      GoRoute(
        path: AppRoutes.passportReview,
        builder: (context, state) =>
            PassportReviewScreen(notifier: verificationNotifier),
      ),
      GoRoute(
        path: AppRoutes.mrzReview,
        builder: (context, state) =>
            MrzReviewScreen(notifier: verificationNotifier),
      ),
      GoRoute(
        path: AppRoutes.selfieInstructions,
        builder: (context, state) =>
            SelfieInstructionScreen(notifier: verificationNotifier),
      ),
      GoRoute(
        path: AppRoutes.selfieCapture,
        builder: (context, state) =>
            SelfieCaptureScreen(
              notifier: verificationNotifier,
              cameraService: cameraService,
            ),
      ),
      GoRoute(
        path: AppRoutes.selfieReview,
        builder: (context, state) =>
            SelfieReviewScreen(notifier: verificationNotifier),
      ),
      GoRoute(
        path: AppRoutes.nfcIntro,
        builder: (context, state) =>
            NfcIntroScreen(notifier: verificationNotifier),
      ),
      GoRoute(
        path: AppRoutes.nfcScan,
        builder: (context, state) =>
            NfcScanScreen(
              notifier: verificationNotifier, 
              nfcService: nfcPassportService,
            ),
      ),
      GoRoute(
        path: AppRoutes.nfcResult,
        builder: (context, state) =>
            NfcResultScreen(notifier: verificationNotifier),
      ),
      GoRoute(
        path: AppRoutes.verificationStatus,
        builder: (context, state) {
          // Extract optional job ID from navigation extras
          final extras = state.extra as Map<String, dynamic>?;
          final jobId = extras?['jobId'] as String?;

          return VerificationStatusScreen(
            authNotifier: authNotifier,
            verificationJobId: jobId,
            verificationNotifier: verificationNotifier,
          );
        },
      ),
    ],
  );
}
