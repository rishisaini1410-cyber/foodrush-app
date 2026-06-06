class FavoriteItem {
  final String id;
  final String name;
  final String restaurantName;
  final int price;
  final String diet;

  const FavoriteItem({
    required this.id,
    required this.name,
    required this.restaurantName,
    required this.price,
    required this.diet,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'restaurantName': restaurantName,
        'price': price,
        'diet': diet,
      };

  factory FavoriteItem.fromJson(Map<String, dynamic> json) {
    return FavoriteItem(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      restaurantName: json['restaurantName'] ?? '',
      price: json['price'] ?? 0,
      diet: json['diet'] ?? 'veg',
    );
  }
}
