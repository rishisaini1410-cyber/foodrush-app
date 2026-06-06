import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/food_order.dart';

class OrderProvider extends ChangeNotifier {
  static const _activeOrderKey = 'foodRushActiveOrder';
  static const _startedAtKey = 'foodRushActiveOrderStartedAt';

  FoodOrder? activeOrder;
  int elapsedSeconds = 0;
  DateTime? _startedAt;
  Timer? _timer;
  bool _feedbackShown = false;

  OrderProvider() {
    _restoreActiveOrder();
  }

  bool get hasOrder => activeOrder != null;
  bool get isDelivered => activeOrder?.status == 'Delivered';
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

  Future<void> _restoreActiveOrder() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_activeOrderKey);
    final started = prefs.getString(_startedAtKey);
    if (raw == null || started == null) return;

    final order = FoodOrder.fromJson(jsonDecode(raw) as Map<String, dynamic>);
    final startDate = DateTime.tryParse(started);
    if (startDate == null) return;

    final elapsed = DateTime.now().difference(startDate).inSeconds;
    activeOrder = order;
    _startedAt = startDate;
    elapsedSeconds = elapsed.clamp(0, 60);

    if (elapsedSeconds >= 60) {
      activeOrder = activeOrder?.copyWith(status: 'Delivered');
      _feedbackShown = true;
      await _saveState();
      notifyListeners();
      return;
    }

    _startTimer();
    notifyListeners();
  }

  Future<void> placeOrder(FoodOrder order) async {
    activeOrder = order.copyWith(status: 'Placed');
    elapsedSeconds = 0;
    _startedAt = DateTime.now();
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
        activeOrder = activeOrder?.copyWith(status: 'Delivered');
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

  bool get shouldShowFeedback => isDelivered && !_feedbackShown;

  Future<void> clearOrder() async {
    activeOrder = null;
    elapsedSeconds = 0;
    _feedbackShown = false;
    _timer?.cancel();
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_activeOrderKey);
    await prefs.remove(_startedAtKey);
    notifyListeners();
  }

  Future<void> _saveState() async {
    final prefs = await SharedPreferences.getInstance();
    if (activeOrder == null) {
      await prefs.remove(_activeOrderKey);
      await prefs.remove(_startedAtKey);
      return;
    }
    await prefs.setString(_activeOrderKey, jsonEncode(activeOrder!.toJson()));
    await prefs.setString(
      _startedAtKey,
      _startedAt?.toIso8601String() ?? DateTime.now().toIso8601String(),
    );
  }
}
