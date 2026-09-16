import 'package:flutter/material.dart';

import '../focus_page.dart';
import '../widgets/exam_countdown_card.dart';
import '../widgets/quick_action_card.dart';
import '../widgets/study_task_card.dart';
import '../widgets/today_progress_card.dart';

/// The Home dashboard: greeting, exam countdown, today's progress and plan,
/// and quick actions for the rest of the app.
class HomeScreen extends StatefulWidget {
  /// Creates the Home screen.
  ///
  /// [onNavigate] routes the user to another [FocusPage].
  const HomeScreen({super.key, required this.onNavigate});

  /// Called to switch to another page, e.g. from a quick action.
  final void Function(FocusPage) onNavigate;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  /// Today's fixed study plan.
  static const List<_StudyTask> _tasks = <_StudyTask>[
    _StudyTask('Quantitative Aptitude', 'Percentages', '45 min'),
    _StudyTask('Reasoning', 'Coding Decoding', '40 min'),
    _StudyTask('English', 'Vocabulary', '30 min'),
    _StudyTask('General Awareness', 'Current Affairs', '30 min'),
  ];

  /// Whether each task in [_tasks] has been completed.
  final List<bool> _done = <bool>[false, false, false, false];

  void _setDone(int index, bool value) {
    setState(() {
      _done[index] = value;
    });
  }

  int get _completed => _done.where((bool value) => value).length;

  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = Theme.of(context).colorScheme;
    final int completed = _completed;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        _greeting(context, scheme),
        const SizedBox(height: 24),
        const ExamCountdownCard(),
        const SizedBox(height: 16),
        TodayProgressCard(completed: completed, total: _tasks.length),
        const SizedBox(height: 28),
        _sectionTitle(context, "Today's Plan"),
        const SizedBox(height: 14),
        for (int i = 0; i < _tasks.length; i++)
          Padding(
            padding: EdgeInsets.only(bottom: i + 1 == _tasks.length ? 0 : 10),
            child: StudyTaskCard(
              subject: _tasks[i].subject,
              topic: _tasks[i].topic,
              duration: _tasks[i].duration,
              completed: _done[i],
              onChanged: (bool value) => _setDone(i, value),
            ),
          ),
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
              'U',
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
              'Good morning, Udit 👋',
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
}

/// A static description of one study task.
class _StudyTask {
  const _StudyTask(this.subject, this.topic, this.duration);

  final String subject;
  final String topic;
  final String duration;
}
