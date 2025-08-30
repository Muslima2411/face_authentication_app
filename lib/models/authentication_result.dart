// models/authentication_result.dart
enum AuthStatus { success, failure, error }

class AuthenticationResult {
  final AuthStatus status;
  final double confidence;
  final String? userId;
  final DateTime timestamp;
  final int processingTime;
  final String message;

  AuthenticationResult({
    required this.status,
    required this.confidence,
    this.userId,
    required this.timestamp,
    required this.processingTime,
    required this.message,
  });

  Map<String, dynamic> toJson() {
    return {
      'status': status.toString().split('.').last,
      'confidence': confidence,
      'userId': userId,
      'timestamp': timestamp.toIso8601String(),
      'processingTime': processingTime,
      'message': message,
    };
  }
}
