import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../config/app_config.dart';
import '../errors/exceptions.dart';

class ApiClient {
  late final Dio dio;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  ApiClient({Dio? customDio}) {
    dio = customDio ??
        Dio(
          BaseOptions(
            baseUrl: AppConfig.apiBaseUrl,
            connectTimeout: AppConfig.connectTimeout,
            receiveTimeout: AppConfig.receiveTimeout,
            headers: {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
            },
          ),
        );

    // Authentication & Error Interceptor
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final user = _auth.currentUser;
          if (user != null) {
            try {
              final token = await user.getIdToken();
              if (token != null) {
                options.headers['Authorization'] = 'Bearer $token';
              }
            } catch (_) {}
          }
          return handler.next(options);
        },
        onError: (DioException error, handler) {
          if (error.response?.statusCode == 401) {
            return handler.reject(
              DioException(
                requestOptions: error.requestOptions,
                error: UnauthorizedException(),
                response: error.response,
                type: error.type,
              ),
            );
          } else if (error.response?.statusCode == 404) {
            return handler.reject(
              DioException(
                requestOptions: error.requestOptions,
                error: NotFoundException(),
                response: error.response,
                type: error.type,
              ),
            );
          }
          return handler.next(error);
        },
      ),
    );
  }
}
