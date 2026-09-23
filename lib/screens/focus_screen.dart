import 'package:flutter/material.dart';

import '../app_state.dart';
import '../theme/app_theme.dart';

/// A focus-session screen backed by the shared app state.
///
/// The countdown itself lives in [FocusFlowAppState], so it keeps running
/// (or staying paused) when the user navigates to another screen and back.
class FocusScreen extends StatefulWidget {
  /// Creates the Focus screen.
  ///
  /// [appState] owns the session timer state shared across screens.
  const FocusScreen({super.key, required this.appState});

  /// The shared session state (timer, remaining time, running/paused flags).
  final FocusFlowAppState appState;

  @override
  State<FocusScreen> createState() => _FocusScreenState();
}

class _FocusScreenState extends State<FocusScreen> {
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

  /// The timer display, formatted as `MM:SS`.
  String get _formattedTime {
    final int minutes = widget.appState.remainingSeconds ~/ 60;
    final int seconds = widget.appState.remainingSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:'
        '${seconds.toString().padLeft(2, '0')}';
  }

  String get _statusLabel {
    if (!widget.appState.focusInSession) {
      return 'Session ready';
    }
    return widget.appState.focusRunning
        ? 'Session in progress'
        : 'Session paused';
  }

  Color _statusColor(ColorScheme scheme) {
    if (widget.appState.focusRunning) {
      return scheme.primary;
    }
    if (widget.appState.focusInSession) {
      return scheme.tertiary;
    }
    return scheme.outlineVariant;
  }

  void _startSession() => widget.appState.startFocus();
  void _pauseSession() => widget.appState.pauseFocus();
  void _resumeSession() => widget.appState.resumeFocus();
  void _endSession() => widget.appState.endFocus();

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
                        color: _statusColor(scheme),
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      _statusLabel,
                      style: TextStyle(
                        color: _statusColor(scheme),
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
                        _formattedTime,
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
        _buildActions(context),
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

  /// Renders the primary session actions: Start when idle; Pause or Resume
  /// plus End Session while a session is active.
  Widget _buildActions(BuildContext context) {
    if (!widget.appState.focusInSession) {
      return FilledButton(
        onPressed: _startSession,
        child: Text(
          'Start',
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
        ),
      );
    }
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        Flexible(
          child: FilledButton(
            onPressed: widget.appState.focusRunning
                ? _pauseSession
                : _resumeSession,
            child: Text(
              widget.appState.focusRunning ? 'Pause' : 'Resume',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Flexible(
          child: FilledButton.tonal(
            onPressed: _endSession,
            child: Text(
              'End Session',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
            ),
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
