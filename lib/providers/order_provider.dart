import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/food_order.dart';

class OrderProvider extends ChangeNotifier {
  static const _activeOrdersKey = 'foodRushActiveOrders';
  static const _startedAtKey = 'foodRushActiveOrdersStartedAt';

  /// MVP: single timeline for all active orders created in one checkout.
  /// Each order still shows its own status but progression is shared.
  final List<FoodOrder> activeOrders = [];
  DateTime? _startedAt;
  int elapsedSeconds = 0;
  Timer? _timer;
  bool _feedbackShown = false;

  OrderProvider() {
    _restoreActiveOrders();
  }

  bool get hasOrders => activeOrders.isNotEmpty;

  double get progress => (elapsedSeconds / 60).clamp(0, 1);

  String get statusLabel {
    if (elapsedSeconds < 15) {
      return 'Restaurant is confirming your order...';
    }
    if (elapsedSeconds < 30) {
      return 'Chef is preparing your hot meal...';
    }
    if (elapsedSeconds < 45) {
      return 'Delivery Partner has picked up your order and is on the way!';
    }
    if (elapsedSeconds < 60) {
      return 'Almost there — food is arriving soon.';
    }
    return 'Delivered! Enjoy your meal!';
  }

  String get stageLabel {
    if (elapsedSeconds < 15) return 'Confirming';
    if (elapsedSeconds < 30) return 'Preparing';
    if (elapsedSeconds < 45) return 'On the way';
    return 'Delivered';
  }

  Future<void> _restoreActiveOrders() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_activeOrdersKey);
    final started = prefs.getString(_startedAtKey);
    if (raw == null || started == null) return;

    final decoded = jsonDecode(raw) as List<dynamic>;
    final orders = decoded
        .map((e) => FoodOrder.fromJson(Map<String, dynamic>.from(e as Map)))
        .toList();

    final startDate = DateTime.tryParse(started);
    if (startDate == null) return;

    final elapsed = DateTime.now().difference(startDate).inSeconds;
    activeOrders
      ..clear()
      ..addAll(orders);

    _startedAt = startDate;
    elapsedSeconds = elapsed.clamp(0, 60);

    if (elapsedSeconds >= 60) {
      for (var i = 0; i < activeOrders.length; i++) {
        activeOrders[i] = activeOrders[i].copyWith(status: 'Delivered');
      }
      _feedbackShown = true;
      await _saveState();
      notifyListeners();
      return;
    }

    _startTimer();
    notifyListeners();
  }

  Future<void> placeOrders(List<FoodOrder> orders) async {
    final now = DateTime.now();
    final placed = orders.map((o) => o.copyWith(status: 'Placed')).toList();

    activeOrders
      ..clear()
      ..addAll(placed);

    elapsedSeconds = 0;
    _startedAt = now;
    _feedbackShown = false;

    await _saveState();
    _startTimer();
    notifyListeners();
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) async {
      elapsedSeconds += 1;
      if (elapsedSeconds >= 60) {
        elapsedSeconds = 60;
        for (var i = 0; i < activeOrders.length; i++) {
          activeOrders[i] = activeOrders[i].copyWith(status: 'Delivered');
        }
        await _saveState();
        notifyListeners();
        _timer?.cancel();
        return;
      }
      await _saveState();
      notifyListeners();
    });
  }

  Future<void> dismissFeedback() async {
    _feedbackShown = true;
    notifyListeners();
  }

  bool get shouldShowFeedback {
    final anyDelivered = activeOrders.any((o) => o.status == 'Delivered');
    return anyDelivered && !_feedbackShown;
  }

  Future<void> clearOrders() async {
    activeOrders.clear();
    elapsedSeconds = 0;
    _feedbackShown = false;
    _timer?.cancel();

    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_activeOrdersKey);
    await prefs.remove(_startedAtKey);
    notifyListeners();
  }

  Future<void> _saveState() async {
    final prefs = await SharedPreferences.getInstance();
    if (activeOrders.isEmpty) {
      await prefs.remove(_activeOrdersKey);
      await prefs.remove(_startedAtKey);
      return;
    }

    await prefs.setString(
      _activeOrdersKey,
      jsonEncode(activeOrders.map((o) => o.toJson()).toList()),
    );
    await prefs.setString(
      _startedAtKey,
      _startedAt?.toIso8601String() ?? DateTime.now().toIso8601String(),
    );
  }
}

