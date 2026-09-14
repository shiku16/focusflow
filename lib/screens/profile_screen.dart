import 'package:flutter/material.dart';

/// A polished profile screen with account details, goal targets, and a
/// settings-style list.
class ProfileScreen extends StatelessWidget {
  /// Creates the Profile screen.
  const ProfileScreen({super.key});

  static const List<_SettingRow> _settings = <_SettingRow>[
    _SettingRow('Daily study reminders', Icons.notifications),
    _SettingRow('Distraction-free mode', Icons.timer),
    _SettingRow('Coach preferences', Icons.psychology),
    _SettingRow('Help center', Icons.lightbulb),
  ];

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
        Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Padding(
              padding: EdgeInsets.only(bottom: 10),
              child: _statCard(context, scheme, 'Exam Goal', 'SSC CGL 2027'),
            ),
            _statCard(context, scheme, 'Daily Target', '3 hrs / day'),
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

  Widget _header(BuildContext context, ColorScheme scheme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          'Profile',
          style: TextStyle(
            color: scheme.onSurface,
            fontSize: 26,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Your goals & settings',
          style: TextStyle(
            color: scheme.onSurfaceVariant,
            fontSize: 15,
          ),
        ),
      ],
    );
  }
Widget _profileCard(BuildContext context, ColorScheme scheme) {
    return Card.filled(
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(22)),
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
                  'U',
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
                    'Udit',
                    style: TextStyle(
                      color: scheme.onSurface,
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    'Aspirant · SSC CGL 2027',
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
              onPressed: () {},
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
        borderRadius: BorderRadius.all(Radius.circular(18)),
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
              style: TextStyle(
                color: scheme.onSurfaceVariant,
                fontSize: 12.5,
              ),
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

  Widget _settingRow(BuildContext context, ColorScheme scheme, _SettingRow row) {
    return Card.filled(
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(16)),
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
                borderRadius: BorderRadius.all(Radius.circular(12)),
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
              Icon(
                Icons.arrow_forward,
                color: scheme.outline,
                size: 18,
              ),
            ],
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

/// A single settings-style list row.
class _SettingRow {
  const _SettingRow(this.label, this.icon);

  final String label;
  final IconData icon;
}
