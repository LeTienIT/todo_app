import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../domain/entities/user_entity.dart';

const CACHED_USER = 'CACHED_USER';

class AuthenticationLocalDataSource {
  Future<void> cacheUser(User user) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = json.encode({
      'id': user.id,
      'email': user.email,
      'displayName': user.displayName,
      'createdAt': user.createdAt?.toIso8601String(),
    });
    await prefs.setString(CACHED_USER, jsonString);
  }

  Future<User?> getCachedUser() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(CACHED_USER);
    if (jsonString == null) return null;

    final jsonMap = json.decode(jsonString) as Map<String, dynamic>;
    return User(
      id: jsonMap['id'] as String,
      email: jsonMap['email'] as String,
      displayName: jsonMap['displayName'],
      createdAt: DateTime.tryParse(jsonMap['createdAt'] ?? ''),
    );
  }

  Future<void> clearCachedUser() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(CACHED_USER);
  }
}