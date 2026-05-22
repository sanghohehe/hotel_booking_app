// lib/src/features/home/presentation/pages/home_page.dart

import 'package:flutter/material.dart';

class HomePage extends StatelessWidget {
  final String email;

  const HomePage({super.key, required this.email});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Hotel Booking')),
      body: Center(
        child: Text('Xin chào, $email\n(Sau này sẽ là danh sách khách sạn)'),
      ),
    );
  }
}
