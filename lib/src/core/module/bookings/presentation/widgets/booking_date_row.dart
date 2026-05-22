import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class DateColumn extends StatelessWidget {
  final String label;
  final DateTime date;
  final DateFormat format;

  const DateColumn(this.label, this.date, this.format, {super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [Text(label), Text(format.format(date))],
    );
  }
}
