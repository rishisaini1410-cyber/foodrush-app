import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_colors.dart';
import '../../data/restaurants_data.dart';
import '../../models/food_order.dart';
import '../../models/menu_item.dart';
import '../../providers/cart_provider.dart';
import '../../providers/order_provider.dart';
import '../../providers/profile_provider.dart';
import '../../widgets/past_order_tile.dart';
import 'tracking_screen.dart';

class OrdersScreen extends StatelessWidget {
  const OrdersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final orderState = context.watch<OrderProvider>();
    final profile = context.watch<ProfileProvider>();
    final accent = Theme.of(context).colorScheme.primary;
    final activeOrders = orderState.activeOrders;

    if (orderState.shouldShowFeedback && activeOrders.isNotEmpty) {


      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (context.mounted) {
          _showFeedbackDialog(context, orderState);
        }
      });
    }

    return Scaffold(
      backgroundColor: AppColors.paper,
      appBar: AppBar(
        title: const Text('Orders', style: TextStyle(fontWeight: FontWeight.w900)),
        backgroundColor: AppColors.paper,
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          if (activeOrders.isNotEmpty) ...[
            ...activeOrders.map((o) => _activeOrderCard(context, orderState, accent, o)).toList(),
            const SizedBox(height: 20),
          ],

          const Text('Order history', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900)),
          const SizedBox(height: 12),
          if (profile.pastOrdersSorted.isEmpty)
            const Center(
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 60),
                child: Text(
                  'Abhi koi past order nahi hai.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: AppColors.muted),
                ),
              ),
            )
          else
            ...profile.pastOrdersSorted.map(
              (order) => Column(
                children: [
                  PastOrderTile(
                    order: order,
                    serial: profile.pastOrdersSorted.indexOf(order) + 1,
                    accent: accent,
                    onReorder: () => _reorderOrder(context, order),
                    onInvoice: () => _showInvoice(context, order),
                  ),
                  const SizedBox(height: 10),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _activeOrderCard(BuildContext context, OrderProvider orderState, Color accent, FoodOrder order) {

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.line),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Active order', style: TextStyle(fontWeight: FontWeight.w900)),
          const SizedBox(height: 10),
          Row(
            children: [
              CircleAvatar(backgroundColor: accent.withOpacity(0.12), child: Icon(Icons.delivery_dining_rounded, color: accent)),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(order.restaurantName, style: const TextStyle(fontWeight: FontWeight.w800)),
                    const SizedBox(height: 4),
                    Text(orderState.statusLabel, style: const TextStyle(color: AppColors.muted, fontSize: 12)),
                  ],
                ),
              ),
              FilledButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => TrackingScreen()),
                  );
                },
                style: FilledButton.styleFrom(backgroundColor: accent),
                child: const Text('Track'),
              ),
            ],
          ),
          const SizedBox(height: 16),
          LinearProgressIndicator(value: orderState.progress, color: accent, backgroundColor: accent.withOpacity(0.15)),

          const SizedBox(height: 14),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Items: ${order.items.length}', style: const TextStyle(fontWeight: FontWeight.w700)),
              Text('₹${order.total}', style: TextStyle(color: accent, fontWeight: FontWeight.w900)),
            ],
          ),
        ],
      ),
    );
  }

  void _reorderOrder(BuildContext context, FoodOrder order) {
    final cart = context.read<CartProvider>();
    cart.clear();
    final restaurant = allRestaurants.firstWhere(
      (r) => r.name == order.restaurantName,
      orElse: () => allRestaurants.first,
    );
    for (final itemName in order.items) {
      final existingItem = restaurant.menu.firstWhere(
        (menuItem) => menuItem.name == itemName,
        orElse: () => MenuItem(
          id: 'reorder-${itemName.hashCode}',
          diet: restaurant.diet,
          best: false,
          name: itemName,
          price: 149,
          note: 'Reordered from previous order',
          image: restaurant.image,
          tags: [restaurant.category],
        ),
      );
      cart.add(existingItem, restaurant.name);
    }
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Order rebuilt in your cart.')),
    );
  }

  void _showInvoice(BuildContext context, FoodOrder order) {
    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: const Text('Invoice mockup'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Order ID: ${order.id}'),
              const SizedBox(height: 6),
              Text('Restaurant: ${order.restaurantName}'),
              const SizedBox(height: 6),
              Text('Delivered to: ${order.deliveryAddress}'),
              const SizedBox(height: 6),
              Text('Items: ${order.itemsSummary}'),
              const SizedBox(height: 6),
              Text('Total: ₹${order.total}'),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Close')),
          ],
        );
      },
    );
  }

  void _showFeedbackDialog(BuildContext context, OrderProvider orderState) {
    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: const Text('Order delivered!'),
          content: const Text('Rate your food, packaging, and rider to complete the experience.'),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Later')),
            FilledButton(
              onPressed: () {
                orderState.dismissFeedback();
                Navigator.pop(ctx);
              },
              child: const Text('Give rating'),
            ),
          ],
        );
      },
    );
  }
}
