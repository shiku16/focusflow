import 'package:flutter_test/flutter_test.dart';

import 'package:focusflow/app_persistence.dart';
import 'package:focusflow/app_state.dart';
import 'package:focusflow/study_task.dart';

void main() {
  testWidgets('default plan is seeded on first launch', (
    WidgetTester tester,
  ) async {
    final store = InMemoryPersistence();
    final state = FocusFlowAppState(persistence: store);
    await state.restore();

    expect(state.totalTaskCountFor(DateTime.now()), 4);
    expect(state.completedTaskCountFor(DateTime.now()), 0);

    state.dispose();
  });

  testWidgets('study task creation persists across a reload', (
    WidgetTester tester,
  ) async {
    final store = InMemoryPersistence();
    final date = DateTime(2026, 9, 19);
    final state = FocusFlowAppState(persistence: store);
    await state.restore();

    final StudyTask added = state.addStudyTask(
      subject: 'Reasoning',
      topic: 'Puzzles',
      durationMinutes: 40,
      date: date,
    );

    final reloaded = FocusFlowAppState(persistence: store);
    await reloaded.restore();
    final List<StudyTask> tasks = reloaded.tasksForDate(date);
    expect(tasks.length, 1);
    expect(tasks.first.id, added.id);
    expect(tasks.first.topic, 'Puzzles');
    expect(tasks.first.durationMinutes, 40);

    state.dispose();
    reloaded.dispose();
  });

  testWidgets('invalid study task input is rejected', (
    WidgetTester tester,
  ) async {
    final date = DateTime(2026, 9, 19);
    expect(
      () => StudyTask(
        id: 'a',
        subject: 'Reasoning',
        topic: '   ',
        durationMinutes: 40,
        date: date,
        completed: false,
      ),
      throwsArgumentError,
    );
    expect(
      () => StudyTask(
        id: 'b',
        subject: 'Reasoning',
        topic: 'Puzzles',
        durationMinutes: 0,
        date: date,
        completed: false,
      ),
      throwsArgumentError,
    );
    expect(
      () => StudyTask(
        id: 'c',
        subject: '',
        topic: 'Puzzles',
        durationMinutes: 40,
        date: date,
        completed: false,
      ),
      throwsArgumentError,
    );
  });

  testWidgets('task completion updates progress and persists', (
    WidgetTester tester,
  ) async {
    final store = InMemoryPersistence();
    final date = DateTime(2026, 9, 21);
    final state = FocusFlowAppState(persistence: store);
    await state.restore();

    final StudyTask t1 = state.addStudyTask(
      subject: 'English',
      topic: 'Grammar',
      durationMinutes: 30,
      date: date,
    );
    state.addStudyTask(
      subject: 'Reasoning',
      topic: 'Syllogisms',
      durationMinutes: 25,
      date: date,
    );

    expect(state.totalTaskCountFor(date), 2);
    expect(state.totalMinutesFor(date), 55);
    expect(state.completedTaskCountFor(date), 0);
    expect(state.progressPercentFor(date), 0);

    state.setTaskCompleted(t1.id, true);
    expect(state.completedTaskCountFor(date), 1);
    expect(state.progressPercentFor(date), 50);
    expect(state.completedMinutesFor(date), 30);

    // Unchecking updates progress too.
    state.setTaskCompleted(t1.id, false);
    expect(state.completedTaskCountFor(date), 0);

    // Reload keeps the latest completion.
    state.setTaskCompleted(t1.id, true);
    final reloaded = FocusFlowAppState(persistence: store);
    await reloaded.restore();
    expect(reloaded.isTaskCompleted(t1.id), isTrue);
    expect(reloaded.completedTaskCountFor(date), 1);

    state.dispose();
    reloaded.dispose();
  });
  testWidgets('completion and tasks do not leak across dates', (
    WidgetTester tester,
  ) async {
    final store = InMemoryPersistence();
    final day1 = DateTime(2026, 9, 19);
    final day2 = DateTime(2026, 9, 20);
    final state = FocusFlowAppState(persistence: store);
    await state.restore();

    final StudyTask task = state.addStudyTask(
      subject: 'English',
      topic: 'Vocabulary',
      durationMinutes: 30,
      date: day1,
    );
    state.setTaskCompleted(task.id, true);

    expect(state.tasksForDate(day2), isEmpty);
    expect(state.completedTaskCountFor(day2), 0);

    final reloaded = FocusFlowAppState(persistence: store);
    await reloaded.restore();
    expect(reloaded.tasksForDate(day2), isEmpty);
    expect(reloaded.tasksForDate(day1).length, 1);

    state.dispose();
    reloaded.dispose();
  });

  testWidgets('legacy Day 4 completion migrates into the default plan', (
    WidgetTester tester,
  ) async {
    final today = DateTime.now();
    final store = InMemoryPersistence();
    await store.writeString(
      'tasks.${studyDateKey(today)}',
      '[true,false,true,false]',
    );

    final state = FocusFlowAppState(persistence: store);
    await state.restore();

    final List<StudyTask> tasks = state.tasksForDate(today);
    expect(tasks.length, 4);
    expect(tasks[0].completed, isTrue);
    expect(tasks[1].completed, isFalse);
    expect(tasks[2].completed, isTrue);
    expect(state.completedTaskCountFor(today), 2);

    state.dispose();
  });

  testWidgets('profile edits persist across a reload', (
    WidgetTester tester,
  ) async {
    final store = InMemoryPersistence();
    final state = FocusFlowAppState(persistence: store);
    await state.restore();

    state.setProfile(
      name: 'Priya',
      examGoal: 'UPSC CSE 2028',
      dailyTargetMinutes: 240,
    );
    expect(state.dailyTargetMinutes, 240);
    expect(FocusFlowAppState.formatMinutes(240), '4 hrs');

    final reloaded = FocusFlowAppState(persistence: store);
    await reloaded.restore();
    expect(reloaded.userName, 'Priya');
    expect(reloaded.examGoal, 'UPSC CSE 2028');
    expect(reloaded.dailyTargetMinutes, 240);

    state.dispose();
    reloaded.dispose();
  });
  testWidgets('running focus session is restored with elapsed time', (
    WidgetTester tester,
  ) async {
    final now = DateTime.now();
    final store = InMemoryPersistence();
    await store.writeBool('focus.active', true);
    await store.writeBool('focus.running', true);
    await store.writeInt('focus.remainingSeconds', 1500);
    // The session was still running 30 seconds before "shutdown".
    await store.writeInt('focus.startedAt', now.millisecondsSinceEpoch - 30000);

    final state = FocusFlowAppState(persistence: store);
    await state.restore();

    expect(state.focusInSession, isTrue);
    expect(state.focusRunning, isTrue);
    expect(state.remainingSeconds, 1470);

    state.dispose();
  });

  testWidgets('expired focus session restores to idle', (
    WidgetTester tester,
  ) async {
    final now = DateTime.now();
    final store = InMemoryPersistence();
    await store.writeBool('focus.active', true);
    await store.writeBool('focus.running', true);
    await store.writeInt('focus.remainingSeconds', 120);
    // Expired: it started more than two minutes ago.
    await store.writeInt(
      'focus.startedAt',
      now.millisecondsSinceEpoch - 500000,
    );

    final state = FocusFlowAppState(persistence: store);
    await state.restore();

    expect(state.focusInSession, isFalse);
    expect(state.focusRunning, isFalse);
    expect(state.remainingSeconds, FocusFlowAppState.totalSeconds);

    // The saved active session was cleared by the restore.
    final reloaded = FocusFlowAppState(persistence: store);
    await reloaded.restore();
    expect(reloaded.focusInSession, isFalse);

    state.dispose();
    reloaded.dispose();
  });

  testWidgets('paused session restores paused with remaining time', (
    WidgetTester tester,
  ) async {
    final store = InMemoryPersistence();
    await store.writeBool('focus.active', true);
    await store.writeBool('focus.running', false);
    await store.writeInt('focus.remainingSeconds', 900);

    final state = FocusFlowAppState(persistence: store);
    await state.restore();

    expect(state.focusInSession, isTrue);
    expect(state.focusRunning, isFalse);
    expect(state.remainingSeconds, 900);

    state.dispose();
  });

  testWidgets('End Session clears the persisted active session', (
    WidgetTester tester,
  ) async {
    final store = InMemoryPersistence();
    await store.writeBool('focus.active', true);
    await store.writeBool('focus.running', false);
    await store.writeInt('focus.remainingSeconds', 600);

    final state = FocusFlowAppState(persistence: store);
    await state.restore();
    expect(state.focusInSession, isTrue);

    state.endFocus();
    expect(state.focusInSession, isFalse);

    final reloaded = FocusFlowAppState(persistence: store);
    await reloaded.restore();
    expect(reloaded.focusInSession, isFalse);
    expect(reloaded.remainingSeconds, FocusFlowAppState.totalSeconds);

    state.dispose();
    reloaded.dispose();
  });
}
