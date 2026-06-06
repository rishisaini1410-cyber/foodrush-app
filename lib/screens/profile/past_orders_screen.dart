import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_colors.dart';
import '../../providers/app_provider.dart';
import '../../providers/profile_provider.dart';
import '../../widgets/past_order_tile.dart';

class PastOrdersScreen extends StatelessWidget {
  const PastOrdersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final profile = context.watch<ProfileProvider>();
    final accent = context.watch<AppProvider>().activeMode == 'veg'
        ? AppColors.vegAccent
        : AppColors.nonVegAccent;
    final orders = profile.pastOrdersSorted;

    return Scaffold(
      backgroundColor: AppColors.paper,
      appBar: AppBar(
        title: const Text(
          'Order history',
          style: TextStyle(fontWeight: FontWeight.w900),
        ),
        backgroundColor: AppColors.paper,
      ),
      body: orders.isEmpty
          ? const Center(
              child: Text(
                'Abhi koi order nahi hai.',
                style: TextStyle(color: AppColors.muted),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: orders.length,
              itemBuilder: (_, i) => PastOrderTile(
                order: orders[i],
                serial: i + 1,
                accent: accent,
              ),
            ),
    );
  }
}
