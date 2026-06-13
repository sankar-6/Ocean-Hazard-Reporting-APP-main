enum Environment { development, staging, production }

class EnvironmentConfig {
  // Change this to switch between environments
  static const Environment _environment = Environment.development;
  
  static String get baseUrl {
    switch (_environment) {
      case Environment.development:
        return 'https://dev-api.oceanhazardreporter.com/v1';
      case Environment.staging:
        return 'https://staging-api.oceanhazardreporter.com/v1';
      case Environment.production:
        return 'https://api.oceanhazardreporter.com/v1';
    }
  }
  
  static Duration get timeout {
    switch (_environment) {
      case Environment.development:
        return const Duration(seconds: 60);
      case Environment.staging:
        return const Duration(seconds: 30);
      case Environment.production:
        return const Duration(seconds: 15);
    }
  }
  
  static bool get enableLogging {
    switch (_environment) {
      case Environment.development:
        return true;
      case Environment.staging:
        return true;
      case Environment.production:
        return false;
    }
  }
  
  static bool get enableCrashlytics {
    switch (_environment) {
      case Environment.development:
        return false;
      case Environment.staging:
        return true;
      case Environment.production:
        return true;
    }
  }
  
  static bool get enableAnalytics {
    switch (_environment) {
      case Environment.development:
        return false;
      case Environment.staging:
        return true;
      case Environment.production:
        return true;
    }
  }
  
  static int get maxRetries {
    switch (_environment) {
      case Environment.development:
        return 1;
      case Environment.staging:
        return 2;
      case Environment.production:
        return 3;
    }
  }
  
  static Duration get cacheExpiry {
    switch (_environment) {
      case Environment.development:
        return const Duration(minutes: 1);
      case Environment.staging:
        return const Duration(minutes: 3);
      case Environment.production:
        return const Duration(minutes: 5);
    }
  }
  
  static String get environmentName {
    switch (_environment) {
      case Environment.development:
        return 'Development';
      case Environment.staging:
        return 'Staging';
      case Environment.production:
        return 'Production';
    }
  }
  
  static bool get isDevelopment => _environment == Environment.development;
  static bool get isStaging => _environment == Environment.staging;
  static bool get isProduction => _environment == Environment.production;
}
