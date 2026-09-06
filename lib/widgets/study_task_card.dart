import 'package:flutter/material.dart';

/// A single row in the "Today's Plan" list with a completion checkbox.
///
/// The parent screen owns the checked state; this card calls [onChanged] with
/// the new value and simply reflects [completed] in its visuals (checkbox,
/// strikethrough, muted color).
class StudyTaskCard extends StatelessWidget {
  /// Creates a study task row.
  const StudyTaskCard({
    super.key,
    required this.subject,
    required this.topic,
    required this.duration,
    required this.completed,
    required this.onChanged,
  });

  /// The subject area, e.g. "Quantitative Aptitude".
  final String subject;

  /// The specific topic, e.g. "Percentages".
  final String topic;

  /// A human-readable duration, e.g. "45 min".
  final String duration;

  /// Whether the task is currently marked done.
  final bool completed;

  /// Called with the new checked value when the user taps the checkbox.
  final void Function(bool) onChanged;

  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = Theme.of(context).colorScheme;
    return Card.filled(
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(18)),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(8, 8, 14, 8),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Checkbox(
              value: completed,
              onChanged: (bool? newValue) => onChanged(newValue ?? false),
            ),
            const SizedBox(width: 12),
            Flexible(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    topic,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: completed
                          ? scheme.onSurfaceVariant
                          : scheme.onSurface,
                      decoration: completed
                          ? TextDecoration.lineThrough
                          : TextDecoration.none,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      Icon(
                        Icons.schedule,
                        color: scheme.onSurfaceVariant,
                        size: 14,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        '$subject · $duration',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 12.5,
                          color: scheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            if (completed)
              Padding(
                padding: const EdgeInsets.fromLTRB(0, 0, 4, 0),
                child: Card(
                  margin: EdgeInsets.zero,
                  color: scheme.primaryContainer,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(Radius.circular(10)),
                  ),
                  child: Icon(
                    Icons.check_circle,
                    color: scheme.primary,
                    size: 18,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}