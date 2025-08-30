// lib/utils/logging_service.dart
import 'dart:developer' as developer;
import 'package:flutter/foundation.dart';

enum LogLevel { debug, info, warning, error }

class LoggingService {
  static LoggingService? _instance;
  static LoggingService get instance => _instance ??= LoggingService._();
  LoggingService._();

  static const String _tag = 'FaceAuth';

  void debug(String message, [dynamic error, StackTrace? stackTrace]) {
    _log(LogLevel.debug, message, error, stackTrace);
  }

  void info(String message, [dynamic error, StackTrace? stackTrace]) {
    _log(LogLevel.info, message, error, stackTrace);
  }

  void warning(String message, [dynamic error, StackTrace? stackTrace]) {
    _log(LogLevel.warning, message, error, stackTrace);
  }

  void error(String message, [dynamic error, StackTrace? stackTrace]) {
    _log(LogLevel.error, message, error, stackTrace);
  }

  void _log(LogLevel level, String message, [dynamic error, StackTrace? stackTrace]) {
    if (!kDebugMode && level == LogLevel.debug) return;

    final timestamp = DateTime.now().toIso8601String();
    final prefix = _getLevelPrefix(level);
    final logMessage = '[$timestamp] $_tag $prefix: $message';

    // Print to console
    switch (level) {
      case LogLevel.debug:
        developer.log(logMessage, name: _tag, level: 500);
        break;
      case LogLevel.info:
        developer.log(logMessage, name: _tag, level: 800);
        break;
      case LogLevel.warning:
        developer.log(logMessage, name: _tag, level: 900, error: error, stackTrace: stackTrace);
        break;
      case LogLevel.error:
        developer.log(logMessage, name: _tag, level: 1000, error: error, stackTrace: stackTrace);
        break;
    }

    // In production, you might want to send logs to a remote service
    if (!kDebugMode && (level == LogLevel.error || level == LogLevel.warning)) {
      _sendToRemoteLogging(level, message, error, stackTrace);
    }
  }

  String _getLevelPrefix(LogLevel level) {
    switch (level) {
      case LogLevel.debug:
        return '[DEBUG]';
      case LogLevel.info:
        return '[INFO]';
      case LogLevel.warning:
        return '[WARN]';
      case LogLevel.error:
        return '[ERROR]';
    }
  }

  void _sendToRemoteLogging(LogLevel level, String message, dynamic error, StackTrace? stackTrace) {
    // Implement remote logging service integration here
    // This could be Firebase Crashlytics, Sentry, or custom logging service
  }

  // Authentication specific logging methods
  void logAuthenticationAttempt(String userId, bool success, double confidence) {
    info('Authentication attempt: userId=$userId, success=$success, confidence=${confidence.toStringAsFixed(3)}');
  }

  void logEnrollmentAttempt(String userId, bool success, int samplesCount) {
    info('Enrollment attempt: userId=$userId, success=$success, samples=$samplesCount');
  }

  void logSecurityEvent(String event, String userId, [Map<String, dynamic>? details]) {
    warning('Security event: $event, userId=$userId, details=${details?.toString() ?? 'none'}');
  }

  void logPerformanceMetric(String operation, int durationMs) {
    debug('Performance: $operation completed in ${durationMs}ms');
  }
}
