class Dish {
  final String name;
  final int price;
  final String note;
  final String image;
  final List<String> tags;

  const Dish({
    required this.name,
    required this.price,
    required this.note,
    required this.image,
    this.tags = const [],
  });
}