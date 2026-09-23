import 'package:flutter/material.dart';

import '../app_state.dart';
import '../focus_page.dart';
import '../study_task.dart';
import '../theme/app_theme.dart';
import '../widgets/exam_countdown_card.dart';
import '../widgets/quick_action_card.dart';
import '../widgets/study_task_card.dart';
import '../widgets/today_progress_card.dart';

/// The Home dashboard: greeting, exam countdown, today's progress and plan,
/// and quick actions for the rest of the app.
class HomeScreen extends StatefulWidget {
  /// Creates the Home screen.
  ///
  /// [onNavigate] routes the user to another [FocusPage]; [appState] is the
  /// shared session state this screen reads and writes.
  const HomeScreen({
    super.key,
    required this.onNavigate,
    required this.appState,
  });

  /// Called to switch to another page, e.g. from a quick action.
  final void Function(FocusPage) onNavigate;

  /// The shared session state (today's tasks, focus session).
  final FocusFlowAppState appState;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _topicInput = TextEditingController();
  final TextEditingController _durationInput = TextEditingController();
  String? _newSubject;
  DateTime _newDate = DateTime.now();
  bool _addingTask = false;
  String? _formError;

  static const List<String> _dateLetters = <String>[
    'M',
    'T',
    'W',
    'T',
    'F',
    'S',
    'S',
  ];

  DateTime get _today => DateTime.now();

  DateTime _weekDateFor(int index) =>
      mondayOfWeek(_today).add(Duration(days: index));

  @override
  void initState() {
    super.initState();
    widget.appState.addListener(_onAppStateChanged);
  }

  @override
  void dispose() {
    widget.appState.removeListener(_onAppStateChanged);
    super.dispose();
  }

  void _onAppStateChanged() {
    if (mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = Theme.of(context).colorScheme;
    final FocusFlowAppState appState = widget.appState;
    final List<StudyTask> tasks = appState.tasksForDate(_today);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        _greeting(context, scheme),
        const SizedBox(height: 24),
        const ExamCountdownCard(),
        const SizedBox(height: 16),
        TodayProgressCard(
          completed: appState.completedTaskCountFor(_today),
          total: appState.totalTaskCountFor(_today),
          completedMinutes: appState.completedMinutesFor(_today),
          totalMinutes: appState.totalMinutesFor(_today),
        ),
        const SizedBox(height: 28),
        _sectionTitle(context, "Today's Plan"),
        const SizedBox(height: 14),
        if (tasks.isEmpty)
          _emptyPlanCard(context, scheme)
        else
          for (int i = 0; i < tasks.length; i++)
            Padding(
              padding: EdgeInsets.only(bottom: i + 1 == tasks.length ? 0 : 10),
              child: StudyTaskCard(
                subject: tasks[i].subject,
                topic: tasks[i].topic,
                duration: '${tasks[i].durationMinutes} min',
                completed: tasks[i].completed,
                onChanged: (bool value) =>
                    appState.setTaskCompleted(tasks[i].id, value),
              ),
            ),
        const SizedBox(height: 10),
        if (_addingTask)
          _addTaskForm(context, scheme)
        else
          _addTaskButton(context, scheme),
        const SizedBox(height: 28),
        _sectionTitle(context, 'Quick Actions'),
        const SizedBox(height: 16),
        Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Padding(
              padding: EdgeInsets.only(bottom: 10),
              child: QuickActionCard(
                icon: Icons.play_arrow,
                label: 'Start Focus',
                subtitle: '25 min of deep work',
                accent: true,
                onTap: () => widget.onNavigate(FocusPage.focus),
              ),
            ),
            Padding(
              padding: EdgeInsets.only(bottom: 10),
              child: QuickActionCard(
                icon: Icons.psychology,
                label: 'Ask AI Coach',
                subtitle: 'Plan, recover, or quiz me',
                onTap: () => widget.onNavigate(FocusPage.coach),
              ),
            ),
            QuickActionCard(
              icon: Icons.calendar_month,
              label: 'View Planner',
              subtitle: 'Your weekly overview',
              onTap: () => widget.onNavigate(FocusPage.planner),
            ),
          ],
        ),
      ],
    );
  }

  Widget _greeting(BuildContext context, ColorScheme scheme) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Container(
          width: 52,
          height: 52,
          decoration: BoxDecoration(
            color: scheme.primary,
            borderRadius: BorderRadius.all(Radius.circular(26)),
          ),
          child: Center(
            child: Text(
              widget.appState.userName.substring(0, 1).toUpperCase(),
              style: TextStyle(
                color: scheme.onPrimary,
                fontSize: 22,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ),
        const SizedBox(width: 16),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              'Good morning, ${widget.appState.userName} 👋',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: scheme.onSurface,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 5),
            Text(
              "Let's make today count.",
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: scheme.onSurfaceVariant,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _sectionTitle(BuildContext context, String title) {
    return Text(
      title,
      style: Theme.of(context).textTheme.titleLarge?.copyWith(
        color: Theme.of(context).colorScheme.onSurface,
      ),
    );
  }

  Widget _emptyPlanCard(BuildContext context, ColorScheme scheme) {
    return Card.filled(
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(FocusFlowTheme.radiusM),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 18, 16, 18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              'No tasks yet for today',
              style: TextStyle(
                color: scheme.onSurface,
                fontSize: 15,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Add a study task below to get started.',
              style: TextStyle(color: scheme.onSurfaceVariant, fontSize: 13),
            ),
          ],
        ),
      ),
    );
  }

  Widget _addTaskButton(BuildContext context, ColorScheme scheme) {
    return TextButton.icon(
      icon: Icon(Icons.add, color: scheme.primary, size: 18),
      label: Text(
        'Add Study Task',
        style: TextStyle(color: scheme.primary, fontWeight: FontWeight.w600),
      ),
      onPressed: () {
        setState(() {
          _addingTask = true;
          _formError = null;
        });
      },
    );
  }

  Widget _addTaskForm(BuildContext context, ColorScheme scheme) {
    return Card.filled(
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(FocusFlowTheme.radiusM),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Text(
                  'Add Study Task',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: scheme.onSurface,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                TextButton(
                  onPressed: _cancelAddTask,
                  child: const Text('Cancel'),
                ),
              ],
            ),
            const SizedBox(height: 10),
            _formCaption(context, 'Subject'),
            const SizedBox(height: 8),
            _subjectPicker(context, scheme),
            const SizedBox(height: 12),
            TextField(
              controller: _topicInput,
              maxLines: 1,
              decoration: const InputDecoration(
                hintText: 'Topic, e.g. Percentages',
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _durationInput,
              maxLines: 1,
              decoration: const InputDecoration(
                hintText: 'Duration in minutes',
              ),
            ),
            const SizedBox(height: 12),
            _formCaption(context, 'Date'),
            const SizedBox(height: 8),
            Row(
              children: <Widget>[
                for (int i = 0; i < _dateLetters.length; i++)
                  Flexible(child: _addDatePill(context, scheme, i)),
              ],
            ),
            if (_formError != null)
              Padding(
                padding: const EdgeInsets.only(top: 10),
                child: Text(
                  _formError!,
                  style: TextStyle(
                    color: scheme.error,
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            const SizedBox(height: 14),
            FilledButton(
              onPressed: _saveNewTask,
              child: const Text(
                'Save Task',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _formCaption(BuildContext context, String label) {
    return Text(
      label,
      style: Theme.of(context).textTheme.labelLarge?.copyWith(
        color: Theme.of(context).colorScheme.onSurfaceVariant,
      ),
    );
  }

  Widget _subjectPicker(BuildContext context, ColorScheme scheme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        Row(
          children: <Widget>[
            for (int i = 0; i < 2; i++)
              Flexible(child: _subjectPill(context, scheme, studySubjects[i])),
          ],
        ),
        const SizedBox(height: 6),
        Row(
          children: <Widget>[
            for (int i = 2; i < studySubjects.length; i++)
              Flexible(child: _subjectPill(context, scheme, studySubjects[i])),
          ],
        ),
      ],
    );
  }

  Widget _subjectPill(
    BuildContext context,
    ColorScheme scheme,
    String subject,
  ) {
    final bool selected = subject == _newSubject;
    return SizedBox(
      height: 38,
      child: GestureDetector(
        onTap: selected
            ? null
            : () {
                setState(() {
                  _newSubject = subject;
                  _formError = null;
                });
              },
        child: ClipRRect(
          borderRadius: BorderRadius.all(FocusFlowTheme.radiusS),
          child: ColoredBox(
            color: selected
                ? scheme.primaryContainer
                : scheme.surfaceContainerLow,
            child: Center(
              child: Text(
                subject,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: selected
                      ? scheme.onPrimaryContainer
                      : scheme.onSurface,
                  fontSize: 12.5,
                  fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _addDatePill(BuildContext context, ColorScheme scheme, int index) {
    final DateTime date = _weekDateFor(index);
    final bool selected = studyDateKey(date) == studyDateKey(_newDate);
    return SizedBox(
      height: 34,
      child: GestureDetector(
        onTap: selected
            ? null
            : () {
                setState(() {
                  _newDate = date;
                });
              },
        child: ClipRRect(
          borderRadius: BorderRadius.all(FocusFlowTheme.radiusS),
          child: ColoredBox(
            color: selected ? scheme.primary : Colors.transparent,
            child: Center(
              child: Text(
                _dateLetters[index],
                style: TextStyle(
                  color: selected ? scheme.onPrimary : scheme.onSurface,
                  fontSize: 13,
                  fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _saveNewTask() {
    final String topic = _topicInput.text.trim();
    final String durationText = _durationInput.text.trim();
    final int? duration = int.tryParse(durationText);
    setState(() {
      if (_newSubject == null) {
        _formError = 'Please choose a subject.';
        return;
      }
      if (topic.isEmpty) {
        _formError = 'Topic cannot be empty.';
        return;
      }
      if (duration == null || duration <= 0) {
        _formError = 'Enter a duration greater than zero.';
        return;
      }
      widget.appState.addStudyTask(
        subject: _newSubject!,
        topic: topic,
        durationMinutes: duration,
        date: _newDate,
      );
      _addingTask = false;
      _formError = null;
      _topicInput.clear();
      _durationInput.clear();
      _newSubject = null;
    });
  }

  void _cancelAddTask() {
    setState(() {
      _addingTask = false;
      _formError = null;
      _topicInput.clear();
      _durationInput.clear();
      _newSubject = null;
    });
  }
}
