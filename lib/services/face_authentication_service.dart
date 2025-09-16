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
  static FaceAuthenticationService get instance =>
      _instance ??= FaceAuthenticationService._();
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
      final faceResult = await FaceDetectionService.instance.detectFace(
        imageBytes,
      );
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
      final storedTemplates = await DatabaseService.instance.getTemplates(
        userId,
      );
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
            .calculateCosineSimilarity(
              capturedFeatures.features,
              template.features,
            );
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
      print('=== ENROLLMENT START for userId: $userId ===');
      final List<FeatureVector> templates = [];

      // Capture multiple samples for robustness
      for (int i = 0; i < 3; i++) {
        print('Capturing sample ${i + 1}/3...');
        await Future.delayed(Duration(seconds: 1)); // Give user time to adjust

        final imageBytes = await CameraService.instance.captureFace();
        if (imageBytes == null) {
          print('Sample ${i + 1}: Failed to capture image');
          continue;
        }
        print('Sample ${i + 1}: Image captured (${imageBytes.length} bytes)');

        final faceResult = await FaceDetectionService.instance.detectFace(
          imageBytes,
        );
        if (faceResult == null) {
          print('Sample ${i + 1}: No face detected');
          continue;
        }
        print(
          'Sample ${i + 1}: Face detected with confidence ${faceResult.confidence}',
        );

        final features = await FeatureExtractionService.instance
            .extractFeatures(imageBytes, userId);
        if (features != null) {
          templates.add(features);
          print(
            'Sample ${i + 1}: Features extracted (${features.features.length} features)',
          );
        } else {
          print('Sample ${i + 1}: Feature extraction failed');
        }
      }

      print('Total templates captured: ${templates.length}');
      if (templates.isEmpty) {
        print('=== ENROLLMENT FAILED: No templates captured ===');
        return false;
      }

      // Store templates
      int storedCount = 0;
      for (final template in templates) {
        final stored = await DatabaseService.instance.storeTemplate(template);
        if (stored) {
          storedCount++;
          print('Template stored successfully for userId: ${template.userId}');
        } else {
          print('Failed to store template for userId: ${template.userId}');
        }
      }

      print(
        '=== ENROLLMENT COMPLETE: $storedCount/${templates.length} templates stored ===',
      );

      // Verify storage by immediately querying
      final storedTemplates = await DatabaseService.instance.getTemplates(
        userId,
      );
      print(
        'Verification: Found ${storedTemplates.length} stored templates for userId: $userId',
      );

      return storedCount > 0;
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
