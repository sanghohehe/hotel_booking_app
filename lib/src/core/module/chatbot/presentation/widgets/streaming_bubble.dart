import 'package:flutter/material.dart';
import 'bot_markdown.dart';
import 'blinking_cursor.dart';

class StreamingBubble extends StatelessWidget {
  final String text;
  const StreamingBubble({super.key, required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Padding(
            padding: const EdgeInsets.only(right: 8, bottom: 2),
            child: Container(
              width: 30,
              height: 30,
              decoration: BoxDecoration(
                gradient: const LinearGradient(colors: [Color(0xFF0A84FF), Color(0xFF34AADC)]),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.travel_explore, color: Colors.white, size: 16),
            ),
          ),
          Flexible(
            child: Container(
              constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.78),
              margin: const EdgeInsets.only(top: 2, bottom: 2, right: 48),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(18),
                  topRight: Radius.circular(18),
                  bottomLeft: Radius.circular(4),
                  bottomRight: Radius.circular(18),
                ),
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.07), blurRadius: 8, offset: const Offset(0, 2))],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  BotMarkdown(text: text),
                  const SizedBox(height: 4),
                  const BlinkingCursor(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}