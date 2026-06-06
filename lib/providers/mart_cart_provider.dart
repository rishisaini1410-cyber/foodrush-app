import 'package:flutter/material.dart';

import '../models/grocery_item.dart';
import '../models/order_line.dart';

class MartCartLine {
  final GroceryItem item;
  int qty;

  MartCartLine({required this.item, this.qty = 1});
}

class MartCartProvider extends ChangeNotifier {
  static const vendorName = 'RushMart';

  final Map<String, MartCartLine> _lines = {};
  String paymentMode = 'upi';

  List<MartCartLine> get lines => _lines.values.toList();
  int get count => lines.fold(0, (sum, l) => sum + l.qty);
  int get subtotal => lines.fold(0, (sum, l) => sum + l.qty * l.item.price);

  int get deliveryFee => subtotal > 0 ? 25 : 0;
  int get handlingFee => subtotal > 0 ? 9 : 0;

  /// Backwards-compatible: previously [grandTotal] was just the subtotal.
  int get grandTotal => subtotal + deliveryFee + handlingFee;
  int get total => grandTotal;

  List<OrderLine> get orderLines => lines
      .map((l) => OrderLine(
            name: l.item.name,
            vendor: vendorName,
            qty: l.qty,
            unitPrice: l.item.price,
            options: l.item.unit,
          ))
      .toList();

  void add(GroceryItem item) {
    final existing = _lines[item.id];
    if (existing != null) {
      existing.qty++;
    } else {
      _lines[item.id] = MartCartLine(item: item);
    }
    notifyListeners();
  }

  void changeQty(String id, int delta) {
    final line = _lines[id];
    if (line == null) return;
    line.qty += delta;
    if (line.qty <= 0) _lines.remove(id);
    notifyListeners();
  }

  void setPaymentMode(String mode) {
    paymentMode = mode;
    notifyListeners();
  }

  void clear() {
    _lines.clear();
    paymentMode = 'upi';
    notifyListeners();
  }
}
