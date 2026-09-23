import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';

import 'app_persistence.dart';
import 'study_task.dart';

/// Session-scoped application state shared across FocusFlow screens.
///
/// The shell owns one instance per app run and injects it into the screens.
/// Screens read and write through this object instead of keeping independent
/// copies, and the same data is persisted locally so it survives an app
/// restart for the relevant date.
///
/// Persistence is handled by [FocusFlowPersistence] (backed by
/// `shared_preferences` in production, an in-memory store in tests). No
/// backend, accounts or databases are involved.
class FocusFlowAppState extends ChangeNotifier {
  /// Creates the shared app state, optionally with a specific [persistence].
  ///
  /// When [persistence] is omitted the current default (see
  /// [defaultPersistence]) is used, which is `shared_preferences` in the real
  /// app and can be replaced for testing.
  FocusFlowAppState({FocusFlowPersistence? persistence})
    : _persistence = persistence ?? defaultPersistence;

  final FocusFlowPersistence _persistence;

  static FocusFlowPersistence? _defaultPersistence;

  /// The persistence used when a state is created without an explicit store.
  static FocusFlowPersistence get defaultPersistence =>
      _defaultPersistence ??= SharedPreferencesPersistence();

  /// Overrides [defaultPersistence], mainly for tests.
  static void setDefaultPersistenceForTesting(FocusFlowPersistence value) {
    _defaultPersistence = value;
  }

  /// Formats a [date] as a stable `YYYY-MM-DD` storage key.
  static String dateKey(DateTime date) {
    return '${date.year.toString().padLeft(4, '0')}-'
        '${date.month.toString().padLeft(2, '0')}-'
        '${date.day.toString().padLeft(2, '0')}';
  }

  // ---------------------------------------------------------------------------
  // Study tasks (shared data model for Home and Planner)
  // ---------------------------------------------------------------------------

  /// All study tasks across dates, in insertion order.
  final List<StudyTask> _tasks = <StudyTask>[];

  /// All tasks scheduled for [date] (local calendar date), preserving order.
  List<StudyTask> tasksForDate(DateTime date) {
    final String key = studyDateKey(date);
    return _tasks
        .where((StudyTask task) => studyDateKey(task.date) == key)
        .toList();
  }

  StudyTask? _taskById(String id) {
    for (final StudyTask task in _tasks) {
      if (task.id == id) {
        return task;
      }
    }
    return null;
  }

  /// Whether the task with [id] is completed.
  bool isTaskCompleted(String id) => _taskById(id)?.completed ?? false;

  /// Marks the task with [id] as completed (or not) and persists the change.
  void setTaskCompleted(String id, bool value) {
    final StudyTask? task = _taskById(id);
    if (task == null || task.completed == value) {
      return;
    }
    task.completed = value;
    unawaited(_saveTasks());
    notifyListeners();
  }

  /// Adds a new study task for [date] and persists the updated plan.
  StudyTask addStudyTask({
    required String subject,
    required String topic,
    required int durationMinutes,
    required DateTime date,
  }) {
    final StudyTask task = StudyTask(
      id: 'task-${DateTime.now().millisecondsSinceEpoch}-${_nextTaskId++}',
      subject: subject,
      topic: topic,
      durationMinutes: durationMinutes,
      date: date,
      completed: false,
    );
    _tasks.add(task);
    unawaited(_saveTasks());
    notifyListeners();
    return task;
  }

  int _nextTaskId = 0;

  /// The number of tasks planned for [date].
  int totalTaskCountFor(DateTime date) => tasksForDate(date).length;

  /// The number of tasks completed for [date].
  int completedTaskCountFor(DateTime date) {
    return tasksForDate(date).where((StudyTask task) => task.completed).length;
  }

  /// Total planned study minutes for [date].
  int totalMinutesFor(DateTime date) {
    int total = 0;
    for (final StudyTask task in tasksForDate(date)) {
      total += task.durationMinutes;
    }
    return total;
  }

  /// Completed study minutes for [date].
  int completedMinutesFor(DateTime date) {
    int total = 0;
    for (final StudyTask task in tasksForDate(date)) {
      if (task.completed) {
        total += task.durationMinutes;
      }
    }
    return total;
  }

  /// The completion percentage (0–100) for [date]; 0 when there are no tasks.
  int progressPercentFor(DateTime date) {
    final int total = totalTaskCountFor(date);
    if (total == 0) {
      return 0;
    }
    return (completedTaskCountFor(date) * 100 / total).round();
  }

  Future<void> _saveTasks() async {
    final List<Map<String, Object?>> json = <Map<String, Object?>>[
      for (final StudyTask task in _tasks) task.toJson(),
    ];
    await _persistence.writeString('study.tasks', jsonEncode(json));
  }

  // ---------------------------------------------------------------------------
  // Focus session
  // ---------------------------------------------------------------------------

  /// The default focus session length.
  static const int totalSeconds = 25 * 60;

  /// Seconds remaining in the current focus session.
  int remainingSeconds = totalSeconds;

  /// True while a focus session is active (running or paused).
  bool focusInSession = false;

  /// True only while the countdown is actually running.
  bool focusRunning = false;

  Timer? _focusTimer;

  /// Starts the countdown; no-op if already running.
  void startFocus() {
    if (focusRunning) {
      return;
    }
    if (remainingSeconds <= 0) {
      remainingSeconds = totalSeconds;
    }
    focusInSession = true;
    focusRunning = true;
    _startTimer();
    unawaited(_saveActiveSession(running: true));
    notifyListeners();
  }

  /// Pauses the countdown, keeping the remaining time.
  void pauseFocus() {
    if (!focusRunning) {
      return;
    }
    _cancelTimer();
    focusRunning = false;
    unawaited(_saveActiveSession(running: false));
    notifyListeners();
  }

  /// Resumes a paused countdown.
  void resumeFocus() {
    if (focusRunning || remainingSeconds <= 0) {
      return;
    }
    focusInSession = true;
    focusRunning = true;
    _startTimer();
    unawaited(_saveActiveSession(running: true));
    notifyListeners();
  }

  /// Ends the session, clears the saved active session and resets to idle.
  void endFocus() {
    _cancelTimer();
    focusInSession = false;
    focusRunning = false;
    remainingSeconds = totalSeconds;
    unawaited(_clearSavedFocusSession());
    notifyListeners();
  }

  void _startTimer() {
    // Guard against duplicate timers.
    _focusTimer?.cancel();
    _focusTimer = Timer.periodic(const Duration(seconds: 1), _onTick);
  }

  void _cancelTimer() {
    _focusTimer?.cancel();
    _focusTimer = null;
  }

  void _onTick(Timer timer) {
    if (remainingSeconds > 0) {
      remainingSeconds -= 1;
    }
    if (remainingSeconds <= 0) {
      remainingSeconds = 0;
      focusRunning = false;
      focusInSession = false;
      _cancelTimer();
    }
    notifyListeners();
  }

  /// Persists the current active session so it can be restored after a
  /// restart. A running session stores its start timestamp so elapsed time
  /// can be recomputed; a paused session stores the frozen remaining time.
  Future<void> _saveActiveSession({required bool running}) async {
    await _persistence.writeBool('focus.active', true);
    await _persistence.writeBool('focus.running', running);
    await _persistence.writeInt('focus.remainingSeconds', remainingSeconds);
    await _persistence.writeInt(
      'focus.startedAt',
      running ? DateTime.now().millisecondsSinceEpoch : 0,
    );
  }

  Future<void> _clearSavedFocusSession() async {
    await _persistence.remove('focus.active');
    await _persistence.remove('focus.running');
    await _persistence.remove('focus.remainingSeconds');
    await _persistence.remove('focus.startedAt');
  }

  // ---------------------------------------------------------------------------
  // Profile (name, exam goal, daily study target)
  // ---------------------------------------------------------------------------

  String userName = 'Udit';
  String examGoal = 'SSC CGL 2027';

  /// The user's daily study target, in minutes.
  int dailyTargetMinutes = 180;

  /// Updates the profile preferences and persists the changes.
  void setProfile({String? name, String? examGoal, int? dailyTargetMinutes}) {
    var changed = false;
    if (name != null && name != userName) {
      userName = name;
      changed = true;
    }
    if (examGoal != null && examGoal != this.examGoal) {
      this.examGoal = examGoal;
      changed = true;
    }
    if (dailyTargetMinutes != null &&
        dailyTargetMinutes != this.dailyTargetMinutes) {
      this.dailyTargetMinutes = dailyTargetMinutes;
      changed = true;
    }
    if (!changed) {
      return;
    }
    unawaited(_saveProfile());
    notifyListeners();
  }

  /// Formats [minutes] as a short human-readable duration, e.g. "3 hrs".
  static String formatMinutes(int minutes) {
    final int hours = minutes ~/ 60;
    final int remainder = minutes % 60;
    if (hours > 0 && remainder > 0) {
      return '$hours h $remainder min';
    }
    if (hours > 0) {
      return '$hours hr${hours == 1 ? '' : 's'}';
    }
    return '$remainder min';
  }

  Future<void> _saveProfile() async {
    await _persistence.writeString('profile.name', userName);
    await _persistence.writeString('profile.examGoal', examGoal);
    await _persistence.writeInt(
      'profile.dailyTargetMinutes',
      dailyTargetMinutes,
    );
  }

  // ---------------------------------------------------------------------------
  // Startup / restoration
  // ---------------------------------------------------------------------------

  /// Loads persisted state into this instance.
  ///
  /// Study tasks are loaded across all dates. If no saved plan exists yet,
  /// today's default plan is seeded, and legacy Day 4 completion blobs
  /// (`tasks.<date>` boolean lists) are migrated into those default tasks.
  /// After a running focus session is restored, the countdown resumes
  /// automatically; if it already expired while the app was closed, it
  /// restores idle. A paused session restores paused.
  Future<void> restore() async {
    // Study tasks.
    final String? tasksBlob = await _persistence.readString('study.tasks');
    if (tasksBlob != null) {
      try {
        final dynamic decoded = jsonDecode(tasksBlob);
        if (decoded is List) {
          final List list = decoded;
          for (final dynamic entry in list) {
            if (entry is Map) {
              final Map<String, Object?> map = entry.cast<String, Object?>();
              _tasks.add(StudyTask.fromJson(map));
            }
          }
        }
      } on FormatException {
        // Fall through to seeding the default plan.
      }
    }
    final DateTime today = DateTime.now();
    if (_tasks.isEmpty) {
      final String? legacyBlob = await _persistence.readString(
        'tasks.${studyDateKey(today)}',
      );
      _seedDefaultTasks(today, _readLegacyCompletion(legacyBlob));
    }

    // Focus session.
    final bool active = await _persistence.readBool('focus.active') ?? false;
    if (active) {
      final bool wasRunning =
          await _persistence.readBool('focus.running') ?? false;
      final int savedRemaining =
          await _persistence.readInt('focus.remainingSeconds') ?? totalSeconds;
      if (wasRunning) {
        final int startedAt =
            await _persistence.readInt('focus.startedAt') ?? 0;
        final int elapsedMilliseconds =
            DateTime.now().millisecondsSinceEpoch - startedAt;
        final int elapsedSeconds = elapsedMilliseconds < 0
            ? 0
            : elapsedMilliseconds ~/ 1000;
        final int restored = savedRemaining - elapsedSeconds;
        if (restored > 0) {
          remainingSeconds = restored > totalSeconds ? totalSeconds : restored;
          focusInSession = true;
          focusRunning = true;
          _startTimer();
        } else {
          // The session expired while the app was closed.
          remainingSeconds = totalSeconds;
          focusInSession = false;
          focusRunning = false;
          unawaited(_clearSavedFocusSession());
        }
      } else {
        // A paused session is restored paused with its remaining time.
        remainingSeconds = savedRemaining > 0 ? savedRemaining : totalSeconds;
        focusInSession = true;
        focusRunning = false;
      }
    }

    userName = await _persistence.readString('profile.name') ?? userName;
    examGoal = await _persistence.readString('profile.examGoal') ?? examGoal;
    dailyTargetMinutes =
        await _persistence.readInt('profile.dailyTargetMinutes') ??
        dailyTargetMinutes;

    notifyListeners();
  }

  /// Seeds today's default plan (used on first launch, before any saved plan).
  void _seedDefaultTasks(DateTime today, List<bool> legacyCompletion) {
    const List<String> subjects = <String>[
      'Quantitative Aptitude',
      'Reasoning',
      'English',
      'General Awareness',
    ];
    const List<String> topics = <String>[
      'Percentages',
      'Coding Decoding',
      'Vocabulary',
      'Current Affairs',
    ];
    const List<int> durations = <int>[45, 40, 30, 30];
    for (int i = 0; i < subjects.length; i++) {
      _tasks.add(
        StudyTask(
          id: 'seed-$i',
          subject: subjects[i],
          topic: topics[i],
          durationMinutes: durations[i],
          date: DateTime(today.year, today.month, today.day),
          completed: legacyCompletion.length > i && legacyCompletion[i],
        ),
      );
    }
    unawaited(_saveTasks());
  }

  /// Parses a legacy Day 4 completion blob (list of booleans).
  List<bool> _readLegacyCompletion(String? blob) {
    final List<bool> result = <bool>[];
    if (blob == null) {
      return result;
    }
    try {
      final dynamic decoded = jsonDecode(blob);
      if (decoded is List) {
        final List list = decoded;
        for (final dynamic entry in list) {
          result.add(entry == true);
        }
      }
    } on FormatException {
      // Ignore malformed legacy data.
    }
    return result;
  }

  @override
  void dispose() {
    _cancelTimer();
    super.dispose();
  }
}
