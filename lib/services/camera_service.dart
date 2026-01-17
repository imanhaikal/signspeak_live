import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';

class CameraService {
  static final CameraService _instance = CameraService._internal();

  factory CameraService() {
    return _instance;
  }

  CameraService._internal();

  List<CameraDescription> _cameras = [];
  CameraController? _controller;
  int _selectedCameraIndex = 0;

  CameraController? get controller => _controller;

  CameraDescription? get cameraDescription =>
      _cameras.isNotEmpty ? _cameras[_selectedCameraIndex] : null;

  Future<void> initialize() async {
    try {
      _cameras = await availableCameras();
      if (_cameras.isEmpty) {
        debugPrint('No cameras available');
        return;
      }

      // Default to the first camera (usually back)
      _selectedCameraIndex = 0;
      await _initializeController();
    } catch (e) {
      debugPrint('Error initializing camera service: $e');
    }
  }

  Future<void> _initializeController() async {
    if (_cameras.isEmpty) return;

    final camera = _cameras[_selectedCameraIndex];

    // Dispose previous controller if exists
    await _controller?.dispose();

    _controller = CameraController(
      camera,
      ResolutionPreset.high,
      enableAudio: false, // We use a separate mic button for STT
      imageFormatGroup: ImageFormatGroup.yuv420,
    );

    try {
      await _controller!.initialize();
    } catch (e) {
      debugPrint('Error initializing camera controller: $e');
    }
  }

  Future<void> switchCamera() async {
    if (_cameras.length < 2) {
      debugPrint('Not enough cameras to switch');
      return;
    }

    _selectedCameraIndex = (_selectedCameraIndex + 1) % _cameras.length;
    await _initializeController();
  }

  void dispose() {
    _controller?.dispose();
  }
}
