// services/feature_extraction_service.dart
import 'dart:typed_data';
import 'dart:math';
import '../models/feature_vector.dart';

class FeatureExtractionService {
  static FeatureExtractionService? _instance;
  static FeatureExtractionService get instance => _instance ??= FeatureExtractionService._();
  FeatureExtractionService._();

  // Simplified feature extraction - in production, use a pre-trained model
  Future<FeatureVector?> extractFeatures(Uint8List faceImage, String userId) async {
    try {
      // This is a placeholder implementation
      // In a real application, you would use a pre-trained face recognition model
      // like FaceNet, ArcFace, or similar with TensorFlow Lite
      
      final Random random = Random();
      final features = List.generate(128, (index) => random.nextDouble());
      
      // Normalize features (L2 normalization)
      final magnitude = sqrt(features.map((f) => f * f).reduce((a, b) => a + b));
      final normalizedFeatures = features.map((f) => f / magnitude).toList();

      return FeatureVector(
        features: normalizedFeatures,
        userId: userId,
        timestamp: DateTime.now(),
      );
    } catch (e) {
      print('Feature extraction error: $e');
      return null;
    }
  }

  // Calculate Euclidean distance between two feature vectors
  double calculateDistance(List<double> features1, List<double> features2) {
    if (features1.length != features2.length) {
      throw ArgumentError('Feature vectors must have the same length');
    }

    double sum = 0.0;
    for (int i = 0; i < features1.length; i++) {
      sum += pow(features1[i] - features2[i], 2);
    }
    return sqrt(sum);
  }

  // Calculate cosine similarity between two feature vectors
  double calculateCosineSimilarity(List<double> features1, List<double> features2) {
    if (features1.length != features2.length) {
      throw ArgumentError('Feature vectors must have the same length');
    }

    double dotProduct = 0.0;
    double magnitude1 = 0.0;
    double magnitude2 = 0.0;

    for (int i = 0; i < features1.length; i++) {
      dotProduct += features1[i] * features2[i];
      magnitude1 += features1[i] * features1[i];
      magnitude2 += features2[i] * features2[i];
    }

    magnitude1 = sqrt(magnitude1);
    magnitude2 = sqrt(magnitude2);

    if (magnitude1 == 0.0 || magnitude2 == 0.0) {
      return 0.0;
    }

    return dotProduct / (magnitude1 * magnitude2);
  }
}
