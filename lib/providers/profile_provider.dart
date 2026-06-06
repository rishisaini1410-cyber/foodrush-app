import 'package:flutter/material.dart';

import '../models/favorite_item.dart';
import '../models/food_order.dart';
import '../models/user_model.dart';
import '../models/voucher.dart';
import '../services/profile_storage_service.dart';

enum StatementPeriod { thisMonth, lastMonth, last3Months, last6Months, all }

class ProfileProvider extends ChangeNotifier {
  final ProfileStorageService _storage = ProfileStorageService();

  UserModel? user;
  List<FoodOrder> orders = [];
  List<FavoriteItem> favorites = [];
  List<Voucher> vouchers = [];
  StatementPeriod statementPeriod = StatementPeriod.thisMonth;
  bool callMasking = true;

  Future<void> initForUser(UserModel u) async {
    user = u;
    orders = await _storage.loadOrders(u.id);
    favorites = await _storage.loadFavorites(u.id);
    vouchers = await _storage.loadVouchers(u.id);
    callMasking = await _storage.loadCallMasking(u.id);
    notifyListeners();
  }

  Future<void> setCallMasking(bool enabled) async {
    if (user == null) return;
    callMasking = enabled;
    await _storage.saveCallMasking(user!.id, enabled);
    notifyListeners();
  }

  void setStatementPeriod(StatementPeriod period) {
    statementPeriod = period;
    notifyListeners();
  }

  List<FoodOrder> get pastOrdersSorted {
    final list = List<FoodOrder>.from(orders)
      ..sort((a, b) => b.orderedAt.compareTo(a.orderedAt));
    return list;
  }

  List<FoodOrder> get statementOrders {
    final now = DateTime.now();

    switch (statementPeriod) {
      case StatementPeriod.all:
        return pastOrdersSorted;
      case StatementPeriod.lastMonth:
        final from = DateTime(now.year, now.month - 1, 1);
        final end = DateTime(now.year, now.month, 1);
        return pastOrdersSorted
            .where((o) =>
                !o.orderedAt.isBefore(from) && o.orderedAt.isBefore(end))
            .toList();
      case StatementPeriod.thisMonth:
        final from = DateTime(now.year, now.month, 1);
        return pastOrdersSorted
            .where((o) => !o.orderedAt.isBefore(from))
            .toList();
      case StatementPeriod.last3Months:
        final from = DateTime(now.year, now.month - 2, 1);
        return pastOrdersSorted
            .where((o) => !o.orderedAt.isBefore(from))
            .toList();
      case StatementPeriod.last6Months:
        final from = DateTime(now.year, now.month - 5, 1);
        return pastOrdersSorted
            .where((o) => !o.orderedAt.isBefore(from))
            .toList();
    }
  }

  int get statementTotal =>
      statementOrders.fold(0, (sum, o) => sum + o.total);

  String get statementPeriodLabel {
    switch (statementPeriod) {
      case StatementPeriod.thisMonth:
        return 'This month';
      case StatementPeriod.lastMonth:
        return 'Last month';
      case StatementPeriod.last3Months:
        return 'Last 3 months';
      case StatementPeriod.last6Months:
        return 'Last 6 months';
      case StatementPeriod.all:
        return 'All time';
    }
  }

  Future<void> addOrder(FoodOrder order) async {
    if (user == null) return;
    orders = [order, ...orders];
    await _storage.saveOrders(user!.id, orders);
    notifyListeners();
  }

  Future<void> scratchVoucher(String id) async {
    if (user == null) return;
    vouchers = vouchers
        .map((v) => v.id == id ? v.copyWith(scratched: true) : v)
        .toList();
    await _storage.saveVouchers(user!.id, vouchers);
    notifyListeners();
  }

  void clear() {
    user = null;
    orders = [];
    favorites = [];
    vouchers = [];
    notifyListeners();
  }
}
