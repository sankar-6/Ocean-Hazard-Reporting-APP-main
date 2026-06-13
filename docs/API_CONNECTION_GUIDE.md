# Real-World API Connection Guide for Flutter Apps

## Table of Contents
1. [Environment Configuration](#environment-configuration)
2. [Production-Ready API Service](#production-ready-api-service)
3. [Authentication & Token Management](#authentication--token-management)
4. [Error Handling & Retry Logic](#error-handling--retry-logic)
5. [Offline Support & Caching](#offline-support--caching)
6. [Monitoring & Logging](#monitoring--logging)
7. [Security Best Practices](#security-best-practices)
8. [Testing APIs](#testing-apis)
9. [Deployment Checklist](#deployment-checklist)

## Environment Configuration

### 1. Create Environment-Specific Configurations

Create different configuration files for different environments:

```dart
// lib/core/config/environment.dart
enum Environment { development, staging, production }

class EnvironmentConfig {
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
}
```

### 2. Build Configuration

Update your build configurations to use different environments:

```yaml
# android/app/build.gradle.kts
android {
    buildTypes {
        debug {
            buildConfigField "String", "API_BASE_URL", '"https://dev-api.oceanhazardreporter.com/v1"'
            buildConfigField "boolean", "ENABLE_LOGGING", "true"
        }
        release {
            buildConfigField "String", "API_BASE_URL", '"https://api.oceanhazardreporter.com/v1"'
            buildConfigField "boolean", "ENABLE_LOGGING", "false"
        }
    }
}
```

## Production-Ready API Service

### Enhanced API Service with Real-World Features

```dart
// lib/core/services/enhanced_api_service.dart
import 'package:dio/dio.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../config/environment.dart';

class EnhancedApiService {
  static late Dio _dio;
  static late SharedPreferences _prefs;
  static String? _authToken;
  static final Connectivity _connectivity = Connectivity();
  
  static Future<void> initialize() async {
    _prefs = await SharedPreferences.getInstance();
    _authToken = _prefs.getString('auth_token');
    
    _dio = Dio(BaseOptions(
      baseUrl: EnvironmentConfig.baseUrl,
      connectTimeout: EnvironmentConfig.timeout,
      receiveTimeout: EnvironmentConfig.timeout,
      headers: {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
        'User-Agent': 'OceanHazardReporter/1.0.0',
      },
    ));
    
    _setupInterceptors();
  }
  
  static void _setupInterceptors() {
    // Request interceptor
    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        // Add auth token
        if (_authToken != null) {
          options.headers['Authorization'] = 'Bearer $_authToken';
        }
        
        // Add request ID for tracking
        options.headers['X-Request-ID'] = _generateRequestId();
        
        // Log request in development
        if (EnvironmentConfig.enableLogging) {
          print('🚀 API Request: ${options.method} ${options.path}');
          print('📤 Headers: ${options.headers}');
          if (options.data != null) {
            print('📤 Data: ${options.data}');
          }
        }
        
        handler.next(options);
      },
      onResponse: (response, handler) {
        // Log response in development
        if (EnvironmentConfig.enableLogging) {
          print('✅ API Response: ${response.statusCode} ${response.requestOptions.path}');
          print('📥 Data: ${response.data}');
        }
        handler.next(response);
      },
      onError: (error, handler) async {
        // Log error
        if (EnvironmentConfig.enableLogging) {
          print('❌ API Error: ${error.response?.statusCode} ${error.requestOptions.path}');
          print('📥 Error Data: ${error.response?.data}');
        }
        
        // Handle specific error cases
        await _handleApiError(error);
        handler.next(error);
      },
    ));
    
    // Retry interceptor
    _dio.interceptors.add(RetryInterceptor(
      dio: _dio,
      logPrint: EnvironmentConfig.enableLogging ? print : null,
      retries: 3,
      retryDelays: const [
        Duration(seconds: 1),
        Duration(seconds: 2),
        Duration(seconds: 3),
      ],
    ));
  }
  
  static String _generateRequestId() {
    return DateTime.now().millisecondsSinceEpoch.toString();
  }
  
  static Future<void> _handleApiError(DioException error) async {
    switch (error.response?.statusCode) {
      case 401:
        // Unauthorized - clear token and redirect to login
        await clearAuthToken();
        // Navigate to login screen
        break;
      case 403:
        // Forbidden - show access denied message
        break;
      case 429:
        // Rate limited - show rate limit message
        break;
      case 500:
        // Server error - show generic error message
        break;
    }
  }
  
  // Authentication methods
  static Future<void> setAuthToken(String token) async {
    _authToken = token;
    await _prefs.setString('auth_token', token);
  }
  
  static Future<void> clearAuthToken() async {
    _authToken = null;
    await _prefs.remove('auth_token');
  }
  
  // Network connectivity check
  static Future<bool> isConnected() async {
    final connectivityResult = await _connectivity.checkConnectivity();
    return connectivityResult != ConnectivityResult.none;
  }
  
  // Generic API methods with enhanced error handling
  static Future<T> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      if (!await isConnected()) {
        throw Exception('No internet connection');
      }
      
      final response = await _dio.get<T>(
        path,
        queryParameters: queryParameters,
        options: options,
      );
      
      return response.data as T;
    } on DioException catch (e) {
      throw _handleDioException(e);
    }
  }
  
  static Future<T> post<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      if (!await isConnected()) {
        throw Exception('No internet connection');
      }
      
      final response = await _dio.post<T>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
      
      return response.data as T;
    } on DioException catch (e) {
      throw _handleDioException(e);
    }
  }
  
  static Exception _handleDioException(DioException e) {
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
        return Exception('Connection timeout. Please check your internet connection.');
      case DioExceptionType.sendTimeout:
        return Exception('Request timeout. Please try again.');
      case DioExceptionType.receiveTimeout:
        return Exception('Response timeout. Please try again.');
      case DioExceptionType.badResponse:
        final statusCode = e.response?.statusCode;
        final message = e.response?.data?['message'] ?? 'Server error';
        return Exception('HTTP $statusCode: $message');
      case DioExceptionType.cancel:
        return Exception('Request was cancelled');
      case DioExceptionType.connectionError:
        return Exception('Connection error. Please check your internet connection.');
      default:
        return Exception('An unexpected error occurred');
    }
  }
}
```

## Authentication & Token Management

### Secure Token Storage and Refresh

```dart
// lib/core/services/auth_service.dart
import 'package:shared_preferences/shared_preferences.dart';
import 'package:crypto/crypto.dart';
import 'dart:convert';

class AuthService {
  static const String _tokenKey = 'auth_token';
  static const String _refreshTokenKey = 'refresh_token';
  static const String _tokenExpiryKey = 'token_expiry';
  
  static Future<void> saveTokens({
    required String accessToken,
    required String refreshToken,
    required DateTime expiry,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    
    // Encrypt tokens before storing (basic encryption)
    final encryptedAccessToken = _encryptToken(accessToken);
    final encryptedRefreshToken = _encryptToken(refreshToken);
    
    await prefs.setString(_tokenKey, encryptedAccessToken);
    await prefs.setString(_refreshTokenKey, encryptedRefreshToken);
    await prefs.setString(_tokenExpiryKey, expiry.toIso8601String());
  }
  
  static Future<String?> getAccessToken() async {
    final prefs = await SharedPreferences.getInstance();
    final encryptedToken = prefs.getString(_tokenKey);
    
    if (encryptedToken == null) return null;
    
    // Check if token is expired
    final expiryString = prefs.getString(_tokenExpiryKey);
    if (expiryString != null) {
      final expiry = DateTime.parse(expiryString);
      if (DateTime.now().isAfter(expiry)) {
        // Token expired, try to refresh
        final refreshed = await refreshToken();
        if (refreshed) {
          return await getAccessToken();
        } else {
          await clearTokens();
          return null;
        }
      }
    }
    
    return _decryptToken(encryptedToken);
  }
  
  static Future<bool> refreshToken() async {
    final prefs = await SharedPreferences.getInstance();
    final encryptedRefreshToken = prefs.getString(_refreshTokenKey);
    
    if (encryptedRefreshToken == null) return false;
    
    try {
      final refreshToken = _decryptToken(encryptedRefreshToken);
      
      // Call your refresh token endpoint
      final response = await EnhancedApiService.post('/auth/refresh', data: {
        'refresh_token': refreshToken,
      });
      
      // Save new tokens
      await saveTokens(
        accessToken: response['access_token'],
        refreshToken: response['refresh_token'],
        expiry: DateTime.now().add(Duration(seconds: response['expires_in'])),
      );
      
      return true;
    } catch (e) {
      return false;
    }
  }
  
  static Future<void> clearTokens() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
    await prefs.remove(_refreshTokenKey);
    await prefs.remove(_tokenExpiryKey);
  }
  
  static String _encryptToken(String token) {
    // Basic encryption - in production, use proper encryption
    final bytes = utf8.encode(token);
    final digest = sha256.convert(bytes);
    return base64.encode(digest.bytes);
  }
  
  static String _decryptToken(String encryptedToken) {
    // Basic decryption - in production, use proper decryption
    // This is a simplified example
    return encryptedToken;
  }
}
```

## Error Handling & Retry Logic

### Custom Retry Interceptor

```dart
// lib/core/interceptors/retry_interceptor.dart
import 'package:dio/dio.dart';

class RetryInterceptor extends Interceptor {
  final Dio dio;
  final int retries;
  final List<Duration> retryDelays;
  final Function(String)? logPrint;
  
  RetryInterceptor({
    required this.dio,
    this.retries = 3,
    this.retryDelays = const [
      Duration(seconds: 1),
      Duration(seconds: 2),
      Duration(seconds: 3),
    ],
    this.logPrint,
  });
  
  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    if (_shouldRetry(err)) {
      final retryCount = err.requestOptions.extra['retryCount'] ?? 0;
      
      if (retryCount < retries) {
        logPrint?.call('Retrying request (${retryCount + 1}/$retries)');
        
        // Wait before retrying
        await Future.delayed(retryDelays[retryCount]);
        
        // Update retry count
        err.requestOptions.extra['retryCount'] = retryCount + 1;
        
        try {
          final response = await dio.fetch(err.requestOptions);
          handler.resolve(response);
        } catch (e) {
          handler.next(err);
        }
      } else {
        handler.next(err);
      }
    } else {
      handler.next(err);
    }
  }
  
  bool _shouldRetry(DioException err) {
    // Retry on network errors and 5xx server errors
    return err.type == DioExceptionType.connectionTimeout ||
           err.type == DioExceptionType.sendTimeout ||
           err.type == DioExceptionType.receiveTimeout ||
           err.type == DioExceptionType.connectionError ||
           (err.response?.statusCode != null && 
            err.response!.statusCode! >= 500);
  }
}
```

## Offline Support & Caching

### Offline-First API Service

```dart
// lib/core/services/offline_api_service.dart
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'dart:convert';

class OfflineApiService {
  static Database? _database;
  
  static Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }
  
  static Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'api_cache.db');
    
    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) {
        return db.execute('''
          CREATE TABLE api_cache(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            endpoint TEXT NOT NULL,
            params TEXT,
            data TEXT NOT NULL,
            timestamp INTEGER NOT NULL,
            expires_at INTEGER NOT NULL
          )
        ''');
      },
    );
  }
  
  static Future<void> cacheResponse({
    required String endpoint,
    Map<String, dynamic>? params,
    required Map<String, dynamic> data,
    Duration cacheDuration = const Duration(minutes: 5),
  }) async {
    final db = await database;
    
    await db.insert('api_cache', {
      'endpoint': endpoint,
      'params': params != null ? jsonEncode(params) : null,
      'data': jsonEncode(data),
      'timestamp': DateTime.now().millisecondsSinceEpoch,
      'expires_at': DateTime.now().add(cacheDuration).millisecondsSinceEpoch,
    });
  }
  
  static Future<Map<String, dynamic>?> getCachedResponse({
    required String endpoint,
    Map<String, dynamic>? params,
  }) async {
    final db = await database;
    
    final result = await db.query(
      'api_cache',
      where: 'endpoint = ? AND params = ? AND expires_at > ?',
      whereArgs: [
        endpoint,
        params != null ? jsonEncode(params) : null,
        DateTime.now().millisecondsSinceEpoch,
      ],
      orderBy: 'timestamp DESC',
      limit: 1,
    );
    
    if (result.isNotEmpty) {
      return jsonDecode(result.first['data'] as String);
    }
    
    return null;
  }
  
  static Future<void> clearExpiredCache() async {
    final db = await database;
    await db.delete(
      'api_cache',
      where: 'expires_at < ?',
      whereArgs: [DateTime.now().millisecondsSinceEpoch],
    );
  }
}
```

## Monitoring & Logging

### Production Logging Service

```dart
// lib/core/services/logging_service.dart
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:developer' as developer;

class LoggingService {
  static bool _isInitialized = false;
  
  static Future<void> initialize() async {
    if (_isInitialized) return;
    
    // Initialize Firebase Crashlytics
    await FirebaseCrashlytics.instance.setCrashlyticsCollectionEnabled(true);
    
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
  
  static void logError(String message, {Object? error, StackTrace? stackTrace}) {
    developer.log(message, name: 'ERROR', error: error, stackTrace: stackTrace);
    
    // Send to Crashlytics
    FirebaseCrashlytics.instance.recordError(error, stackTrace);
    
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
  
  static void _trackApiPerformance(String endpoint, Duration duration, int statusCode) {
    // Store performance metrics
    _storeMetric('api_performance', {
      'endpoint': endpoint,
      'duration': duration.inMilliseconds,
      'statusCode': statusCode,
      'timestamp': DateTime.now().toIso8601String(),
    });
  }
  
  static Future<void> _storeMetric(String key, Map<String, dynamic> data) async {
    final prefs = await SharedPreferences.getInstance();
    final metrics = prefs.getStringList('metrics_$key') ?? [];
    metrics.add(jsonEncode(data));
    
    // Keep only last 100 metrics
    if (metrics.length > 100) {
      metrics.removeRange(0, metrics.length - 100);
    }
    
    await prefs.setStringList('metrics_$key', metrics);
  }
}
```

## Security Best Practices

### API Security Implementation

```dart
// lib/core/security/api_security.dart
import 'package:crypto/crypto.dart';
import 'dart:convert';
import 'dart:math';

class ApiSecurity {
  static String generateNonce() {
    final random = Random.secure();
    final bytes = List<int>.generate(16, (i) => random.nextInt(256));
    return base64.encode(bytes);
  }
  
  static String generateSignature({
    required String method,
    required String endpoint,
    required String timestamp,
    required String nonce,
    required String secretKey,
    Map<String, dynamic>? body,
  }) {
    final bodyString = body != null ? jsonEncode(body) : '';
    final message = '$method$endpoint$timestamp$nonce$bodyString';
    
    final key = utf8.encode(secretKey);
    final bytes = utf8.encode(message);
    final hmac = Hmac(sha256, key);
    final digest = hmac.convert(bytes);
    
    return base64.encode(digest.bytes);
  }
  
  static Map<String, String> getSecurityHeaders({
    required String method,
    required String endpoint,
    required String secretKey,
    Map<String, dynamic>? body,
  }) {
    final timestamp = DateTime.now().millisecondsSinceEpoch.toString();
    final nonce = generateNonce();
    final signature = generateSignature(
      method: method,
      endpoint: endpoint,
      timestamp: timestamp,
      nonce: nonce,
      secretKey: secretKey,
      body: body,
    );
    
    return {
      'X-Timestamp': timestamp,
      'X-Nonce': nonce,
      'X-Signature': signature,
    };
  }
}
```

## Testing APIs

### API Testing Utilities

```dart
// test/api_test_utils.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:dio/dio.dart';

class MockDio extends Mock implements Dio {}

class ApiTestUtils {
  static void mockSuccessfulResponse(MockDio mockDio, String endpoint, Map<String, dynamic> responseData) {
    when(mockDio.get(endpoint)).thenAnswer((_) async => Response(
      data: responseData,
      statusCode: 200,
      requestOptions: RequestOptions(path: endpoint),
    ));
  }
  
  static void mockErrorResponse(MockDio mockDio, String endpoint, int statusCode, String message) {
    when(mockDio.get(endpoint)).thenThrow(DioException(
      response: Response(
        data: {'message': message},
        statusCode: statusCode,
        requestOptions: RequestOptions(path: endpoint),
      ),
      requestOptions: RequestOptions(path: endpoint),
    ));
  }
  
  static void mockNetworkError(MockDio mockDio, String endpoint) {
    when(mockDio.get(endpoint)).thenThrow(DioException(
      type: DioExceptionType.connectionError,
      requestOptions: RequestOptions(path: endpoint),
    ));
  }
}
```

## Deployment Checklist

### Pre-Deployment Checklist

- [ ] **Environment Configuration**
  - [ ] Set correct API base URLs for each environment
  - [ ] Configure timeouts appropriately
  - [ ] Disable debug logging in production
  - [ ] Set up proper error reporting

- [ ] **Security**
  - [ ] Implement proper token encryption
  - [ ] Add request signing for sensitive endpoints
  - [ ] Validate SSL certificates
  - [ ] Implement certificate pinning

- [ ] **Performance**
  - [ ] Implement proper caching strategies
  - [ ] Add request/response compression
  - [ ] Optimize image uploads
  - [ ] Implement pagination for large datasets

- [ ] **Error Handling**
  - [ ] Add comprehensive error handling
  - [ ] Implement retry logic for transient failures
  - [ ] Add offline support
  - [ ] Set up crash reporting

- [ ] **Monitoring**
  - [ ] Add API performance monitoring
  - [ ] Implement user analytics
  - [ ] Set up error tracking
  - [ ] Add health checks

- [ ] **Testing**
  - [ ] Unit tests for API service
  - [ ] Integration tests for API endpoints
  - [ ] Load testing for critical endpoints
  - [ ] Security testing

### Production Configuration Example

```dart
// lib/core/config/production_config.dart
class ProductionConfig {
  static const String apiBaseUrl = 'https://api.oceanhazardreporter.com/v1';
  static const Duration timeout = Duration(seconds: 15);
  static const bool enableLogging = false;
  static const bool enableCrashlytics = true;
  static const bool enableAnalytics = true;
  static const int maxRetries = 3;
  static const Duration cacheExpiry = Duration(minutes: 5);
}
```

This comprehensive guide provides you with production-ready API connection strategies for your Flutter app. Each section includes practical code examples that you can implement directly in your project.
