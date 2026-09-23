import 'package:flutter/material.dart';

import '../app_state.dart';
import '../study_task.dart';
import '../theme/app_theme.dart';
import '../widgets/study_task_card.dart';

/// A polished weekly study overview with a day selector and study tasks.
///
/// This is a real, interactive screen: tapping a day updates the selected
/// highlight and the tasks shown below, which come from the shared app state
/// (the same data the Home screen uses).
class PlannerScreen extends StatefulWidget {
  /// Creates the Planner screen.
  ///
  /// [appState] provides the shared study tasks and completion state.
  const PlannerScreen({super.key, required this.appState});

  /// The shared study data.
  final FocusFlowAppState appState;

  @override
  State<PlannerScreen> createState() => _PlannerScreenState();
}

class _PlannerScreenState extends State<PlannerScreen> {
  /// Day letters in order; index 0 = Monday.
  static const List<String> _days = <String>['M', 'T', 'W', 'T', 'F', 'S', 'S'];

  /// Full day names, aligned with [_days].
  static const List<String> _dayNames = <String>[
    'Monday',
    'Tuesday',
    'Wednesday',
    'Thursday',
    'Friday',
    'Saturday',
    'Sunday',
  ];

  int _selectedDay = 0;

  /// Sample subject loads shown as weekly activity bars.
  static const List<_WeekRow> _week = <_WeekRow>[
    _WeekRow('Quantitative Aptitude', 0.8, '6h 00m'),
    _WeekRow('Reasoning', 0.65, '5h 15m'),
    _WeekRow('English', 0.5, '4h 00m'),
    _WeekRow('General Awareness', 0.35, '3h 00m'),
  ];

  DateTime get _today => DateTime.now();

  /// The current week's date for day index 0 (Monday) and beyond.
  DateTime _dateFor(int index) =>
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

  void _selectDay(int index) {
    setState(() {
      _selectedDay = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = Theme.of(context).colorScheme;
    final List<StudyTask> tasks = widget.appState.tasksForDate(
      _dateFor(_selectedDay),
    );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        _header(context, scheme),
        const SizedBox(height: 22),
        Row(
          children: <Widget>[
            for (int i = 0; i < _days.length; i++)
              Flexible(child: _dayPill(context, scheme, i)),
          ],
        ),
        const SizedBox(height: 10),
        Text(
          '${_dayNames[_selectedDay]} · ${tasks.length} tasks planned',
          style: TextStyle(color: scheme.onSurfaceVariant, fontSize: 13),
        ),
        const SizedBox(height: 22),
        _sectionTitle(context, 'Weekly Overview'),
        const SizedBox(height: 14),
        for (final _WeekRow row in _week)
          Padding(
            padding: EdgeInsets.only(bottom: 10),
            child: Card.filled(
              margin: EdgeInsets.zero,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.all(FocusFlowTheme.radiusM),
              ),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Flexible(
                          child: Text(
                            row.subject,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: scheme.onSurface,
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        Text(
                          row.hours,
                          style: TextStyle(
                            color: scheme.onSurfaceVariant,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    ClipRRect(
                      borderRadius: BorderRadius.all(Radius.circular(99)),
                      child: LinearProgressIndicator(
                        value: row.load,
                        minHeight: 8,
                        backgroundColor: scheme.surfaceContainerHighest,
                        color: scheme.primary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        const SizedBox(height: 22),
        _sectionTitle(context, '${_dayNames[_selectedDay]} · Tasks'),
        const SizedBox(height: 14),
        if (tasks.isEmpty)
          _emptyDayCard(context, scheme)
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
                    widget.appState.setTaskCompleted(tasks[i].id, value),
              ),
            ),
      ],
    );
  }

  Widget _header(BuildContext context, ColorScheme scheme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          'Planner',
          style: Theme.of(
            context,
          ).textTheme.headlineMedium?.copyWith(color: scheme.onSurface),
        ),
        const SizedBox(height: 4),
        Text(
          'Your weekly study overview',
          style: Theme.of(
            context,
          ).textTheme.bodyMedium?.copyWith(color: scheme.onSurfaceVariant),
        ),
      ],
    );
  }

  Widget _dayPill(BuildContext context, ColorScheme scheme, int index) {
    final bool selected = index == _selectedDay;
    return GestureDetector(
      onTap: selected ? null : () => _selectDay(index),
      child: SizedBox(
        width: 32,
        height: 32,
        child: ClipRRect(
          borderRadius: BorderRadius.all(FocusFlowTheme.radiusS),
          child: ColoredBox(
            color: selected ? scheme.primary : Colors.transparent,
            child: Center(
              child: Text(
                _days[index],
                style: TextStyle(
                  color: selected ? scheme.onPrimary : scheme.onSurface,
                  fontSize: 15,
                  fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _emptyDayCard(BuildContext context, ColorScheme scheme) {
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
              'No tasks planned for ${_dayNames[_selectedDay]}',
              style: TextStyle(
                color: scheme.onSurface,
                fontSize: 15,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Add tasks from Home to build this day’s plan.',
              style: TextStyle(color: scheme.onSurfaceVariant, fontSize: 13),
            ),
          ],
        ),
      ),
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
}

/// One row in the weekly subject overview.
class _WeekRow {
  const _WeekRow(this.subject, this.load, this.hours);

  final String subject;
  final double load;
  final String hours;
}
