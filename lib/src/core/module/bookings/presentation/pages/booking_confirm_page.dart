import 'package:booking_app/src/core/module/bookings/data/booking_api.dart';
import 'package:booking_app/src/core/module/bookings/datasource/booking_RepositoryImpl%20.dart';
import 'package:booking_app/src/core/module/bookings/presentation/cubit/BookingConfirmCubit.dart';
import 'package:booking_app/src/core/module/bookings/presentation/cubit/booking_confirm_state.dart';
import 'package:booking_app/src/core/module/bookings/presentation/pages/bookings_page.dart';
import 'package:booking_app/src/core/module/bookings/presentation/pages/payment_page.dart';
import 'package:booking_app/src/core/module/bookings/presentation/widgets/booking_date_row.dart';
import 'package:booking_app/src/core/module/bookings/presentation/widgets/booking_info_card.dart';
import 'package:booking_app/src/core/module/bookings/presentation/widgets/booking_label.dart';
import 'package:booking_app/src/core/module/bookings/presentation/widgets/booking_section_card.dart';
import 'package:booking_app/src/core/module/bookings/presentation/widgets/bottom_action_bar.dart';
import 'package:booking_app/src/core/module/bookings/presentation/widgets/guest_counter_card.dart';
import 'package:booking_app/src/core/module/bookings/presentation/widgets/price_row.dart';
import 'package:booking_app/src/core/module/hotel/data/models/hotel_model.dart';
import 'package:booking_app/src/core/module/hotel/domain/entities/hotel_entity.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
// Import các widget bạn đã tách ra ở đây
// import '../widgets/...';

class BookingConfirmPage extends StatelessWidget {
  final HotelEntity hotel;
  final RoomTypeModel roomType;

  const BookingConfirmPage({
    super.key,
    required this.hotel,
    required this.roomType,
  });

  @override
  Widget build(BuildContext context) {
    // Khởi tạo BlocProvider bao bọc View
    return BlocProvider(
      create:
          (context) => BookingConfirmCubit(BookingRepositoryImpl(BookingApi())),
      child: _BookingConfirmView(hotel: hotel, roomType: roomType),
    );
  }
}

class _BookingConfirmView extends StatefulWidget {
  final HotelEntity hotel;
  final RoomTypeModel roomType;
  const _BookingConfirmView({required this.hotel, required this.roomType});

  @override
  State<_BookingConfirmView> createState() => _BookingConfirmViewState();
}

class _BookingConfirmViewState extends State<_BookingConfirmView> {
  final _noteController = TextEditingController();
  final _dateFormat = DateFormat('EEE, dd MMM yyyy');

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<BookingConfirmCubit, BookingConfirmState>(
      listener: (context, state) async {
        if (state.successBooking != null) {
          // 1. Mở trang thanh toán và đợi kết quả
          final bool? isPaid = await Navigator.of(context).push<bool>(
            MaterialPageRoute(
              builder: (_) => PaymentPage(booking: state.successBooking!),
            ),
          );

          // 2. Nếu thanh toán thành công (isPaid == true)
          if (isPaid == true && context.mounted) {
            // Điều hướng đến BookingPage và xóa hết các trang trước đó trong stack
            // (Ví dụ: Trang tìm kiếm, Trang chi tiết khách sạn -> về thẳng trang quản lý đặt phòng)
            Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(
                builder: (_) => const BookingsPage(),
              ), // Trang danh sách đặt phòng của bạn
              (route) =>
                  route
                      .isFirst, // Giữ lại trang Dashboard/Home nếu muốn, hoặc false để xóa hết
            );
          }

          // Reset state để tránh trigger lại listener
          context.read<BookingConfirmCubit>().resetStatus();
        }
      },
      builder: (context, state) {
        final isOverCapacity =
            state.totalGuests > (widget.roomType.capacity ?? 0);

        return Scaffold(
          backgroundColor: const Color(0xFFF8F9FA),
          appBar: AppBar(title: const Text('Xác nhận đặt phòng')),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                BookingInfoCard(
                  hotelName: widget.hotel.name,
                  roomTypeName: widget.roomType.name,
                  imageUrl:
                      widget.roomType.imageUrl.isNotEmpty
                          ? widget.roomType.imageUrl.first
                          : widget.hotel.thumbnailUrl,
                  maxCapacity: widget.roomType.capacity ?? 0,
                ),
                const SizedBox(height: 24),
                Label('Thời gian lưu trú'),
                GestureDetector(
                  onTap: () => _selectDateRange(context, state),
                  child: SectionCard(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        DateColumn('Nhận phòng', state.checkIn, _dateFormat),
                        Icon(
                          Icons.swap_horiz,
                          color: Theme.of(context).primaryColor,
                        ),
                        DateColumn('Trả phòng', state.checkOut, _dateFormat),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Label('Số lượng khách'),
                CounterCard(
                  adults: state.adults,
                  children: state.children,
                  isOverCapacity: isOverCapacity,
                  maxCapacity: widget.roomType.capacity ?? 0,
                  onAdultsChanged:
                      (v) => context.read<BookingConfirmCubit>().updateGuests(
                        v,
                        state.children,
                      ),
                  onChildrenChanged:
                      (v) => context.read<BookingConfirmCubit>().updateGuests(
                        state.adults,
                        v,
                      ),
                ),
                const SizedBox(height: 24),
                Label('Ghi chú'),
                SectionCard(
                  child: TextField(
                    controller: _noteController,
                    maxLines: 2,
                    decoration: const InputDecoration(
                      hintText: 'Nhập ghi chú...',
                      border: InputBorder.none,
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                Label('Thanh toán'),
                SectionCard(
                  child: Column(
                    children: [
                      PriceRow(
                        label:
                            '\$${widget.roomType.pricePerNight} x ${state.nights} đêm',
                        price: state.totalPrice(widget.roomType.pricePerNight),
                      ),
                      const Divider(),
                      PriceRow(
                        label: 'Tổng cộng',
                        price: state.totalPrice(widget.roomType.pricePerNight),
                        isTotal: true,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          bottomSheet: BottomAction(
            isLoading: state.isLoading,
            isDisabled: isOverCapacity || state.nights <= 0,
            totalPrice: state.totalPrice(widget.roomType.pricePerNight),
            onPressed:
                () => context.read<BookingConfirmCubit>().confirmBooking(
                  hotelId: widget.hotel.id,
                  roomId: widget.roomType.id,
                  pricePerNight: widget.roomType.pricePerNight,
                  note: _noteController.text,
                ),
          ),
        );
      },
    );
  }

  void _selectDateRange(BuildContext context, BookingConfirmState state) async {
    final picked = await showDateRangePicker(
      context: context,
      initialDateRange: DateTimeRange(
        start: state.checkIn,
        end: state.checkOut,
      ),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) {
      context.read<BookingConfirmCubit>().updateDates(picked.start, picked.end);
    }
  }
}
