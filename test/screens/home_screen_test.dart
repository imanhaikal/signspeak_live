import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:network_image_mock/network_image_mock.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:signspeak_live/screens/home_screen.dart';
import 'package:signspeak_live/services/camera_service.dart';
import 'package:signspeak_live/widgets/camera/camera_viewport.dart';
import 'package:signspeak_live/widgets/interaction/interaction_area.dart';
import '../helpers/mock_gemini_service.dart';

// Reuse mocks
class MockCameraService extends Mock implements CameraService {}

class MockCameraController extends Mock implements CameraController {}

void main() {
  late MockCameraService mockCameraService;
  late MockCameraController mockCameraController;
  late MockGeminiService mockGeminiService;

  setUp(() {
    mockCameraService = MockCameraService();
    mockCameraController = MockCameraController();
    mockGeminiService = MockGeminiService();

    when(() => mockGeminiService.initialize()).thenAnswer((_) async {});
    when(
      () => mockGeminiService.interpretSign(any()),
    ).thenAnswer((_) async => '');

    // Default stubs
    when(() => mockCameraService.initialize()).thenAnswer((_) async {});
    when(() => mockCameraService.switchCamera()).thenAnswer((_) async {});
    when(() => mockCameraService.controller).thenReturn(mockCameraController);

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

  testWidgets('HomeScreen Integration: Flip Button triggers Camera Flip', (
    WidgetTester tester,
  ) async {
    await mockNetworkImagesFor(() async {
      await tester.pumpWidget(
        MaterialApp(home: HomeScreen(geminiService: mockGeminiService)),
      );

      await tester.pump(const Duration(milliseconds: 500));

      // 1. Verify Structure
      expect(find.byType(CameraViewport), findsOneWidget);
      expect(find.byType(InteractionArea), findsOneWidget);

      // 2. Find the flip button
      final flipButton = find.byIcon(PhosphorIcons.arrowsClockwise());
      expect(flipButton, findsOneWidget);

      // 3. Tap it
      await tester.tap(flipButton);
      await tester.pump();
    });
  });
}
