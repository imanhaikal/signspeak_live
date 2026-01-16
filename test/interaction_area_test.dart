import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:signspeak_live/widgets/interaction/interaction_area.dart';

void main() {
  testWidgets('InteractionArea UI Verification', (WidgetTester tester) async {
    // Wrap in MaterialApp to provide necessary Material context
    await tester.pumpWidget(
      const MaterialApp(home: Scaffold(body: InteractionArea())),
    );

    // Pump to settle animations (e.g. mic pulse)
    await tester.pump(const Duration(seconds: 2));

    // 1. Verify Chat history messages (User and Staff)
    // We look for parts of the text to be robust
    expect(find.textContaining('renew my identification card'), findsOneWidget);
    expect(find.textContaining('I can help with that'), findsOneWidget);

    // 2. Verify Control buttons (Mic, Keyboard, Flip Camera/Refresh)
    // Note: The third icon in code is arrowsClockwise (Flip Camera or Refresh)
    expect(find.byIcon(PhosphorIcons.keyboard()), findsOneWidget);
    expect(
      find.byIcon(PhosphorIcons.microphone(PhosphorIconsStyle.fill)),
      findsOneWidget,
    );
    expect(find.byIcon(PhosphorIcons.arrowsClockwise()), findsOneWidget);

    // 3. Verify "Tap and hold to speak" text
    expect(find.text('Tap and hold to speak'), findsOneWidget);
  });
}
