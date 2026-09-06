import 'package:flutter/material.dart';

/// A full-width, tappable quick-action card shown on the Home screen.
///
/// [accent] cards use the primary color for emphasis (e.g. "Start Focus");
/// regular cards use a subtle surface tone.
class QuickActionCard extends StatelessWidget {
  /// Creates a quick-action card.
  const QuickActionCard({
    super.key,
    required this.icon,
    required this.label,
    this.subtitle,
    required this.onTap,
    this.accent = false,
  });

  /// The leading icon.
  final IconData icon;

  /// The card title.
  final String label;

  /// An optional short description under the title.
  final String? subtitle;

  /// Invoked when the card is tapped.
  final VoidCallback onTap;

  /// When true, renders with the primary color for emphasis.
  final bool accent;

  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = Theme.of(context).colorScheme;
    final Color foreground = accent ? scheme.onPrimary : scheme.primary;
    final Color chipColor = accent
        ? Colors.white12
        : scheme.primaryContainer;
    return Card(
      elevation: accent ? 1 : 0,
      color: accent ? scheme.primary : scheme.surfaceContainerHigh,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(18)),
      ),
      child: GestureDetector(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 18, 16, 18),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Row(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: chipColor,
                      borderRadius: BorderRadius.all(Radius.circular(12)),
                    ),
                    child: Center(
                      child: Icon(icon, color: foreground, size: 22),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        label,
                        style: TextStyle(
                          color: accent ? scheme.onPrimary : scheme.onSurface,
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      if (subtitle != null)
                        Padding(
                          padding: const EdgeInsets.only(top: 3),
                          child: Text(
                            subtitle!,
                            style: TextStyle(
                              color: accent
                                  ? Colors.white70
                                  : scheme.onSurfaceVariant,
                              fontSize: 13,
                            ),
                          ),
                        ),
                    ],
                  ),
                ],
              ),
              Icon(
                Icons.arrow_forward,
                color: accent ? Colors.white70 : scheme.outline,
                size: 18,
              ),
            ],
          ),
        ),
      ),
    );
  }
}