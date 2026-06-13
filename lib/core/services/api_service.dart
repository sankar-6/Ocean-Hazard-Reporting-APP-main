import 'package:dio/dio.dart';

import '../../models/report_model.dart';
import '../../models/social_media_post.dart';
import 'storage_service.dart';

class ApiService {
  static const String baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'https://api.oceanhazardreporter.com/v1',
  );
  static const Duration timeout = Duration(seconds: 30);

  static final Dio _dio =
      Dio(
          BaseOptions(
            baseUrl: baseUrl,
            connectTimeout: timeout,
            receiveTimeout: timeout,
            headers: {
              'Accept': 'application/json',
              'Content-Type': 'application/json',
            },
          ),
        )
        ..interceptors.add(
          InterceptorsWrapper(
            onError: (e, handler) {
              if (e.response?.statusCode == 401) {
                clearAuthToken();
              }
              handler.next(e);
            },
          ),
        );

  // Reports API
  static Future<List<ReportModel>> getReports({
    double? latitude,
    double? longitude,
    double? radius,
    HazardType? hazardType,
    ReportStatus? status,
    int page = 1,
    int limit = 20,
  }) async {
    try {
      final queryParams = <String, dynamic>{'page': page, 'limit': limit};

      if (latitude != null && longitude != null) {
        queryParams['latitude'] = latitude;
        queryParams['longitude'] = longitude;
        if (radius != null) queryParams['radius'] = radius;
      }

      if (hazardType != null) {
        queryParams['hazard_type'] = hazardType.toString().split('.').last;
      }

      if (status != null) {
        queryParams['status'] = status.toString().split('.').last;
      }

      final response = await _dio.get('/reports', queryParameters: queryParams);

      final List<dynamic> data = response.data['data'];
      return data.map((json) => ReportModel.fromJson(json)).toList();
    } catch (e) {
      _rethrow('Fetch reports', e);
    }
  }

  static Future<ReportModel> getReport(String id) async {
    try {
      final response = await _dio.get('/reports/$id');
      return ReportModel.fromJson(response.data['data']);
    } catch (e) {
      _rethrow('Fetch report', e);
    }
  }

  static Future<ReportModel> createReport(ReportModel report) async {
    try {
      final response = await _dio.post('/reports', data: report.toJson());
      return ReportModel.fromJson(response.data['data']);
    } catch (e) {
      _rethrow('Create report', e);
    }
  }

  static Future<ReportModel> updateReport(String id, ReportModel report) async {
    try {
      final response = await _dio.put('/reports/$id', data: report.toJson());
      return ReportModel.fromJson(response.data['data']);
    } catch (e) {
      _rethrow('Update report', e);
    }
  }

  static Future<void> deleteReport(String id) async {
    try {
      await _dio.delete('/reports/$id');
    } catch (e) {
      _rethrow('Delete report', e);
    }
  }

  static Future<void> verifyReport(
    String id,
    String verifiedBy,
    String notes,
  ) async {
    try {
      await _dio.post(
        '/reports/$id/verify',
        data: {'verified_by': verifiedBy, 'verification_notes': notes},
      );
    } catch (e) {
      _rethrow('Verify report', e);
    }
  }

  // Social Media API
  static Future<List<SocialMediaPost>> getSocialMediaPosts({
    String? platform,
    SentimentType? sentiment,
    bool? hazardRelated,
    double? latitude,
    double? longitude,
    double? radius,
    int page = 1,
    int limit = 20,
  }) async {
    try {
      final queryParams = <String, dynamic>{'page': page, 'limit': limit};

      if (platform != null) queryParams['platform'] = platform;
      if (sentiment != null) {
        queryParams['sentiment'] = sentiment.toString().split('.').last;
      }
      if (hazardRelated != null) queryParams['hazard_related'] = hazardRelated;

      if (latitude != null && longitude != null) {
        queryParams['latitude'] = latitude;
        queryParams['longitude'] = longitude;
        if (radius != null) queryParams['radius'] = radius;
      }

      final response = await _dio.get(
        '/social-media/posts',
        queryParameters: queryParams,
      );

      final List<dynamic> data = response.data['data'];
      return data.map((json) => SocialMediaPost.fromJson(json)).toList();
    } catch (e) {
      _rethrow('Fetch social media posts', e);
    }
  }

  // Analytics API
  static Future<Map<String, dynamic>> getAnalytics({
    DateTime? startDate,
    DateTime? endDate,
    String? region,
  }) async {
    try {
      final queryParams = <String, dynamic>{};

      if (startDate != null) {
        queryParams['start_date'] = startDate.toIso8601String();
      }
      if (endDate != null) queryParams['end_date'] = endDate.toIso8601String();
      if (region != null) queryParams['region'] = region;

      final response = await _dio.get(
        '/analytics',
        queryParameters: queryParams,
      );
      return response.data['data'];
    } catch (e) {
      _rethrow('Fetch analytics', e);
    }
  }

  // Hotspots API
  static Future<List<Map<String, dynamic>>> getHotspots({
    double? latitude,
    double? longitude,
    double? radius,
    String? timeRange,
  }) async {
    try {
      final queryParams = <String, dynamic>{};

      if (latitude != null && longitude != null) {
        queryParams['latitude'] = latitude;
        queryParams['longitude'] = longitude;
        if (radius != null) queryParams['radius'] = radius;
      }
      if (timeRange != null) queryParams['time_range'] = timeRange;

      final response = await _dio.get(
        '/hotspots',
        queryParameters: queryParams,
      );
      return List<Map<String, dynamic>>.from(response.data['data']);
    } catch (e) {
      _rethrow('Fetch hotspots', e);
    }
  }

  // Media Upload API - Now using Firebase Storage
  static Future<String> uploadMedia(String filePath, String type) async {
    try {
      if (type == 'image') {
        return await StorageService.uploadImage(imagePath: filePath);
      } else if (type == 'video') {
        return await StorageService.uploadVideo(videoPath: filePath);
      } else {
        return await StorageService.uploadFile(
          filePath: filePath,
          folder: 'media',
        );
      }
    } catch (e) {
      _rethrow('Upload media', e);
    }
  }

  // Health Check
  static Future<bool> healthCheck() async {
    try {
      final response = await _dio.get('/health');
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  // Set authentication token
  static void setAuthToken(String token) {
    _dio.options.headers['Authorization'] = 'Bearer $token';
  }

  // Clear authentication token
  static void clearAuthToken() {
    _dio.options.headers.remove('Authorization');
  }

  // Centralized error mapper
  static Never _rethrow(String context, Object error) {
    if (error is DioException) {
      final status = error.response?.statusCode;
      final data = error.response?.data;
      String? serverMessage;
      if (data is Map<String, dynamic>) {
        final dynamic msg = data['message'];
        if (msg is String) serverMessage = msg;
      }
      final details =
          serverMessage ??
          error.message ??
          error.error?.toString() ??
          'Unknown error';
      throw Exception(
        '$context failed${status != null ? ' (HTTP $status)' : ''}: $details',
      );
    }
    throw Exception('$context failed: $error');
  }
}
