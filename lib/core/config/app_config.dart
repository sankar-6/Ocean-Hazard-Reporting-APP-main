/// App configuration and environment variables
/// Reads compile-time constants via --dart-define

class AppConfig {
  /// Base URL for the REST API (e.g., https://ocean-reports-api.onrender.com)
  static const String apiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'https://ocean-reports-api.onrender.com',
  );
}
