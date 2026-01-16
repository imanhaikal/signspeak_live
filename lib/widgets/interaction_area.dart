import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../theme/app_theme.dart';

class InteractionArea extends StatefulWidget {
  const InteractionArea({super.key});

  @override
  State<InteractionArea> createState() => _InteractionAreaState();
}

class _InteractionAreaState extends State<InteractionArea>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: false);
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.voidBlack,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(32),
          topRight: Radius.circular(32),
        ),
      ),
      child: Column(
        children: [
          const SizedBox(height: 12),
          // Drag Handle
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: AppColors.mutedGray.withOpacity(0.3),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          // Chat History
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
              children: [
                // Date Separator
                Center(
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 24.0),
                    child: Text(
                      "Live Session • 10:42 AM",
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.mutedGray,
                      ),
                    ),
                  ),
                ),

                // User Message (Received/Glassmorphic)
                Align(
                  alignment: Alignment.centerLeft,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ClipRRect(
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(18),
                          topRight: Radius.circular(18),
                          bottomRight: Radius.circular(18),
                          bottomLeft: Radius.circular(4),
                        ),
                        child: BackdropFilter(
                          filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                          child: Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: AppColors.glassWhite,
                              border: Border.all(color: AppColors.glassBorder),
                            ),
                            child: Text(
                              "I need to renew my identification card...",
                              style: AppTextStyles.body,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        "Detected from Sign • 98% confidence",
                        style: AppTextStyles.caption.copyWith(
                          color: AppColors.signalGreen,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // Staff Message (Sent/White)
                Align(
                  alignment: Alignment.centerRight,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(18),
                            topRight: Radius.circular(18),
                            bottomLeft: Radius.circular(18),
                            bottomRight: Radius.circular(4),
                          ),
                        ),
                        child: Text(
                          "I can help with that...",
                          style: AppTextStyles.body.copyWith(
                            color: Colors.black,
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text("Spoken", style: AppTextStyles.caption),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // Typing Indicator
                Row(
                  children: [
                    _buildDot(0),
                    const SizedBox(width: 4),
                    _buildDot(100),
                    const SizedBox(width: 4),
                    _buildDot(200),
                  ],
                ),
              ],
            ),
          ),

          // Bottom Controls
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 0, 24, 32),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      onPressed: () {},
                      icon: Icon(
                        PhosphorIcons.keyboard(),
                        color: Colors.white,
                        size: 24,
                      ),
                    ),

                    // Mic Button with Pulse Ring
                    SizedBox(
                      width: 80,
                      height: 80,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          // Pulse Ring
                          AnimatedBuilder(
                            animation: _pulseController,
                            builder: (context, child) {
                              return Opacity(
                                opacity: (1.0 - _pulseController.value),
                                child: Transform.scale(
                                  scale: 1.0 + (_pulseController.value * 0.5),
                                  child: Container(
                                    width: 80,
                                    height: 80,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: Colors.white.withOpacity(0.2),
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                          // Main Button
                          Container(
                            width: 64,
                            height: 64,
                            decoration: const BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              PhosphorIcons.microphone(PhosphorIconsStyle.fill),
                              color: AppColors.voidBlack,
                              size: 32,
                            ),
                          ),
                        ],
                      ),
                    ),

                    IconButton(
                      onPressed: () {},
                      icon: Icon(
                        PhosphorIcons.arrowsClockwise(),
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  "Tap and hold to speak",
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDot(int delay) {
    return Container(
          width: 8,
          height: 8,
          decoration: const BoxDecoration(
            color: AppColors.textSecondary,
            shape: BoxShape.circle,
          ),
        )
        .animate(onPlay: (controller) => controller.repeat())
        .scale(
          duration: 600.ms,
          delay: delay.ms,
          begin: const Offset(1, 1),
          end: const Offset(1.2, 1.2),
        )
        .then()
        .scale(
          duration: 600.ms,
          begin: const Offset(1.2, 1.2),
          end: const Offset(1, 1),
        );
  }
}
