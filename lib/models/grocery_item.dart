import 'package:flutter/material.dart';

class GroceryItem {
  final String id;
  final String name;
  final int price;
  final int mrp;
  final String unit;
  final String category;
  final IconData icon;
  final Color color;

  const GroceryItem({
    required this.id,
    required this.name,
    required this.price,
    required this.mrp,
    required this.unit,
    required this.category,
    required this.icon,
    required this.color,
  });

  int get discountPercent =>
      mrp > price ? ((mrp - price) * 100 / mrp).round() : 0;
}
