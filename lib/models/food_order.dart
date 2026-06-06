class FoodOrder {
  final String id;
  final String restaurantName;
  final List<String> items;
  final int total;
  final DateTime orderedAt;

  final String deliveryAddress;
  final String status;

  /// Mocked fields for MVP: shows payment + partner assignment in UI.
  final String paymentMethod;
  final String partnerId;
  final String partnerName;

  const FoodOrder({
    required this.id,
    required this.restaurantName,
    required this.items,
    required this.total,
    required this.orderedAt,
    required this.deliveryAddress,
    this.status = 'Delivered',
    this.paymentMethod = 'UPI',
    this.partnerId = '',
    this.partnerName = '',
  });


  Map<String, dynamic> toJson() => {
        'id': id,
        'restaurantName': restaurantName,
        'items': items,
        'total': total,
        'orderedAt': orderedAt.toIso8601String(),
        'deliveryAddress': deliveryAddress,
        'status': status,
        'paymentMethod': paymentMethod,
        'partnerId': partnerId,
        'partnerName': partnerName,
      };


  FoodOrder copyWith({
    String? status,
    int? total,
    List<String>? items,
    String? paymentMethod,
    String? partnerId,
    String? partnerName,
  }) {
    return FoodOrder(
      id: id,
      restaurantName: restaurantName,
      items: items ?? this.items,
      total: total ?? this.total,
      orderedAt: orderedAt,
      deliveryAddress: deliveryAddress,
      status: status ?? this.status,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      partnerId: partnerId ?? this.partnerId,
      partnerName: partnerName ?? this.partnerName,
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
      paymentMethod: json['paymentMethod'] ?? 'UPI',
      partnerId: json['partnerId'] ?? '',
      partnerName: json['partnerName'] ?? '',
    );
  }


  String get itemsSummary =>
      items.length <= 2 ? items.join(', ') : '${items.take(2).join(', ')} +${items.length - 2} more';
}
