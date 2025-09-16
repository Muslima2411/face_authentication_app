// services/face_detection_service.dart
import 'dart:typed_data';
import 'dart:ui';
import 'dart:io';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import 'package:path_provider/path_provider.dart';
import '../models/face_detection_result.dart';

class FaceDetectionService {
  static final FaceDetectionService _instance =
      FaceDetectionService._internal();
  factory FaceDetectionService() => _instance;
  static FaceDetectionService get instance => _instance;
  FaceDetectionService._internal();

  late FaceDetector _faceDetector;
  bool _isInitialized = false;

  Future<void> initialize() async {
    if (!_isInitialized) {
      _faceDetector = FaceDetector(
        options: FaceDetectorOptions(
          enableContours: true,
          enableLandmarks: true,
          enableClassification: true,
          enableTracking: true,
          minFaceSize: 0.1,
          performanceMode: FaceDetectorMode.accurate,
        ),
      );
      _isInitialized = true;
    }
  }

  Future<FaceDetectionResult?> detectFace(Uint8List imageBytes) async {
    try {
      await initialize();

      // Write JPEG bytes to temporary file for ML Kit processing
      final tempDir = await getTemporaryDirectory();
      final tempFile = File(
        '${tempDir.path}/temp_face_${DateTime.now().millisecondsSinceEpoch}.jpg',
      );
      await tempFile.writeAsBytes(imageBytes);

      // Create InputImage from file path (works better with JPEG)
      final inputImage = InputImage.fromFilePath(tempFile.path);

      final List<Face> faces = await _faceDetector.processImage(inputImage);

      // Clean up temporary file
      try {
        await tempFile.delete();
      } catch (e) {
        print('Failed to delete temp file: $e');
      }

      if (faces.isNotEmpty) {
        final face = faces.first;
        return FaceDetectionResult(
          boundingBox: face.boundingBox,
          confidence: _calculateConfidence(face),
        );
      }

      return null;
    } catch (e) {
      print('Face detection error: $e');
      return null;
    }
  }

  double _calculateConfidence(Face face) {
    // Calculate confidence based on face quality indicators
    double confidence = 0.5; // Base confidence

    // Check if face has good landmarks
    if (face.landmarks.isNotEmpty) {
      confidence += 0.2;
    }

    // Check head pose (prefer frontal faces)
    if (face.headEulerAngleY != null && face.headEulerAngleY!.abs() < 15) {
      confidence += 0.2;
    }

    // Check if eyes are open (if classification is available)
    if (face.leftEyeOpenProbability != null &&
        face.leftEyeOpenProbability! > 0.5) {
      confidence += 0.05;
    }
    if (face.rightEyeOpenProbability != null &&
        face.rightEyeOpenProbability! > 0.5) {
      confidence += 0.05;
    }

    return confidence.clamp(0.0, 1.0);
  }

  bool checkLiveness(Face face) {
    // Basic liveness check based on eye state and head pose
    final leftEyeOpen = face.leftEyeOpenProbability ?? 0.0;
    final rightEyeOpen = face.rightEyeOpenProbability ?? 0.0;
    final headAngleY = face.headEulerAngleY ?? 0.0;
    final headAngleZ = face.headEulerAngleZ ?? 0.0;

    // Eyes should be open and head should be reasonably straight
    return leftEyeOpen > 0.3 &&
        rightEyeOpen > 0.3 &&
        headAngleY.abs() < 30 &&
        headAngleZ.abs() < 30;
  }

  void dispose() {
    if (_isInitialized) {
      _faceDetector.close();
      _isInitialized = false;
    }
  }
}
