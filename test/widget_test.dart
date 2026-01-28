import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:network_image_mock/network_image_mock.dart';
import 'package:signspeak_live/screens/home_screen.dart';
import 'package:signspeak_live/widgets/camera/camera_viewport.dart';
import 'package:signspeak_live/widgets/interaction/interaction_area.dart';

import 'helpers/mock_gemini_service.dart';

void main() {
  testWidgets('HomeScreen initialization test', (WidgetTester tester) async {
    final mockGeminiService = MockGeminiService();
    when(() => mockGeminiService.initialize()).thenAnswer((_) async {});
    when(
      () => mockGeminiService.interpretSign(any()),
    ).thenAnswer((_) async => '');

    // Build our app and trigger a frame.
    // Wrap in MaterialApp for Theme and MediaQuery context
    await mockNetworkImagesFor(() async {
      await tester.pumpWidget(
        MaterialApp(home: HomeScreen(geminiService: mockGeminiService)),
      );

      // Pump to allow animations to settle.
      // Using pumpAndSettle can be tricky with infinite animations, so sometimes a fixed duration pump is safer if loop animations exist.
      // However, detected timers often mean pumpAndSettle times out or doesn't finish if logic keeps reposting.
      // CameraViewport has a repeating animation controller.
      // InteractionArea has a repeating animation controller.

      // Instead of pumpAndSettle, let's pump for a specific duration to "fast forward" any initial animations
      // and ensure pending timers are handled if possible, or just accept that we are taking a snapshot.
      // But we MUST dispose properly or handle infinite animations.
      // flutter_animate often plays nice, but repeating animations in StatefulWidgets need care in tests.
      await tester.pump(const Duration(seconds: 2));

      // Verify presence of main components
      expect(find.byType(CameraViewport), findsOneWidget);
      expect(find.byType(InteractionArea), findsOneWidget);

      // Verify text content from children
      expect(find.text('BIM (MY)'), findsOneWidget);
      expect(find.textContaining('GEMINI VISION ACTIVE'), findsOneWidget);
    });
  });
}
