// lib/src/core/module/home/presentation/pages/main_shell_page.dart
import 'package:flutter/material.dart';

import '../../../hotel/presentation/pages/hotel_list_page.dart';
import '../../../favorites/presentation/pages/favorites_page.dart';
import '../../../bookings/presentation/pages/bookings_page.dart';
import '../../../profile/presentation/pages/profile_page.dart';
import '../../../chatbot/presentation/pages/chatbot_page.dart';
import '../../../notifications/presentation/widgets/notification_bell.dart';

class MainShellPage extends StatefulWidget {
  final String email;
  const MainShellPage({super.key, required this.email});

  @override
  State<MainShellPage> createState() => _MainShellPageState();
}

class _MainShellPageState extends State<MainShellPage> {
  int _currentIndex = 0;
  late final List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    _pages = [
      const HotelListPage(),
      const FavoritesPage(),
      const BookingsPage(),
      const ChatbotPage(),
      ProfilePage(email: widget.email),
    ];
  }

  String _title() {
    switch (_currentIndex) {
      case 0:
        return 'Discover';
      case 1:
        return 'Favorites';
      case 2:
        return 'Bookings';
      case 3:
        return 'Chatbot';
      case 4:
        return 'Profile';
      default:
        return 'Booking App';
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(_title()),
        actions: const [
          NotificationBell(), // ✅ chuông ở AppBar
        ],
      ),
      body: IndexedStack(index: _currentIndex, children: _pages),

      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          border: Border(
            top: BorderSide(color: Colors.grey.shade200, width: 1),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: SafeArea(
          top: false,
          child: BottomNavigationBar(
            currentIndex: _currentIndex,
            onTap: (index) => setState(() => _currentIndex = index),
            type: BottomNavigationBarType.fixed,
            elevation: 0,
            backgroundColor: Colors.transparent,
            selectedItemColor: theme.colorScheme.primary,
            unselectedItemColor: Colors.grey[500],
            selectedLabelStyle: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
            unselectedLabelStyle: const TextStyle(fontSize: 11),
            showUnselectedLabels: true,
            items: const [
              BottomNavigationBarItem(
                icon: Icon(Icons.search),
                label: 'Discover',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.favorite_border),
                activeIcon: Icon(Icons.favorite),
                label: 'Favorites',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.book_online_outlined),
                label: 'Bookings',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.chat_bubble_outline),
                activeIcon: Icon(Icons.chat_bubble),
                label: 'Chatbot',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.person_outline),
                activeIcon: Icon(Icons.person),
                label: 'Profile',
              ),
            ],
          ),
        ),
      ),
    );
  }
}
