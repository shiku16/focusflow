import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

/// A simple focus-session screen.
///
/// This shows the session UI (timer display, current task, start action)
/// without implementing a full timer engine yet. The Start button toggles a
/// lightweight in-session state so the interaction is real.
class FocusScreen extends StatefulWidget {
  /// Creates the Focus screen.
  const FocusScreen({super.key});

  @override
  State<FocusScreen> createState() => _FocusScreenState();
}

class _FocusScreenState extends State<FocusScreen> {
  bool _inSession = false;

  void _toggleSession() {
    setState(() {
      _inSession = !_inSession;
    });
  }

  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        _header(context, scheme),
        const SizedBox(height: 24),
        Card(
          elevation: 2,
          margin: EdgeInsets.zero,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(FocusFlowTheme.radiusXL),
          ),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 32, 24, 32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Container(
                      width: 12,
                      height: 12,
                      decoration: BoxDecoration(
                        color: _inSession
                            ? scheme.primary
                            : scheme.outlineVariant,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      _inSession ? 'Session in progress' : 'Session ready',
                      style: TextStyle(
                        color: _inSession
                            ? scheme.primary
                            : scheme.onSurfaceVariant,
                        fontSize: 13.5,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 28),
                Center(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      Text(
                        '25:00',
                        style: TextStyle(
                          color: scheme.onSurface,
                          fontSize: 64,
                          fontWeight: FontWeight.w800,
                          letterSpacing: -1,
                          height: 0.9,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'minutes remaining',
                        style: TextStyle(
                          color: scheme.onSurfaceVariant,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 26),
                Divider(),
                const SizedBox(height: 22),
                Text(
                  'Now focusing on',
                  style: TextStyle(
                    color: scheme.onSurfaceVariant,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Quantitative Aptitude · Percentages',
                  style: TextStyle(
                    color: scheme.onSurface,
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 28),
        FilledButton(
          onPressed: _toggleSession,
          child: Text(
            _inSession ? 'End Session' : 'Start',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
          ),
        ),
        const SizedBox(height: 10),
        Center(
          child: Text(
            'Distraction-free focus mode will live here soon.',
            textAlign: TextAlign.center,
            style: TextStyle(color: scheme.onSurfaceVariant, fontSize: 13),
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
          'Focus Session',
          style: Theme.of(
            context,
          ).textTheme.headlineMedium?.copyWith(color: scheme.onSurface),
        ),
        const SizedBox(height: 4),
        Text(
          'Deep work, one task at a time',
          style: Theme.of(
            context,
          ).textTheme.bodyMedium?.copyWith(color: scheme.onSurfaceVariant),
        ),
      ],
    );
  }
}
