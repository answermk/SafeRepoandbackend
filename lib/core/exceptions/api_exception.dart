/// API Exception Classes
/// Custom exceptions for API error handling

class ApiException implements Exception {
  final String message;
  final int? statusCode;
  final dynamic originalError;

  ApiException(this.message, {this.statusCode, this.originalError});

  @override
  String toString() => message;
}

class NetworkException extends ApiException {
  NetworkException(String message, {dynamic originalError})
      : super(message, originalError: originalError);
}

class AuthenticationException extends ApiException {
  AuthenticationException(String message, {int? statusCode, dynamic originalError})
      : super(message, statusCode: statusCode ?? 401, originalError: originalError);
}

class AuthorizationException extends ApiException {
  AuthorizationException(String message, {int? statusCode, dynamic originalError})
      : super(message, statusCode: statusCode ?? 403, originalError: originalError);
}

class NotFoundException extends ApiException {
  NotFoundException(String message, {int? statusCode, dynamic originalError})
      : super(message, statusCode: statusCode ?? 404, originalError: originalError);
}

class ValidationException extends ApiException {
  ValidationException(String message, {int? statusCode, dynamic originalError})
      : super(message, statusCode: statusCode ?? 400, originalError: originalError);
}

class ServerException extends ApiException {
  ServerException(String message, {int? statusCode, dynamic originalError})
      : super(message, statusCode: statusCode ?? 500, originalError: originalError);
}

