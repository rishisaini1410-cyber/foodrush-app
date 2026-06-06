import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/menu_item.dart';
import '../models/restaurant.dart';
import '../providers/cart_provider.dart';

class RestaurantDetailSheet extends StatelessWidget {
  final Restaurant restaurant;

  const RestaurantDetailSheet({super.key, required this.restaurant});

  @override
  Widget build(BuildContext context) {
    final cart = context.read<CartProvider>();
    final best = restaurant.bestDish;

    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.9,
      builder: (_, controller) {
        return ListView(
          controller: controller,
          padding: const EdgeInsets.all(16),
          children: [
            Image.network(restaurant.image, height: 200, fit: BoxFit.cover),
            const SizedBox(height: 12),
            Text(
              restaurant.name,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            Text('★ ${restaurant.rating} • ${restaurant.time} • ${restaurant.zone}'),
            const SizedBox(height: 16),
            _dishTile(context, best, cart, highlight: true),
            const Divider(),
            ...restaurant.menu.map((item) => _dishTile(context, item, cart)),
          ],
        );
      },
    );
  }

  Widget _dishTile(
    BuildContext context,
    MenuItem item,
    CartProvider cart, {
    bool highlight = false,
  }) {
    return Card(
      color: highlight ? Colors.green.shade50 : null,
      child: ListTile(
        leading: Image.network(item.image, width: 56, height: 56, fit: BoxFit.cover),
        title: Text(item.name, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text('${item.note} • ₹${item.price}'),
        trailing: ElevatedButton(
          onPressed: () {
            cart.add(item, restaurant.name);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('${item.name} added')),
            );
          },
          child: const Text('ADD'),
        ),
      ),
    );
  }
}