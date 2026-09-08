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
import 'package:trvlez_mobile/features/properties/domain/property.dart';
import 'package:trvlez_mobile/features/properties/presentation/properties_listing_screen.dart';
import 'package:trvlez_mobile/features/properties/presentation/property_detail_screen.dart';
import 'package:trvlez_mobile/features/properties/data/properties_repository.dart';
import 'package:trvlez_mobile/features/reservations/data/reservation_repository.dart';
import 'package:trvlez_mobile/features/reservations/domain/reservation.dart';
import 'package:trvlez_mobile/features/reservations/presentation/booking_confirmation_screen.dart';
import 'package:trvlez_mobile/features/reservations/presentation/create_reservation_screen.dart';
import 'package:trvlez_mobile/features/reservations/presentation/my_trips_screen.dart';
import 'package:trvlez_mobile/features/reservations/presentation/qr_code_screen.dart';
import 'package:trvlez_mobile/features/reservations/presentation/reservation_detail_screen.dart';
import 'package:trvlez_mobile/features/reservations/presentation/pre_arrival_form_screen.dart';
import 'package:trvlez_mobile/features/verification/data/nfc_passport_service.dart';
import 'package:trvlez_mobile/features/verification/presentation/mrz_review_screen.dart';
import 'package:trvlez_mobile/features/verification/presentation/nfc_intro_screen.dart';
import 'package:trvlez_mobile/features/verification/presentation/nfc_result_screen.dart';
import 'package:trvlez_mobile/features/verification/presentation/nfc_scan_screen.dart';
import 'package:trvlez_mobile/features/verification/domain/passport_crop_params.dart';
import 'package:trvlez_mobile/features/verification/presentation/passport_capture_screen.dart';
import 'package:trvlez_mobile/features/verification/presentation/passport_instruction_screen.dart';
import 'package:trvlez_mobile/features/verification/presentation/passport_processing_screen.dart';
import 'package:trvlez_mobile/features/verification/presentation/passport_review_screen.dart';
import 'package:trvlez_mobile/features/verification/presentation/selfie_capture_screen.dart';
import 'package:trvlez_mobile/features/verification/presentation/selfie_instruction_screen.dart';
import 'package:trvlez_mobile/features/verification/presentation/selfie_review_screen.dart';
import 'package:trvlez_mobile/features/verification/presentation/verification_status_screen.dart';
import 'package:trvlez_mobile/features/verification/presentation/verification_processing_screen.dart';
import 'package:trvlez_mobile/features/verification/domain/processing_stage.dart';

/// Adapter to trigger GoRouter refresh when AuthState changes
class RouterNotifier extends ChangeNotifier {
  final Ref _ref;
  RouterNotifier(this._ref) {
    _ref.listen(authNotifierProvider, (_, _) => notifyListeners());
  }
}

/// Central router configuration for the TrvlEz app.
///
/// Redirect logic:
/// - Not authenticated → `/login`
final routerProvider = Provider<GoRouter>((ref) {
  final routerNotifier = RouterNotifier(ref);

  final cameraService = ref.read(cameraServiceProvider);
  final nfcPassportService = ref.read(nfcPassportServiceProvider);

  return GoRouter(
    initialLocation: AppRoutes.welcome,
    refreshListenable: routerNotifier,
    redirect: (context, state) {
      final authState = ref.read(authNotifierProvider).valueOrNull;
      final isAuthenticated = authState?.isAuthenticated ?? false;

      final location = state.matchedLocation;
      final isAuthRoute =
          location == AppRoutes.login ||
          location == AppRoutes.register ||
          location == AppRoutes.welcome;

      if (!isAuthenticated) {
        if (!isAuthRoute) return AppRoutes.login;
        return null;
      }

      if (location == AppRoutes.login ||
          location == AppRoutes.register ||
          location == AppRoutes.welcome) {
        return AppRoutes.home;
      }

      return null;
    },
    routes: [
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
          final id = state.pathParameters['id'] ?? '';
          final property = state.extra as Property?;
          if (property == null && id.isEmpty) {
            return const PropertiesListingScreen();
          }
          return PropertyDetailScreen(
            propertyId: property?.id ?? id,
            property: property,
            repository: ref.read(propertiesRepositoryProvider),
          );
        },
      ),
      // ─── Reservation Routes ─────────────────────────────────────
      GoRoute(
        path: AppRoutes.createReservation,
        builder: (context, state) {
          final property = state.extra as Property?;
          if (property == null) {
            return const PropertiesListingScreen();
          }
          return CreateReservationScreen(property: property);
        },
      ),
      GoRoute(
        path: AppRoutes.reservationDetail,
        builder: (context, state) {
          final reservation = state.extra is Reservation
              ? state.extra as Reservation
              : (state.extra is Map<String, dynamic>
                  ? (state.extra as Map<String, dynamic>)['reservation']
                      as Reservation?
                  : null);
          if (reservation == null) {
            return const MyTripsScreen();
          }
          return ReservationDetailScreen(reservation: reservation);
        },
      ),
      GoRoute(
        path: AppRoutes.bookingConfirmation,
        builder: (context, state) {
          final id = state.pathParameters['id'] ?? '';
          final reservation = state.extra is Reservation
              ? state.extra as Reservation
              : (state.extra is Map<String, dynamic>
                  ? (state.extra as Map<String, dynamic>)['reservation']
                      as Reservation?
                  : null);
          if (reservation == null && id.isEmpty) {
            return const MyTripsScreen();
          }
          return BookingConfirmationScreen(
            reservationId: reservation?.id ?? id,
            reservation: reservation,
            repository: ref.read(reservationRepositoryProvider),
          );
        },
      ),
      GoRoute(
        path: AppRoutes.reservationQr,
        builder: (context, state) {
          final reservation = state.extra is Reservation
              ? state.extra as Reservation
              : (state.extra is Map<String, dynamic>
                  ? (state.extra as Map<String, dynamic>)['reservation']
                      as Reservation?
                  : null);
          if (reservation == null) {
            return const MyTripsScreen();
          }
          return QrCodeScreen(reservation: reservation);
        },
      ),
      GoRoute(
        path: AppRoutes.reservationForm,
        builder: (context, state) {
          final extras = state.extra as Map<String, dynamic>?;
          final reservation = extras?['reservation'] as Reservation?;
          if (reservation == null) {
            return const MyTripsScreen();
          }
          return PreArrivalFormScreen(reservationId: reservation.id);
        },
      ),
      // ─── Profile & Verification Routes ──────────────────────────
      GoRoute(
        path: AppRoutes.profileSetup,
        builder: (context, state) => const ProfileSetupScreen(),
      ),
      GoRoute(
        path: AppRoutes.passportInstructions,
        builder: (context, state) => const PassportInstructionScreen(),
      ),
      GoRoute(
        path: AppRoutes.passportCapture,
        builder: (context, state) =>
            PassportCaptureScreen(cameraService: cameraService),
      ),
      GoRoute(
        path: AppRoutes.passportProcessing,
        builder: (context, state) {
          final extras = state.extra as Map<String, dynamic>?;
          final cropParams = extras?['cropParams'] as PassportCropParams?;
          return PassportProcessingScreen(cropParams: cropParams);
        },
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
          final extras = state.extra as Map<String, dynamic>?;
          final type = extras?['type'] as ProcessingType?;
          if (type == null) {
            // Process death recovery: redirect to status screen which
            // will reconcile with backend
            return const VerificationStatusScreen(verificationJobId: null);
          }
          return VerificationProcessingScreen(type: type);
        },
      ),
      GoRoute(
        path: AppRoutes.verificationStatus,
        builder: (context, state) {
          final extras = state.extra as Map<String, dynamic>?;
          final jobId = extras?['jobId'] as String?;
          return VerificationStatusScreen(verificationJobId: jobId);
        },
      ),
    ],
  );
});
