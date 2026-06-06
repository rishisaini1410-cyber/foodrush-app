import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_colors.dart';
import '../../providers/app_provider.dart';
import '../home/home_screen.dart';
import '../profile/profile_screen.dart';
import 'offers_screen.dart';
import 'orders_screen.dart';
import 'search_screen.dart';

class MainTabsScreen extends StatefulWidget {
  const MainTabsScreen({super.key});

  @override
  State<MainTabsScreen> createState() => _MainTabsScreenState();
}

class _MainTabsScreenState extends State<MainTabsScreen> {
  int _selectedIndex = 0;

  static final _tabRoutes = <Widget>[
    const HomeScreen(),
    const SearchScreen(),
    const OffersScreen(),
    const OrdersScreen(),
    const ProfileScreen(),
  ];

  static const _labels = [
    'Home',
    'Search',
    'Offers',
    'Orders',
    'Profile',
  ];

  static const _icons = [
    Icons.home_rounded,
    Icons.search_rounded,
    Icons.local_offer_rounded,
    Icons.receipt_long_rounded,
    Icons.person_rounded,
  ];

  @override
  Widget build(BuildContext context) {
    final accent = context.watch<AppProvider>().activeMode == 'veg'
        ? AppColors.vegAccent
        : AppColors.nonVegAccent;

    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: _tabRoutes,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) => setState(() => _selectedIndex = index),
        selectedItemColor: accent,
        unselectedItemColor: AppColors.muted,
        backgroundColor: Colors.white,
        type: BottomNavigationBarType.fixed,
        items: List.generate(_labels.length, (index) {
          return BottomNavigationBarItem(
            icon: Icon(_icons[index]),
            label: _labels[index],
          );
        }),
      ),
    );
  }
}
