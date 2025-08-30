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

  Future<bool> initialize() async {
    try {
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
      );

      await _controller!.initialize();
      _isInitialized = true;
      return true;
    } catch (e) {
      print('Camera initialization error: $e');
      return false;
    }
  }

  Future<Uint8List?> captureFace() async {
    if (!_isInitialized || _controller == null) {
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

  CameraController? get controller => _controller;
  bool get isInitialized => _isInitialized;

  void dispose() {
    _controller?.dispose();
    _isInitialized = false;
  }
}
