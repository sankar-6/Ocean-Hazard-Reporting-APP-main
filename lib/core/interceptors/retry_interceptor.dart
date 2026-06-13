import 'package:dio/dio.dart';
import '../config/environment.dart';

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

class LoggingInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    if (EnvironmentConfig.enableLogging) {
      print('🚀 API Request: ${options.method} ${options.path}');
      print('📤 Headers: ${options.headers}');
      if (options.data != null) {
        print('📤 Data: ${options.data}');
      }
    }
    handler.next(options);
  }
  
  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    if (EnvironmentConfig.enableLogging) {
      print('✅ API Response: ${response.statusCode} ${response.requestOptions.path}');
      print('📥 Data: ${response.data}');
    }
    handler.next(response);
  }
  
  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    if (EnvironmentConfig.enableLogging) {
      print('❌ API Error: ${err.response?.statusCode} ${err.requestOptions.path}');
      print('📥 Error Data: ${err.response?.data}');
    }
    handler.next(err);
  }
}
