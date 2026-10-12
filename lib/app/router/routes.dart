/// Declarative route path constants for TrvlEz.
class AppRoutes {
  const AppRoutes._();

  // Auth & Onboarding
  static const String welcome = '/welcome';
  static const String login = '/login';
  static const String register = '/register';
  static const String onboarding = '/onboarding';
  static const String forgotPassword = '/forgot-password';
  static const String newPassword = '/new-password';
  static const String twoStepCode = '/two-step-code';

  // Main Shell
  static const String home = '/home';
  static const String myTrips = '/my-trips';
  static const String bookings = '/my-trips';
  static const String favorites = '/favorites';
  static const String saved = '/favorites';
  static const String profile = '/profile';
  static const String account = '/profile';

  // Properties / ezStays
  static const String ezStays = '/stays';
  static const String propertyDetail = '/properties/:id';

  // Account Operations
  static const String closeAccount = '/close-account';

  static String propertyDetailPath(String id) => '/properties/$id';

  // Section 05 · Booking Flow
  static const String bookingProperty = '/stays/property';
  static const String bookingDates = '/stays/property/dates';
  static const String bookingReview = '/stays/review';
  static const String bookingCard = '/stays/review/card';
  static const String bookingDone = '/stays/booked';

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
  static const String verificationLanding = '/verification/landing';
  static const String verificationStatus = '/verification/status';
  static const String reportProblem = '/verification/report-problem';
  static const String passportInstructions =
      '/verification/passport-instructions';
  static const String passportHowTo = '/verification/passport-instructions';
  static const String passportCapture = '/verification/passport-capture';
  static const String passportProcessing = '/verification/passport-processing';
  static const String passportReview = '/verification/passport-review';
  static const String passportFailed = '/verification/passport-failed';
  static const String mrzReview = '/verification/confirm-details';
  static const String confirmDetails = '/verification/confirm-details';
  static const String selfieInstructions = '/verification/selfie-instructions';
  static const String selfieIntro = '/verification/selfie-instructions';
  static const String selfieCapture = '/verification/selfie-capture';
  static const String selfieRecording = '/verification/selfie-capture';
  static const String selfieReview = '/verification/selfie-review';
  static const String selfieProcessing = '/verification/selfie-processing';
  static const String selfieFailed = '/verification/selfie-failed';
  static const String selfieSuccess = '/verification/selfie-success';
  static const String nfcIntro = '/verification/nfc-intro';
  static const String nfcScan = '/verification/nfc-scan';
  static const String nfcResult = '/verification/chip-data';
  static const String chipData = '/verification/chip-data';
  static const String nfcFinalCheck = '/verification/nfc-final-check';
  static const String nfcFailed = '/verification/nfc-failed';
  static const String verificationProcessing = '/verification/processing';
  static const String verificationSuccess = '/verification/success';
}

/// Alias for [AppRoutes] per architecture guidelines.
typedef Routes = AppRoutes;
