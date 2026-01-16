import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../theme/app_theme.dart';

class CameraViewport extends StatefulWidget {
  const CameraViewport({super.key});

  @override
  State<CameraViewport> createState() => _CameraViewportState();
}

class _CameraViewportState extends State<CameraViewport>
    with SingleTickerProviderStateMixin {
  late AnimationController _scanController;

  @override
  void initState() {
    super.initState();
    _scanController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat();
  }

  @override
  void dispose() {
    _scanController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // 1. Camera Feed (Placeholder)
        Positioned.fill(
          child: Image.network(
            'https://images.unsplash.com/photo-1485217988980-11786ced9454?ixlib=rb-4.0.3&auto=format&fit=crop&w=2070&q=80',
            fit: BoxFit.cover,
            loadingBuilder: (context, child, loadingProgress) {
              if (loadingProgress == null) return child;
              return Container(color: Colors.black);
            },
            errorBuilder: (context, error, stackTrace) => Container(
              color: Colors.black,
              child: const Center(
                child: Text(
                  'Camera Feed Offline',
                  style: TextStyle(color: Colors.white54),
                ),
              ),
            ),
          ),
        ),

        // 2. Vision Overlay (Skeleton)
        Positioned.fill(child: CustomPaint(painter: SkeletonPainter())),

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
                    color: Colors.white.withOpacity(0.5),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.white.withOpacity(0.5),
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
                colors: [Colors.black.withOpacity(0.8), Colors.transparent],
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
              color: Colors.black.withOpacity(0.4),
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

class SkeletonPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.6)
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    final jointPaint = Paint()
      ..color = Colors.white.withOpacity(0.8)
      ..style = PaintingStyle.fill;

    // Simulate a hand skeleton (Right hand roughly)
    final center = Offset(size.width * 0.7, size.height * 0.5);
    final scale = size.width * 0.15;

    // Wrist
    final wrist = center + Offset(0, scale);

    // Thumb
    final thumbCMC = wrist + Offset(-scale * 0.3, -scale * 0.2);
    final thumbMCP = thumbCMC + Offset(-scale * 0.2, -scale * 0.3);
    final thumbIP = thumbMCP + Offset(-scale * 0.1, -scale * 0.3);
    final thumbTip = thumbIP + Offset(-scale * 0.05, -scale * 0.3);

    // Index
    final indexMCP = wrist + Offset(-scale * 0.1, -scale * 0.5);
    final indexPIP = indexMCP + Offset(-scale * 0.05, -scale * 0.4);
    final indexDIP = indexPIP + Offset(-scale * 0.02, -scale * 0.3);
    final indexTip = indexDIP + Offset(0, -scale * 0.3);

    // Middle
    final middleMCP = wrist + Offset(scale * 0.1, -scale * 0.55);
    final middlePIP = middleMCP + Offset(scale * 0.05, -scale * 0.45);
    final middleDIP = middlePIP + Offset(scale * 0.02, -scale * 0.35);
    final middleTip = middleDIP + Offset(0, -scale * 0.35);

    // Ring
    final ringMCP = wrist + Offset(scale * 0.3, -scale * 0.5);
    final ringPIP = ringMCP + Offset(scale * 0.15, -scale * 0.4);
    final ringDIP = ringPIP + Offset(scale * 0.1, -scale * 0.3);
    final ringTip = ringDIP + Offset(scale * 0.05, -scale * 0.3);

    // Pinky
    final pinkyMCP = wrist + Offset(scale * 0.45, -scale * 0.4);
    final pinkyPIP = pinkyMCP + Offset(scale * 0.2, -scale * 0.3);
    final pinkyDIP = pinkyPIP + Offset(scale * 0.1, -scale * 0.2);
    final pinkyTip = pinkyDIP + Offset(scale * 0.05, -scale * 0.2);

    final points = [
      wrist,
      thumbCMC,
      thumbMCP,
      thumbIP,
      thumbTip,
      indexMCP,
      indexPIP,
      indexDIP,
      indexTip,
      middleMCP,
      middlePIP,
      middleDIP,
      middleTip,
      ringMCP,
      ringPIP,
      ringDIP,
      ringTip,
      pinkyMCP,
      pinkyPIP,
      pinkyDIP,
      pinkyTip,
    ];

    // Draw connections
    // Thumb
    canvas.drawLine(wrist, thumbCMC, paint);
    canvas.drawLine(thumbCMC, thumbMCP, paint);
    canvas.drawLine(thumbMCP, thumbIP, paint);
    canvas.drawLine(thumbIP, thumbTip, paint);

    // Fingers
    canvas.drawLine(wrist, indexMCP, paint);
    canvas.drawLine(wrist, middleMCP, paint);
    canvas.drawLine(wrist, ringMCP, paint);
    canvas.drawLine(wrist, pinkyMCP, paint);

    // Index
    canvas.drawLine(indexMCP, indexPIP, paint);
    canvas.drawLine(indexPIP, indexDIP, paint);
    canvas.drawLine(indexDIP, indexTip, paint);

    // Middle
    canvas.drawLine(middleMCP, middlePIP, paint);
    canvas.drawLine(middlePIP, middleDIP, paint);
    canvas.drawLine(middleDIP, middleTip, paint);

    // Ring
    canvas.drawLine(ringMCP, ringPIP, paint);
    canvas.drawLine(ringPIP, ringDIP, paint);
    canvas.drawLine(ringDIP, ringTip, paint);

    // Pinky
    canvas.drawLine(pinkyMCP, pinkyPIP, paint);
    canvas.drawLine(pinkyPIP, pinkyDIP, paint);
    canvas.drawLine(pinkyDIP, pinkyTip, paint);

    // Draw joints
    for (var point in points) {
      canvas.drawCircle(point, 4, jointPaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
