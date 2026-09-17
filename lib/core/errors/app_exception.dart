import 'package:equatable/equatable.dart';

/// MYBIKE Custom Exception Hierarchy
///
/// All app exceptions extend [AppException].
/// Used by the error handler to show appropriate user-facing messages.
abstract class AppException extends Equatable implements Exception {
  final String message;
  final String? code;
  final dynamic originalError;

  const AppException({
    required this.message,
    this.code,
    this.originalError,
  });

  @override
  List<Object?> get props => [message, code];

  @override
  String toString() => '$runtimeType(message: $message, code: $code)';
}

/// Network-related errors (no connectivity, DNS, etc.)
class NetworkException extends AppException {
  const NetworkException({
    super.message = 'No internet connection. Please check your network.',
    super.code = 'NETWORK_ERROR',
    super.originalError,
  });
}

/// Request timeout
class TimeoutException extends AppException {
  const TimeoutException({
    super.message = 'The request timed out. Please try again.',
    super.code = 'TIMEOUT',
    super.originalError,
  });
}

/// Authentication errors (invalid credentials, expired session)
class AuthException extends AppException {
  const AuthException({
    super.message = 'Authentication failed. Please log in again.',
    super.code = 'AUTH_ERROR',
    super.originalError,
  });
}

/// Authorization / permission errors
class PermissionException extends AppException {
  const PermissionException({
    super.message = 'You do not have permission to perform this action.',
    super.code = 'PERMISSION_DENIED',
    super.originalError,
  });
}

/// Form / data validation errors
class ValidationException extends AppException {
  final Map<String, String>? fieldErrors;

  const ValidationException({
    super.message = 'Please check the form for errors.',
    super.code = 'VALIDATION_ERROR',
    super.originalError,
    this.fieldErrors,
  });

  @override
  List<Object?> get props => [message, code, fieldErrors];
}

/// Database / Supabase errors
class DatabaseException extends AppException {
  const DatabaseException({
    super.message = 'A database error occurred. Please try again.',
    super.code = 'DATABASE_ERROR',
    super.originalError,
  });
}

/// File storage errors
class StorageException extends AppException {
  const StorageException({
    super.message = 'File operation failed. Please try again.',
    super.code = 'STORAGE_ERROR',
    super.originalError,
  });
}

/// Server / Edge Function errors
class ServerException extends AppException {
  final int? statusCode;

  const ServerException({
    super.message = 'A server error occurred. Please try again later.',
    super.code = 'SERVER_ERROR',
    super.originalError,
    this.statusCode,
  });

  @override
  List<Object?> get props => [message, code, statusCode];
}

/// Catch-all for unexpected errors
class UnknownException extends AppException {
  const UnknownException({
    super.message = 'An unexpected error occurred. Please try again.',
    super.code = 'UNKNOWN_ERROR',
    super.originalError,
  });
}
