import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/athlete_model.dart';
import '../models/user_model.dart';
import 'auth_repository.dart';

class LocalAuthRepository implements AuthRepository {
  static const _currentUserKey = 'rolla_user';
  static const _currentRoleKey = 'rolla_role';
  static const _currentEmailKey = 'rolla_current_email';
  static const _cachedAthleteKey = 'cached_athlete';

  String _userKey(String email) => 'rolla_user_$email';

  String _publicAthleteKey(String email) => 'rolla_public_profile_$email';

  @override
  Future<UserModel?> getUser(String email) async {
    final prefs = await SharedPreferences.getInstance();
    return _decodeUser(prefs.getString(_userKey(email)));
  }

  @override
  Future<void> saveUser(UserModel user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_userKey(user.email), jsonEncode(user.toJson()));
  }

  @override
  Future<UserModel?> getCurrentUser() async {
    final prefs = await SharedPreferences.getInstance();
    return _decodeUser(prefs.getString(_currentUserKey));
  }

  @override
  Future<String?> getCurrentEmail() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_currentEmailKey);
  }

  @override
  Future<String?> getCurrentRole() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_currentRoleKey);
  }

  @override
  Future<void> setCurrentEmail(String email) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_currentEmailKey, email);
  }

  @override
  Future<void> saveSession(UserModel user) async {
    final role = user.role;
    if (role == null) {
      throw StateError('No se puede guardar una sesión sin rol.');
    }

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_currentUserKey, jsonEncode(user.toJson()));
    await prefs.setString(_currentRoleKey, role);
    await prefs.setString(_currentEmailKey, user.email);
  }

  @override
  Future<void> clearSession() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_currentUserKey);
    await prefs.remove(_currentRoleKey);
    await prefs.remove(_currentEmailKey);
  }

  @override
  Future<bool> assignSchoolToUser({
    required String email,
    required String? schoolId,
    required String? schoolName,
  }) async {
    final user = await getUser(email);
    if (user == null) return false;

    final updatedUser = user.copyWith(
      schoolId: schoolId,
      schoolName: schoolName,
    );
    await saveUser(updatedUser);

    if (await getCurrentEmail() == email) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_currentUserKey, jsonEncode(updatedUser.toJson()));
    }
    return true;
  }

  @override
  Future<AthleteModel?> getCachedAthlete() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getString(_cachedAthleteKey);
    if (data == null) return null;
    return AthleteModel.fromJson(jsonDecode(data) as Map<String, dynamic>);
  }

  @override
  Future<void> saveCachedAthlete(AthleteModel athlete) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_cachedAthleteKey, jsonEncode(athlete.toJson()));
  }

  @override
  Future<void> savePublicAthlete(AthleteModel athlete) async {
    final email = athlete.email;
    if (email == null) return;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _publicAthleteKey(email),
      jsonEncode(athlete.toJson()),
    );
  }

  @override
  Future<AthleteModel?> getPublicAthlete(String email) async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getString(_publicAthleteKey(email));
    if (data == null) return null;
    return AthleteModel.fromJson(jsonDecode(data) as Map<String, dynamic>);
  }

  UserModel? _decodeUser(String? data) {
    if (data == null) return null;
    return UserModel.fromJson(jsonDecode(data) as Map<String, dynamic>);
  }
}
