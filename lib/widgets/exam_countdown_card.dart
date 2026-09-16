import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

/// A premium highlight card showing the user's next big exam and a
/// prominent countdown.
///
/// The card uses the theme's primary color as its background so it stands out
/// at the top of the Home dashboard.
class ExamCountdownCard extends StatelessWidget {
  /// Creates an exam countdown card.
  const ExamCountdownCard({
    super.key,
    this.examName = 'SSC CGL 2027',
    this.daysLeft = 245,
    this.subtitle = 'Your exam is getting closer',
  });

  /// The name of the target exam.
  final String examName;

  /// Days remaining until the exam.
  final int daysLeft;

  /// A short, encouraging subtitle below the exam name.
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = Theme.of(context).colorScheme;
    return Card(
      elevation: 2,
      color: scheme.primary,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(FocusFlowTheme.radiusL),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 22),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: Colors.white12,
                    borderRadius: BorderRadius.all(FocusFlowTheme.radiusS),
                  ),
                  child: Icon(
                    Icons.calendar_month,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 14),
                Flexible(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        examName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: scheme.onPrimary,
                          fontSize: 17,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        subtitle,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(color: Colors.white70, fontSize: 13),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 22),
            Row(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: <Widget>[
                Text(
                  '$daysLeft',
                  style: TextStyle(
                    color: scheme.onPrimary,
                    fontSize: 46,
                    fontWeight: FontWeight.w800,
                    height: 0.9,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(width: 8),
                Padding(
                  padding: const EdgeInsets.only(bottom: 6),
                  child: Text(
                    'days\nto go',
                    textAlign: TextAlign.left,
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      height: 1.1,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18),
            ClipRRect(
              borderRadius: BorderRadius.all(Radius.circular(99)),
              child: LinearProgressIndicator(
                value: 0.18,
                minHeight: 6,
                backgroundColor: Colors.white24,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
