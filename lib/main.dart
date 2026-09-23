import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart' show Ticker;

import 'app_state.dart';
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

  /// Shared, session-scoped app state injected into screens that need it.
  final FocusFlowAppState _appState = FocusFlowAppState();

  /// Shared scroll controller for the shell's page area.
  final ScrollController _scrollController = ScrollController();

  /// Whether the branded launch splash is still showing.
  bool _showSplash = true;
  Ticker? _splashTicker;
  Duration _splashElapsed = Duration.zero;

  /// Whether persisted app state has been loaded.
  bool _readyToShowApp = false;

  /// The brief branded launch moment (kept short by design).
  static const Duration _splashDuration = Duration(milliseconds: 900);

  @override
  void initState() {
    super.initState();
    unawaited(_restore());
    _splashTicker = createTicker((Duration elapsed) {
      _splashElapsed += elapsed;
      if (_splashElapsed >= _splashDuration && _readyToShowApp) {
        _splashTicker!.stop();
        setState(() {
          _showSplash = false;
        });
      }
    });
    _splashTicker!.start();
  }

  /// Loads persisted state. The splash stays up until this completes so the
  /// dashboard never flashes back to a default state after being restored.
  Future<void> _restore() async {
    await _appState.restore();
    if (!mounted) {
      return;
    }
    setState(() {
      _readyToShowApp = true;
    });
  }

  @override
  void dispose() {
    _splashTicker?.stop();
    _scrollController.dispose();
    _appState.dispose();
    super.dispose();
  }

  void _go(FocusPage page) {
    setState(() {
      _page = page;
    });
    // Each page should open at the top; the shared scroll position from a
    // previously scrolled page must not leak into the next screen.
    if (_scrollController.hasClients) {
      _scrollController.jumpTo(0);
    }
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
                    controller: _scrollController,
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
        return HomeScreen(
          onNavigate: (FocusPage page) => _go(page),
          appState: _appState,
        );
      case FocusPage.planner:
        return PlannerScreen(appState: _appState);
      case FocusPage.focus:
        return FocusScreen(appState: _appState);
      case FocusPage.profile:
        return ProfileScreen(appState: _appState);
      case FocusPage.coach:
        return CoachScreen(onNavigate: (FocusPage page) => _go(page));
    }
  }
}
