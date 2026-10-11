class AppException implements Exception {
  final String message;
  final String? code;
  final dynamic originalError;

  AppException(this.message, {this.code, this.originalError});

  @override
  String toString() => message;
}

class NetworkException extends AppException {
  NetworkException(super.message, {super.code, super.originalError});
}

class UnauthorizedException extends AppException {
  UnauthorizedException([super.message = 'Session expirée ou non autorisée'])
      : super(code: 'UNAUTHORIZED');
}

class NotFoundException extends AppException {
  NotFoundException([super.message = 'Ressource introuvable'])
      : super(code: 'NOT_FOUND');
}

class CacheException extends AppException {
  CacheException(super.message, {super.code, super.originalError});
}
