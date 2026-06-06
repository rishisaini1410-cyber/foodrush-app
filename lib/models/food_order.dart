class FoodOrder {
  final String id;
  final String restaurantName;
  final List<String> items;
  final int total;
  final DateTime orderedAt;
  final String deliveryAddress;
  final String status;

  const FoodOrder({
    required this.id,
    required this.restaurantName,
    required this.items,
    required this.total,
    required this.orderedAt,
    required this.deliveryAddress,
    this.status = 'Delivered',
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'restaurantName': restaurantName,
        'items': items,
        'total': total,
        'orderedAt': orderedAt.toIso8601String(),
        'deliveryAddress': deliveryAddress,
        'status': status,
      };

  FoodOrder copyWith({
    String? status,
    int? total,
    List<String>? items,
  }) {
    return FoodOrder(
      id: id,
      restaurantName: restaurantName,
      items: items ?? this.items,
      total: total ?? this.total,
      orderedAt: orderedAt,
      deliveryAddress: deliveryAddress,
      status: status ?? this.status,
    );
  }

  factory FoodOrder.fromJson(Map<String, dynamic> json) {
    return FoodOrder(
      id: json['id'] ?? '',
      restaurantName: json['restaurantName'] ?? '',
      items: (json['items'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      total: json['total'] ?? 0,
      orderedAt: DateTime.tryParse(json['orderedAt'] ?? '') ?? DateTime.now(),
      deliveryAddress: json['deliveryAddress'] ?? '',
      status: json['status'] ?? 'Delivered',
    );
  }

  String get itemsSummary =>
      items.length <= 2 ? items.join(', ') : '${items.take(2).join(', ')} +${items.length - 2} more';
}
