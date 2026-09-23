import 'package:flutter/material.dart';

import '../app_state.dart';
import '../theme/app_theme.dart';

/// A polished profile screen with editable account details, goal targets,
/// and a settings-style list.
class ProfileScreen extends StatefulWidget {
  /// Creates the Profile screen.
  ///
  /// [appState] provides the persisted profile values (name, exam goal, daily
  /// study target).
  const ProfileScreen({super.key, required this.appState});

  /// The shared session state.
  final FocusFlowAppState appState;

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  static const List<_SettingRow> _settings = <_SettingRow>[
    _SettingRow('Daily study reminders', Icons.notifications),
    _SettingRow('Distraction-free mode', Icons.timer),
    _SettingRow('Coach preferences', Icons.psychology),
    _SettingRow('Help center', Icons.lightbulb),
  ];

  final TextEditingController _nameInput = TextEditingController();
  final TextEditingController _goalInput = TextEditingController();
  final TextEditingController _hoursInput = TextEditingController();
  final TextEditingController _minutesInput = TextEditingController();
  bool _editing = false;
  String? _formError;

  FocusFlowAppState get _appState => widget.appState;

  void _openEdit() {
    _nameInput.text = _appState.userName;
    _goalInput.text = _appState.examGoal;
    _hoursInput.text = '${_appState.dailyTargetMinutes ~/ 60}';
    _minutesInput.text = '${_appState.dailyTargetMinutes % 60}';
    setState(() {
      _editing = true;
      _formError = null;
    });
  }

  void _cancelEdit() {
    setState(() {
      _editing = false;
      _formError = null;
    });
  }

  void _saveEdit() {
    final String name = _nameInput.text.trim();
    final String goal = _goalInput.text.trim();
    final int? hours = int.tryParse(_hoursInput.text.trim());
    final int? minutes = int.tryParse(_minutesInput.text.trim());
    setState(() {
      if (name.isEmpty) {
        _formError = 'Name cannot be empty.';
        return;
      }
      if (hours == null ||
          minutes == null ||
          hours < 0 ||
          hours > 24 ||
          minutes < 0 ||
          minutes > 59 ||
          (hours == 0 && minutes == 0)) {
        _formError = 'Enter a valid daily target (0–24 hrs, 0–59 min).';
        return;
      }
      _appState.setProfile(
        name: name,
        examGoal: goal.isEmpty ? null : goal,
        dailyTargetMinutes: hours * 60 + minutes,
      );
      _editing = false;
      _formError = null;
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
        _profileCard(context, scheme),
        const SizedBox(height: 18),
        if (_editing)
          _editForm(context, scheme)
        else
          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Padding(
                padding: EdgeInsets.only(bottom: 10),
                child: _statCard(
                  context,
                  scheme,
                  'Exam Goal',
                  _appState.examGoal,
                ),
              ),
              _statCard(
                context,
                scheme,
                'Daily Target',
                '${FocusFlowAppState.formatMinutes(_appState.dailyTargetMinutes)} / day',
              ),
            ],
          ),
        const SizedBox(height: 26),
        _sectionTitle(context, 'Settings'),
        const SizedBox(height: 14),
        for (final _SettingRow row in _settings)
          Padding(
            padding: EdgeInsets.only(bottom: 10),
            child: _settingRow(context, scheme, row),
          ),
      ],
    );
  }

  Widget _editForm(BuildContext context, ColorScheme scheme) {
    return Card.filled(
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(FocusFlowTheme.radiusL),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Text(
              'Edit Profile',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: scheme.onSurface,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 6),
            TextField(
              controller: _nameInput,
              maxLines: 1,
              decoration: const InputDecoration(hintText: 'Your name'),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _goalInput,
              maxLines: 1,
              decoration: const InputDecoration(
                hintText: 'Exam goal, e.g. SSC CGL 2027',
              ),
            ),
            const SizedBox(height: 10),
            Text(
              'Daily study target',
              style: Theme.of(
                context,
              ).textTheme.labelLarge?.copyWith(color: scheme.onSurfaceVariant),
            ),
            const SizedBox(height: 6),
            Row(
              children: <Widget>[
                Flexible(
                  child: SizedBox(
                    height: 56,
                    child: TextField(
                      controller: _hoursInput,
                      maxLines: 1,
                      decoration: const InputDecoration(
                        hintText: 'Hours (0–24)',
                        labelText: 'Hours',
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Flexible(
                  child: SizedBox(
                    height: 56,
                    child: TextField(
                      controller: _minutesInput,
                      maxLines: 1,
                      decoration: const InputDecoration(
                        hintText: 'Minutes (0–59)',
                        labelText: 'Minutes',
                      ),
                    ),
                  ),
                ),
              ],
            ),
            if (_formError != null)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  _formError!,
                  style: TextStyle(
                    color: scheme.error,
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                TextButton(onPressed: _cancelEdit, child: const Text('Cancel')),
                FilledButton(
                  onPressed: _saveEdit,
                  child: const Text(
                    'Save',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _header(BuildContext context, ColorScheme scheme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          'Profile',
          style: Theme.of(
            context,
          ).textTheme.headlineMedium?.copyWith(color: scheme.onSurface),
        ),
        const SizedBox(height: 4),
        Text(
          'Your goals & settings',
          style: Theme.of(
            context,
          ).textTheme.bodyMedium?.copyWith(color: scheme.onSurfaceVariant),
        ),
      ],
    );
  }

  Widget _profileCard(BuildContext context, ColorScheme scheme) {
    return Card.filled(
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(FocusFlowTheme.radiusL),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(18, 18, 18, 18),
        child: Row(
          children: <Widget>[
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: scheme.primary,
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  _appState.userName.substring(0, 1).toUpperCase(),
                  style: TextStyle(
                    color: scheme.onPrimary,
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Flexible(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    _appState.userName,
                    style: TextStyle(
                      color: scheme.onSurface,
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    'Aspirant · ${_appState.examGoal}',
                    style: TextStyle(
                      color: scheme.onSurfaceVariant,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
            IconButton(
              icon: Icon(Icons.edit, color: scheme.onSurfaceVariant),
              tooltip: 'Edit profile',
              onPressed: _openEdit,
            ),
          ],
        ),
      ),
    );
  }

  Widget _statCard(
    BuildContext context,
    ColorScheme scheme,
    String label,
    String value,
  ) {
    return Card.filled(
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(FocusFlowTheme.radiusM),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(color: scheme.onSurfaceVariant, fontSize: 12.5),
            ),
            const SizedBox(height: 4),
            Text(
              value,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: scheme.onSurface,
                fontSize: 16,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _settingRow(
    BuildContext context,
    ColorScheme scheme,
    _SettingRow row,
  ) {
    return Card.filled(
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(FocusFlowTheme.radiusM),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 14, 14, 14),
        child: Row(
          children: <Widget>[
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: scheme.primaryContainer,
                borderRadius: BorderRadius.all(FocusFlowTheme.radiusS),
              ),
              child: Center(
                child: Icon(row.icon, color: scheme.primary, size: 20),
              ),
            ),
            const SizedBox(width: 14),
            Flexible(
              child: Text(
                row.label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: scheme.onSurface,
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const SizedBox(width: 6),
            Icon(Icons.arrow_forward, color: scheme.outline, size: 18),
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

/// A single settings-style list row.
class _SettingRow {
  const _SettingRow(this.label, this.icon);

  final String label;
  final IconData icon;
}
