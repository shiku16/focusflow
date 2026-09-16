import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart' show Ticker;

import 'focus_page.dart';
import 'screens/coach_screen.dart';
import 'screens/focus_screen.dart';
import 'screens/home_screen.dart';
import 'screens/planner_screen.dart';
import 'screens/profile_screen.dart';
import 'theme/app_theme.dart';
import 'widgets/app_bottom_navigation.dart';
import 'widgets/focusflow_splash.dart';

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
      darkTheme: FocusFlowTheme.dark(),
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

class _FocusFlowShellState extends State<FocusFlowShell>
    with SingleTickerProviderStateMixin {
  FocusPage _page = FocusPage.home;

  /// Whether the branded launch splash is still showing.
  bool _showSplash = true;
  Ticker? _splashTicker;
  Duration _splashElapsed = Duration.zero;

  /// The brief branded launch moment (kept short by design).
  static const Duration _splashDuration = Duration(milliseconds: 900);

  @override
  void initState() {
    super.initState();
    _splashTicker = createTicker((Duration elapsed) {
      _splashElapsed += elapsed;
      if (_splashElapsed >= _splashDuration) {
        _splashTicker!.stop();
        setState(() {
          _showSplash = false;
        });
      }
    });
    _splashTicker!.start();
  }

  @override
  void dispose() {
    _splashTicker?.stop();
    super.dispose();
  }

  void _go(FocusPage page) {
    setState(() {
      _page = page;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_showSplash) {
      return const FocusFlowSplash();
    }
    final bool showBottomNavigation = _page != FocusPage.coach;
    return Scaffold(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Expanded(
            child: showBottomNavigation
                ? SingleChildScrollView(
                    child: Padding(
                      padding: FocusFlowTheme.screenInset,
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
