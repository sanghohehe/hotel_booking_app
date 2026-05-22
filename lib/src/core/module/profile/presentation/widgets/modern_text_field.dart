import 'package:flutter/material.dart';

class ModernTextField extends StatelessWidget {
  final String label;
  final TextEditingController? controller;
  final String? initialValue;
  final IconData icon;
  final bool enabled;
  final int maxLines;
  final TextInputType? keyboardType;
  final String? Function(String?)? validator;

  const ModernTextField({
    super.key,
    required this.label,
    this.controller,
    this.initialValue,
    required this.icon,
    this.enabled = true,
    this.maxLines = 1,
    this.keyboardType,
    this.validator,
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
        TextFormField(
          controller: controller,
          initialValue: initialValue,
          enabled: enabled,
          maxLines: maxLines,
          keyboardType: keyboardType,
          validator: validator,
          style: const TextStyle(fontSize: 15),
          decoration: InputDecoration(
            filled: true,
            fillColor: enabled ? Colors.white : Colors.grey[200],
            prefixIcon: Icon(icon, color: enabled ? Colors.blue : Colors.grey, size: 22),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(color: Theme.of(context).primaryColor, width: 1),
            ),
          ),
        ),
      ],
    );
  }
}