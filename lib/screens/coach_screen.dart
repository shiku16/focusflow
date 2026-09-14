import 'package:flutter/material.dart';

import '../focus_page.dart';

/// The AI Study Coach chat screen.
///
/// A polished chat-style interface with suggested prompts and an input bar.
/// No AI API is connected yet — sending a message simply echoes it into the
/// thread with a friendly placeholder reply.
class CoachScreen extends StatefulWidget {
  /// Creates the Coach screen.
  ///
  /// [onNavigate] is used to return to the Home screen via the back button.
  const CoachScreen({
    super.key,
    required this.onNavigate,
  });

  /// Called to switch to another page (used by the back button).
  final void Function(FocusPage) onNavigate;

  @override
  State<CoachScreen> createState() => _CoachScreenState();
}

class _CoachScreenState extends State<CoachScreen> {
  /// Bound input for the composer at the bottom of the chat.
  final TextEditingController _input = TextEditingController();

  /// The ordered chat thread; the first bubble is the coach's intro.
  final List<_Message> _messages = <_Message>[
    _Message(
      fromCoach: true,
      text: "Hi Udit! 👋 I'm your AI study coach. Ask me to plan your day, "
          'help you recover, or quiz you on a topic.',
    ),
  ];

  static const List<String> _suggestions = <String>[
    'Plan my study day',
    'I missed yesterday. Help me recover.',
    'Quiz me on percentages.',
  ];

  void _send(String text) {
    final String trimmed = text.trim();
    if (trimmed.isEmpty) {
      return;
    }
    setState(() {
      _messages.add(_Message(fromCoach: false, text: trimmed));
      _messages.add(
        _Message(
          fromCoach: true,
          text: "Got it — I'd love to help. Full coaching is coming soon. "
              'Meanwhile, add this to your planner and start with a focus session.',
        ),
      );
      _input.clear();
    });
  }
@override
  Widget build(BuildContext context) {
    final ColorScheme scheme = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        _topBar(context, scheme),
        Expanded(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  for (final _Message message in _messages)
                    Padding(
                      padding: EdgeInsets.only(bottom: 12),
                      child: _bubble(context, scheme, message),
                    ),
                  const SizedBox(height: 6),
                  Text(
                    'Suggested prompts',
                    style: TextStyle(
                      color: scheme.onSurfaceVariant,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 10),
                  for (final String prompt in _suggestions)
                    Padding(
                      padding: EdgeInsets.only(bottom: 8),
                      child: _suggestionChip(context, scheme, prompt),
                    ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ),
        _composer(context, scheme),
      ],
    );
  }

  Widget _topBar(BuildContext context, ColorScheme scheme) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 14),
      child: Row(
        children: <Widget>[
          IconButton(
            icon: Icon(Icons.arrow_back, color: scheme.onSurface),
            tooltip: 'Back to Home',
            onPressed: () => widget.onNavigate(FocusPage.home),
          ),
          const SizedBox(width: 12),
          Flexible(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  'AI Study Coach',
                  style: TextStyle(
                    color: scheme.onSurface,
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Always in your corner',
                  style: TextStyle(
                    color: scheme.onSurfaceVariant,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: scheme.primaryContainer,
              borderRadius: BorderRadius.all(Radius.circular(12)),
            ),
            child: Center(
              child: Icon(
                Icons.psychology,
                color: scheme.primary,
                size: 22,
              ),
            ),
          ),
        ],
      ),
    );
  }
Widget _bubble(BuildContext context, ColorScheme scheme, _Message message) {
    final Color bubbleColor = message.fromCoach
        ? scheme.surfaceContainerHigh
        : scheme.primary;
    final Color textColor =
        message.fromCoach ? scheme.onSurface : scheme.onPrimary;
    return Align(
      alignment: message.fromCoach
          ? AlignmentDirectional.centerStart
          : AlignmentDirectional.centerEnd,
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: 320),
        child: ClipRRect(
          borderRadius: message.fromCoach
              ? BorderRadius.only(
                  topLeft: Radius.circular(4),
                  topRight: Radius.circular(16),
                  bottomLeft: Radius.circular(16),
                  bottomRight: Radius.circular(16),
                )
              : BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(4),
                  bottomLeft: Radius.circular(16),
                  bottomRight: Radius.circular(16),
                ),
          child: ColoredBox(
            color: bubbleColor,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
              child: Text(
                message.text,
                textAlign: TextAlign.start,
                style: TextStyle(
                  color: textColor,
                  fontSize: 14.5,
                  height: 1.35,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _suggestionChip(
    BuildContext context,
    ColorScheme scheme,
    String label,
  ) {
    return TextButton(
      onPressed: () => _send(label),
      child: Text(
        label,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(color: scheme.primary, fontSize: 13),
      ),
    );
  }

  Widget _composer(BuildContext context, ColorScheme scheme) {
    return ColoredBox(
      color: scheme.surfaceContainer,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
        child: Row(
          children: <Widget>[
            Flexible(
              child: TextField(
                controller: _input,
                maxLines: 1,
                decoration: const InputDecoration(hintText: 'Message the coach…'),
                onSubmitted: (String value) => _send(value),
              ),
            ),
            const SizedBox(width: 10),
            IconButton(
              icon: const Icon(Icons.send),
              tooltip: 'Send message',
              onPressed: () => _send(_input.text),
              style: IconButton.styleFrom(
                backgroundColor: scheme.primary,
                foregroundColor: scheme.onPrimary,
                shape: const StadiumBorder(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// A single chat bubble.
class _Message {
  const _Message({required this.fromCoach, required this.text});

  final bool fromCoach;
  final String text;
}