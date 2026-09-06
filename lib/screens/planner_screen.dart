import 'package:flutter/material.dart';

import '../widgets/study_task_card.dart';

/// A polished weekly study overview with a day selector and sample tasks.
///
/// This is a real, interactive screen: tapping a day updates the selected
/// highlight and the tasks shown below.
class PlannerScreen extends StatefulWidget {
  /// Creates the Planner screen.
  const PlannerScreen({super.key});

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

  /// Sample tasks for each day of the week.
  static final List<List<_StudyTask>> _byDay = <List<_StudyTask>>[
    <_StudyTask>[
      _StudyTask('Quantitative Aptitude', 'Percentages', '45 min'),
      _StudyTask('Reasoning', 'Coding Decoding', '40 min'),
      _StudyTask('English', 'Vocabulary', '30 min'),
    ],
    <_StudyTask>[
      _StudyTask('General Awareness', 'Current Affairs', '30 min'),
      _StudyTask('Reasoning', 'Syllogisms', '35 min'),
      _StudyTask('English', 'Idioms & Phrases', '25 min'),
    ],
    <_StudyTask>[
      _StudyTask('Quantitative Aptitude', 'Averages', '40 min'),
      _StudyTask('General Awareness', 'Geography', '30 min'),
    ],
    <_StudyTask>[
      _StudyTask('English', 'Reading Comprehension', '40 min'),
      _StudyTask('Reasoning', 'Blood Relations', '35 min'),
      _StudyTask('Quantitative Aptitude', 'Ratio', '40 min'),
    ],
    <_StudyTask>[
      _StudyTask('General Awareness', 'Polity', '30 min'),
      _StudyTask('English', 'Grammar', '30 min'),
    ],
    <_StudyTask>[
      _StudyTask('Quantitative Aptitude', 'Percentages', '45 min'),
      _StudyTask('Reasoning', 'Puzzles', '40 min'),
    ],
    <_StudyTask>[
      _StudyTask('English', 'Vocabulary Revision', '30 min'),
      _StudyTask('General Awareness', 'Current Affairs', '30 min'),
      _StudyTask('Reasoning', 'Mock Test Review', '45 min'),
    ],
  ];

  void _selectDay(int index) {
    setState(() {
      _selectedDay = index;
    });
  }
@override
  Widget build(BuildContext context) {
    final ColorScheme scheme = Theme.of(context).colorScheme;
    final List<_StudyTask> tasks = _byDay[_selectedDay];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        _header(context, scheme),
        const SizedBox(height: 22),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            for (int i = 0; i < _days.length; i++)
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 2),
                child: _dayPill(context, scheme, i),
              ),
          ],
        ),
        const SizedBox(height: 10),
        Text(
          '${_dayNames[_selectedDay]} · ${tasks.length} tasks planned',
          style: TextStyle(
            color: scheme.onSurfaceVariant,
            fontSize: 13,
          ),
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
                borderRadius: BorderRadius.all(Radius.circular(16)),
              ),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Expanded(
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
        for (int i = 0; i < tasks.length; i++)
          Padding(
            padding: EdgeInsets.only(bottom: i + 1 == tasks.length ? 0 : 10),
            child: StudyTaskCard(
              subject: tasks[i].subject,
              topic: tasks[i].topic,
              duration: tasks[i].duration,
              completed: false,
              onChanged: (bool value) {},
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
          style: TextStyle(
            color: scheme.onSurface,
            fontSize: 26,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Your weekly study overview',
          style: TextStyle(
            color: scheme.onSurfaceVariant,
            fontSize: 15,
          ),
        ),
      ],
    );
  }

  Widget _dayPill(BuildContext context, ColorScheme scheme, int index) {
    final bool selected = index == _selectedDay;
    return GestureDetector(
      onTap: selected ? null : () => _selectDay(index),
      child: SizedBox(
        width: 40,
        height: 40,
        child: ClipRRect(
          borderRadius: BorderRadius.all(Radius.circular(13)),
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

  Widget _sectionTitle(BuildContext context, String title) {
    return Text(
      title,
      style: TextStyle(
        color: Theme.of(context).colorScheme.onSurface,
        fontSize: 18,
        fontWeight: FontWeight.w800,
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

/// A description of a study task used inside the Planner.
class _StudyTask {
  const _StudyTask(this.subject, this.topic, this.duration);

  final String subject;
  final String topic;
  final String duration;
}
