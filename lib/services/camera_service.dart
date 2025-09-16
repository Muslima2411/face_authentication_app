// services/camera_service.dart
import 'package:camera/camera.dart';
import 'package:flutter/services.dart';
import 'dart:typed_data';

class CameraService {
  static CameraService? _instance;
  static CameraService get instance => _instance ??= CameraService._();
  CameraService._();

  CameraController? _controller;
  List<CameraDescription>? _cameras;
  bool _isInitialized = false;
  bool _isDisposing = false;

  Future<bool> initialize() async {
    if (_isDisposing) {
      await Future.delayed(const Duration(milliseconds: 100));
      return initialize();
    }

    try {
      // Dispose existing controller if any
      await forceDispose();

      _cameras = await availableCameras();
      if (_cameras == null || _cameras!.isEmpty) {
        return false;
      }

      // Use front camera for face authentication
      final frontCamera = _cameras!.firstWhere(
        (camera) => camera.lensDirection == CameraLensDirection.front,
        orElse: () => _cameras!.first,
      );

      _controller = CameraController(
        frontCamera,
        ResolutionPreset.medium,
        enableAudio: false,
        imageFormatGroup: ImageFormatGroup.jpeg,
      );

      await _controller!.initialize();
      _isInitialized = true;
      return true;
    } catch (e) {
      print('Camera initialization error: $e');
      _isInitialized = false;
      return false;
    }
  }

  Future<Uint8List?> captureFace() async {
    if (!_isInitialized || _controller == null || _isDisposing) {
      return null;
    }

    try {
      final XFile image = await _controller!.takePicture();
      return await image.readAsBytes();
    } catch (e) {
      print('Face capture error: $e');
      return null;
    }
  }

  Future<void> pausePreview() async {
    if (_isInitialized && _controller != null && !_isDisposing) {
      try {
        await _controller!.pausePreview();
      } catch (e) {
        print('Pause preview error: $e');
      }
    }
  }

  Future<void> resumePreview() async {
    if (_isInitialized && _controller != null && !_isDisposing) {
      try {
        await _controller!.resumePreview();
      } catch (e) {
        print('Resume preview error: $e');
      }
    }
  }

  Future<void> forceDispose() async {
    if (_controller != null && !_isDisposing) {
      _isDisposing = true;
      _isInitialized = false;

      try {
        // Stop any ongoing operations first
        if (_controller!.value.isInitialized) {
          await _controller!.pausePreview();
        }

        // Add a small delay to ensure operations complete
        await Future.delayed(const Duration(milliseconds: 50));

        await _controller!.dispose();
      } catch (e) {
        print('Camera disposal error: $e');
      } finally {
        _controller = null;
        _isDisposing = false;
      }
    }
  }

  Future<void> reinitialize() async {
    await forceDispose();
    await initialize();
  }

  CameraController? get controller => _controller;
  bool get isInitialized => _isInitialized && !_isDisposing;
  bool get isDisposing => _isDisposing;

  void dispose() {
    forceDispose();
  }
}
