import 'package:flutter/material.dart';

class ProfileMenuItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? trailing;
  final VoidCallback onTap;
  final bool isDestructive;

  const ProfileMenuItem({
    super.key,
    required this.icon,
    required this.title,
    this.trailing,
    required this.onTap,
    this.isDestructive = false,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
        decoration: BoxDecoration(
          color: isDestructive ? Colors.red.withOpacity(0.05) : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: isDestructive ? Border.all(color: Colors.red.withOpacity(0.1)) : null,
          boxShadow: isDestructive ? null : [
            BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 4))
          ],
        ),
        child: Row(
          children: [
            Icon(icon, color: isDestructive ? Colors.red : Colors.grey[700]),
            const SizedBox(width: 16),
            Text(
              title,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: isDestructive ? Colors.red : Colors.black87,
              ),
            ),
            const Spacer(),
            if (trailing != null)
              Text(trailing!, style: TextStyle(color: Colors.grey[500], fontSize: 13))
            else
              Icon(Icons.chevron_right_rounded, color: Colors.grey[400]),
          ],
        ),
      ),
    );
  }
}