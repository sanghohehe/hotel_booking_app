import 'package:flutter/material.dart';

class ProfileHeader extends StatelessWidget {
  final String fullName;
  final String email;
  final String? avatarUrl;
  final String initials;
  final VoidCallback onEditTap;

  const ProfileHeader({
    super.key,
    required this.fullName,
    required this.email,
    required this.initials,
    this.avatarUrl,
    required this.onEditTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Stack(
          alignment: Alignment.bottomRight,
          children: [
            Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 4),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 15,
                    offset: const Offset(0, 8),
                  )
                ],
              ),
              child: CircleAvatar(
                radius: 55,
                backgroundColor: Colors.white,
                backgroundImage: (avatarUrl != null && avatarUrl!.isNotEmpty)
                    ? NetworkImage(avatarUrl!)
                    : null,
                child: (avatarUrl == null || avatarUrl!.isEmpty)
                    ? Text(initials, style: const TextStyle(fontSize: 36, fontWeight: FontWeight.bold))
                    : null,
              ),
            ),
            GestureDetector(
              onTap: onEditTap,
              child: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 2.5),
                ),
                child: const Icon(Icons.edit, size: 18, color: Colors.white),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Text(
          fullName.isNotEmpty ? fullName : 'Guest User',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
            color: Colors.white,
            shadows: [
              Shadow(color: Colors.black.withOpacity(0.5), offset: const Offset(0, 2), blurRadius: 4),
            ],
          ),
        ),
        Text(
          email,
          style: TextStyle(
            color: Colors.white.withOpacity(0.85),
            shadows: [
              Shadow(color: Colors.black.withOpacity(0.5), offset: const Offset(0, 1), blurRadius: 2),
            ],
          ),
        ),
      ],
    );
  }
}