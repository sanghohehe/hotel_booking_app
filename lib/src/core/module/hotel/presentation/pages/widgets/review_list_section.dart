import 'package:booking_app/src/core/module/hotel/presentation/cubit/hotel_detail_cubit.dart';
import 'package:booking_app/src/core/module/hotel/presentation/cubit/hotel_detail_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'review_item.dart'; // Giả sử bạn tách ReviewItem ra file riêng

class ReviewListSection extends StatelessWidget {
  final VoidCallback onAddReview;

  const ReviewListSection({super.key, required this.onAddReview});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return BlocBuilder<HotelDetailCubit, HotelDetailState>(
      builder: (context, state) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Reviews',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (state.canReview)
                  TextButton.icon(
                    onPressed: onAddReview,
                    icon: const Icon(Icons.edit),
                    label: const Text('Write'),
                  ),
              ],
            ),
            if (state.reviews.isEmpty)
              const Text('No reviews yet.')
            else
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: state.reviews.length,
                itemBuilder:
                    (context, index) =>
                        ReviewItem(review: state.reviews[index]),
              ),
          ],
        );
      },
    );
  }
}
