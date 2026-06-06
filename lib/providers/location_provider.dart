import 'package:flutter/material.dart';

import '../models/saved_location.dart';
import '../services/profile_storage_service.dart';

/// `current` = GPS-detected address (id: current)
/// `selected` = user choice shown on home bar
class LocationProvider extends ChangeNotifier {
  final ProfileStorageService _storage = ProfileStorageService();

  String? _userId;
  List<SavedLocation> savedLocations = [];
  String? currentLocationAddress;
  String? lastOrderAddress;
  String? selectedLocationId;
  bool detecting = false;

  static const currentLocationId = 'current';

  bool get hasCurrentLocation =>
      currentLocationAddress != null && currentLocationAddress!.isNotEmpty;

  Future<void> initForUser(String userId) async {
    _userId = userId;
    savedLocations = await _storage.loadLocations(userId);
    currentLocationAddress = await _storage.loadCurrentLocationAddress(userId);
    lastOrderAddress = await _storage.loadLastOrderAddress(userId);
    selectedLocationId = await _storage.loadSelectedLocationId(userId);

    if (selectedLocationId == null) {
      if (hasCurrentLocation) {
        selectedLocationId = currentLocationId;
      } else {
        final defaultLoc = savedLocations.where((l) => l.isDefault).firstOrNull;
        selectedLocationId = defaultLoc?.id ?? savedLocations.firstOrNull?.id;
      }
    }
    notifyListeners();
  }

  String get displayAddress {
    if (selectedLocationId == currentLocationId && hasCurrentLocation) {
      return currentLocationAddress!;
    }
    final loc = savedLocations
        .where((l) => l.id == selectedLocationId)
        .firstOrNull;
    if (loc != null) return loc.displayLine;
    if (hasCurrentLocation) return currentLocationAddress!;
    if (savedLocations.isNotEmpty) return savedLocations.first.displayLine;
    return 'Set delivery location';
  }

  String get displayLabel {
    if (selectedLocationId == currentLocationId) return 'Current location';
    final loc = savedLocations
        .where((l) => l.id == selectedLocationId)
        .firstOrNull;
    return loc?.label ?? 'Delivery to';
  }

  SavedLocation? get selectedSavedLocation {
    if (selectedLocationId == currentLocationId) return null;
    return savedLocations.where((l) => l.id == selectedLocationId).firstOrNull;
  }

  Future<void> detectCurrentLocation() async {
    if (_userId == null) return;
    detecting = true;
    notifyListeners();

    await Future.delayed(const Duration(milliseconds: 1500));

    const detected = 'Connaught Place, Block A, New Delhi 110001';
    currentLocationAddress = detected;
    selectedLocationId = currentLocationId;
    await _storage.saveCurrentLocationAddress(_userId!, detected);
    await _storage.saveSelectedLocationId(_userId!, currentLocationId);

    detecting = false;
    notifyListeners();
  }

  Future<void> selectLocation(String id) async {
    if (_userId == null) return;
    selectedLocationId = id;
    await _storage.saveSelectedLocationId(_userId!, id);
    notifyListeners();
  }

  Future<void> setLastOrderAddress(String address) async {
    if (_userId == null) return;
    lastOrderAddress = address;
    await _storage.saveLastOrderAddress(_userId!, address);
    notifyListeners();
  }

  Future<void> addSavedLocation({
    required String label,
    required String address,
    String? landmark,
  }) async {
    if (_userId == null) return;
    final loc = SavedLocation(
      id: 'loc-${DateTime.now().millisecondsSinceEpoch}',
      label: label,
      address: address,
      landmark: landmark,
    );
    savedLocations = [...savedLocations, loc];
    await _storage.saveLocations(_userId!, savedLocations);
    notifyListeners();
  }
}

extension _FirstOrNull<E> on Iterable<E> {
  E? get firstOrNull {
    final it = iterator;
    if (!it.moveNext()) return null;
    return it.current;
  }
}
