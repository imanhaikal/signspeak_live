import 'dart:async';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:google_mlkit_pose_detection/google_mlkit_pose_detection.dart';
import '../models/chat_message.dart';
import '../services/gemini_service.dart';
import '../theme/app_theme.dart';
import '../utils/landmark_utils.dart';
import '../widgets/camera/camera_viewport.dart';
import '../widgets/interaction/interaction_area.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final GlobalKey<CameraViewportState> _cameraKey = GlobalKey();
  final GeminiService _geminiService = GeminiService();

  // State
  final List<ChatMessage> _messages = [];
  final ValueNotifier<String> _currentTranslation = ValueNotifier('');
  bool _isTyping = false;

  // Buffering & Debouncing
  Timer? _apiTimer;
  Map<PoseLandmarkType, PoseLandmark>? _lastBufferedLandmarks;
  Size? _lastImageSize;
  bool _isProcessingApi = false;

  @override
  void initState() {
    super.initState();
    _initializeServices();
    _startApiTimer();
  }

  Future<void> _initializeServices() async {
    await _geminiService.initialize();
  }

  void _startApiTimer() {
    // Trigger API call every 2 seconds if there's new data
    _apiTimer = Timer.periodic(const Duration(seconds: 2), (timer) {
      _processBufferedPose();
    });
  }

  Future<void> _processBufferedPose() async {
    // If no data or already processing, skip
    if (_lastBufferedLandmarks == null || _isProcessingApi) return;

    setState(() {
      _isProcessingApi = true;
      _isTyping = true;
    });

    final landmarks = _lastBufferedLandmarks!;
    final imageSize = _lastImageSize;
    // Clear buffer to ensure we don't process the exact same frame twice
    // unless it's updated by a new detection
    _lastBufferedLandmarks = null;

    try {
      final landmarkJson = LandmarkUtils.landmarksToJson(landmarks, imageSize);
      final result = await _geminiService.interpretSign(landmarkJson);

      if (mounted && result.isNotEmpty) {
        // Update the notifier with the new translation
        _currentTranslation.value = result;

        setState(() {
          _messages.add(
            ChatMessage(
              text: result,
              isUser: true, // Interpreted sign language comes from the user
              timestamp: DateTime.now(),
            ),
          );
        });
      }
    } catch (e) {
      debugPrint('Error interpreting sign: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isProcessingApi = false;
          _isTyping = false;
        });
      }
    }
  }

  void _onPoseDetected(
    List<Pose> poses,
    Size imageSize,
    InputImageRotation rotation,
    CameraLensDirection direction,
  ) {
    if (poses.isEmpty) return;

    // Buffer the latest pose
    // We only take the first detected person
    _lastBufferedLandmarks = poses.first.landmarks;
    _lastImageSize = imageSize;
  }

  @override
  void dispose() {
    _apiTimer?.cancel();
    _currentTranslation.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.voidBlack,
      body: Stack(
        children: [
          // Layer 1 & 2: Camera Viewport (Video + Overlays + Header)
          Positioned.fill(
            child: CameraViewport(
              key: _cameraKey,
              onPoseDetected: _onPoseDetected,
            ),
          ),

          // Layer 3: Interaction Area
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            height: MediaQuery.of(context).size.height * 0.45,
            child: InteractionArea(
              messages: _messages,
              translationNotifier: _currentTranslation,
              isTyping: _isTyping,
              onFlipCamera: () {
                _cameraKey.currentState?.flipCamera();
              },
            ),
          ),
        ],
      ),
    );
  }
}
