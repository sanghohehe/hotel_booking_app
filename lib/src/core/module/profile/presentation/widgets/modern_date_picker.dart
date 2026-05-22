import 'package:flutter/material.dart';

class ModernDatePicker extends StatelessWidget {
  final String label;
  final DateTime? selectedDate;
  final String formattedDate;
  final VoidCallback onTap;

  const ModernDatePicker({
    super.key,
    required this.label,
    required this.selectedDate,
    required this.formattedDate,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 8),
          child: Text(label, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.black54)),
        ),
        InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
            child: Row(
              children: [
                const Icon(Icons.cake_outlined, color: Colors.orange, size: 22),
                const SizedBox(width: 12),
                Text(
                  selectedDate == null ? 'Select Date' : formattedDate,
                  style: const TextStyle(fontSize: 15, color: Colors.black87),
                ),
                const Spacer(),
                const Icon(Icons.calendar_month_rounded, color: Colors.grey, size: 20),
              ],
            ),
          ),
        ),
      ],
    );
  }
}