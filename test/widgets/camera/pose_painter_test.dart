import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_mlkit_pose_detection/google_mlkit_pose_detection.dart';
import 'package:signspeak_live/widgets/camera/pose_painter.dart';

void main() {
  group('PosePainter', () {
    const size = Size(640, 480);
    const rotation = InputImageRotation.rotation0deg;
    const lensDirection = CameraLensDirection.back;

    test('shouldRepaint returns true when poses change', () {
      final painter1 = PosePainter(
        poses: [],
        absoluteImageSize: size,
        rotation: rotation,
        cameraLensDirection: lensDirection,
      );

      final painter2 = PosePainter(
        poses: [
          Pose(
            landmarks: {
              PoseLandmarkType.nose: PoseLandmark(
                type: PoseLandmarkType.nose,
                x: 10,
                y: 10,
                z: 0,
                likelihood: 1.0,
              ),
            },
          ),
        ],
        absoluteImageSize: size,
        rotation: rotation,
        cameraLensDirection: lensDirection,
      );

      expect(painter1.shouldRepaint(painter2), isTrue);
    });

    test('shouldRepaint returns true when image size changes', () {
      final painter1 = PosePainter(
        poses: [],
        absoluteImageSize: size,
        rotation: rotation,
        cameraLensDirection: lensDirection,
      );

      final painter2 = PosePainter(
        poses: [],
        absoluteImageSize: const Size(1280, 720),
        rotation: rotation,
        cameraLensDirection: lensDirection,
      );

      expect(painter1.shouldRepaint(painter2), isTrue);
    });

    testWidgets('paints without error', (WidgetTester tester) async {
      final pose = Pose(
        landmarks: {
          PoseLandmarkType.leftShoulder: PoseLandmark(
            type: PoseLandmarkType.leftShoulder,
            x: 100,
            y: 100,
            z: 0,
            likelihood: 1.0,
          ),
          PoseLandmarkType.rightShoulder: PoseLandmark(
            type: PoseLandmarkType.rightShoulder,
            x: 200,
            y: 100,
            z: 0,
            likelihood: 1.0,
          ),
          PoseLandmarkType.leftElbow: PoseLandmark(
            type: PoseLandmarkType.leftElbow,
            x: 100,
            y: 200,
            z: 0,
            likelihood: 1.0,
          ),
          PoseLandmarkType.rightElbow: PoseLandmark(
            type: PoseLandmarkType.rightElbow,
            x: 200,
            y: 200,
            z: 0,
            likelihood: 1.0,
          ),
          PoseLandmarkType.leftWrist: PoseLandmark(
            type: PoseLandmarkType.leftWrist,
            x: 100,
            y: 300,
            z: 0,
            likelihood: 1.0,
          ),
          PoseLandmarkType.rightWrist: PoseLandmark(
            type: PoseLandmarkType.rightWrist,
            x: 200,
            y: 300,
            z: 0,
            likelihood: 1.0,
          ),
          PoseLandmarkType.leftHip: PoseLandmark(
            type: PoseLandmarkType.leftHip,
            x: 100,
            y: 400,
            z: 0,
            likelihood: 1.0,
          ),
          PoseLandmarkType.rightHip: PoseLandmark(
            type: PoseLandmarkType.rightHip,
            x: 200,
            y: 400,
            z: 0,
            likelihood: 1.0,
          ),
          PoseLandmarkType.leftKnee: PoseLandmark(
            type: PoseLandmarkType.leftKnee,
            x: 100,
            y: 500,
            z: 0,
            likelihood: 1.0,
          ),
          PoseLandmarkType.rightKnee: PoseLandmark(
            type: PoseLandmarkType.rightKnee,
            x: 200,
            y: 500,
            z: 0,
            likelihood: 1.0,
          ),
          PoseLandmarkType.leftAnkle: PoseLandmark(
            type: PoseLandmarkType.leftAnkle,
            x: 100,
            y: 600,
            z: 0,
            likelihood: 1.0,
          ),
          PoseLandmarkType.rightAnkle: PoseLandmark(
            type: PoseLandmarkType.rightAnkle,
            x: 200,
            y: 600,
            z: 0,
            likelihood: 1.0,
          ),
        },
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CustomPaint(
              painter: PosePainter(
                poses: [pose],
                absoluteImageSize: const Size(640, 480),
                rotation: InputImageRotation.rotation0deg,
                cameraLensDirection: CameraLensDirection.back,
              ),
              size: const Size(300, 300),
            ),
          ),
        ),
      );

      // We expect one CustomPaint for the widget we inserted, but depending on the implementation
      // there might be internal CustomPaints.
      // However, finding byType(CustomPaint) usually finds the widget wrapping the painter.
      // If there are multiple, we can be more specific.
      expect(find.byType(CustomPaint), findsWidgets);
    });
  });
}
