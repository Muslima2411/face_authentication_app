// lib/config/app_config.dart
class AppConfig {
  // Authentication Thresholds
  static const double authenticationThreshold = 0.6;
  static const double livenessThreshold = 0.7;
  static const double faceDetectionThreshold = 0.7;
  
  // Security Settings
  static const int maxFailedAttempts = 3;
  static const int lockoutDurationMinutes = 5;
  static const int templateExpiryDays = 90;
  
  // Performance Settings
  static const int maxProcessingTimeMs = 5000;
  static const int featureVectorSize = 128;
  static const int maxTemplatesPerUser = 5;
  
  // Camera Settings
  static const double minFaceSize = 0.1;
  static const int targetImageWidth = 720;
  static const int targetImageHeight = 1280;
  static const int cameraFps = 30;
  
  // Database Settings
  static const String databaseName = 'face_auth.db';
  static const int databaseVersion = 1;
  static const String templatesTableName = 'biometric_templates';
  
  // Error Messages
  static const String noFaceDetectedMessage = 'No face detected. Please position your face in the frame.';
  static const String multipleFacesMessage = 'Multiple faces detected. Please ensure only one person is in frame.';
  static const String poorLightingMessage = 'Poor lighting conditions. Please move to better lighting.';
  static const String faceNotClearMessage = 'Face not clear enough. Please hold steady and look directly at camera.';
  static const String authenticationFailedMessage = 'Authentication failed. Face not recognized.';
  static const String enrollmentFailedMessage = 'Enrollment failed. Please try again.';
  static const String accountLockedMessage = 'Account locked due to multiple failed attempts.';
  
  // Success Messages
  static const String enrollmentSuccessMessage = 'Face enrollment completed successfully!';
  static const String authenticationSuccessMessage = 'Authentication successful. Access granted.';
  
  // App Information
  static const String appName = 'Face Authentication';
  static const String appVersion = '1.0.0';
  static const String companyName = 'SecureTech Solutions';
}