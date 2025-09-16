// models/face_detection_result.dart
import 'dart:ui';

class FaceDetectionResult {
  final Rect boundingBox;
  final double confidence;

  FaceDetectionResult({required this.boundingBox, required this.confidence});

  Map<String, dynamic> toJson() {
    return {
      'boundingBox': {
        'left': boundingBox.left,
        'top': boundingBox.top,
        'right': boundingBox.right,
        'bottom': boundingBox.bottom,
      },
      'confidence': confidence,
    };
  }

  factory FaceDetectionResult.fromJson(Map<String, dynamic> json) {
    final bbox = json['boundingBox'];
    return FaceDetectionResult(
      boundingBox: Rect.fromLTRB(
        bbox['left'].toDouble(),
        bbox['top'].toDouble(),
        bbox['right'].toDouble(),
        bbox['bottom'].toDouble(),
      ),
      confidence: json['confidence'].toDouble(),
    );
  }
}
