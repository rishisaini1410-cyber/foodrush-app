import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:food_rush/models/cart_line.dart';
import 'package:food_rush/models/menu_item.dart';

class CartProvider extends ChangeNotifier {
  static const _storageKey = 'foodRushCart';

  final Map<String, CartLine> _lines = {};
  bool noCutlery = true;
  String couponCode = '';
  int tip = 0;
  String specialInstructions = '';
  String deliveryInstructions = '';

  CartProvider() {
    _restoreCart();
  }

  List<CartLine> get lines => _lines.values.toList();
  int get count => lines.fold<int>(0, (sum, l) => sum + l.qty);
  int get subtotal => lines.fold<int>(0, (sum, l) => sum + l.lineTotal);
  int get gst => (subtotal * 0.05).round();
  int get deliveryFee => subtotal > 0 ? 35 : 0;
  int get packingFee => subtotal > 0 ? 18 : 0;
  int get discount {
    if (couponCode.trim().toUpperCase() == 'RUSH50') {
      return (subtotal * 0.5).round();
    }
    return 0;
  }

  int get total => subtotal + gst + deliveryFee + packingFee - discount + tip;

  int get plasticSaved => noCutlery ? 8 : 0;

  /// List of distinct restaurants present in the cart.
  Set<String> get restaurantNames =>
      _lines.values.map((l) => l.restaurantName).toSet();


  void add(
    MenuItem item,
    String restaurantName, {
    String size = 'Regular',
    List<String> toppings = const [],
    String spiceLevel = 'Medium',
    int quantity = 1,
    bool clearExisting = false,
  }) {
    // Multi-restaurant cart allowed.
    // If clearExisting is true, remove lines only for the provided restaurant.
    if (clearExisting) {
      _lines.removeWhere((_, line) => line.restaurantName == restaurantName);
    }

    final key =
        '${restaurantName}|${item.id}|$size|${toppings.join(',')}|$spiceLevel';
    final existing = _lines[key];



    if (existing != null) {
      existing.qty += quantity;
    } else {
      _lines[key] = CartLine(
        id: key,
        item: item,
        restaurantName: restaurantName,
        qty: quantity,
        size: size,
        toppings: toppings,
        spiceLevel: spiceLevel,
      );
    }
    _saveCart();
    notifyListeners();
  }

  void changeQty(String id, int delta) {
    final line = _lines[id];
    if (line == null) return;
    line.qty += delta;
    if (line.qty <= 0) {
      _lines.remove(id);
    }
    _saveCart();
    notifyListeners();
  }

  void setCoupon(String code) {
    couponCode = code;
    _saveCart();
    notifyListeners();
  }

  void setTip(int value) {
    tip = value;
    _saveCart();
    notifyListeners();
  }

  void setNoCutlery(bool value) {
    noCutlery = value;
    _saveCart();
    notifyListeners();
  }

  void setSpecialInstructions(String text) {
    specialInstructions = text;
    _saveCart();
    notifyListeners();
  }

  void setDeliveryInstructions(String text) {
    deliveryInstructions = text;
    _saveCart();
    notifyListeners();
  }

  void cleanForMode(String mode) {
    _lines.removeWhere((_, line) => line.item.diet != mode);
    _saveCart();
    notifyListeners();
  }

  void clear() {
    _lines.clear();
    noCutlery = true;
    couponCode = '';
    tip = 0;
    specialInstructions = '';
    deliveryInstructions = '';
    _saveCart();
    notifyListeners();
  }

  Future<void> _restoreCart() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_storageKey);
    if (raw == null) return;

    try {
      final data = jsonDecode(raw) as Map<String, dynamic>;
      final items = (data['lines'] as List<dynamic>)
          .map((e) => CartLine.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList();
      _lines
        ..clear()
        ..addEntries(items.map((line) => MapEntry(line.id, line)));
      noCutlery = data['noCutlery'] as bool? ?? true;
      couponCode = data['couponCode'] as String? ?? '';
      tip = data['tip'] as int? ?? 0;
      specialInstructions = data['specialInstructions'] as String? ?? '';
      deliveryInstructions = data['deliveryInstructions'] as String? ?? '';
      notifyListeners();
    } catch (_) {
      // ignore malformed cart state
    }
  }

  Future<void> _saveCart() async {
    final prefs = await SharedPreferences.getInstance();
    final data = {
      'lines': lines.map((line) => line.toJson()).toList(),
      'noCutlery': noCutlery,
      'couponCode': couponCode,
      'tip': tip,
      'specialInstructions': specialInstructions,
      'deliveryInstructions': deliveryInstructions,
    };
    await prefs.setString(_storageKey, jsonEncode(data));
  }
}
