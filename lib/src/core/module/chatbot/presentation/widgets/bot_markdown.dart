import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';

class BotMarkdown extends StatelessWidget {
  final String text;
  const BotMarkdown({super.key, required this.text});

  @override
  Widget build(BuildContext context) {
    return MarkdownBody(
      data: text,
      selectable: true,
      styleSheet: MarkdownStyleSheet(
        p: const TextStyle(color: Color(0xFF1C1C1E), fontSize: 15, height: 1.45),
        strong: const TextStyle(color: Color(0xFF1C1C1E), fontWeight: FontWeight.w700, fontSize: 15),
        em: const TextStyle(color: Color(0xFF1C1C1E), fontStyle: FontStyle.italic, fontSize: 15),
        code: TextStyle(backgroundColor: Colors.grey.shade100, color: const Color(0xFF0A84FF), fontFamily: 'monospace', fontSize: 13),
        codeblockDecoration: BoxDecoration(color: Colors.grey.shade100, borderRadius: BorderRadius.circular(8)),
        listBullet: const TextStyle(color: Color(0xFF1C1C1E), fontSize: 15),
        blockquoteDecoration: BoxDecoration(
          color: Colors.blue.shade50,
          borderRadius: BorderRadius.circular(4),
          border: Border(left: BorderSide(color: Colors.blue.shade200, width: 3)),
        ),
        h1: const TextStyle(color: Color(0xFF1C1C1E), fontSize: 18, fontWeight: FontWeight.bold),
        h2: const TextStyle(color: Color(0xFF1C1C1E), fontSize: 16, fontWeight: FontWeight.bold),
        h3: const TextStyle(color: Color(0xFF1C1C1E), fontSize: 15, fontWeight: FontWeight.w600),
        horizontalRuleDecoration: BoxDecoration(border: Border(bottom: BorderSide(color: Colors.grey.shade300))),
      ),
    );
  }
}