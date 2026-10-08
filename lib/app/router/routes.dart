/// Declarative route path constants for TrvlEz.
class AppRoutes {
  const AppRoutes._();

  // Auth & Onboarding
  static const String welcome = '/welcome';
  static const String login = '/login';
  static const String register = '/register';
  static const String onboarding = '/onboarding';

  // Main Shell
  static const String home = '/home';
  static const String myTrips = '/my-trips';
  static const String favorites = '/favorites';
  static const String profile = '/profile';

  // Properties
  static const String propertyDetail = '/properties/:id';

  static String propertyDetailPath(String id) => '/properties/$id';

  // Reservations
  static const String createReservation = '/reservations/create';
  static const String reservationDetail = '/reservations/:id';
  static const String reservationQr = '/reservations/:id/qr';
  static const String reservationForm = '/reservations/:id/form';
  static const String bookingConfirmation = '/reservations/:id/confirmation';

  static String reservationDetailPath(String id) => '/reservations/$id';
  static String reservationQrPath(String id) => '/reservations/$id/qr';
  static String reservationFormPath(String id) => '/reservations/$id/form';
  static String bookingConfirmationPath(String id) =>
      '/reservations/$id/confirmation';

  // Profile Setup
  static const String profileSetup = '/profile-setup';

  // Verification Flow
  static const String passportInstructions =
      '/verification/passport-instructions';
  static const String passportCapture = '/verification/passport-capture';
  static const String passportProcessing = '/verification/passport-processing';
  static const String passportReview = '/verification/passport-review';
  static const String mrzReview = '/verification/mrz-review';
  static const String selfieInstructions = '/verification/selfie-instructions';
  static const String selfieCapture = '/verification/selfie-capture';
  static const String selfieReview = '/verification/selfie-review';
  static const String nfcIntro = '/verification/nfc-intro';
  static const String nfcScan = '/verification/nfc-scan';
  static const String nfcResult = '/verification/nfc-result';
  static const String verificationProcessing = '/verification/processing';
  static const String verificationStatus = '/verification/status';
}

/// Alias for [AppRoutes] per architecture guidelines.
typedef Routes = AppRoutes;
