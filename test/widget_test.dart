// This is a basic Flutter widget test for FocusFlow.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:focusflow/main.dart';

void main() {
  testWidgets('FocusFlow navigates between all screens', (
    WidgetTester tester,
  ) async {
    // Build the FocusFlow app and trigger a frame.
    await tester.pumpWidget(const FocusFlowApp());

    // The branded launch splash is shown first.
    expect(find.text('FocusFlow'), findsOneWidget);

    // Let the brief splash finish and reveal the dashboard.
    await tester.pump(const Duration(milliseconds: 1200));
    await tester.pump();
    expect(find.text('FocusFlow'), findsNothing);

    // The Home dashboard shows the greeting, countdown and plan.
    expect(find.text('Good morning, Udit 👋'), findsOneWidget);
    expect(find.text("Today's Plan"), findsOneWidget);
    expect(find.text('245'), findsOneWidget);
    expect(find.text('0 of 4 tasks completed'), findsOneWidget);

    // Navigate to Planner via the bottom navigation.
    await tester.tap(find.text('Planner'));
    await tester.pump();
    expect(find.text('Your weekly study overview'), findsOneWidget);
    expect(find.text('Weekly Overview'), findsOneWidget);

    // Navigate to Profile.
    await tester.tap(find.text('Profile'));
    await tester.pump();
    expect(find.text('Your goals & settings'), findsOneWidget);
    expect(find.text('Exam Goal'), findsOneWidget);

    // Back to Home.
    await tester.tap(find.text('Home'));
    await tester.pump();
    expect(find.text("Today's Plan"), findsOneWidget);

    // Open the Coach from the Home quick action.
    await tester.scrollUntilVisible(find.text('Ask AI Coach'), 200);
    await tester.pump();
    await tester.tap(find.text('Ask AI Coach'));
    await tester.pump();
    expect(find.text('AI Study Coach'), findsOneWidget);
    expect(find.text('Suggested prompts'), findsOneWidget);

    // Send a suggested prompt and check it is echoed into the thread.
    await tester.tap(find.text('Plan my study day'));
    await tester.pump();
    expect(find.text('Plan my study day'), findsNWidgets(2));

    // Return Home with the back button.
    await tester.tap(find.byIcon(Icons.arrow_back));
    await tester.pump();
    expect(find.text("Today's Plan"), findsOneWidget);

    // Navigate to Focus and toggle a session.
    await tester.tap(find.text('Focus'));
    await tester.pump();
    expect(find.text('Focus Session'), findsOneWidget);

    await tester.tap(find.text('Start'));
    await tester.pump();
    expect(find.text('Session in progress'), findsOneWidget);

    await tester.tap(find.text('End Session'));
    await tester.pump();
    expect(find.text('Session ready'), findsOneWidget);
  });
}
