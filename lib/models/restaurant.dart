import 'menu_item.dart';

class Restaurant {
  final String id;
  final String name;
  final String category;
  final String time;
  final String rating;
  final String zone;
  final String diet;
  final String image;
  final List<String> tags;
  final List<MenuItem> menu;
  final double distanceKm;

  const Restaurant({
    required this.id,
    required this.name,
    required this.category,
    required this.time,
    required this.rating,
    required this.zone,
    required this.diet,
    required this.image,
    required this.tags,
    required this.menu,
    required this.distanceKm,
  });

  double get ratingValue => double.tryParse(rating) ?? 0;

  MenuItem get bestDish => menu.firstWhere((m) => m.best, orElse: () => menu.first);
}