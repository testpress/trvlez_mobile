/// App-wide configuration constants.
class AppConfig {
  const AppConfig._();

  /// Base URL for the TrvlEz backend API.
  ///
  /// For Android emulator targeting localhost, use `http://10.0.2.2:8000`.
  /// For iOS simulator, use `http://localhost:8000`.
  /// For a deployed environment, pass the URL via --dart-define.
  /// Example: flutter build apk --release --dart-define=API_BASE_URL=https://api.production.com
  static const String apiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://localhost:8000',
  );

  /// API version prefix matching the backend's `API_V1_STR`.
  static const String apiPrefix = '/api/v1';

  /// Full API base path: `{apiBaseUrl}{apiPrefix}`.
  static String get apiUrl => '$apiBaseUrl$apiPrefix';
}
