import 'package:flutter/material.dart';
import '../models/restaurant.dart';

class RestaurantCard extends StatelessWidget {
  final Restaurant restaurant;
  final String mode;
  final VoidCallback onOpen;

  const RestaurantCard({
    super.key,
    required this.restaurant,
    required this.mode,
    required this.onOpen,
  });

  @override
  Widget build(BuildContext context) {
    final best = restaurant.bestDish;
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onOpen,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Image.network(restaurant.image, height: 160, width: double.infinity, fit: BoxFit.cover),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(restaurant.name, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  Text('${restaurant.zone} • ${restaurant.category} • ${restaurant.distanceKm.toStringAsFixed(1)} km'),
                  const SizedBox(height: 8),
                  Text('Our best: ${best.name}'),
                  Text('${best.note} • ₹${best.price}'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}