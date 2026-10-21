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
  static const String profile = '/profile';

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

  // Section 06 · Check-in Flow
  static const String checkInSteps = '/check-in/:id/steps';
  static const String checkInVisa = '/check-in/:id/visa';
  static const String checkInVisaCapture = '/check-in/:id/visa-capture';
  static const String checkInVisaReview = '/check-in/:id/visa-review';
  static const String checkInDisclosure = '/check-in/:id/disclosure';
  static const String checkInDeclined = '/check-in/:id/declined';
  static const String checkInGuests = '/check-in/:id/guests';
  static const String checkInQuestions = '/check-in/:id/questions';
  static const String checkInDone = '/check-in/:id/done';
  static const String checkInPass = '/check-in/:id/pass';
  static const String hotelView = '/check-in/:id/hotel-view';

  static String checkInStepsPath(String id) => '/check-in/$id/steps';
  static String checkInVisaPath(String id) => '/check-in/$id/visa';
  static String checkInVisaCapturePath(String id) =>
      '/check-in/$id/visa-capture';
  static String checkInVisaReviewPath(String id) => '/check-in/$id/visa-review';
  static String checkInDisclosurePath(String id) => '/check-in/$id/disclosure';
  static String checkInDeclinedPath(String id) => '/check-in/$id/declined';
  static String checkInGuestsPath(String id) => '/check-in/$id/guests';
  static String checkInQuestionsPath(String id) => '/check-in/$id/questions';
  static String checkInDonePath(String id) => '/check-in/$id/done';
  static String checkInPassPath(String id) => '/check-in/$id/pass';
  static String hotelViewPath(String id) => '/check-in/$id/hotel-view';

  // Section 04 · Findr Programme
  static const String findr = '/findr';
  static const String joinFindr = '/findr/join';

  // Section 06b · Check in Anywhere
  static const String anywhereFind = '/anywhere/find';
  static const String anywhereHotel = '/anywhere/hotel';
  static const String anywhereStay = '/anywhere/stay';
  static const String anywhereTold = '/anywhere/told';
  static const String anywhereSent = '/anywhere/sent';

  // Section 06c · Disputes
  static const String disputeReason = '/dispute/:id/reason';
  static const String disputeDetail = '/dispute/:id/detail';
  static const String disputeRaised = '/dispute/:id/raised';
  static const String disputeStatus = '/dispute/:id/status';

  static String disputeReasonPath(String id) => '/dispute/$id/reason';
  static String disputeDetailPath(String id) => '/dispute/$id/detail';
  static String disputeRaisedPath(String id) => '/dispute/$id/raised';
  static String disputeStatusPath(String id) => '/dispute/$id/status';

  // Reservations
  static const String reservationDetail = '/reservations/:id';
  static const String reservationForm = '/reservations/:id/form';

  static String reservationFormPath(String id) => '/reservations/$id/form';

  // Profile Setup
  static const String profileSetup = '/profile-setup';

  // Verification Flow
  static const String verificationLanding = '/verification/landing';
  static const String verificationStatus = '/verification/status';
  static const String reportProblem = '/verification/report-problem';
  static const String passportInstructions =
      '/verification/passport-instructions';
  static const String passportCapture = '/verification/passport-capture';
  static const String passportProcessing = '/verification/passport-processing';
  static const String passportReview = '/verification/passport-review';
  static const String passportFailed = '/verification/passport-failed';
  static const String mrzReview = '/verification/confirm-details';
  static const String confirmDetails = '/verification/confirm-details';
  static const String selfieInstructions = '/verification/selfie-instructions';
  static const String selfieCapture = '/verification/selfie-capture';
  static const String selfieReview = '/verification/selfie-review';
  static const String selfieProcessing = '/verification/selfie-processing';
  static const String selfieFailed = '/verification/selfie-failed';
  static const String selfieSuccess = '/verification/selfie-success';
  static const String nfcIntro = '/verification/nfc-intro';
  static const String nfcScan = '/verification/nfc-scan';
  static const String chipData = '/verification/chip-data';
  static const String verificationFinalCheck = '/verification/final-check';
  @Deprecated('Use verificationFinalCheck instead')
  static const String nfcFinalCheck = verificationFinalCheck;
  static const String nfcFailed = '/verification/failed';
  @Deprecated(
    'Verification processing is now per-step (passportProcessing / selfieProcessing)',
  )
  static const String verificationProcessing = '/verification/processing';
  static const String verificationSuccess = '/verification/success';
}
