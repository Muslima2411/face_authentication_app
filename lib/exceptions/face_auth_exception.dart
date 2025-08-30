// lib/exceptions/face_auth_exceptions.dart
class FaceAuthException implements Exception {
  final String message;
  final String code;
  final dynamic originalException;

  FaceAuthException(this.message, this.code, [this.originalException]);

  @override
  String toString() => 'FaceAuthException: $message (Code: $code)';
}

class CameraException extends FaceAuthException {
  CameraException(String message, [dynamic originalException])
      : super(message, 'CAMERA_ERROR', originalException);
}

class FaceDetectionException extends FaceAuthException {
  FaceDetectionException(String message, [dynamic originalException])
      : super(message, 'FACE_DETECTION_ERROR', originalException);
}

class FeatureExtractionException extends FaceAuthException {
  FeatureExtractionException(String message, [dynamic originalException])
      : super(message, 'FEATURE_EXTRACTION_ERROR', originalException);
}

class DatabaseException extends FaceAuthException {
  DatabaseException(String message, [dynamic originalException])
      : super(message, 'DATABASE_ERROR', originalException);
}

class AuthenticationException extends FaceAuthException {
  AuthenticationException(String message, [dynamic originalException])
      : super(message, 'AUTHENTICATION_ERROR', originalException);
}

class EnrollmentException extends FaceAuthException {
  EnrollmentException(String message, [dynamic originalException])
      : super(message, 'ENROLLMENT_ERROR', originalException);
}
