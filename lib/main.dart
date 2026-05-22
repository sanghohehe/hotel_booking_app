import 'package:booking_app/src/core/module/admin/domain/repositories/i_hotel_repository.dart';
import 'package:booking_app/src/core/module/hotel/domain/repositories/hotel_detail_repository.dart';
import 'package:booking_app/src/core/module/hotel/domain/repositories/hotel_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'src/core/supabase/supabase_manager.dart';
import 'src/core/theme/app_theme.dart';
import 'src/core/module/auth/presentation/pages/sign_in_page.dart';

import 'package:booking_app/src/core/module/hotel/data/hotel_api.dart';
import 'package:booking_app/src/core/module/hotel/data/repositories/hotel_repository_impl.dart';
import 'package:booking_app/src/core/module/hotel/presentation/cubit/hotel_cubit.dart';

import 'package:booking_app/src/core/module/chatbot/domain/usecases/chatbot_usecase.dart';
import 'package:booking_app/src/core/module/chatbot/presentation/cubit/chatbot_cubit.dart';

import 'package:booking_app/src/core/module/bookings/data/booking_api.dart';
import 'package:booking_app/src/core/module/bookings/domain/usecases/booking_usecases.dart';
import 'package:booking_app/src/core/module/bookings/presentation/cubit/bookings_cubit.dart';

import 'package:booking_app/src/core/module/profile/presentation/cubit/profile_cubit.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SupabaseManager.init();

  final hotelApi = HotelApi();
  final hotelRepository = HotelRepositoryImpl(hotelApi);

  final bookingApi = BookingApi();
  final bookingUseCases = BookingUseCases(bookingApi);

  final chatbotUseCase = ChatbotUseCase();

  runApp(
    MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => HotelCubit(hotelRepository)..fetchHotels(),
        ),
        BlocProvider(create: (context) => ChatbotCubit(chatbotUseCase)),
        BlocProvider(create: (context) => BookingsCubit(bookingUseCases)),
        RepositoryProvider<HotelRepository>(create: (_) => hotelRepository),
        RepositoryProvider<HotelDetailRepository>(
          create: (_) => hotelRepository,
        ),
        RepositoryProvider<IHotelRepository>(create: (_) => hotelRepository),
        BlocProvider(create: (context) => ProfileCubit()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Hotel Booking',
      theme: AppTheme.lightTheme,
      home: const SignInPage(),
    );
  }
}
