import 'package:flutter/material.dart';

class PromoSlide {
  final String restaurant;
  final String dish;
  final String offer;
  final String category;
  final Color gradientStart;
  final Color gradientEnd;
  final IconData dishIcon;
  final String badge;

  const PromoSlide({
    required this.restaurant,
    required this.dish,
    required this.offer,
    required this.category,
    required this.gradientStart,
    required this.gradientEnd,
    required this.dishIcon,
    this.badge = 'HOT',
  });
}
