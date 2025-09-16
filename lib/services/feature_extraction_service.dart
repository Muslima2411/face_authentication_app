import 'dart:typed_data';
import 'dart:math';
import 'package:image/image.dart' as img;
import '../models/feature_vector.dart';

class FeatureExtractionService {
  static FeatureExtractionService? _instance;
  static FeatureExtractionService get instance =>
      _instance ??= FeatureExtractionService._();
  FeatureExtractionService._();

  // Extract features using image processing techniques
  // This is a simplified implementation - in production, use FaceNet or similar models
  Future<FeatureVector?> extractFeatures(
    Uint8List faceImage,
    String userId,
  ) async {
    try {
      // Decode the image
      final image = img.decodeImage(faceImage);
      if (image == null) return null;

      // Resize to standard size for consistency
      final resized = img.copyResize(image, width: 160, height: 160);

      // Convert to grayscale for feature extraction
      final grayscale = img.grayscale(resized);

      // Extract features using various image processing techniques
      final features = <double>[];

      // 1. Histogram features (32 features)
      features.addAll(_extractHistogramFeatures(grayscale));

      // 2. Local Binary Pattern features (32 features)
      features.addAll(_extractLBPFeatures(grayscale));

      // 3. Gradient features (32 features)
      features.addAll(_extractGradientFeatures(grayscale));

      // 4. Texture features (32 features)
      features.addAll(_extractTextureFeatures(grayscale));

      // Normalize features (L2 normalization)
      final magnitude = sqrt(
        features.map((f) => f * f).reduce((a, b) => a + b),
      );
      final normalizedFeatures = features
          .map((f) => f / (magnitude + 1e-8))
          .toList();

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

  // Extract histogram features from grayscale image
  List<double> _extractHistogramFeatures(img.Image image) {
    final histogram = List.filled(256, 0);
    final totalPixels = image.width * image.height;

    for (int y = 0; y < image.height; y++) {
      for (int x = 0; x < image.width; x++) {
        final pixel = image.getPixel(x, y);
        final gray = img.getLuminance(pixel).toInt();
        histogram[gray]++;
      }
    }

    // Normalize histogram and extract 32 bins
    final features = <double>[];
    final binSize = 256 ~/ 32;

    for (int i = 0; i < 32; i++) {
      double sum = 0;
      for (int j = i * binSize; j < (i + 1) * binSize; j++) {
        sum += histogram[j];
      }
      features.add(sum / totalPixels);
    }

    return features;
  }

  // Extract Local Binary Pattern features
  List<double> _extractLBPFeatures(img.Image image) {
    final lbpHistogram = List.filled(256, 0);
    final totalPatterns = (image.width - 2) * (image.height - 2);

    for (int y = 1; y < image.height - 1; y++) {
      for (int x = 1; x < image.width - 1; x++) {
        final center = img.getLuminance(image.getPixel(x, y));
        int lbpValue = 0;

        // 8 neighbors
        final neighbors = [
          img.getLuminance(image.getPixel(x - 1, y - 1)),
          img.getLuminance(image.getPixel(x, y - 1)),
          img.getLuminance(image.getPixel(x + 1, y - 1)),
          img.getLuminance(image.getPixel(x + 1, y)),
          img.getLuminance(image.getPixel(x + 1, y + 1)),
          img.getLuminance(image.getPixel(x, y + 1)),
          img.getLuminance(image.getPixel(x - 1, y + 1)),
          img.getLuminance(image.getPixel(x - 1, y)),
        ];

        for (int i = 0; i < 8; i++) {
          if (neighbors[i] >= center) {
            lbpValue |= (1 << i);
          }
        }

        lbpHistogram[lbpValue]++;
      }
    }

    // Extract 32 features from LBP histogram
    final features = <double>[];
    final binSize = 256 ~/ 32;

    for (int i = 0; i < 32; i++) {
      double sum = 0;
      for (int j = i * binSize; j < (i + 1) * binSize; j++) {
        sum += lbpHistogram[j];
      }
      features.add(sum / totalPatterns);
    }

    return features;
  }

  // Extract gradient-based features
  List<double> _extractGradientFeatures(img.Image image) {
    final features = <double>[];
    final width = image.width;
    final height = image.height;

    // Calculate gradients using Sobel operators
    final gradientMagnitudes = <double>[];

    for (int y = 1; y < height - 1; y++) {
      for (int x = 1; x < width - 1; x++) {
        // Sobel X kernel
        final gx =
            -1 * img.getLuminance(image.getPixel(x - 1, y - 1)) +
            1 * img.getLuminance(image.getPixel(x + 1, y - 1)) +
            -2 * img.getLuminance(image.getPixel(x - 1, y)) +
            2 * img.getLuminance(image.getPixel(x + 1, y)) +
            -1 * img.getLuminance(image.getPixel(x - 1, y + 1)) +
            1 * img.getLuminance(image.getPixel(x + 1, y + 1));

        // Sobel Y kernel
        final gy =
            -1 * img.getLuminance(image.getPixel(x - 1, y - 1)) +
            -2 * img.getLuminance(image.getPixel(x, y - 1)) +
            -1 * img.getLuminance(image.getPixel(x + 1, y - 1)) +
            1 * img.getLuminance(image.getPixel(x - 1, y + 1)) +
            2 * img.getLuminance(image.getPixel(x, y + 1)) +
            1 * img.getLuminance(image.getPixel(x + 1, y + 1));

        final magnitude = sqrt(gx * gx + gy * gy);
        gradientMagnitudes.add(magnitude);
      }
    }

    // Extract statistical features from gradients
    gradientMagnitudes.sort();
    final len = gradientMagnitudes.length;

    if (len > 0) {
      features.add(gradientMagnitudes.reduce((a, b) => a + b) / len); // Mean
      features.add(gradientMagnitudes[len ~/ 2]); // Median
      features.add(gradientMagnitudes[(len * 0.25).floor()]); // Q1
      features.add(gradientMagnitudes[(len * 0.75).floor()]); // Q3
      features.add(gradientMagnitudes.last - gradientMagnitudes.first); // Range

      // Add more statistical moments
      final mean = features[0];
      double variance = 0;
      for (final mag in gradientMagnitudes) {
        variance += pow(mag - mean, 2);
      }
      variance /= len;
      features.add(sqrt(variance)); // Standard deviation
    }

    // Pad to 32 features
    while (features.length < 32) {
      features.add(0.0);
    }

    return features.take(32).toList();
  }

  // Extract texture-based features
  List<double> _extractTextureFeatures(img.Image image) {
    final features = <double>[];
    final width = image.width;
    final height = image.height;

    // Calculate energy and entropy for different regions
    final regionSize = 20;
    final regions = <List<int>>[];

    for (int ry = 0; ry < height - regionSize; ry += regionSize) {
      for (int rx = 0; rx < width - regionSize; rx += regionSize) {
        final region = <int>[];
        for (int y = ry; y < ry + regionSize && y < height; y++) {
          for (int x = rx; x < rx + regionSize && x < width; x++) {
            region.add(img.getLuminance(image.getPixel(x, y)).toInt());
          }
        }
        regions.add(region);
      }
    }

    // Calculate features for each region
    for (final region in regions.take(8)) {
      // Limit to 8 regions for 32 features
      if (region.isNotEmpty) {
        // Energy
        final mean = region.reduce((a, b) => a + b) / region.length;
        double energy = 0;
        for (final pixel in region) {
          energy += pow(pixel - mean, 2);
        }
        features.add(energy / region.length);

        // Entropy approximation
        final histogram = List.filled(256, 0);
        for (final pixel in region) {
          histogram[pixel]++;
        }
        double entropy = 0;
        for (final count in histogram) {
          if (count > 0) {
            final p = count / region.length;
            entropy -= p * log(p) / log(2);
          }
        }
        features.add(entropy);

        // Contrast
        double contrast = 0;
        for (int i = 0; i < region.length - 1; i++) {
          contrast += pow(region[i] - region[i + 1], 2).toDouble();
        }
        features.add(contrast / (region.length - 1));

        // Homogeneity
        double homogeneity = 0;
        for (int i = 0; i < region.length - 1; i++) {
          homogeneity += 1 / (1 + pow(region[i] - region[i + 1], 2));
        }
        features.add(homogeneity / (region.length - 1));
      }
    }

    // Pad to 32 features
    while (features.length < 32) {
      features.add(0.0);
    }

    return features.take(32).toList();
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
  double calculateCosineSimilarity(
    List<double> features1,
    List<double> features2,
  ) {
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
