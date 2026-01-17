import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:signspeak_live/widgets/camera/camera_viewport.dart';
import 'package:network_image_mock/network_image_mock.dart';
import 'package:signspeak_live/services/camera_service.dart';

// Create a MockCameraService
class MockCameraService extends Mock implements CameraService {}

// Create a MockCameraController
class MockCameraController extends Mock implements CameraController {}

void main() {
  late MockCameraService mockCameraService;
  late MockCameraController mockCameraController;

  setUp(() {
    mockCameraService = MockCameraService();
    mockCameraController = MockCameraController();

    // Default stubs
    when(() => mockCameraService.initialize()).thenAnswer((_) async {});
    when(() => mockCameraService.switchCamera()).thenAnswer((_) async {});
    when(() => mockCameraService.controller).thenReturn(mockCameraController);

    // Mock controller value
    when(() => mockCameraController.value).thenReturn(
      const CameraValue(
        isInitialized: true,
        isRecordingVideo: false,
        isTakingPicture: false,
        isStreamingImages: false,
        errorDescription: null,
        previewSize: Size(1080, 1920),
        recordingOrientation: null,
        description: CameraDescription(
          name: 'back',
          lensDirection: CameraLensDirection.back,
          sensorOrientation: 90,
        ),
        isRecordingPaused: false,
        flashMode: FlashMode.off,
        exposureMode: ExposureMode.auto,
        focusMode: FocusMode.auto,
        exposurePointSupported: false,
        focusPointSupported: false,
        deviceOrientation: DeviceOrientation.portraitUp,
      ),
    );
  });

  testWidgets('CameraViewport UI Verification and Flip', (
    WidgetTester tester,
  ) async {
    await mockNetworkImagesFor(() async {
      await tester.pumpWidget(const MaterialApp(home: CameraViewport()));

      await tester.pump(const Duration(milliseconds: 500));

      // 1. Verify badges
      expect(find.text('GEMINI VISION ACTIVE'), findsOneWidget);
      expect(find.text('BIM (MY)'), findsOneWidget);

      // 2. Header icons
      expect(find.byIcon(PhosphorIcons.handWaving()), findsOneWidget);
      expect(find.byIcon(PhosphorIcons.gear()), findsOneWidget);

      // 3. Verify public method 'flipCamera' exists via key interaction
      final CameraViewportState state = tester.state(
        find.byType(CameraViewport),
      );

      // Calling flipCamera shouldn't crash
      await state.flipCamera();
      await tester.pump();
    });
  });
}
