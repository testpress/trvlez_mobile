import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:trvlez_mobile/app/router/routes.dart';
import 'package:trvlez_mobile/core/auth/auth_notifier.dart';
import 'package:trvlez_mobile/core/device/camera_service.dart';
import 'package:trvlez_mobile/core/widgets/join_findr_sheet.dart';
import 'package:trvlez_mobile/features/anywhere/presentation/screens/anywhere_sent_screen.dart';
import 'package:trvlez_mobile/features/anywhere/presentation/screens/find_hotel_screen.dart';
import 'package:trvlez_mobile/features/anywhere/presentation/screens/hotel_details_screen.dart';
import 'package:trvlez_mobile/features/anywhere/presentation/screens/stay_details_screen.dart';
import 'package:trvlez_mobile/features/anywhere/presentation/screens/what_they_are_told_screen.dart';
import 'package:trvlez_mobile/features/auth/presentation/screens/forgot_password_screen.dart';
import 'package:trvlez_mobile/features/auth/presentation/screens/login_screen.dart';
import 'package:trvlez_mobile/features/auth/presentation/screens/new_password_screen.dart';
import 'package:trvlez_mobile/features/auth/presentation/screens/registration_screen.dart';
import 'package:trvlez_mobile/features/auth/presentation/screens/two_step_code_screen.dart';
import 'package:trvlez_mobile/features/auth/presentation/screens/welcome_screen.dart';
import 'package:trvlez_mobile/features/booking/presentation/screens/booked_screen.dart';
import 'package:trvlez_mobile/features/booking/presentation/screens/booking_card_screen.dart';
import 'package:trvlez_mobile/features/booking/presentation/screens/booking_dates_screen.dart';
import 'package:trvlez_mobile/features/booking/presentation/screens/booking_review_screen.dart';
import 'package:trvlez_mobile/features/booking/presentation/screens/property_screen.dart';
import 'package:trvlez_mobile/features/check_in/presentation/screens/check_in_declined_screen.dart';
import 'package:trvlez_mobile/features/check_in/presentation/screens/check_in_disclosure_screen.dart';
import 'package:trvlez_mobile/features/check_in/presentation/screens/check_in_done_screen.dart';
import 'package:trvlez_mobile/features/check_in/presentation/screens/check_in_guests_screen.dart';
import 'package:trvlez_mobile/features/check_in/presentation/screens/check_in_pass_screen.dart';
import 'package:trvlez_mobile/features/check_in/presentation/screens/check_in_questions_screen.dart';
import 'package:trvlez_mobile/features/check_in/presentation/screens/check_in_steps_screen.dart';
import 'package:trvlez_mobile/features/check_in/presentation/screens/check_in_visa_capture_screen.dart';
import 'package:trvlez_mobile/features/check_in/presentation/screens/check_in_visa_review_screen.dart';
import 'package:trvlez_mobile/features/check_in/presentation/screens/check_in_visa_screen.dart';
import 'package:trvlez_mobile/features/check_in/presentation/screens/hotel_view_screen.dart';
import 'package:trvlez_mobile/features/disputes/presentation/screens/dispute_detail_screen.dart';
import 'package:trvlez_mobile/features/disputes/presentation/screens/dispute_raised_screen.dart';
import 'package:trvlez_mobile/features/disputes/presentation/screens/dispute_reason_screen.dart';
import 'package:trvlez_mobile/features/disputes/presentation/screens/dispute_status_screen.dart';
import 'package:trvlez_mobile/features/findr/presentation/screens/findr_programme_screen.dart';
import 'package:trvlez_mobile/features/home/presentation/screens/home_screen.dart';
import 'package:trvlez_mobile/features/home/presentation/widgets/main_scaffold.dart';
import 'package:trvlez_mobile/features/profile/presentation/screens/account_screen.dart';
import 'package:trvlez_mobile/features/profile/presentation/screens/close_account_screen.dart';
import 'package:trvlez_mobile/features/profile/presentation/screens/profile_setup_screen.dart';
import 'package:trvlez_mobile/features/properties/domain/entities/property.dart';
import 'package:trvlez_mobile/features/properties/presentation/screens/properties_listing_screen.dart';
import 'package:trvlez_mobile/features/reservations/presentation/providers/reservations_providers.dart';
import 'package:trvlez_mobile/features/reservations/presentation/screens/my_trips_screen.dart';
import 'package:trvlez_mobile/features/reservations/presentation/screens/pre_arrival_form_screen.dart';
import 'package:trvlez_mobile/features/reservations/presentation/screens/reservation_detail_screen.dart';
import 'package:trvlez_mobile/features/saved/presentation/screens/saved_screen.dart';
import 'package:trvlez_mobile/features/verification/data/services/nfc_passport_service_impl.dart';
import 'package:trvlez_mobile/features/verification/domain/entities/problem_report_context.dart';
import 'package:trvlez_mobile/features/verification/domain/passport_crop_params.dart';
import 'package:trvlez_mobile/features/verification/presentation/screens/chip_data_screen.dart';
import 'package:trvlez_mobile/features/verification/presentation/screens/confirm_details_screen.dart';
import 'package:trvlez_mobile/features/verification/presentation/screens/nfc_failed_screen.dart';
import 'package:trvlez_mobile/features/verification/presentation/screens/nfc_intro_screen.dart';
import 'package:trvlez_mobile/features/verification/presentation/screens/nfc_scan_screen.dart';
import 'package:trvlez_mobile/features/verification/presentation/screens/passport_capture_screen.dart';
import 'package:trvlez_mobile/features/verification/presentation/screens/passport_failed_screen.dart';
import 'package:trvlez_mobile/features/verification/presentation/screens/passport_instruction_screen.dart';
import 'package:trvlez_mobile/features/verification/presentation/screens/passport_processing_screen.dart';
import 'package:trvlez_mobile/features/verification/presentation/screens/passport_review_screen.dart';
import 'package:trvlez_mobile/features/verification/presentation/screens/report_a_problem_screen.dart';
import 'package:trvlez_mobile/features/verification/presentation/screens/selfie_capture_screen.dart';
import 'package:trvlez_mobile/features/verification/presentation/screens/selfie_failed_screen.dart';
import 'package:trvlez_mobile/features/verification/presentation/screens/selfie_instruction_screen.dart';
import 'package:trvlez_mobile/features/verification/presentation/screens/selfie_processing_screen.dart';
import 'package:trvlez_mobile/features/verification/presentation/screens/selfie_review_screen.dart';
import 'package:trvlez_mobile/features/verification/presentation/screens/selfie_success_screen.dart';
import 'package:trvlez_mobile/features/verification/presentation/screens/verification_final_check_screen.dart';
import 'package:trvlez_mobile/features/verification/presentation/screens/verification_landing_screen.dart';
import 'package:trvlez_mobile/features/verification/presentation/screens/verification_success_screen.dart';
import 'package:trvlez_mobile/features/verification/presentation/state/verification_state.dart';

/// Adapter to trigger GoRouter refresh when AuthState changes
class RouterNotifier extends ChangeNotifier {
  final Ref _ref;
  RouterNotifier(this._ref) {
    _ref.listen(authNotifierProvider, (previous, next) {
      // Do not notify during transient loading states without values
      // to prevent premature redirection before auth state is resolved.
      if (!next.isLoading || next.hasValue) {
        notifyListeners();
      }
    });
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
      final authAsync = ref.read(authNotifierProvider);
      // Wait for auth initialization if in-flight on startup without a value
      if (authAsync.isLoading && !authAsync.hasValue) {
        return null;
      }

      final authState = authAsync.valueOrNull;
      final isAuthenticated = authState?.isAuthenticated ?? false;

      final location = state.matchedLocation;
      final isAuthRoute =
          location == AppRoutes.login ||
          location == AppRoutes.register ||
          location == AppRoutes.welcome ||
          location == AppRoutes.forgotPassword ||
          location == AppRoutes.newPassword ||
          location == AppRoutes.twoStepCode;

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
        path: AppRoutes.forgotPassword,
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>?;
          return ForgotPasswordScreen(
            email: extra?['email'] as String? ?? '',
            isChangePassword: extra?['isChangePassword'] as bool?,
          );
        },
      ),
      GoRoute(
        path: AppRoutes.newPassword,
        builder: (context, state) => const NewPasswordScreen(),
      ),
      GoRoute(
        path: AppRoutes.twoStepCode,
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>?;
          return TwoStepCodeScreen(
            email: extra?['email'] as String? ?? '',
            isPasswordReset: extra?['isPasswordReset'] as bool? ?? false,
          );
        },
      ),
      GoRoute(
        path: AppRoutes.onboarding,
        redirect: (context, state) => AppRoutes.verificationLanding,
      ),
      ShellRoute(
        builder: (context, state, child) {
          return MainScaffold(child: child);
        },
        routes: [
          GoRoute(
            path: AppRoutes.home,
            builder: (context, state) => const HomeScreen(),
          ),
          GoRoute(
            path: AppRoutes.myTrips,
            builder: (context, state) => const MyTripsScreen(),
          ),
          GoRoute(
            path: AppRoutes.favorites,
            builder: (context, state) => const SavedScreen(),
          ),
          GoRoute(
            path: AppRoutes.profile,
            builder: (context, state) => const AccountScreen(),
          ),
        ],
      ),
      GoRoute(
        path: AppRoutes.ezStays,
        builder: (context, state) => const PropertiesListingScreen(),
      ),
      GoRoute(
        path: AppRoutes.closeAccount,
        builder: (context, state) => const CloseAccountScreen(),
      ),
      GoRoute(
        path: AppRoutes.propertyDetail,
        builder: (context, state) {
          final id = state.pathParameters['id'] ?? '';
          final property = state.extra as Property?;
          final propertyId = property?.id ?? id;
          if (propertyId.isEmpty) {
            return const PropertiesListingScreen();
          }
          return PropertyScreen(property: property, propertyId: propertyId);
        },
      ),
      // ─── Booking Flow Routes ─────────────────────────────────────
      GoRoute(
        path: AppRoutes.bookingProperty,
        builder: (context, state) {
          final property = state.extra as Property?;
          final propertyId =
              property?.id ?? state.uri.queryParameters['id'] ?? '';
          return PropertyScreen(
            property: property,
            propertyId: propertyId.isNotEmpty ? propertyId : null,
          );
        },
      ),
      GoRoute(
        path: AppRoutes.bookingDates,
        builder: (context, state) => const BookingDatesScreen(),
      ),
      GoRoute(
        path: AppRoutes.bookingReview,
        builder: (context, state) => const BookingReviewScreen(),
      ),
      GoRoute(
        path: AppRoutes.bookingCard,
        builder: (context, state) => const BookingCardScreen(),
      ),
      GoRoute(
        path: AppRoutes.bookingDone,
        builder: (context, state) => const BookedScreen(),
      ),
      // ─── Reservation Routes ─────────────────────────────────────
      GoRoute(
        path: AppRoutes.reservationDetail,
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
          return ReservationDetailScreen(
            reservationId: reservation?.id ?? id,
            reservation: reservation,
            repository: ref.read(reservationRepositoryProvider),
          );
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
      // ─── Check-in Routes (Section 06) ───────────────────────────
      GoRoute(
        path: AppRoutes.checkInSteps,
        builder: (context, state) {
          final id = state.pathParameters['id'] ?? '';
          return CheckInStepsScreen(reservationId: id);
        },
      ),
      GoRoute(
        path: AppRoutes.checkInVisa,
        builder: (context, state) {
          final id = state.pathParameters['id'] ?? '';
          return CheckInVisaScreen(reservationId: id);
        },
      ),
      GoRoute(
        path: AppRoutes.checkInVisaCapture,
        builder: (context, state) {
          final id = state.pathParameters['id'] ?? '';
          return CheckInVisaCaptureScreen(reservationId: id);
        },
      ),
      GoRoute(
        path: AppRoutes.checkInVisaReview,
        builder: (context, state) {
          final id = state.pathParameters['id'] ?? '';
          return CheckInVisaReviewScreen(reservationId: id);
        },
      ),
      GoRoute(
        path: AppRoutes.checkInDisclosure,
        builder: (context, state) {
          final id = state.pathParameters['id'] ?? '';
          return CheckInDisclosureScreen(reservationId: id);
        },
      ),
      GoRoute(
        path: AppRoutes.checkInDeclined,
        builder: (context, state) {
          final id = state.pathParameters['id'] ?? '';
          return CheckInDeclinedScreen(reservationId: id);
        },
      ),
      GoRoute(
        path: AppRoutes.checkInGuests,
        builder: (context, state) {
          final id = state.pathParameters['id'] ?? '';
          return CheckInGuestsScreen(reservationId: id);
        },
      ),
      GoRoute(
        path: AppRoutes.checkInQuestions,
        builder: (context, state) {
          final id = state.pathParameters['id'] ?? '';
          return CheckInQuestionsScreen(reservationId: id);
        },
      ),
      GoRoute(
        path: AppRoutes.checkInDone,
        builder: (context, state) {
          final id = state.pathParameters['id'] ?? '';
          return CheckInDoneScreen(reservationId: id);
        },
      ),
      GoRoute(
        path: AppRoutes.checkInPass,
        builder: (context, state) {
          final id = state.pathParameters['id'] ?? '';
          return CheckInPassScreen(reservationId: id);
        },
      ),
      GoRoute(
        path: AppRoutes.hotelView,
        builder: (context, state) {
          final id = state.pathParameters['id'] ?? '';
          return HotelViewScreen(reservationId: id);
        },
      ),
      // ─── Findr Routes (Section 04) ──────────────────────────────
      GoRoute(
        path: AppRoutes.findr,
        builder: (context, state) => const FindrProgrammeScreen(),
      ),
      GoRoute(
        path: AppRoutes.joinFindr,
        builder: (context, state) => const JoinFindrSheet(),
      ),
      // ─── Check-in Anywhere Routes ───────────────────────────────
      GoRoute(
        path: AppRoutes.anywhereFind,
        builder: (context, state) => const FindHotelScreen(),
      ),
      GoRoute(
        path: AppRoutes.anywhereHotel,
        builder: (context, state) => const HotelDetailsScreen(),
      ),
      GoRoute(
        path: AppRoutes.anywhereStay,
        builder: (context, state) => const StayDetailsScreen(),
      ),
      GoRoute(
        path: AppRoutes.anywhereTold,
        builder: (context, state) => const WhatTheyAreToldScreen(),
      ),
      GoRoute(
        path: AppRoutes.anywhereSent,
        builder: (context, state) => const AnywhereSentScreen(),
      ),
      // ─── Dispute Routes ─────────────────────────────────────────
      GoRoute(
        path: AppRoutes.disputeReason,
        builder: (context, state) {
          final id = state.pathParameters['id'] ?? '';
          return DisputeReasonScreen(reservationId: id);
        },
      ),
      GoRoute(
        path: AppRoutes.disputeDetail,
        builder: (context, state) {
          final id = state.pathParameters['id'] ?? '';
          return DisputeDetailScreen(reservationId: id);
        },
      ),
      GoRoute(
        path: AppRoutes.disputeRaised,
        builder: (context, state) {
          final id = state.pathParameters['id'] ?? '';
          return DisputeRaisedScreen(reservationId: id);
        },
      ),
      GoRoute(
        path: AppRoutes.disputeStatus,
        builder: (context, state) {
          final id = state.pathParameters['id'] ?? '';
          return DisputeStatusScreen(reservationId: id);
        },
      ),
      // ─── Profile & Verification Routes ──────────────────────────
      GoRoute(
        path: AppRoutes.profileSetup,
        builder: (context, state) => const ProfileSetupScreen(),
      ),
      GoRoute(
        path: AppRoutes.verificationLanding,
        builder: (context, state) => const VerificationLandingScreen(),
      ),
      GoRoute(
        path: AppRoutes.reportProblem,
        builder: (context, state) {
          final contextData = state.extra as ProblemReportContext?;
          return ReportAProblemScreen(contextData: contextData);
        },
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
        path: AppRoutes.passportFailed,
        builder: (context, state) {
          final extra = state.extra;
          String? reason;
          String? phase;
          if (extra is String) {
            reason = extra;
          } else if (extra is Map<String, dynamic>) {
            reason = extra['reason'] as String?;
            phase = extra['phase'] as String?;
          }
          return PassportFailedScreen(
            failureReason: reason,
            failurePhase: phase != null
                ? VerificationPhase.values
                      .where((p) => p.name == phase)
                      .firstOrNull
                : null,
          );
        },
      ),
      GoRoute(
        path: AppRoutes.confirmDetails,
        builder: (context, state) => const ConfirmDetailsScreen(),
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
        path: AppRoutes.selfieProcessing,
        builder: (context, state) => const SelfieProcessingScreen(),
      ),
      GoRoute(
        path: AppRoutes.selfieFailed,
        builder: (context, state) {
          final extra = state.extra;
          final reason = extra is String
              ? extra
              : (extra is Map<String, dynamic>
                    ? extra['reason'] as String?
                    : null);
          return SelfieFailedScreen(failureReason: reason);
        },
      ),
      GoRoute(
        path: AppRoutes.selfieSuccess,
        builder: (context, state) => const SelfieSuccessScreen(),
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
        path: AppRoutes.chipData,
        builder: (context, state) => const ChipDataScreen(),
      ),
      GoRoute(
        path: AppRoutes.verificationFinalCheck,
        builder: (context, state) => const VerificationFinalCheckScreen(),
      ),
      GoRoute(
        path: '/verification/nfc-final-check',
        redirect: (context, state) => AppRoutes.verificationFinalCheck,
      ),
      GoRoute(
        path: AppRoutes.nfcFailed,
        builder: (context, state) {
          final extra = state.extra;
          final extras = extra is Map<String, dynamic> ? extra : null;
          return NfcFailedScreen(
            failedStepTitle:
                extras?['failedStepTitle'] as String? ?? 'Chip scan',
            redoButtonLabel: extras?['redoButtonLabel'] as String?,
            redoRoute: extras?['redoRoute'] as String?,
            reason: extras?['reason'] as String?,
            mitigation: extras?['mitigation'] as String?,
          );
        },
      ),
      GoRoute(
        path: AppRoutes.verificationSuccess,
        builder: (context, state) => const VerificationSuccessScreen(),
      ),
      GoRoute(
        path: AppRoutes.verificationProcessing,
        redirect: (context, state) => AppRoutes.verificationStatus,
      ),
      GoRoute(
        path: AppRoutes.verificationStatus,
        builder: (context, state) {
          final extras = state.extra as Map<String, dynamic>?;
          final jobId = extras?['jobId'] as String?;
          return VerificationFinalCheckScreen(verificationJobId: jobId);
        },
      ),
    ],
  );
});
