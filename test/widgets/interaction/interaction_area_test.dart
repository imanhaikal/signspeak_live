import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:signspeak_live/widgets/interaction/interaction_area.dart';

void main() {
  testWidgets('InteractionArea UI Verification and Callback', (
    WidgetTester tester,
  ) async {
    bool flipCallbackTriggered = false;

    // Wrap in MaterialApp to provide necessary Material context
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: InteractionArea(
            onFlipCamera: () {
              flipCallbackTriggered = true;
            },
          ),
        ),
      ),
    );

    // Pump to settle animations (e.g. mic pulse)
    await tester.pump(const Duration(seconds: 2));

    // 1. Verify Chat history messages (User and Staff)
    expect(find.textContaining('renew my identification card'), findsOneWidget);
    expect(find.textContaining('I can help with that'), findsOneWidget);

    // 2. Verify Control buttons (Mic, Keyboard, Flip Camera/Refresh)
    expect(find.byIcon(PhosphorIcons.keyboard()), findsOneWidget);
    expect(
      find.byIcon(PhosphorIcons.microphone(PhosphorIconsStyle.fill)),
      findsOneWidget,
    );
    expect(find.byIcon(PhosphorIcons.arrowsClockwise()), findsOneWidget);

    // 3. Verify "Tap and hold to speak" text
    expect(find.text('Tap and hold to speak'), findsOneWidget);

    // 4. Verify Flip Camera Callback
    final flipButton = find.byIcon(PhosphorIcons.arrowsClockwise());
    await tester.tap(flipButton);
    await tester.pump();

    expect(flipCallbackTriggered, isTrue);
  });
}
