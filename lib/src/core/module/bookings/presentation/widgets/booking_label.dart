import 'package:flutter/material.dart';

class Label extends StatelessWidget {
  final String text;

  const Label(this.text, {super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 8),
      child: Text(text, style: const TextStyle(fontWeight: FontWeight.bold)),
    );
  }
}
