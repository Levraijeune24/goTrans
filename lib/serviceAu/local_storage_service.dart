import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../model/userModel.dart';

class LocalStorageService {
  static const String _tokenKey = 'auth_token';
  static const String _userKey = 'auth_user';

  // Sauvegarder le token
  Future<void> saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, token);
  }

  // Récupérer le token
  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_tokenKey);
  }

  // Supprimer le token
  Future<void> clearToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
  }

  // Sauvegarder l'utilisateur (en JSON)
  Future<void> saveUser(User user) async {
    final prefs = await SharedPreferences.getInstance();
    final userJson = jsonEncode({
      'id': user.id,
      'name': user.name,
      'email': user.email,
      'number_phone': user.number_phone,

    });
    await prefs.setString(_userKey, userJson);
  }

  // Récupérer l'utilisateur
  Future<User?> getUser() async {
    final prefs = await SharedPreferences.getInstance();
    final userJson = prefs.getString(_userKey);
    if (userJson != null) {
      final Map<String, dynamic> userMap = jsonDecode(userJson);
      return User.fromJson(userMap);
    }
    return null;
  }

  // Supprimer l'utilisateur
  Future<void> clearUser() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_userKey);
  }
  static const String _roleInfoKey = 'user_role_info';

// Sauvegarder roleInfo
  Future<void> saveRoleInfo(RoleInfo roleInfo) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonStr = jsonEncode(roleInfo.toJson());
    await prefs.setString(_roleInfoKey, jsonStr);
  }

// Récupérer roleInfo
  Future<RoleInfo?> getRoleInfo() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonStr = prefs.getString(_roleInfoKey);
    if (jsonStr != null) {
      final Map<String, dynamic> jsonMap = jsonDecode(jsonStr);
      return RoleInfo.fromJson(jsonMap);
    }
    return null;
  }

// Supprimer roleInfo
  Future<void> clearRoleInfo() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_roleInfoKey);
  }

}
