import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

// Import các thành phần theo cấu trúc Clean Architecture
import '../../data/booking_api.dart';
import '../../data/models/booking_model.dart';
import '../../domain/entities/bookingEntity .dart'; // TODO: kiểm tra lại path
import '../../domain/usecases/booking_usecases.dart';
import '../cubit/bookings_cubit.dart';
import '../cubit/bookings_state.dart';
import '../widgets/booking_card.dart';
import '../utils/booking_ui_helper.dart';
import 'payment_page.dart'; // import PaymentPage

// Import từ các module khác
import '../../../hotel/data/hotel_api.dart';
import '../../../hotel/presentation/pages/hotel_detail_page.dart';

class BookingsPage extends StatelessWidget {
  const BookingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create:
          (context) =>
              BookingsCubit(BookingUseCases(BookingApi()))..loadBookings(),
      child: const BookingsView(),
    );
  }
}

class BookingsView extends StatelessWidget {
  const BookingsView({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        body: SafeArea(
          child: NestedScrollView(
            headerSliverBuilder: (context, innerBoxIsScrolled) {
              return [
                SliverAppBar(
                  toolbarHeight: 0,
                  automaticallyImplyLeading: false,
                  floating: true,
                  pinned: true,
                  backgroundColor: Theme.of(context).scaffoldBackgroundColor,
                  elevation: 0,
                  bottom: const TabBar(
                    labelColor: Colors.blue,
                    unselectedLabelColor: Colors.grey,
                    indicatorColor: Colors.blue,
                    tabs: [
                      Tab(text: 'Pending'),
                      Tab(text: 'Done'),
                      Tab(text: 'Cancelled'),
                    ],
                  ),
                ),
              ];
            },
            body: BlocBuilder<BookingsCubit, BookingsState>(
              builder: (context, state) {
                if (state is BookingsLoading) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (state is BookingsError) {
                  return Center(child: Text('Lỗi: ${state.message}'));
                }

                if (state is BookingsLoaded) {
                  return TabBarView(
                    children: [
                      _buildList(
                        context,
                        state,
                        (b) => b.status == 'pending' || b.status == 'confirmed',
                      ),
                      _buildList(context, state, (b) => b.status == 'done'),
                      _buildList(
                        context,
                        state,
                        (b) =>
                            b.status == 'cancelled' || b.status == 'canceled',
                      ),
                    ],
                  );
                }
                return const SizedBox.shrink();
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildList(
    BuildContext context,
    BookingsLoaded state,
    bool Function(BookingModel) filter,
  ) {
    final list = state.bookings.where(filter).toList();

    if (list.isEmpty) {
      return const Center(child: Text('Không có dữ liệu.'));
    }

    return RefreshIndicator(
      onRefresh: () => context.read<BookingsCubit>().loadBookings(),
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: list.length,
        itemBuilder: (ctx, i) {
          final booking = list[i];
          return BookingCard(
            booking: booking,
            isPaying: state.processingIds.contains(booking.id),
            onPay: () => _onPayAction(context, booking),
            onCancel: () => _onCancelAction(context, booking),
            onMarkDone:
                () => context.read<BookingsCubit>().markDone(booking.id),
            onReview: () => _onReviewAction(context, booking),
            paymentLabel: BookingUIHelper.getPaymentLabel,
            paymentChipBg: BookingUIHelper.getPaymentChipBg,
            paymentChipTextColor: BookingUIHelper.getPaymentChipTextColor,
            statusChipBg: BookingUIHelper.getStatusChipBg,
            statusChipText: BookingUIHelper.getStatusChipText,
          );
        },
      ),
    );
  }

  // --- UI Logic: Dialogs & BottomSheets ---

  /// Mở PaymentPage thay vì bottom sheet cũ
  Future<void> _onPayAction(BuildContext context, BookingModel booking) async {
    // Convert BookingModel → BookingEntity để truyền vào PaymentPage
    final entity = BookingEntity(
      id: booking.id,
      checkIn: booking.checkIn,
      checkOut: booking.checkOut,
      totalPrice: booking.totalPrice,
      status: booking.status,
      paymentStatus: booking.paymentStatus,
      guestsAdults: booking.guestsAdults,
      guestsChildren: booking.guestsChildren,
      hotelId: booking.hotelId,
      hotelName: booking.hotelName,
      hotelCity: booking.hotelCity,
      roomTypeName: booking.roomTypeName,
      paymentMethod: booking.paymentMethod,
      paidAt: booking.paidAt,
      nights: booking.checkOut.difference(booking.checkIn).inDays,
    );

    // PaymentPage tự xử lý navigate đến BookingsPage khi thành công
    // nên ở đây chỉ cần push và reload khi quay lại (trường hợp thất bại)
    await Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (_) => PaymentPage(booking: entity)));

    // Reload lại list phòng trường hợp payment thất bại và user quay lại
    if (context.mounted) {
      context.read<BookingsCubit>().loadBookings();
    }
  }

  Future<void> _onCancelAction(
    BuildContext context,
    BookingModel booking,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder:
          (ctx) => AlertDialog(
            title: const Text('Hủy đặt phòng'),
            content: const Text('Bạn có chắc muốn hủy không?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx, false),
                child: const Text('Không'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(ctx, true),
                child: const Text('Hủy ngay'),
              ),
            ],
          ),
    );

    if (confirmed == true && context.mounted) {
      context.read<BookingsCubit>().cancelBooking(booking.id);
    }
  }

  Future<void> _onReviewAction(
    BuildContext context,
    BookingModel booking,
  ) async {
    final hotelId = booking.hotelId;
    if (hotelId == null) return;

    try {
      final hotelModel = await HotelApi().getHotelDetail(hotelId);

      if (context.mounted) {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder:
                (_) => HotelDetailPage(
                  hotel: hotelModel.toEntity(),
                  openReviewOnStart: true,
                ),
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Không thể mở phần đánh giá')),
        );
      }
    }
  }
}
