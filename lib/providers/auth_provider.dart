import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthProvider extends ChangeNotifier {
  Map<String, dynamic>? _user;
  String? _role;
  bool _isLoading = false;

  Map<String, dynamic>? get user => _user;
  String? get role => _role;
  bool get isLoading => _isLoading;
  bool get isAuthenticated => _user != null;

  // NUEVO: datos de escuela del usuario actual
  String? get schoolId => _user?['schoolId'];
  String? get schoolName => _user?['schoolName'];
  bool get hasSchool =>
      _user?['schoolId'] != null && (_user?['schoolId'] as String?)?.isNotEmpty == true;

  Future<bool> checkSession() async {
    _isLoading = true;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      final String? userData = prefs.getString('rolla_user');
      final String? userRole = prefs.getString('rolla_role');

      if (userData != null && userRole != null) {
        _user = jsonDecode(userData);
        _role = userRole;
        _isLoading = false;
        notifyListeners();
        return true;
      }
    } catch (e) {
      debugPrint('Error verificando sesión: $e');
    }

    _isLoading = false;
    notifyListeners();
    return false;
  }

  Future<bool> register({
    required String fullName,
    required String email,
    required String password,
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      final String? existingUser = prefs.getString('rolla_user_$email');
      if (existingUser != null) {
        _isLoading = false;
        notifyListeners();
        return false;
      }

      final newUser = {
        'id': 'usr_${DateTime.now().millisecondsSinceEpoch}',
        'fullName': fullName,
        'email': email,
        'password': password,
        'createdAt': DateTime.now().toIso8601String(),
        'schoolId': null,
        'schoolName': null,
      };

      await prefs.setString('rolla_user_$email', jsonEncode(newUser));
      await prefs.setString('rolla_current_email', email);

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      debugPrint('Error en registro: $e');
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> setRole(String role) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? email = prefs.getString('rolla_current_email');

      if (email != null) {
        final String? userData = prefs.getString('rolla_user_$email');
        if (userData != null) {
          final user = jsonDecode(userData);
          user['role'] = role;

          await prefs.setString('rolla_user_$email', jsonEncode(user));
          _user = user;
          _role = role;

          await prefs.setString('rolla_user', jsonEncode(user));
          await prefs.setString('rolla_role', role);
          notifyListeners();
        }
      }
    } catch (e) {
      debugPrint('Error asignando rol: $e');
    }
  }

  Future<bool> login({
    required String email,
    required String password,
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      final String? userData = prefs.getString('rolla_user_$email');
      if (userData == null) {
        _isLoading = false;
        notifyListeners();
        return false;
      }

      final user = jsonDecode(userData);

      if (user['password'] != password) {
        _isLoading = false;
        notifyListeners();
        return false;
      }

      _user = user;
      _role = user['role'];

      await prefs.setString('rolla_user', jsonEncode(user));
      await prefs.setString('rolla_role', user['role']);
      await prefs.setString('rolla_current_email', email);

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      debugPrint('Error en login: $e');
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Asignar escuela al usuario actual
  Future<void> assignSchool(String schoolId, String schoolName) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? email = prefs.getString('rolla_current_email');

      if (email != null && _user != null) {
        _user!['schoolId'] = schoolId;
        _user!['schoolName'] = schoolName;

        await prefs.setString('rolla_user', jsonEncode(_user));
        await prefs.setString('rolla_user_$email', jsonEncode(_user));
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error asignando escuela: $e');
    }
  }

  /// Quitar escuela (quedar libre)
  Future<void> leaveSchool() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? email = prefs.getString('rolla_current_email');

      if (email != null && _user != null) {
        _user!['schoolId'] = null;
        _user!['schoolName'] = null;

        await prefs.setString('rolla_user', jsonEncode(_user));
        await prefs.setString('rolla_user_$email', jsonEncode(_user));
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error saliendo de escuela: $e');
    }
  }

  /// Asignar escuela a OTRO usuario (usado cuando entrenador acepta solicitud)
  static Future<bool> assignSchoolToUser(
    String userEmail,
    String schoolId,
    String schoolName,
  ) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? userData = prefs.getString('rolla_user_$userEmail');

      if (userData != null) {
        final user = jsonDecode(userData);
        user['schoolId'] = schoolId;
        user['schoolName'] = schoolName;
        await prefs.setString('rolla_user_$userEmail', jsonEncode(user));

        // Si es el usuario actualmente logueado, actualizar sesión activa
        final currentEmail = prefs.getString('rolla_current_email');
        if (currentEmail == userEmail) {
          await prefs.setString('rolla_user', jsonEncode(user));
        }
        return true;
      }
      return false;
    } catch (e) {
      debugPrint('Error asignando escuela a usuario: $e');
      return false;
    }
  }

  Future<void> logout() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('rolla_user');
      await prefs.remove('rolla_role');
      await prefs.remove('rolla_current_email');

      _user = null;
      _role = null;
      notifyListeners();
    } catch (e) {
      debugPrint('Error en logout: $e');
    }
  }
}