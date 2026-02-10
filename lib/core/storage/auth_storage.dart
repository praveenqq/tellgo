// lib/core/storage/auth_storage.dart
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tellgo_app/screens/auth/models/user.dart';

class AuthStorage {
  static const _kV2 = 'auth_user_v2';
  static const _kLegacy = 'auth_user';
  User? _cache;

  Future<void> saveUser(User u) async {
    _cache = u;
    final sp = await SharedPreferences.getInstance();
    await sp.setString(_kV2, jsonEncode(u.toJson()));
  }

  Future<User?> readUser() async {
    if (_cache != null) return _cache;
    final sp = await SharedPreferences.getInstance();
    final raw = sp.getString(_kV2) ?? sp.getString(_kLegacy);
    if (raw == null) return null;
    try {
      final map = jsonDecode(raw) as Map<String, dynamic>;
      if (map.containsKey('userId') || map.containsKey('userName')) {
        _cache = User.fromJson(map);
      } else {
        // migrate legacy minimal
        _cache = User(
          userId: _asInt(map['id']),
          userName: map['username']?.toString(),
          fullName: map['displayName']?.toString(),
        );
        await saveUser(_cache!);
        await sp.remove(_kLegacy);
      }
      return _cache;
    } catch (_) {
      return null;
    }
  }

  Future<void> clear() async {
    _cache = null;
    final sp = await SharedPreferences.getInstance();
    await sp.remove(_kV2);
    await sp.remove(_kLegacy);
  }

  Future<bool> isLoggedIn() async => (await readUser()) != null;
}

int? _asInt(dynamic v) {
  if (v == null) return null;
  if (v is int) return v;
  if (v is num) return v.toInt();
  return int.tryParse(v.toString());
}

