import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:booking_app/src/core/module/reviews/data/review_api.dart';
import 'package:booking_app/src/core/module/hotel/presentation/cubit/hotel_detail_cubit.dart';

class AddReviewBottomSheet extends StatefulWidget {
  final String hotelId;

  const AddReviewBottomSheet({super.key, required this.hotelId});

  @override
  State<AddReviewBottomSheet> createState() => _AddReviewBottomSheetState();
}

class _AddReviewBottomSheetState extends State<AddReviewBottomSheet> {
  final _commentController = TextEditingController();
  final _reviewApi = ReviewApi();
  int _rating = 5;
  List<File> _images = [];
  bool _submitting = false;

  Future<void> _pickImages() async {
    final picker = ImagePicker();
    final picked = await picker.pickMultiImage();
    if (picked.isNotEmpty) {
      setState(() {
        _images = picked.map((e) => File(e.path)).toList();
      });
    }
  }

  Future<void> _submit() async {
    setState(() => _submitting = true);
    try {
      List<String> imageUrls = [];
      if (_images.isNotEmpty) {
        imageUrls = await _reviewApi.uploadReviewImages(
          files: _images,
          hotelId: widget.hotelId,
        );
      }

      await _reviewApi.addReview(
        hotelId: widget.hotelId,
        rating: _rating,
        comment: _commentController.text.trim(),
        images: imageUrls,
      );

      if (mounted) {
        // Reload reviews
        context.read<HotelDetailCubit>().loadHotelDetail(widget.hotelId);
        Navigator.pop(context);
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Review submitted!')));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Write a Review',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),

          // Rating
          Row(
            children: List.generate(
              5,
              (i) => IconButton(
                icon: Icon(
                  i < _rating ? Icons.star : Icons.star_border,
                  color: Colors.amber,
                ),
                onPressed: () => setState(() => _rating = i + 1),
              ),
            ),
          ),

          // Comment
          TextField(
            controller: _commentController,
            maxLines: 3,
            decoration: const InputDecoration(
              hintText: 'Share your experience...',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 12),

          // Images
          if (_images.isNotEmpty)
            SizedBox(
              height: 80,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: _images.length,
                separatorBuilder: (_, __) => const SizedBox(width: 8),
                itemBuilder:
                    (_, i) => ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.file(
                        _images[i],
                        width: 80,
                        height: 80,
                        fit: BoxFit.cover,
                      ),
                    ),
              ),
            ),

          TextButton.icon(
            onPressed: _pickImages,
            icon: const Icon(Icons.photo),
            label: const Text('Add Photos'),
          ),
          const SizedBox(height: 8),

          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _submitting ? null : _submit,
              child:
                  _submitting
                      ? const CircularProgressIndicator(strokeWidth: 2)
                      : const Text('Submit'),
            ),
          ),
        ],
      ),
    );
  }
}
