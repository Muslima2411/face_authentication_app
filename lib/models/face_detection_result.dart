// models/face_detection_result.dart
class FaceDetectionResult {
  final List<int> boundingBox;
  final double confidence;
  final String? imageData;

  FaceDetectionResult({
    required this.boundingBox,
    required this.confidence,
    this.imageData,
  });
}

