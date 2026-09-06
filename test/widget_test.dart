// This is a basic Flutter widget test for FocusFlow.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter_test/flutter_test.dart';

import 'package:focusflow/main.dart';

void main() {
  testWidgets('FocusFlow home renders and navigates', (WidgetTester tester) async {
    // Build the FocusFlow app and trigger a frame.
    await tester.pumpWidget(const FocusFlowApp());
    await tester.pump();

    // The Home dashboard shows the greeting and the day's plan.
    expect(find.text('Good morning, Udit 👋'), findsOneWidget);
    expect(find.text("Today's Plan"), findsOneWidget);
    expect(find.text('245'), findsOneWidget);

    // Navigate to the Focus screen via the bottom navigation.
    expect(find.text('Focus'), findsOneWidget);
    await tester.tap(find.text('Focus'));
    await tester.pump();

    expect(find.text('Focus Session'), findsOneWidget);

    // Start a focus session.
    await tester.tap(find.text('Start'));
    await tester.pump();

    expect(find.text('Session in progress'), findsOneWidget);
  });
}
