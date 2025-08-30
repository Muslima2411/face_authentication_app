// utils/face_auth_utils.dart
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/services.dart';

class FaceAuthUtils {
  // Convert image to different formats if needed
  static Future<Uint8List> convertImageFormat(Uint8List imageBytes) async {
    // This is a placeholder for image format conversion
    // In a real implementation, you might need to convert between formats
    return imageBytes;
  }

  // Validate image quality
  static bool validateImageQuality(Uint8List imageBytes) {
    // Basic validation - check if image exists and has minimum size
    return imageBytes.isNotEmpty && imageBytes.length > 1000;
  }

  // Generate unique user ID
  static String generateUserId() {
    return DateTime.now().millisecondsSinceEpoch.toString();
  }

  // Format confidence score as percentage
  static String formatConfidence(double confidence) {
    return '${(confidence * 100).toStringAsFixed(1)}%';
  }

  // Check if device supports face authentication
  static Future<bool> checkDeviceSupport() async {
    try {
      // Check if camera permission is available
      // Check if ML Kit is supported
      // Add more device capability checks here
      return true;
    } catch (e) {
      return false;
    }
  }

  // Security helper methods
  static String hashUserId(String userId) {
    // Simple hash function for user ID
    return userId.hashCode.toString();
  }

  // Biometric template validation
  static bool validateTemplate(List<double> features) {
    if (features.isEmpty || features.length != 128) {
      return false;
    }
    
    // Check for NaN values
    return !features.any((feature) => feature.isNaN || feature.isInfinite);
  }
}