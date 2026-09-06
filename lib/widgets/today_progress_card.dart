import 'package:flutter/material.dart';

/// A soft card summarizing today's study progress.
///
/// Keeps a positive, encouraging tone — it simply reports how much of the
/// day's plan is done without any streak-guilt language.
class TodayProgressCard extends StatelessWidget {
  /// Creates a today-progress card.
  ///
  /// [completed] and [total] drive the percentage and progress bar shown.
  const TodayProgressCard({
    super.key,
    required this.completed,
    required this.total,
  });

  /// Number of study tasks already finished today.
  final int completed;

  /// Total number of study tasks planned for today.
  final int total;

  /// The percentage (0–100) of tasks completed.
  int get percent => total == 0 ? 0 : (completed * 100 / total).round();

  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = Theme.of(context).colorScheme;
    final double progress = total == 0 ? 0 : completed / total;
    return Card.filled(
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(20)),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 18, 20, 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Text(
                  "Today's Progress",
                  style: TextStyle(
                    color: scheme.onSurface,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Text(
                  '$percent%',
                  style: TextStyle(
                    color: scheme.primary,
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              '$completed of $total tasks completed',
              style: TextStyle(
                color: scheme.onSurfaceVariant,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 18),
            ClipRRect(
              borderRadius: BorderRadius.all(Radius.circular(99)),
              child: LinearProgressIndicator(
                value: progress,
                minHeight: 10,
                backgroundColor: scheme.surfaceContainerHighest,
                color: scheme.primary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}