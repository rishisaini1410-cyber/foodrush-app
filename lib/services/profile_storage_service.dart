import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/favorite_item.dart';
import '../models/food_order.dart';
import '../models/saved_location.dart';
import '../models/voucher.dart';

class ProfileStorageService {
  String _prefix(String userId) => 'foodRush_$userId';

  Future<List<SavedLocation>> loadLocations(String userId) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString('${_prefix(userId)}_locations');
    if (raw == null) return _defaultLocations();
    final list = jsonDecode(raw) as List<dynamic>;
    final locations = list
        .map((e) => SavedLocation.fromJson(Map<String, dynamic>.from(e as Map)))
        .toList();
    return locations.isEmpty ? _defaultLocations() : locations;
  }

  Future<void> saveLocations(String userId, List<SavedLocation> locations) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      '${_prefix(userId)}_locations',
      jsonEncode(locations.map((l) => l.toJson()).toList()),
    );
  }

  Future<String?> loadSelectedLocationId(String userId) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('${_prefix(userId)}_selectedLoc');
  }

  Future<void> saveSelectedLocationId(String userId, String? id) async {
    final prefs = await SharedPreferences.getInstance();
    if (id == null) {
      await prefs.remove('${_prefix(userId)}_selectedLoc');
    } else {
      await prefs.setString('${_prefix(userId)}_selectedLoc', id);
    }
  }

  Future<String?> loadCurrentLocationAddress(String userId) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('${_prefix(userId)}_currentLoc');
  }

  Future<void> saveCurrentLocationAddress(String userId, String address) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('${_prefix(userId)}_currentLoc', address);
  }

  Future<String?> loadLastOrderAddress(String userId) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('${_prefix(userId)}_lastOrderLoc');
  }

  Future<void> saveLastOrderAddress(String userId, String address) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('${_prefix(userId)}_lastOrderLoc', address);
  }

  Future<List<FoodOrder>> loadOrders(String userId) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString('${_prefix(userId)}_orders');
    if (raw == null) return _sampleOrders();
    final list = jsonDecode(raw) as List<dynamic>;
    final orders = list
        .map((e) => FoodOrder.fromJson(Map<String, dynamic>.from(e as Map)))
        .toList();
    return orders.isEmpty ? _sampleOrders() : orders;
  }

  Future<void> saveOrders(String userId, List<FoodOrder> orders) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      '${_prefix(userId)}_orders',
      jsonEncode(orders.map((o) => o.toJson()).toList()),
    );
  }

  Future<List<FavoriteItem>> loadFavorites(String userId) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString('${_prefix(userId)}_favorites');
    if (raw == null) return _sampleFavorites();
    final list = jsonDecode(raw) as List<dynamic>;
    final favs = list
        .map((e) => FavoriteItem.fromJson(Map<String, dynamic>.from(e as Map)))
        .toList();
    return favs.isEmpty ? _sampleFavorites() : favs;
  }

  Future<void> saveFavorites(String userId, List<FavoriteItem> favorites) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      '${_prefix(userId)}_favorites',
      jsonEncode(favorites.map((f) => f.toJson()).toList()),
    );
  }

  Future<List<Voucher>> loadVouchers(String userId) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString('${_prefix(userId)}_vouchers');
    if (raw == null) return _defaultVouchers();
    final list = jsonDecode(raw) as List<dynamic>;
    return list
        .map((e) => Voucher.fromJson(Map<String, dynamic>.from(e as Map)))
        .toList();
  }

  Future<void> saveVouchers(String userId, List<Voucher> vouchers) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      '${_prefix(userId)}_vouchers',
      jsonEncode(vouchers.map((v) => v.toJson()).toList()),
    );
  }

  Future<bool> loadCallMasking(String userId) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('${_prefix(userId)}_callMasking') ?? true;
  }

  Future<void> saveCallMasking(String userId, bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('${_prefix(userId)}_callMasking', enabled);
  }

  List<SavedLocation> _defaultLocations() => [
        const SavedLocation(
          id: 'home',
          label: 'Home',
          address: 'B-42, Rajouri Garden, New Delhi',
          landmark: 'Near metro gate 3',
          isDefault: true,
        ),
        const SavedLocation(
          id: 'work',
          label: 'Work',
          address: 'Cyber Hub, DLF Phase 2, Gurugram',
          landmark: 'Tower B, 5th floor',
        ),
        const SavedLocation(
          id: 'mom',
          label: 'Mom\'s place',
          address: 'Sector 62, Noida',
          landmark: 'Opposite city centre',
        ),
      ];

  List<FoodOrder> _sampleOrders() {
    final now = DateTime.now();
    return [
      FoodOrder(
        id: 'ord-1',
        restaurantName: 'Spice Route Kitchen',
        items: ['Paneer Butter Masala', 'Garlic Naan', 'Lassi'],
        total: 489,
        orderedAt: now.subtract(const Duration(days: 2)),
        deliveryAddress: 'B-42, Rajouri Garden, New Delhi',
      ),
      FoodOrder(
        id: 'ord-2',
        restaurantName: 'Tandoori Nights',
        items: ['Chicken Biryani', 'Raita'],
        total: 349,
        orderedAt: now.subtract(const Duration(days: 8)),
        deliveryAddress: 'Cyber Hub, DLF Phase 2, Gurugram',
        status: 'Delivered',
      ),
      FoodOrder(
        id: 'ord-3',
        restaurantName: 'Green Bowl Cafe',
        items: ['Veg Thali', 'Fresh Juice'],
        total: 279,
        orderedAt: now.subtract(const Duration(days: 15)),
        deliveryAddress: 'Sector 62, Noida',
      ),
      FoodOrder(
        id: 'ord-4',
        restaurantName: 'Street Wok',
        items: ['Hakka Noodles', 'Manchurian'],
        total: 319,
        orderedAt: now.subtract(const Duration(days: 22)),
        deliveryAddress: 'B-42, Rajouri Garden, New Delhi',
      ),
      FoodOrder(
        id: 'ord-5',
        restaurantName: 'Dosa Corner',
        items: ['Masala Dosa', 'Filter Coffee'],
        total: 199,
        orderedAt: now.subtract(const Duration(days: 35)),
        deliveryAddress: 'Sector 62, Noida',
      ),
      FoodOrder(
        id: 'ord-6',
        restaurantName: 'Pizza Junction',
        items: ['Farmhouse Pizza', 'Garlic Bread'],
        total: 599,
        orderedAt: now.subtract(const Duration(days: 48)),
        deliveryAddress: 'Cyber Hub, DLF Phase 2, Gurugram',
      ),
    ];
  }

  List<FavoriteItem> _sampleFavorites() => const [
        FavoriteItem(
          id: 'fav-1',
          name: 'Paneer Butter Masala',
          restaurantName: 'Spice Route Kitchen',
          price: 249,
          diet: 'veg',
        ),
        FavoriteItem(
          id: 'fav-2',
          name: 'Chicken Biryani',
          restaurantName: 'Tandoori Nights',
          price: 299,
          diet: 'nonveg',
        ),
        FavoriteItem(
          id: 'fav-3',
          name: 'Veg Thali',
          restaurantName: 'Green Bowl Cafe',
          price: 179,
          diet: 'veg',
        ),
      ];

  List<Voucher> _defaultVouchers() {
    final now = DateTime.now();
    return [
      Voucher(
        id: 'v1',
        title: 'Welcome Rush',
        code: 'RUSH50',
        discountText: '₹50 off on orders above ₹299',
        validUntil: now.add(const Duration(days: 30)),
      ),
      Voucher(
        id: 'v2',
        title: 'Weekend Feast',
        code: 'FEAST20',
        discountText: '20% off up to ₹120',
        validUntil: now.add(const Duration(days: 14)),
      ),
      Voucher(
        id: 'v3',
        title: 'Free Delivery',
        code: 'FREEDEL',
        discountText: 'Free delivery on next order',
        validUntil: now.add(const Duration(days: 7)),
      ),
    ];
  }
}
