import 'package:flutter/material.dart';

class CounterBtn extends StatelessWidget {
  final IconData icon;
  final bool enabled;
  final VoidCallback onTap;

  const CounterBtn({
    super.key,
    required this.icon,
    required this.enabled,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: enabled ? onTap : null,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: enabled ? const Color(0xFFE8F0FE) : Colors.grey.shade100,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Icon(icon, color: enabled ? const Color(0xFF0A84FF) : Colors.grey.shade400),
      ),
    );
  }
}