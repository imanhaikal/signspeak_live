import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_mlkit_pose_detection/google_mlkit_pose_detection.dart';
import 'package:mocktail/mocktail.dart';
import 'package:signspeak_live/screens/home_screen.dart';
import 'package:signspeak_live/services/gemini_service.dart';
import 'package:signspeak_live/widgets/interaction/interaction_area.dart';

class MockGeminiService extends Mock implements GeminiService {}

void main() {
  group('InteractionArea UI Updates', () {
    testWidgets('displays LIVE TRANSLATION when notifier updates', (
      WidgetTester tester,
    ) async {
      final translationNotifier = ValueNotifier<String>('');

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: InteractionArea(translationNotifier: translationNotifier),
          ),
        ),
      );

      // Initial state: No "LIVE TRANSLATION" text
      expect(find.text('LIVE TRANSLATION'), findsNothing);

      // Update notifier
      translationNotifier.value = 'Hello World';
      await tester
          .pump(); // Use pump instead of pumpAndSettle due to infinite animation

      // Verify "LIVE TRANSLATION" appears
      expect(find.text('LIVE TRANSLATION'), findsOneWidget);
      expect(find.text('Hello World'), findsOneWidget);
    });
  });

  group('HomeScreen Throttling Logic', () {
    late MockGeminiService mockGeminiService;

    setUp(() {
      mockGeminiService = MockGeminiService();
      when(() => mockGeminiService.initialize()).thenAnswer((_) async {});
      when(
        () => mockGeminiService.interpretSign(any()),
      ).thenAnswer((_) async => 'Translated Text');
    });

    testWidgets('throttles API calls to once every 2 seconds', (
      WidgetTester tester,
    ) async {
      late void Function(
        List<Pose>,
        Size,
        InputImageRotation,
        CameraLensDirection,
      )
      capturedOnPoseDetected;

      await tester.pumpWidget(
        MaterialApp(
          home: HomeScreen(
            geminiService: mockGeminiService,
            cameraViewportBuilder: (key, onPoseDetected) {
              capturedOnPoseDetected = onPoseDetected;
              return const SizedBox();
            },
          ),
        ),
      );

      // Create dummy pose data
      final dummyLandmark = PoseLandmark(
        type: PoseLandmarkType.nose,
        x: 100,
        y: 100,
        z: 0,
        likelihood: 0.9,
      );
      final dummyPose = Pose(landmarks: {PoseLandmarkType.nose: dummyLandmark});
      final dummySize = const Size(640, 480);

      // 1. Simulate multiple rapid triggers within < 2 seconds
      // T=0.0s
      capturedOnPoseDetected(
        [dummyPose],
        dummySize,
        InputImageRotation.rotation0deg,
        CameraLensDirection.front,
      );
      await tester.pump(const Duration(milliseconds: 500)); // T=0.5s

      // T=0.5s
      capturedOnPoseDetected(
        [dummyPose],
        dummySize,
        InputImageRotation.rotation0deg,
        CameraLensDirection.front,
      );
      await tester.pump(const Duration(milliseconds: 500)); // T=1.0s

      // T=1.0s
      capturedOnPoseDetected(
        [dummyPose],
        dummySize,
        InputImageRotation.rotation0deg,
        CameraLensDirection.front,
      );
      await tester.pump(const Duration(milliseconds: 500)); // T=1.5s

      // Verify NO calls yet (Timer fires at 2s)
      verifyNever(() => mockGeminiService.interpretSign(any()));

      // 2. Advance time to complete the 2-second window
      await tester.pump(const Duration(milliseconds: 600)); // T=2.1s

      // Now the timer should have fired once and processed the latest buffered pose
      verify(() => mockGeminiService.interpretSign(any())).called(1);

      // 3. Verify subsequent calls obey the interval
      // Clear interactions
      clearInteractions(mockGeminiService);
      when(
        () => mockGeminiService.interpretSign(any()),
      ).thenAnswer((_) async => 'Next Text');

      // Send another pose immediately
      capturedOnPoseDetected(
        [dummyPose],
        dummySize,
        InputImageRotation.rotation0deg,
        CameraLensDirection.front,
      );

      // Advance by 1 second (total 3.1s from start, 1.0s from last timer)
      await tester.pump(const Duration(seconds: 1));

      // Should not have called yet (next timer at T=4.0s relative to start, or 2s from last tick)
      verifyNever(() => mockGeminiService.interpretSign(any()));

      // Advance another 1.1 second
      await tester.pump(const Duration(milliseconds: 1100));

      // Should have called again
      verify(() => mockGeminiService.interpretSign(any())).called(1);
    });
  });
}
