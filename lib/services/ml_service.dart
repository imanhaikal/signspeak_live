import 'package:google_mlkit_pose_detection/google_mlkit_pose_detection.dart';
import 'package:flutter/foundation.dart';

class MLService {
  static final MLService _instance = MLService._internal();

  factory MLService() {
    return _instance;
  }

  MLService._internal();

  PoseDetector? _poseDetector;

  void initialize() {
    // Initialize with stream mode as required for video feed processing
    final options = PoseDetectorOptions(mode: PoseDetectionMode.stream);
    _poseDetector = PoseDetector(options: options);
    debugPrint('MLService initialized with PoseDetector (stream mode)');
  }

  Future<List<Pose>> processImage(InputImage inputImage) async {
    if (_poseDetector == null) {
      initialize();
    }

    try {
      final poses = await _poseDetector!.processImage(inputImage);
      return poses;
    } catch (e) {
      debugPrint('Error processing image for pose detection: $e');
      return [];
    }
  }

  void dispose() {
    _poseDetector?.close();
    _poseDetector = null;
    debugPrint('MLService disposed');
  }
}
