import 'menu_item.dart';

class CartLine {
  final String id;
  final MenuItem item;
  final String restaurantName;
  int qty;
  final String size;
  final List<String> toppings;
  final String spiceLevel;

  CartLine({
    required this.id,
    required this.item,
    required this.restaurantName,
    this.qty = 1,
    this.size = 'Regular',
    this.toppings = const [],
    this.spiceLevel = 'Medium',
  });

  int get sizeAddon {
    switch (size) {
      case 'Medium':
        return 40;
      case 'Large':
        return 70;
      default:
        return 0;
    }
  }

  int get toppingsAddon {
    return toppings.fold<int>(0, (sum, topping) {
      if (topping.contains('Cheese')) return sum + 30;
      if (topping.contains('Mushroom')) return sum + 25;
      if (topping.contains('Jalape�o')) return sum + 20;
      if (topping.contains('Olive')) return sum + 20;
      return sum + 18;
    });
  }

  int get unitPrice => item.price + sizeAddon + toppingsAddon;
  int get lineTotal => unitPrice * qty;

  Map<String, dynamic> toJson() => {
        'id': id,
        'item': {
          'id': item.id,
          'diet': item.diet,
          'best': item.best,
          'name': item.name,
          'price': item.price,
          'note': item.note,
          'image': item.image,
          'tags': item.tags,
        },
        'restaurantName': restaurantName,
        'qty': qty,
        'size': size,
        'toppings': toppings,
        'spiceLevel': spiceLevel,
      };

  factory CartLine.fromJson(Map<String, dynamic> json) {
    final itemJson = Map<String, dynamic>.from(json['item'] as Map);
    return CartLine(
      id: json['id'] as String,
      item: MenuItem(
        id: itemJson['id'] as String,
        diet: itemJson['diet'] as String,
        best: itemJson['best'] as bool,
        name: itemJson['name'] as String,
        price: itemJson['price'] as int,
        note: itemJson['note'] as String,
        image: itemJson['image'] as String,
        tags: List<String>.from(itemJson['tags'] as List<dynamic>),
      ),
      restaurantName: json['restaurantName'] as String,
      qty: json['qty'] as int,
      size: json['size'] as String,
      toppings: List<String>.from(json['toppings'] as List<dynamic>),
      spiceLevel: json['spiceLevel'] as String,
    );
  }
}
