import 'package:flutter/material.dart';

import '../focus_page.dart';

/// The primary bottom navigation bar for FocusFlow.
///
/// Renders the four main tabs (Home, Planner, Focus, Profile) in a full-width,
/// surface-colored bar. The selected tab is highlighted with the theme's
/// primary color and a short indicator bar.
///
/// Callbacks are wired through [onSelected] so the shell can switch pages.
class AppBottomNavigation extends StatelessWidget {
  /// Creates a bottom navigation bar.
  ///
  /// [current] is the active [FocusPage]; [onSelected] is invoked when a
  /// different tab is tapped.
  const AppBottomNavigation({
    super.key,
    required this.current,
    required this.onSelected,
  });

  /// The page that is currently shown; rendered as the active tab.
  final FocusPage current;

  /// Called when the user taps a tab. The selected page is passed in.
  final void Function(FocusPage) onSelected;

  @override
  Widget build(BuildContext context) {
    final List<_NavDestination> tabs = <_NavDestination>[
      _NavDestination(FocusPage.home, Icons.home, 'Home'),
      _NavDestination(FocusPage.planner, Icons.calendar_month, 'Planner'),
      _NavDestination(FocusPage.focus, Icons.timer, 'Focus'),
      _NavDestination(FocusPage.profile, Icons.person, 'Profile'),
    ];
    final scheme = Theme.of(context).colorScheme;
    return ColoredBox(
      color: scheme.surfaceContainerHigh,
      child: Padding(
        padding: const EdgeInsets.only(top: 10, bottom: 14),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            for (final _NavDestination tab in tabs)
              SizedBox(
                width: 72,
                child: GestureDetector(
                  behavior: HitTestBehavior.translucent,
                  onTap: tab.page == current
                      ? null
                      : () => onSelected(tab.page),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      Icon(
                        tab.icon,
                        color: tab.page == current
                            ? scheme.primary
                            : scheme.onSurfaceVariant,
                        size: 24,
                        semanticLabel: tab.label,
                      ),
                      SizedBox(height: 4),
                      Text(
                        tab.label,
                        style: TextStyle(
                          fontSize: 11.5,
                          fontWeight: tab.page == current
                              ? FontWeight.w700
                              : FontWeight.w500,
                          color: tab.page == current
                              ? scheme.primary
                              : scheme.onSurfaceVariant,
                        ),
                      ),
                      SizedBox(height: 4),
                      SizedBox(
                        width: tab.page == current ? 22 : 0,
                        height: 3,
                        child: ColoredBox(
                          color: tab.page == current
                              ? scheme.primary
                              : Colors.transparent,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

/// A single destination shown in the bottom navigation bar.
class _NavDestination {
  const _NavDestination(this.page, this.icon, this.label);

  final FocusPage page;
  final IconData icon;
  final String label;
}