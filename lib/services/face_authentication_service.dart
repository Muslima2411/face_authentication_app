// services/face_authentication_service.dart - Main Service
import 'dart:typed_data';
import '../models/authentication_result.dart';
import '../models/feature_vector.dart';
import 'camera_service.dart';
import 'face_detection_service.dart';
import 'feature_extraction_service.dart';
import 'database_service.dart';

class FaceAuthenticationService {
  static FaceAuthenticationService? _instance;
  static FaceAuthenticationService get instance => _instance ??= FaceAuthenticationService._();
  FaceAuthenticationService._();

  final double _authenticationThreshold = 0.6;
  final int _maxFailedAttempts = 3;
  int _failedAttempts = 0;

  Future<bool> initialize() async {
    final cameraInitialized = await CameraService.instance.initialize();
    return cameraInitialized;
  }

  Future<AuthenticationResult> authenticate(String userId) async {
    final stopwatch = Stopwatch()..start();
    
    try {
      // Check if user is locked out
      if (_failedAttempts >= _maxFailedAttempts) {
        return AuthenticationResult(
          status: AuthStatus.error,
          confidence: 0.0,
          timestamp: DateTime.now(),
          processingTime: stopwatch.elapsedMilliseconds,
          message: 'Account locked due to multiple failed attempts',
        );
      }

      // Capture face image
      final imageBytes = await CameraService.instance.captureFace();
      if (imageBytes == null) {
        return AuthenticationResult(
          status: AuthStatus.error,
          confidence: 0.0,
          timestamp: DateTime.now(),
          processingTime: stopwatch.elapsedMilliseconds,
          message: 'Failed to capture face image',
        );
      }

      // Detect face
      final faceResult = await FaceDetectionService.instance.detectFace(imageBytes);
      if (faceResult == null) {
        return AuthenticationResult(
          status: AuthStatus.failure,
          confidence: 0.0,
          timestamp: DateTime.now(),
          processingTime: stopwatch.elapsedMilliseconds,
          message: 'No face detected',
        );
      }

      // Extract features
      final capturedFeatures = await FeatureExtractionService.instance
          .extractFeatures(imageBytes, userId);
      if (capturedFeatures == null) {
        return AuthenticationResult(
          status: AuthStatus.error,
          confidence: 0.0,
          timestamp: DateTime.now(),
          processingTime: stopwatch.elapsedMilliseconds,
          message: 'Feature extraction failed',
        );
      }

      // Get stored templates
      final storedTemplates = await DatabaseService.instance.getTemplates(userId);
      if (storedTemplates.isEmpty) {
        return AuthenticationResult(
          status: AuthStatus.error,
          confidence: 0.0,
          timestamp: DateTime.now(),
          processingTime: stopwatch.elapsedMilliseconds,
          message: 'No enrolled templates found',
        );
      }

      // Match against stored templates
      double bestSimilarity = 0.0;
      for (final template in storedTemplates) {
        final similarity = FeatureExtractionService.instance
            .calculateCosineSimilarity(capturedFeatures.features, template.features);
        if (similarity > bestSimilarity) {
          bestSimilarity = similarity;
        }
      }

      stopwatch.stop();

      if (bestSimilarity >= _authenticationThreshold) {
        _failedAttempts = 0; // Reset on success
        return AuthenticationResult(
          status: AuthStatus.success,
          confidence: bestSimilarity,
          userId: userId,
          timestamp: DateTime.now(),
          processingTime: stopwatch.elapsedMilliseconds,
          message: 'Authentication successful',
        );
      } else {
        _failedAttempts++;
        return AuthenticationResult(
          status: AuthStatus.failure,
          confidence: bestSimilarity,
          timestamp: DateTime.now(),
          processingTime: stopwatch.elapsedMilliseconds,
          message: 'Authentication failed - insufficient match confidence',
        );
      }
    } catch (e) {
      stopwatch.stop();
      return AuthenticationResult(
        status: AuthStatus.error,
        confidence: 0.0,
        timestamp: DateTime.now(),
        processingTime: stopwatch.elapsedMilliseconds,
        message: 'Authentication error: $e',
      );
    }
  }

  Future<bool> enrollUser(String userId) async {
    try {
      final List<FeatureVector> templates = [];

      // Capture multiple samples for robustness
      for (int i = 0; i < 3; i++) {
        await Future.delayed(Duration(seconds: 1)); // Give user time to adjust

        final imageBytes = await CameraService.instance.captureFace();
        if (imageBytes == null) continue;

        final faceResult = await FaceDetectionService.instance.detectFace(imageBytes);
        if (faceResult == null) continue;

        final features = await FeatureExtractionService.instance
            .extractFeatures(imageBytes, userId);
        if (features != null) {
          templates.add(features);
        }
      }

      if (templates.isEmpty) {
        return false;
      }

      // Store templates
      for (final template in templates) {
        await DatabaseService.instance.storeTemplate(template);
      }

      return true;
    } catch (e) {
      print('Enrollment error: $e');
      return false;
    }
  }

  void resetFailedAttempts() {
    _failedAttempts = 0;
  }

  void dispose() {
    CameraService.instance.dispose();
    FaceDetectionService.instance.dispose();
  }
}
