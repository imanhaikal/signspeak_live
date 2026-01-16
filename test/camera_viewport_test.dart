import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:signspeak_live/widgets/camera_viewport.dart';
import 'package:network_image_mock/network_image_mock.dart';

void main() {
  testWidgets('CameraViewport UI Verification', (WidgetTester tester) async {
    // Wrap in mockNetworkImages to handle the Image.network widget
    await mockNetworkImagesFor(() async {
      await tester.pumpWidget(const MaterialApp(home: CameraViewport()));

      // Pump to allow animations to settle or at least start
      await tester.pump(const Duration(milliseconds: 500));

      // 1. Verify "Gemini Vision Active" badge
      expect(find.text('GEMINI VISION ACTIVE'), findsOneWidget);

      // 2. Verify "Detected Language" badge
      expect(find.text('BIM (MY)'), findsOneWidget);

      // 3. Check for the presence of the Header icons (Hand Waving, Gear)
      expect(find.byIcon(PhosphorIcons.handWaving()), findsOneWidget);
      expect(find.byIcon(PhosphorIcons.gear()), findsOneWidget);

      // Optional: Verify "Camera Feed Offline" if image fails (though mock should handle success or empty)
      // Since we are mocking network images, it usually returns a transparent image, so error builder might not trigger.
      // But we can check that no error text is visible if successful mock.
      // expect(find.text('Camera Feed Offline'), findsNothing);
    });
  });
}
