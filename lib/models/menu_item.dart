import 'dish.dart';

class MenuItem {
  final String id;
  final String diet;
  final bool best;
  final String name;
  final int price;
  final String note;
  final String image;
  final List<String> tags;

  const MenuItem({
    required this.id,
    required this.diet,
    required this.best,
    required this.name,
    required this.price,
    required this.note,
    required this.image,
    this.tags = const [],
  });

  factory MenuItem.fromDish({
    required String id,
    required String diet,
    required bool best,
    required Dish dish,
  }) {
    return MenuItem(
      id: id,
      diet: diet,
      best: best,
      name: dish.name,
      price: dish.price,
      note: dish.note,
      image: dish.image,
      tags: dish.tags,
    );
  }
}