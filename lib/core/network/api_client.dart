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

    // Interceptor: Token injection + Refresh Token + Network Error mapping
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          // Injection du token d'authentification Bearer
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
        onError: (DioException error, handler) async {
          // Gestion du Refresh Token en cas d'expiration (HTTP 401)
          if (error.response?.statusCode == 401 &&
              error.requestOptions.extra['token_refreshed'] != true) {
            final user = _auth.currentUser;
            if (user != null) {
              try {
                // Force le rafraîchissement du JWT token Firebase
                final refreshedToken = await user.getIdToken(true);
                if (refreshedToken != null) {
                  final retryOptions = error.requestOptions;
                  retryOptions.headers['Authorization'] = 'Bearer $refreshedToken';
                  retryOptions.extra['token_refreshed'] = true;

                  // Rejouer la requête avec le nouveau token
                  final response = await dio.fetch(retryOptions);
                  return handler.resolve(response);
                }
              } catch (_) {}
            }

            return handler.reject(
              DioException(
                requestOptions: error.requestOptions,
                error: UnauthorizedException(
                    'Session expirée. Veuillez vous reconnecter.'),
                response: error.response,
                type: error.type,
              ),
            );
          } else if (error.response?.statusCode == 404) {
            return handler.reject(
              DioException(
                requestOptions: error.requestOptions,
                error: NotFoundException('Ressource introuvable.'),
                response: error.response,
                type: error.type,
              ),
            );
          } else if (error.type == DioExceptionType.connectionTimeout ||
              error.type == DioExceptionType.receiveTimeout ||
              error.type == DioExceptionType.connectionError) {
            return handler.reject(
              DioException(
                requestOptions: error.requestOptions,
                error: NetworkException(
                    'Connexion au serveur impossible. Vérifiez votre réseau.'),
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
