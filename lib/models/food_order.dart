import 'order_line.dart';

class FoodOrder {
  final String id;
  final String restaurantName;
  final List<String> items;
  final int total;
  final DateTime orderedAt;
  final String deliveryAddress;
  final String status;

  /// `food` for restaurant orders, `mart` for RushMart grocery orders.
  final String orderType;

  /// All vendors (restaurants / stores) included in this order. Supports
  /// multi-restaurant and multi-store baskets.
  final List<String> vendors;

  final String paymentMode;
  final List<OrderLine> lines;

  // Bill breakdown (grand total = subtotal + taxes + delivery + packing + tip - discount).
  final int subtotal;
  final int taxes;
  final int deliveryFee;
  final int packingFee;
  final int discount;
  final int tip;

  const FoodOrder({
    required this.id,
    required this.restaurantName,
    required this.items,
    required this.total,
    required this.orderedAt,
    required this.deliveryAddress,
    this.status = 'Delivered',
    this.orderType = 'food',
    this.vendors = const [],
    this.paymentMode = 'upi',
    this.lines = const [],
    this.subtotal = 0,
    this.taxes = 0,
    this.deliveryFee = 0,
    this.packingFee = 0,
    this.discount = 0,
    this.tip = 0,
  });

  bool get isMart => orderType == 'mart';

  /// Distinct vendor list, falling back to [restaurantName] for legacy orders.
  List<String> get vendorNames {
    if (vendors.isNotEmpty) return vendors;
    return restaurantName.isEmpty ? const [] : [restaurantName];
  }

  bool get isMultiVendor => vendorNames.length > 1;

  String get vendorSummary {
    final names = vendorNames;
    if (names.isEmpty) return restaurantName;
    if (names.length == 1) return names.first;
    return '${names.first} +${names.length - 1} more';
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'restaurantName': restaurantName,
        'items': items,
        'total': total,
        'orderedAt': orderedAt.toIso8601String(),
        'deliveryAddress': deliveryAddress,
        'status': status,
        'orderType': orderType,
        'vendors': vendors,
        'paymentMode': paymentMode,
        'lines': lines.map((l) => l.toJson()).toList(),
        'subtotal': subtotal,
        'taxes': taxes,
        'deliveryFee': deliveryFee,
        'packingFee': packingFee,
        'discount': discount,
        'tip': tip,
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
      orderType: orderType,
      vendors: vendors,
      paymentMode: paymentMode,
      lines: lines,
      subtotal: subtotal,
      taxes: taxes,
      deliveryFee: deliveryFee,
      packingFee: packingFee,
      discount: discount,
      tip: tip,
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
      orderType: json['orderType'] ?? 'food',
      vendors: (json['vendors'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          const [],
      paymentMode: json['paymentMode'] ?? 'upi',
      lines: (json['lines'] as List<dynamic>?)
              ?.map((e) => OrderLine.fromJson(Map<String, dynamic>.from(e as Map)))
              .toList() ??
          const [],
      subtotal: json['subtotal'] ?? 0,
      taxes: json['taxes'] ?? 0,
      deliveryFee: json['deliveryFee'] ?? 0,
      packingFee: json['packingFee'] ?? 0,
      discount: json['discount'] ?? 0,
      tip: json['tip'] ?? 0,
    );
  }

  String get itemsSummary =>
      items.length <= 2 ? items.join(', ') : '${items.take(2).join(', ')} +${items.length - 2} more';
}
