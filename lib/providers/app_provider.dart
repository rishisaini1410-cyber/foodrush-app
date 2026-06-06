import 'package:flutter/material.dart';
import '../data/filters.dart';
import '../data/mode_copy.dart';
import '../data/restaurants_data.dart';
import '../models/restaurant.dart';

class AppProvider extends ChangeNotifier {
  String activeMode = 'veg';
  String activeFilter = 'All';
  String query = '';
  /// `food` = restaurants | `rushmart` = grocery instamart mode
  String serviceMode = 'food';
  String martCategory = 'All';
  String martQuery = '';

  List<String> get filters => Filters.forMode(activeMode);
  ModeCopyData get copy => ModeCopy.forMode(activeMode);

  List<Restaurant> get visibleRestaurants {
    final q = query.trim().toLowerCase();

    return allRestaurants.where((r) {
      if (r.diet != activeMode) return false;

      final matchesFilter = activeFilter == 'All' ||
          r.category == activeFilter ||
          r.tags.contains(activeFilter) ||
          r.menu.any((item) => item.tags.contains(activeFilter));

      if (!matchesFilter) return false;
      if (q.isEmpty) return true;

      final searchable = [
        r.name,
        r.category,
        r.zone,
        ...r.tags,
        ...r.menu.expand((m) => [m.name, m.note, ...m.tags]),
      ].join(' ').toLowerCase();

      return searchable.contains(q);
    }).toList();
  }

  List<Restaurant> get popularRestaurants {
    final list = visibleRestaurants.toList()
      ..sort((a, b) => b.ratingValue.compareTo(a.ratingValue));
    return list;
  }

  List<Restaurant> get restaurantsByDistance {
    final list = visibleRestaurants.toList()
      ..sort((a, b) => a.distanceKm.compareTo(b.distanceKm));
    return list;
  }

  void setMode(String mode) {
    if (mode == activeMode) return;
    activeMode = mode;
    activeFilter = 'All';
    query = '';
    notifyListeners();
  }

  void setFilter(String filter) {
    activeFilter = filter;
    notifyListeners();
  }

  void setQuery(String value) {
    query = value;
    notifyListeners();
  }

  void reset() {
    activeFilter = 'All';
    query = '';
    notifyListeners();
  }

  void setServiceMode(String mode) {
    if (mode == serviceMode) return;
    serviceMode = mode;
    notifyListeners();
  }

  void setMartCategory(String category) {
    martCategory = category;
    notifyListeners();
  }

  void setMartQuery(String value) {
    martQuery = value;
    notifyListeners();
  }

  bool get isFoodMode => serviceMode == 'food';
  bool get isRushMartMode => serviceMode == 'rushmart';
}