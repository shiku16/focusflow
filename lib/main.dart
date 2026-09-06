import 'package:flutter/material.dart';

import 'focus_page.dart';
import 'screens/coach_screen.dart';
import 'screens/focus_screen.dart';
import 'screens/home_screen.dart';
import 'screens/planner_screen.dart';
import 'screens/profile_screen.dart';
import 'theme/app_theme.dart';
import 'widgets/app_bottom_navigation.dart';

void main() {
  runApp(const FocusFlowApp());
}

/// Root widget for FocusFlow.
///
/// Wraps the application in a [MaterialApp] with the FocusFlow light theme and
/// hands off to [FocusFlowShell].
class FocusFlowApp extends StatelessWidget {
  const FocusFlowApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'FocusFlow',
      themeMode: ThemeMode.light,
      theme: FocusFlowTheme.light(),
      debugShowCheckedModeBanner: false,
      home: const FocusFlowShell(),
    );
  }
}

/// The application shell.
///
/// Owns which page is currently shown and renders the shared chrome: a
/// scrollable content area plus the bottom navigation (hidden while the Coach
/// chat is open).
class FocusFlowShell extends StatefulWidget {
  const FocusFlowShell({super.key});

  @override
  State<FocusFlowShell> createState() => _FocusFlowShellState();
}

class _FocusFlowShellState extends State<FocusFlowShell> {
  FocusPage _page = FocusPage.home;

  void _go(FocusPage page) {
    setState(() {
      _page = page;
    });
  }

  @override
  Widget build(BuildContext context) {
    final bool showBottomNavigation = _page != FocusPage.coach;
    return Scaffold(
      backgroundColor: const Color(0xFFF6F6F9),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Expanded(
            child: showBottomNavigation
                ? SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(20, 22, 20, 26),
                      child: _pageWidget(context),
                    ),
                  )
                : _pageWidget(context),
          ),
          if (showBottomNavigation)
            AppBottomNavigation(
              current: _page,
              onSelected: (FocusPage page) => _go(page),
            ),
        ],
      ),
    );
  }

  Widget _pageWidget(BuildContext context) {
    switch (_page) {
      case FocusPage.home:
        return HomeScreen(onNavigate: (FocusPage page) => _go(page));
      case FocusPage.planner:
        return const PlannerScreen();
      case FocusPage.focus:
        return const FocusScreen();
      case FocusPage.profile:
        return const ProfileScreen();
      case FocusPage.coach:
        return CoachScreen(onNavigate: (FocusPage page) => _go(page));
    }
  }
}
