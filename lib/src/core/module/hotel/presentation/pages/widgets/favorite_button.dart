import 'package:booking_app/src/core/module/hotel/presentation/cubit/hotel_detail_cubit.dart';
import 'package:booking_app/src/core/module/hotel/presentation/cubit/hotel_detail_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class FavoriteButton extends StatelessWidget {
  const FavoriteButton({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HotelDetailCubit, HotelDetailState>(
      // Build lại khi trạng thái favorite hoặc dữ liệu khách sạn thay đổi
      buildWhen:
          (prev, curr) =>
              prev.isFavorite != curr.isFavorite ||
              prev.hotel?.id != curr.hotel?.id,
      builder: (context, state) {
        return IconButton(
          onPressed: () {
            // Kiểm tra hotel khác null trước khi gọi Cubit
            final id = state.hotel?.id;
            if (id != null) {
              context.read<HotelDetailCubit>().toggleFavorite(id);
            }
          },
          icon: Icon(
            state.isFavorite ? Icons.favorite : Icons.favorite_border,
            color: state.isFavorite ? Colors.red : Colors.white,
          ),
        );
      },
    );
  }
}
