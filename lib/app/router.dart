import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:trvlez_mobile/app/routes.dart';
import 'package:trvlez_mobile/core/auth/auth_notifier.dart';
import 'package:trvlez_mobile/core/device/camera_service.dart';
import 'package:trvlez_mobile/features/auth/presentation/login_screen.dart';
import 'package:trvlez_mobile/features/auth/presentation/registration_screen.dart';
import 'package:trvlez_mobile/features/auth/presentation/welcome_screen.dart';
import 'package:trvlez_mobile/features/home/presentation/home_screen.dart';
import 'package:trvlez_mobile/features/home/presentation/main_scaffold.dart';
import 'package:trvlez_mobile/features/onboarding/presentation/onboarding_screen.dart';
import 'package:trvlez_mobile/features/profile/presentation/profile_setup_screen.dart';
import 'package:trvlez_mobile/features/properties/data/properties_repository.dart';
import 'package:trvlez_mobile/features/properties/domain/property.dart';
import 'package:trvlez_mobile/features/properties/presentation/properties_listing_screen.dart';
import 'package:trvlez_mobile/features/properties/presentation/property_detail_screen.dart';
import 'package:trvlez_mobile/features/reservations/domain/reservation.dart';
import 'package:trvlez_mobile/features/reservations/presentation/create_reservation_screen.dart';
import 'package:trvlez_mobile/features/reservations/presentation/my_trips_screen.dart';
import 'package:trvlez_mobile/features/reservations/presentation/pre_arrival_form_screen.dart';
import 'package:trvlez_mobile/features/reservations/presentation/qr_code_screen.dart';
import 'package:trvlez_mobile/features/reservations/presentation/reservation_detail_screen.dart';
import 'package:trvlez_mobile/features/verification/data/nfc_passport_service.dart';
import 'package:trvlez_mobile/features/verification/domain/processing_stage.dart';
import 'package:trvlez_mobile/features/verification/presentation/mrz_review_screen.dart';
import 'package:trvlez_mobile/features/verification/presentation/nfc_intro_screen.dart';
import 'package:trvlez_mobile/features/verification/presentation/nfc_result_screen.dart';
import 'package:trvlez_mobile/features/verification/presentation/nfc_scan_screen.dart';
import 'package:trvlez_mobile/features/verification/presentation/passport_capture_screen.dart';
import 'package:trvlez_mobile/features/verification/presentation/passport_review_screen.dart';
import 'package:trvlez_mobile/features/verification/presentation/selfie_capture_screen.dart';
import 'package:trvlez_mobile/features/verification/presentation/selfie_instruction_screen.dart';
import 'package:trvlez_mobile/features/verification/presentation/selfie_review_screen.dart';
import 'package:trvlez_mobile/features/verification/presentation/verification_processing_screen.dart';
import 'package:trvlez_mobile/features/verification/presentation/verification_status_screen.dart';

class RouterNotifier extends ChangeNotifier {
  final Ref _ref;

  RouterNotifier(this._ref) {
    _ref.listen<AsyncValue<AuthState>>(
      authNotifierProvider,
      (previous, next) {
        if (previous?.valueOrNull?.isAuthenticated !=
            next.valueOrNull?.isAuthenticated) {
          notifyListeners();
        }
      },
    );
  }
}

final routerProvider = Provider<GoRouter>((ref) {
  final notifier = RouterNotifier(ref);
  final cameraService = ref.read(cameraServiceProvider);
  final nfcPassportService = ref.read(nfcPassportServiceProvider);

  return GoRouter(
    initialLocation: AppRoutes.home,
    refreshListenable: notifier,
    redirect: (context, state) {
      final authState = ref.read(authNotifierProvider);
      if (authState.isLoading) return null;

      final auth = authState.valueOrNull;
      final isAuthenticated = auth?.isAuthenticated ?? false;
      final currentPath = state.matchedLocation;

      final isAuthRoute =
          currentPath == AppRoutes.welcome ||
          currentPath == AppRoutes.login ||
          currentPath == AppRoutes.register;

      if (!isAuthenticated) {
        return isAuthRoute ? null : AppRoutes.welcome;
      }

      if (isAuthRoute) {
        return AppRoutes.home;
      }

      return null;
    },
    routes: [
      GoRoute(
        path: AppRoutes.splash,
        builder: (context, state) =>
            const Scaffold(body: Center(child: CircularProgressIndicator())),
      ),
      GoRoute(
        path: AppRoutes.welcome,
        builder: (context, state) => const WelcomeScreen(),
      ),
      GoRoute(
        path: AppRoutes.login,
        builder: (context, state) => const LoginScreen(),
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
            builder: (context, state) => const HomeScreen(),
          ),
        ],
      ),
      GoRoute(
        path: AppRoutes.propertyDetail,
        builder: (context, state) {
          final property = state.extra is Property ? state.extra as Property : null;
          if (property == null) {
            return const PropertiesListingScreen();
          }
          return PropertyDetailScreen(
            property: property,
            repository: ref.read(propertiesRepositoryProvider),
          );
        },
      ),
      // ─── Reservation Routes ─────────────────────────────────────
      GoRoute(
        path: AppRoutes.createReservation,
        builder: (context, state) {
          final property = state.extra is Property ? state.extra as Property : null;
          if (property == null) {
            return const PropertiesListingScreen();
          }
          return CreateReservationScreen(property: property);
        },
      ),
      GoRoute(
        path: AppRoutes.reservationDetail,
        builder: (context, state) {
          final extras = state.extra is Map<String, dynamic>
              ? state.extra as Map<String, dynamic>
              : null;
          final reservation = extras?['reservation'] as Reservation?;
          if (reservation == null) {
            return const MyTripsScreen();
          }
          return ReservationDetailScreen(reservation: reservation);
        },
      ),
      GoRoute(
        path: AppRoutes.reservationQr,
        builder: (context, state) {
          final extras = state.extra is Map<String, dynamic>
              ? state.extra as Map<String, dynamic>
              : null;
          final reservation = extras?['reservation'] as Reservation?;
          if (reservation == null) {
            return const MyTripsScreen();
          }
          return QrCodeScreen(reservation: reservation);
        },
      ),
      GoRoute(
        path: AppRoutes.reservationForm,
        builder: (context, state) {
          final extras = state.extra is Map<String, dynamic>
              ? state.extra as Map<String, dynamic>
              : null;
          final reservation = extras?['reservation'] as Reservation?;
          final reservationId = reservation?.id ?? (extras?['reservationId'] as String?) ?? '';
          return PreArrivalFormScreen(reservationId: reservationId);
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
            PassportCaptureScreen(cameraService: cameraService),
      ),
      GoRoute(
        path: AppRoutes.passportReview,
        builder: (context, state) => const PassportReviewScreen(),
      ),
      GoRoute(
        path: AppRoutes.mrzReview,
        builder: (context, state) => const MrzReviewScreen(),
      ),
      GoRoute(
        path: AppRoutes.selfieInstructions,
        builder: (context, state) => const SelfieInstructionScreen(),
      ),
      GoRoute(
        path: AppRoutes.selfieCapture,
        builder: (context, state) =>
            SelfieCaptureScreen(cameraService: cameraService),
      ),
      GoRoute(
        path: AppRoutes.selfieReview,
        builder: (context, state) => const SelfieReviewScreen(),
      ),
      GoRoute(
        path: AppRoutes.nfcIntro,
        builder: (context, state) => const NfcIntroScreen(),
      ),
      GoRoute(
        path: AppRoutes.nfcScan,
        builder: (context, state) =>
            NfcScanScreen(nfcService: nfcPassportService),
      ),
      GoRoute(
        path: AppRoutes.nfcResult,
        builder: (context, state) => const NfcResultScreen(),
      ),
      GoRoute(
        path: AppRoutes.verificationProcessing,
        builder: (context, state) {
          final extras = state.extra is Map<String, dynamic>
              ? state.extra as Map<String, dynamic>
              : null;
          final type = (extras?['type'] as ProcessingType?) ?? ProcessingType.passport;
          return VerificationProcessingScreen(type: type);
        },
      ),
      GoRoute(
        path: AppRoutes.verificationStatus,
        builder: (context, state) {
          final extras = state.extra is Map<String, dynamic>
              ? state.extra as Map<String, dynamic>
              : null;
          final jobId = extras?['jobId'] as String?;
          return VerificationStatusScreen(verificationJobId: jobId);
        },
      ),
    ],
  );
});
