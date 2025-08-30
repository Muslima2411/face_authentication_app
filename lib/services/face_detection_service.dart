// services/face_detection_service.dart
import 'package:google_ml_kit/google_ml_kit.dart';
import 'dart:typed_data';
import 'dart:ui';
import '../models/face_detection_result.dart';

class FaceDetectionService {
  static FaceDetectionService? _instance;
  static FaceDetectionService get instance => _instance ??= FaceDetectionService._();
  FaceDetectionService._();

  final FaceDetector _faceDetector = GoogleMlKit.vision.faceDetector(
    FaceDetectorOptions(
      enableContours: true,
      enableLandmarks: true,
      enableClassification: true,
      enableTracking: true,
      minFaceSize: 0.1,
      performanceMode: FaceDetectorMode.accurate,
    ),
  );

  Future<FaceDetectionResult?> detectFace(Uint8List imageBytes) async {
    try {
      final inputImage = InputImage.fromBytes(
        bytes: imageBytes,
        metadata: InputImageMetadata(
          size: Size(720, 1280), // Adjust based on actual image size
          rotation: InputImageRotation.rotation0deg,
          format: InputImageFormat.nv21,
          bytesPerRow: 720, // Width for nv21 format
        ),
      );

      final List<Face> faces = await _faceDetector.processImage(inputImage);
      
      if (faces.isEmpty) {
        return null;
      }

      // Use the first detected face
      final Face face = faces.first;
      final boundingBox = face.boundingBox;

      return FaceDetectionResult(
        boundingBox: [
          boundingBox.left.toInt(),
          boundingBox.top.toInt(),
          boundingBox.width.toInt(),
          boundingBox.height.toInt(),
        ],
        confidence: 0.95, // ML Kit doesn't provide confidence, using default
      );
    } catch (e) {
      print('Face detection error: $e');
      return null;
    }
  }

  Future<bool> checkLiveness(List<Face> faces) async {
    // Basic liveness check - could be enhanced with more sophisticated methods
    for (Face face in faces) {
      // Check if eyes are open
      if (face.leftEyeOpenProbability != null && face.rightEyeOpenProbability != null) {
        if (face.leftEyeOpenProbability! > 0.5 && face.rightEyeOpenProbability! > 0.5) {
          return true;
        }
      }
    }
    return false;
  }

  void dispose() {
    _faceDetector.close();
  }
}
