import 'package:shared_preferences/shared_preferences.dart';
import 'dart:developer' as developer;
import 'dart:convert';
import '../config/environment.dart';

class LoggingService {
  static bool _isInitialized = false;

  static Future<void> initialize() async {
    if (_isInitialized) return;

    // Initialize Firebase Crashlytics only in staging/production
    if (EnvironmentConfig.enableCrashlytics) {
      try {
        // Firebase Crashlytics will be initialized when the package is added
        // For now, just log that it would be initialized
        print('Firebase Crashlytics would be initialized here');
      } catch (e) {
        // Handle case where Firebase is not properly configured
        print('Warning: Firebase Crashlytics not available: $e');
      }
    }

    _isInitialized = true;
  }

  static void logInfo(String message, {Map<String, dynamic>? data}) {
    developer.log(message, name: 'INFO', error: data);

    // Send to analytics in production
    if (EnvironmentConfig.enableLogging) {
      print('ℹ️ $message');
      if (data != null) print('📊 Data: $data');
    }
  }

  static void logWarning(String message, {Map<String, dynamic>? data}) {
    developer.log(message, name: 'WARNING', error: data);

    if (EnvironmentConfig.enableLogging) {
      print('⚠️ $message');
      if (data != null) print('📊 Data: $data');
    }
  }

  static void logError(
    String message, {
    Object? error,
    StackTrace? stackTrace,
  }) {
    developer.log(message, name: 'ERROR', error: error, stackTrace: stackTrace);

    // Send to Crashlytics in staging/production
    if (EnvironmentConfig.enableCrashlytics) {
      try {
        // FirebaseCrashlytics.instance.recordError(error, stackTrace);
        // For now, just log that it would be sent to Crashlytics
        print('Error would be sent to Firebase Crashlytics: $error');
      } catch (e) {
        // Handle case where Firebase is not available
        print('Warning: Could not send error to Crashlytics: $e');
      }
    }

    if (EnvironmentConfig.enableLogging) {
      print('❌ $message');
      if (error != null) print('🐛 Error: $error');
      if (stackTrace != null) print('📚 Stack: $stackTrace');
    }
  }

  static void logApiCall({
    required String method,
    required String endpoint,
    required int statusCode,
    required Duration duration,
    Map<String, dynamic>? requestData,
    Map<String, dynamic>? responseData,
  }) {
    final logData = {
      'method': method,
      'endpoint': endpoint,
      'statusCode': statusCode,
      'duration': duration.inMilliseconds,
      'requestData': requestData,
      'responseData': responseData,
    };

    logInfo('API Call: $method $endpoint', data: logData);

    // Track API performance
    _trackApiPerformance(endpoint, duration, statusCode);
  }

  static void _trackApiPerformance(
    String endpoint,
    Duration duration,
    int statusCode,
  ) {
    // Store performance metrics
    _storeMetric('api_performance', {
      'endpoint': endpoint,
      'duration': duration.inMilliseconds,
      'statusCode': statusCode,
      'timestamp': DateTime.now().toIso8601String(),
    });
  }

  static Future<void> _storeMetric(
    String key,
    Map<String, dynamic> data,
  ) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final metrics = prefs.getStringList('metrics_$key') ?? [];
      metrics.add(jsonEncode(data));

      // Keep only last 100 metrics
      if (metrics.length > 100) {
        metrics.removeRange(0, metrics.length - 100);
      }

      await prefs.setStringList('metrics_$key', metrics);
    } catch (e) {
      // Handle storage errors gracefully
      print('Warning: Could not store metric: $e');
    }
  }

  static Future<List<Map<String, dynamic>>> getMetrics(String key) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final metrics = prefs.getStringList('metrics_$key') ?? [];

      return metrics.map((metric) {
        try {
          return jsonDecode(metric) as Map<String, dynamic>;
        } catch (e) {
          return <String, dynamic>{};
        }
      }).toList();
    } catch (e) {
      return [];
    }
  }

  static Future<void> clearMetrics(String key) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('metrics_$key');
    } catch (e) {
      print('Warning: Could not clear metrics: $e');
    }
  }

  static Future<void> clearAllMetrics() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final keys = prefs.getKeys().where((key) => key.startsWith('metrics_'));

      for (final key in keys) {
        await prefs.remove(key);
      }
    } catch (e) {
      print('Warning: Could not clear all metrics: $e');
    }
  }

  // User action tracking
  static void trackUserAction(
    String action, {
    Map<String, dynamic>? properties,
  }) {
    final data = {
      'action': action,
      'properties': properties,
      'timestamp': DateTime.now().toIso8601String(),
    };

    logInfo('User Action: $action', data: data);
    _storeMetric('user_actions', data);
  }

  // App lifecycle tracking
  static void trackAppLifecycle(String event) {
    final data = {
      'event': event,
      'timestamp': DateTime.now().toIso8601String(),
    };

    logInfo('App Lifecycle: $event', data: data);
    _storeMetric('app_lifecycle', data);
  }

  // Performance tracking
  static void trackPerformance(
    String operation,
    Duration duration, {
    Map<String, dynamic>? metadata,
  }) {
    final data = {
      'operation': operation,
      'duration': duration.inMilliseconds,
      'metadata': metadata,
      'timestamp': DateTime.now().toIso8601String(),
    };

    logInfo(
      'Performance: $operation took ${duration.inMilliseconds}ms',
      data: data,
    );
    _storeMetric('performance', data);
  }

  // Network status tracking
  static void trackNetworkStatus(String status, {String? error}) {
    final data = {
      'status': status,
      'error': error,
      'timestamp': DateTime.now().toIso8601String(),
    };

    logInfo('Network Status: $status', data: data);
    _storeMetric('network_status', data);
  }

  // Get analytics summary
  static Future<Map<String, dynamic>> getAnalyticsSummary() async {
    try {
      final apiMetrics = await getMetrics('api_performance');
      final userActions = await getMetrics('user_actions');
      final performance = await getMetrics('performance');
      final networkStatus = await getMetrics('network_status');

      // Calculate API performance stats
      final apiStats = _calculateApiStats(apiMetrics);
      final performanceStats = _calculatePerformanceStats(performance);

      return {
        'api_stats': apiStats,
        'performance_stats': performanceStats,
        'total_user_actions': userActions.length,
        'network_events': networkStatus.length,
        'generated_at': DateTime.now().toIso8601String(),
      };
    } catch (e) {
      return {
        'error': 'Could not generate analytics summary: $e',
        'generated_at': DateTime.now().toIso8601String(),
      };
    }
  }

  static Map<String, dynamic> _calculateApiStats(
    List<Map<String, dynamic>> apiMetrics,
  ) {
    if (apiMetrics.isEmpty) {
      return {
        'total_calls': 0,
        'average_duration': 0,
        'success_rate': 0,
        'error_rate': 0,
      };
    }

    final totalCalls = apiMetrics.length;
    final totalDuration = apiMetrics.fold<int>(
      0,
      (sum, metric) => sum + (metric['duration'] as int? ?? 0),
    );
    final successfulCalls = apiMetrics
        .where((metric) => (metric['statusCode'] as int? ?? 0) < 400)
        .length;
    final errorCalls = totalCalls - successfulCalls;

    return {
      'total_calls': totalCalls,
      'average_duration': totalDuration / totalCalls,
      'success_rate': (successfulCalls / totalCalls) * 100,
      'error_rate': (errorCalls / totalCalls) * 100,
    };
  }

  static Map<String, dynamic> _calculatePerformanceStats(
    List<Map<String, dynamic>> performanceMetrics,
  ) {
    if (performanceMetrics.isEmpty) {
      return {
        'total_operations': 0,
        'average_duration': 0,
        'slowest_operation': null,
      };
    }

    final totalOperations = performanceMetrics.length;
    final totalDuration = performanceMetrics.fold<int>(
      0,
      (sum, metric) => sum + (metric['duration'] as int? ?? 0),
    );

    // Find slowest operation
    Map<String, dynamic>? slowestOperation;
    int maxDuration = 0;

    for (final metric in performanceMetrics) {
      final duration = metric['duration'] as int? ?? 0;
      if (duration > maxDuration) {
        maxDuration = duration;
        slowestOperation = metric;
      }
    }

    return {
      'total_operations': totalOperations,
      'average_duration': totalDuration / totalOperations,
      'slowest_operation': slowestOperation,
    };
  }
}
