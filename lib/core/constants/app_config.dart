/// App-wide configuration constants.
class AppConfig {
  const AppConfig._();

  /// Base URL for the TrvlEz backend API.
  ///
  /// For Android emulator targeting localhost, use `http://10.0.2.2:8000`.
  /// For iOS simulator, use `http://localhost:8000`.
  /// For a deployed environment, replace with the actual URL.
  static const String apiBaseUrl = 'http://localhost:8000';
  // ?static const String apiBaseUrl = 'http://10.0.2.2:8000';

  /// API version prefix matching the backend's `API_V1_STR`.
  static const String apiPrefix = '/api/v1';

  /// Full API base path: `{apiBaseUrl}{apiPrefix}`.
  static String get apiUrl => '$apiBaseUrl$apiPrefix';
}
