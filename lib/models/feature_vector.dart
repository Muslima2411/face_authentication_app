// models/feature_vector.dart
class FeatureVector {
  final List<double> features;
  final String userId;
  final DateTime timestamp;

  FeatureVector({
    required this.features,
    required this.userId,
    required this.timestamp,
  });

  Map<String, dynamic> toMap() {
    return {
      'features': features.join(','),
      'userId': userId,
      'timestamp': timestamp.toIso8601String(),
    };
  }

  factory FeatureVector.fromMap(Map<String, dynamic> map) {
    return FeatureVector(
      features: map['features'].split(',').map<double>((e) => double.parse(e)).toList(),
      userId: map['userId'],
      timestamp: DateTime.parse(map['timestamp']),
    );
  }
}