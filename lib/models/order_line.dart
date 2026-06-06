/// A single structured line in a placed order. Keeps the per-item details
/// (vendor, quantity, price, chosen options) so invoices and reorders can show
/// exactly what the customer picked — across multiple restaurants or stores.
class OrderLine {
  final String name;
  final String vendor;
  final int qty;
  final int unitPrice;
  final String options;

  const OrderLine({
    required this.name,
    required this.vendor,
    required this.qty,
    required this.unitPrice,
    this.options = '',
  });

  int get lineTotal => unitPrice * qty;

  Map<String, dynamic> toJson() => {
        'name': name,
        'vendor': vendor,
        'qty': qty,
        'unitPrice': unitPrice,
        'options': options,
      };

  factory OrderLine.fromJson(Map<String, dynamic> json) {
    return OrderLine(
      name: json['name'] as String? ?? '',
      vendor: json['vendor'] as String? ?? '',
      qty: json['qty'] as int? ?? 1,
      unitPrice: json['unitPrice'] as int? ?? 0,
      options: json['options'] as String? ?? '',
    );
  }
}
