import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class EditAvatarSection extends StatelessWidget {
  final String? currentAvatarUrl;
  final XFile? newAvatarFile;
  final VoidCallback onPickImage;

  const EditAvatarSection({
    super.key,
    this.currentAvatarUrl,
    this.newAvatarFile,
    required this.onPickImage,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Center(
      child: Stack(
        children: [
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: theme.primaryColor.withOpacity(0.2), width: 2),
            ),
            child: CircleAvatar(
              radius: 60,
              backgroundColor: Colors.white,
              backgroundImage: newAvatarFile != null 
                  ? FileImage(File(newAvatarFile!.path))
                  : (currentAvatarUrl != null ? NetworkImage(currentAvatarUrl!) as ImageProvider : null),
              child: (newAvatarFile == null && currentAvatarUrl == null)
                  ? Icon(Icons.person, size: 60, color: Colors.grey[400])
                  : null,
            ),
          ),
          Positioned(
            bottom: 0,
            right: 4,
            child: GestureDetector(
              onTap: onPickImage,
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: theme.primaryColor,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 3),
                  boxShadow: [
                    BoxShadow(color: theme.primaryColor.withOpacity(0.3), blurRadius: 10, offset: const Offset(0, 4))
                  ],
                ),
                child: const Icon(Icons.camera_alt_rounded, color: Colors.white, size: 20),
              ),
            ),
          ),
        ],
      ),
    );
  }
}