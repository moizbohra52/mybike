import 'package:equatable/equatable.dart';

/// MYBIKE Failure Model
///
/// Represents a failure state in the application.
/// Used as a return type when operations fail (Either-style or state-based).
class Failure extends Equatable {
  final String message;
  final String? code;

  const Failure({
    required this.message,
    this.code,
  });

  @override
  List<Object?> get props => [message, code];

  @override
  String toString() => 'Failure(message: $message, code: $code)';
}
