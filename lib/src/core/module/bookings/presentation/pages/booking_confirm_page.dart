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

class BookingConfirmPage extends StatelessWidget {
  final HotelEntity hotel;
  final RoomTypeModel roomType;
  final DateTime checkIn; // ← thêm
  final DateTime checkOut; // ← thêm

  const BookingConfirmPage({
    super.key,
    required this.hotel,
    required this.roomType,
    required this.checkIn, // ← thêm
    required this.checkOut, // ← thêm
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) {
        final cubit = BookingConfirmCubit(BookingRepositoryImpl(BookingApi()));
        cubit.checkAvailability(
          hotelId: hotel.id,
          roomTypeId: roomType.id,
          checkIn: checkIn, // ← thêm
          checkOut: checkOut, // ← thêm
        );
        return cubit;
      },
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
          final bool? isPaid = await Navigator.of(context).push<bool>(
            MaterialPageRoute(
              builder: (_) => PaymentPage(booking: state.successBooking!),
            ),
          );

          if (isPaid == true && context.mounted) {
            Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(builder: (_) => const BookingsPage()),
              (route) => route.isFirst,
            );
          }

          context.read<BookingConfirmCubit>().resetStatus();
        }
      },
      builder: (context, state) {
        final isOverCapacity =
            state.totalGuests > (widget.roomType.capacity ?? 0);

        // ✅ Disable nút khi: hết phòng, đang check, quá capacity, ngày sai
        final isDisabled =
            state.isUnavailable ||
            state.isCheckingAvailability ||
            isOverCapacity ||
            state.nights <= 0;

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

                // ✅ BANNER HẾT PHÒNG
                if (state.isUnavailable) ...[
                  const SizedBox(height: 12),
                  _UnavailableBanner(),
                ],

                // ✅ BANNER ĐANG KIỂM TRA
                if (state.isCheckingAvailability) ...[
                  const SizedBox(height: 12),
                  _CheckingAvailabilityBanner(),
                ],

                const SizedBox(height: 24),
                Label('Thời gian lưu trú'),
                GestureDetector(
                  onTap:
                      state.isUnavailable
                          ? null
                          : () => _selectDateRange(context, state),
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
                      state.isUnavailable
                          ? (_) {}
                          : (v) => context
                              .read<BookingConfirmCubit>()
                              .updateGuests(v, state.children),
                  onChildrenChanged:
                      state.isUnavailable
                          ? (_) {}
                          : (v) => context
                              .read<BookingConfirmCubit>()
                              .updateGuests(state.adults, v),
                ),
                const SizedBox(height: 24),
                Label('Ghi chú'),
                SectionCard(
                  child: TextField(
                    controller: _noteController,
                    maxLines: 2,
                    enabled: !state.isUnavailable,
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
            isDisabled: isDisabled,
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

// ✅ WIDGET: Banner hết phòng
class _UnavailableBanner extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFFFEBEE),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFEF9A9A)),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.do_not_disturb_alt_rounded,
            color: Color(0xFFC62828),
            size: 20,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text(
                  'Phòng đã hết',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Color(0xFFC62828),
                    fontSize: 14,
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  'Loại phòng này đã được khách khác đặt. Vui lòng quay lại chọn phòng khác.',
                  style: TextStyle(color: Color(0xFFB71C1C), fontSize: 12),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ✅ WIDGET: Banner đang kiểm tra
class _CheckingAvailabilityBanner extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F5F5),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE0E0E0)),
      ),
      child: Row(
        children: [
          const SizedBox(
            width: 18,
            height: 18,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
          const SizedBox(width: 10),
          const Text(
            'Đang kiểm tra tình trạng phòng...',
            style: TextStyle(color: Colors.grey, fontSize: 13),
          ),
        ],
      ),
    );
  }
}
