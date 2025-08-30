// lib/config/security_config.dart
import 'dart:convert';
import 'package:crypto/crypto.dart';

class SecurityConfig {
  // Encryption Settings
  static const String encryptionAlgorithm = 'AES-256-GCM';
  static const int keySize = 256;
  static const int ivSize = 128;
  
  // Hashing Settings
  static const String hashAlgorithm = 'SHA-256';
  static const int saltLength = 32;
  
  // Security Keys (In production, these should be from secure key management)
  static const String templateEncryptionKey = 'your-template-encryption-key-here';
  static const String databaseEncryptionKey = 'your-database-encryption-key-here';
  
  // Generate secure hash for data integrity
  static String generateHash(String data, {String? salt}) {
    final saltToUse = salt ?? _generateSalt();
    final bytes = utf8.encode(data + saltToUse);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }
  
  // Generate random salt
  static String _generateSalt() {
    final timestamp = DateTime.now().millisecondsSinceEpoch.toString();
    return generateHash(timestamp);
  }
  
  // Validate hash integrity
  static bool validateHash(String data, String expectedHash, String salt) {
    final computedHash = generateHash(data, salt: salt);
    return computedHash == expectedHash;
  }
  
  // Template anonymization (one-way transformation)
  static List<double> anonymizeTemplate(List<double> features) {
    // Apply irreversible transformation to protect biometric data
    return features.map((feature) {
      return _oneWayTransform(feature);
    }).toList();
  }
  
  static double _oneWayTransform(double value) {
    // Simple one-way transformation - in production use more sophisticated methods
    final hash = sha256.convert(utf8.encode(value.toString()));
    final hashBytes = hash.bytes;
    return (hashBytes[0] + hashBytes[1] * 256) / 65536.0 - 0.5;
  }
}
