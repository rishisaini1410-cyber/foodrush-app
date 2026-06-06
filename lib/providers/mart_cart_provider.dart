import 'package:flutter/material.dart';

import '../models/grocery_item.dart';

class MartCartLine {
  final GroceryItem item;
  int qty;

  MartCartLine({required this.item, this.qty = 1});
}

class MartCartProvider extends ChangeNotifier {
  final Map<String, MartCartLine> _lines = {};

  List<MartCartLine> get lines => _lines.values.toList();
  int get count => lines.fold(0, (sum, l) => sum + l.qty);
  int get subtotal => lines.fold(0, (sum, l) => sum + l.qty * l.item.price);
  int get grandTotal => subtotal > 0 ? subtotal : 0;

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

  void clear() {
    _lines.clear();
    notifyListeners();
  }
}
