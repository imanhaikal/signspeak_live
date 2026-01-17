import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../widgets/camera/camera_viewport.dart';
import '../widgets/interaction/interaction_area.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final GlobalKey<CameraViewportState> cameraKey = GlobalKey();

    return Scaffold(
      backgroundColor: AppColors.voidBlack,
      body: Stack(
        children: [
          // Layer 1 & 2: Camera Viewport (Video + Overlays + Header)
          Positioned.fill(child: CameraViewport(key: cameraKey)),

          // Layer 3: Interaction Area
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            height: MediaQuery.of(context).size.height * 0.45,
            child: InteractionArea(
              onFlipCamera: () {
                cameraKey.currentState?.flipCamera();
              },
            ),
          ),
        ],
      ),
    );
  }
}
