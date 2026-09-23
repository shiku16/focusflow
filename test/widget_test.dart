// This is a basic Flutter widget test for FocusFlow.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:focusflow/app_persistence.dart';
import 'package:focusflow/app_state.dart';
import 'package:focusflow/main.dart';

void main() {
  // Keep the whole E2E run on an in-memory store: no real disk I/O in tests.
  setUp(() {
    FocusFlowAppState.setDefaultPersistenceForTesting(InMemoryPersistence());
  });

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

    // Complete the first task; progress count and percentage must update.
    await tester.scrollUntilVisible(find.byType(Checkbox).first, 100);
    await tester.pump();
    await tester.tap(find.byType(Checkbox).first);
    await tester.pump();
    expect(find.text('1 of 4 tasks completed'), findsOneWidget);
    expect(find.text('25%'), findsOneWidget);

    // Navigate to Planner via the bottom navigation.
    await tester.tap(find.text('Planner'));
    await tester.pump();
    expect(find.text('Your weekly study overview'), findsOneWidget);
    expect(find.text('Weekly Overview'), findsOneWidget);

    // Select Friday; the day name and task list must update.
    await tester.tap(find.text('F'));
    await tester.pump();
    expect(find.text('Friday · Tasks'), findsOneWidget);

    // Navigate to Profile.
    await tester.tap(find.text('Profile'));
    await tester.pump();
    expect(find.text('Your goals & settings'), findsOneWidget);
    expect(find.text('Exam Goal'), findsOneWidget);

    // Back to Home.
    await tester.tap(find.text('Home'));
    await tester.pump();
    expect(find.text("Today's Plan"), findsOneWidget);

    // The completed task and progress persist after navigating away.
    expect(find.text('1 of 4 tasks completed'), findsOneWidget);
    expect(find.text('25%'), findsOneWidget);

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

    // Navigate to Focus and exercise the countdown timer.
    await tester.tap(find.text('Focus'));
    await tester.pump();
    expect(find.text('Focus Session'), findsOneWidget);
    expect(find.text('25:00'), findsOneWidget);

    // Start the countdown.
    await tester.tap(find.text('Start'));
    await tester.pump();
    expect(find.text('Session in progress'), findsOneWidget);
    await tester.pump(const Duration(seconds: 1));
    expect(find.text('24:59'), findsOneWidget);

    // Navigate away; the timer keeps running in the shared app state.
    await tester.tap(find.text('Planner'));
    await tester.pump();
    expect(find.text('Your weekly study overview'), findsOneWidget);
    await tester.pump(const Duration(seconds: 2));

    // Return to Focus: remaining time kept counting, not reset.
    await tester.tap(find.text('Focus'));
    await tester.pump();
    expect(find.text('Focus Session'), findsOneWidget);
    expect(find.text('Session in progress'), findsOneWidget);
    expect(find.text('24:57'), findsOneWidget);

    // Pause, then verify the paused state survives navigation too.
    await tester.tap(find.text('Pause'));
    await tester.pump();
    expect(find.text('Session paused'), findsOneWidget);
    await tester.pump(const Duration(seconds: 2));
    expect(find.text('24:57'), findsOneWidget);
    await tester.tap(find.text('Profile'));
    await tester.pump();
    await tester.tap(find.text('Focus'));
    await tester.pump();
    expect(find.text('Session paused'), findsOneWidget);
    expect(find.text('24:57'), findsOneWidget);

    // Resume continues the countdown, then End Session resets to idle.
    await tester.tap(find.text('Resume'));
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));
    expect(find.text('24:56'), findsOneWidget);

    await tester.tap(find.text('End Session'));
    await tester.pump();
    expect(find.text('Session ready'), findsOneWidget);
    expect(find.text('25:00'), findsOneWidget);
  });
}
