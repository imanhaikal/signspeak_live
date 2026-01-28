import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_mlkit_pose_detection/google_mlkit_pose_detection.dart';
import '../../services/camera_service.dart';
import '../../services/ml_service.dart';
import '../../utils/image_utils.dart';
import '../../theme/app_theme.dart';
import 'pose_painter.dart';

class CameraViewport extends StatefulWidget {
  final CameraService? cameraService;
  final MLService? mlService;
  final Function(List<Pose>, Size, InputImageRotation, CameraLensDirection)?
  onPoseDetected;

  const CameraViewport({
    super.key,
    this.cameraService,
    this.mlService,
    this.onPoseDetected,
  });

  @override
  State<CameraViewport> createState() => CameraViewportState();
}

class CameraViewportState extends State<CameraViewport>
    with SingleTickerProviderStateMixin {
  late AnimationController _scanController;
  late final CameraService _cameraService;
  late final MLService _mlService;
  bool _isCameraInitialized = false;
  bool _isProcessing = false;
  DateTime? _lastProcessingTime;

  // Pose Detection State
  List<Pose> _poses = [];
  Size _inputImageSize = Size.zero;
  InputImageRotation _rotation = InputImageRotation.rotation0deg;
  CameraLensDirection _cameraLensDirection = CameraLensDirection.back;

  @override
  void initState() {
    super.initState();
    _cameraService = widget.cameraService ?? CameraService();
    _mlService = widget.mlService ?? MLService();
    _scanController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat();

    _initializeCamera();
  }

  Future<void> _initializeCamera() async {
    await _cameraService.initialize();
    if (mounted) {
      setState(() {
        _isCameraInitialized =
            _cameraService.controller?.value.isInitialized ?? false;
      });
      if (_isCameraInitialized) {
        try {
          await _cameraService.controller?.startImageStream(_processImage);
        } catch (e) {
          debugPrint('Error starting image stream: $e');
        }
      }
    }
  }

  Future<void> _processImage(CameraImage image) async {
    if (_isProcessing) return;

    // Throttle to ~10 FPS (100ms interval)
    if (_lastProcessingTime != null &&
        DateTime.now().difference(_lastProcessingTime!) <
            const Duration(milliseconds: 100)) {
      return;
    }
    _lastProcessingTime = DateTime.now();

    _isProcessing = true;
    try {
      final cameraDescription = _cameraService.cameraDescription;
      if (cameraDescription == null) return;

      final inputImage = ImageUtils.convertCameraImageToInputImage(
        image,
        cameraDescription,
      );

      if (inputImage != null) {
        final poses = await _mlService.processImage(inputImage);
        if (mounted) {
          final imageSize = inputImage.metadata?.size ?? Size.zero;
          final rotation =
              inputImage.metadata?.rotation ?? InputImageRotation.rotation0deg;
          final cameraLensDirection = cameraDescription.lensDirection;

          widget.onPoseDetected?.call(
            poses,
            imageSize,
            rotation,
            cameraLensDirection,
          );

          setState(() {
            _poses = poses;
            _inputImageSize = imageSize;
            _rotation = rotation;
            _cameraLensDirection = cameraLensDirection;
          });
        }
      }
    } catch (e) {
      debugPrint('Error processing image: $e');
    } finally {
      _isProcessing = false;
    }
  }

  Future<void> flipCamera() async {
    setState(() {
      _isCameraInitialized = false;
      _poses = [];
    });

    await _cameraService.switchCamera();

    if (mounted) {
      setState(() {
        _isCameraInitialized =
            _cameraService.controller?.value.isInitialized ?? false;
      });

      if (_isCameraInitialized) {
        try {
          await _cameraService.controller?.startImageStream(_processImage);
        } catch (e) {
          debugPrint('Error restarting image stream: $e');
        }
      }
    }
  }

  @override
  void dispose() {
    _scanController.dispose();
    _cameraService.dispose();
    _mlService.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // 1. Camera Feed
        Positioned.fill(
          child: _isCameraInitialized && _cameraService.controller != null
              ? CameraPreview(_cameraService.controller!)
              : Container(
                  color: Colors.black,
                  child: const Center(
                    child: Text(
                      'Initializing Camera...',
                      style: TextStyle(color: Colors.white54),
                    ),
                  ),
                ),
        ),

        // 2. Vision Overlay (Skeleton)
        Positioned.fill(
          child: CustomPaint(
            painter: PosePainter(
              poses: _poses,
              absoluteImageSize: _inputImageSize,
              rotation: _rotation,
              cameraLensDirection: _cameraLensDirection,
            ),
          ),
        ),

        // 3. Scan Line Animation
        Positioned.fill(
          child: AnimatedBuilder(
            animation: _scanController,
            builder: (context, child) {
              return FractionallySizedBox(
                heightFactor: 0.005, // Thin line
                alignment: Alignment(0, 2 * _scanController.value - 1),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.5),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.white.withValues(alpha: 0.5),
                        blurRadius: 10,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),

        // 4. Header (Gradient & Controls)
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          height: 120, // Enough space for status bar + content
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.black.withValues(alpha: 0.8),
                  Colors.transparent,
                ],
              ),
            ),
            padding: const EdgeInsets.fromLTRB(
              24,
              60,
              24,
              0,
            ), // Adjust for SafeArea
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Logo Area
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.glassWhite,
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.glassBorder),
                  ),
                  child: Icon(
                    PhosphorIcons.handWaving(),
                    color: Colors.white,
                    size: 24,
                  ),
                ),
                // Settings Area
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.glassWhite,
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.glassBorder),
                  ),
                  child: Icon(
                    PhosphorIcons.gear(),
                    color: Colors.white,
                    size: 24,
                  ),
                ),
              ],
            ),
          ),
        ),

        // 5. Status Indicators
        // Detected Language (Top Right, below Header)
        Positioned(
          top: 130, // Below the header area
          right: 24,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.4),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppColors.glassBorder),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'BIM (MY)',
                  style: AppTextStyles.caption.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ),

        // Gemini Vision Active (Bottom Left)
        Positioned(
          left: 24,
          bottom: MediaQuery.of(context).size.height * 0.4 + 16,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: AppColors.glassWhite,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: AppColors.glassBorder),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Animate(
                  onPlay: (controller) => controller.repeat(reverse: true),
                  effects: [
                    FadeEffect(duration: 1000.ms, begin: 0.4, end: 1.0),
                    ScaleEffect(
                      duration: 1000.ms,
                      begin: const Offset(0.8, 0.8),
                      end: const Offset(1.2, 1.2),
                    ),
                  ],
                  child: Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                      color: AppColors.signalGreen,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  'GEMINI VISION ACTIVE',
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.signalGreen,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.0,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
