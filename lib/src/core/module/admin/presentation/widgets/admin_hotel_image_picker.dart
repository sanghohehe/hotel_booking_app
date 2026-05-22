import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class AdminHotelImagePicker extends StatelessWidget {
  final XFile? pickedImage;
  final String? imageUrl;
  final VoidCallback onPick;

  const AdminHotelImagePicker({
    super.key,
    this.pickedImage,
    this.imageUrl,
    required this.onPick,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPick,
      child: Stack(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: AspectRatio(
              aspectRatio: 16 / 9,
              child: Container(
                color: Colors.grey[200],
                child:
                    pickedImage != null
                        ? Image.file(File(pickedImage!.path), fit: BoxFit.cover)
                        : (imageUrl != null && imageUrl!.isNotEmpty)
                        ? CachedNetworkImage(
                          imageUrl: imageUrl!,
                          fit: BoxFit.cover,
                          // Thay thế cho errorBuilder của Image.network
                          errorWidget:
                              (context, url, error) => const Icon(
                                Icons.broken_image,
                                color: Colors.grey,
                              ),
                          // Option: Thêm hiệu ứng loading nhẹ nhàng
                          placeholder:
                              (context, url) => const Center(
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              ),
                        )
                        : const Icon(
                          Icons.add_photo_alternate_outlined,
                          size: 50,
                          color: Colors.grey,
                        ),
              ),
            ),
          ),
          Positioned(
            right: 12,
            bottom: 12,
            child: CircleAvatar(
              backgroundColor: Colors.blueAccent,
              child: const Icon(
                Icons.camera_alt,
                color: Colors.white,
                size: 20,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
