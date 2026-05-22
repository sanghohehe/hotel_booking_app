import 'package:booking_app/src/core/module/reviews/data/models/review_model.dart';
import 'package:flutter/material.dart';

class ReviewItem extends StatelessWidget {
  final ReviewModel review;

  const ReviewItem({super.key, required this.review});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: CircleAvatar(
                backgroundImage:
                    (review.avatarUrl != null && review.avatarUrl!.isNotEmpty)
                        ? NetworkImage(review.avatarUrl!)
                        : null,
                child:
                    (review.avatarUrl == null || review.avatarUrl!.isEmpty)
                        ? Text(review.username?[0].toUpperCase() ?? 'U')
                        : null,
              ),
              title: Text(
                review.username ?? 'Anonymous',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Row(
                children: List.generate(
                  5,
                  (i) => Icon(
                    i < review.rating ? Icons.star : Icons.star_border,
                    size: 14,
                    color: Colors.amber,
                  ),
                ),
              ),
              trailing: Text(
                review.createdAt.toString().split(' ').first,
                style: theme.textTheme.bodySmall,
              ),
            ),

            if (review.comment != null && review.comment!.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 4.0),
                child: Text(review.comment!),
              ),

            // HIỂN THỊ DANH SÁCH ẢNH REVIEW (NẾU CÓ)
            if (review.images.isNotEmpty) ...[
              const SizedBox(height: 10),
              SizedBox(
                height: 80,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: review.images.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 8),
                  itemBuilder:
                      (_, i) => ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.network(
                          review.images[i],
                          width: 80,
                          height: 80,
                          fit: BoxFit.cover,
                          errorBuilder:
                              (context, error, stackTrace) => Container(
                                width: 80,
                                color: Colors.grey[200],
                                child: const Icon(Icons.error),
                              ),
                        ),
                      ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
