import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/user_model.dart';

class AuthService {
  static const _usersKey = 'foodRushUsers';
  static const _sessionKey = 'foodRushSession';
  static const _legacyKey = 'foodRushUser';

  Future<List<UserModel>> getAllUsers() async {
    final prefs = await SharedPreferences.getInstance();
    await _migrateLegacyUser(prefs);

    final raw = prefs.getString(_usersKey);
    if (raw == null) return [];

    final list = jsonDecode(raw) as List<dynamic>;
    return list
        .map((e) => UserModel.fromJson(Map<String, dynamic>.from(e as Map)))
        .toList();
  }

  Future<UserModel?> getSessionUser() async {
    final prefs = await SharedPreferences.getInstance();
    final sessionId = prefs.getString(_sessionKey);
    if (sessionId == null) return null;

    final users = await getAllUsers();
    for (final user in users) {
      if (user.id == sessionId) return user;
    }
    return null;
  }

  Future<UserModel?> findByEmail(String email) async {
    final normalized = email.trim().toLowerCase();
    final users = await getAllUsers();
    for (final user in users) {
      if (user.email?.trim().toLowerCase() == normalized) return user;
    }
    return null;
  }

  Future<UserModel?> findByPhone(String phone) async {
    final normalized = phone.trim();
    final users = await getAllUsers();
    for (final user in users) {
      if (user.phone?.trim() == normalized) return user;
    }
    return null;
  }

  Future<UserModel?> findByContact(String contact) async {
    final value = contact.trim();
    if (value.contains('@')) return findByEmail(value);
    return findByPhone(value);
  }

  Future<String?> register({
    required String name,
    required String password,
    String? email,
    String? phone,
  }) async {
    final cleanEmail = email?.trim();
    final cleanPhone = phone?.trim();

    if ((cleanEmail == null || cleanEmail.isEmpty) &&
        (cleanPhone == null || cleanPhone.isEmpty)) {
      return 'Email ya phone number required hai.';
    }

    if (cleanEmail != null && cleanEmail.isNotEmpty && !isValidEmail(cleanEmail)) {
      return 'Valid email enter karo.';
    }

    if (cleanPhone != null && cleanPhone.isNotEmpty && !isValidPhone(cleanPhone)) {
      return 'Valid 10-digit phone number enter karo.';
    }

    if (cleanEmail != null && cleanEmail.isNotEmpty) {
      if (await findByEmail(cleanEmail) != null) {
        return 'Yeh email pehle se registered hai.';
      }
    }

    if (cleanPhone != null && cleanPhone.isNotEmpty) {
      if (await findByPhone(cleanPhone) != null) {
        return 'Yeh phone number pehle se registered hai.';
      }
    }

    final user = UserModel(
      id: 'fr-${DateTime.now().millisecondsSinceEpoch}',
      name: name.trim(),
      email: cleanEmail?.isEmpty == true ? null : cleanEmail,
      phone: cleanPhone?.isEmpty == true ? null : cleanPhone,
      password: password,
    );

    final users = await getAllUsers()..add(user);
    await _saveUsers(users);
    await setSession(user);
    return null;
  }

  Future<String?> login({
    required String contact,
    required String password,
  }) async {
    final user = await findByContact(contact);
    if (user == null) {
      return contact.contains('@')
          ? 'Yeh email registered nahi hai.'
          : 'Yeh phone number registered nahi hai.';
    }

    if (user.password != password) {
      return 'Galat password. Dobara try karo.';
    }

    await setSession(user);
    return null;
  }

  Future<void> setSession(UserModel user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_sessionKey, user.id);
  }

  Future<void> clearSession() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_sessionKey);
  }

  bool isValidEmail(String email) {
    return RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$').hasMatch(email.trim());
  }

  bool isValidPhone(String phone) {
    return RegExp(r'^\d{10}$').hasMatch(phone.trim());
  }

  bool isValidContact(String contact) {
    final value = contact.trim();
    return isValidPhone(value) || isValidEmail(value);
  }

  String contactLabel(String contact) {
    final value = contact.trim();
    if (isValidPhone(value)) return '+91 $value';
    return value;
  }

  Future<void> _saveUsers(List<UserModel> users) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _usersKey,
      jsonEncode(users.map((u) => u.toJson()).toList()),
    );
  }

  Future<void> _migrateLegacyUser(SharedPreferences prefs) async {
    final legacyRaw = prefs.getString(_legacyKey);
    if (legacyRaw == null) return;

    final legacy = UserModel.fromLegacyJson(
      Map<String, dynamic>.from(jsonDecode(legacyRaw) as Map),
    );

    final users = <UserModel>[];
    final existing = prefs.getString(_usersKey);
    if (existing != null) {
      final list = jsonDecode(existing) as List<dynamic>;
      users.addAll(
        list.map((e) => UserModel.fromJson(Map<String, dynamic>.from(e as Map))),
      );
    }

    final alreadyExists = users.any((u) {
      if (legacy.hasEmail && u.email == legacy.email) return true;
      if (legacy.hasPhone && u.phone == legacy.phone) return true;
      return false;
    });

    if (!alreadyExists && (legacy.hasEmail || legacy.hasPhone)) {
      users.add(legacy);
      await _saveUsers(users);
      await prefs.setString(_sessionKey, legacy.id);
    }

    await prefs.remove(_legacyKey);
  }
}
