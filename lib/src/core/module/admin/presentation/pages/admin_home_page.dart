// lib/src/core/module/admin/presentation/pages/admin_home_page.dart

import 'package:flutter/material.dart';

import 'admin_hotels_page.dart';
import 'admin_stats_page.dart';
import 'admin_profile_page.dart';

class AdminHomePage extends StatefulWidget {
  final String email;

  const AdminHomePage({super.key, required this.email});

  @override
  State<AdminHomePage> createState() => _AdminHomePageState();
}

class _AdminHomePageState extends State<AdminHomePage> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    final pages = [
      const AdminHotelsPage(),
      const AdminStatsPage(),
      AdminProfilePage(email: widget.email),
    ];

    final titles = ['Manage hotels', 'Statistics', 'Profile'];

    return Scaffold(
      appBar: AppBar(title: Text('Admin • ${titles[_currentIndex]}')),
      body: IndexedStack(index: _currentIndex, children: pages),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (i) => setState(() => _currentIndex = i),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.hotel), label: 'Hotels'),
          BottomNavigationBarItem(icon: Icon(Icons.bar_chart), label: 'Stats'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }
}
