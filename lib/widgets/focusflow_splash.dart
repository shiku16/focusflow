import 'package:flutter/material.dart';

/// The FocusFlow branded launch screen.
///
/// A calm, full-bleed primary-colored splash with the brand mark, wordmark and
/// tagline. The application shell shows it briefly before the dashboard loads;
/// it requires no input and dismisses itself quickly.
class FocusFlowSplash extends StatelessWidget {
  /// Creates the launch splash.
  const FocusFlowSplash({super.key});

  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = Theme.of(context).colorScheme;
    return Scaffold(
      backgroundColor: scheme.primary,
      body: SizedBox.expand(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 28),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  color: Colors.white12,
                  borderRadius: BorderRadius.all(Radius.circular(30)),
                ),
                child: Center(
                  child: Text(
                    'F',
                    style: TextStyle(
                      color: scheme.onPrimary,
                      fontSize: 46,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 30),
              Text(
                'FocusFlow',
                style: TextStyle(
                  color: scheme.onPrimary,
                  fontSize: 36,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Your exam. Your time.\nYour AI study coach.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 15.5,
                  height: 1.45,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
