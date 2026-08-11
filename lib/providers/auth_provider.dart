import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthProvider extends ChangeNotifier {
  // Usuario actual en sesión
  Map<String, dynamic>? _user;
  String? _role; // 'athlete' o 'coach'
  bool _isLoading = false;

  // Getters
  Map<String, dynamic>? get user => _user;
  String? get role => _role;
  bool get isLoading => _isLoading;
  bool get isAuthenticated => _user != null;

  /// Verificar si hay sesión activa al iniciar la app
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

  /// Registrar un nuevo usuario
  Future<bool> register({
    required String fullName,
    required String email,
    required String password,
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();

      // Verificar si el correo ya existe
      final String? existingUser = prefs.getString('rolla_user_$email');
      if (existingUser != null) {
        _isLoading = false;
        notifyListeners();
        return false; // Usuario ya existe
      }

      // Crear usuario
      final newUser = {
        'id': 'usr_${DateTime.now().millisecondsSinceEpoch}',
        'fullName': fullName,
        'email': email,
        'password': password, // En producción: hashear
        'createdAt': DateTime.now().toIso8601String(),
      };

      // Guardar usuario
      await prefs.setString('rolla_user_$email', jsonEncode(newUser));

      // Guardar como usuario actual (pero sin rol aún)
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

  /// Asignar rol después del registro
  Future<void> setRole(String role) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? email = prefs.getString('rolla_current_email');

      if (email != null) {
        // Obtener el usuario guardado
        final String? userData = prefs.getString('rolla_user_$email');
        if (userData != null) {
          final user = jsonDecode(userData);
          user['role'] = role;

          // Actualizar usuario
          await prefs.setString('rolla_user_$email', jsonEncode(user));

          // Establecer sesión activa
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

  /// Iniciar sesión
  Future<bool> login({
    required String email,
    required String password,
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();

      // Buscar usuario
      final String? userData = prefs.getString('rolla_user_$email');
      if (userData == null) {
        _isLoading = false;
        notifyListeners();
        return false; // Usuario no existe
      }

      final user = jsonDecode(userData);

      // Verificar contraseña
      if (user['password'] != password) {
        _isLoading = false;
        notifyListeners();
        return false; // Contraseña incorrecta
      }

      // Establecer sesión
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

  /// Cerrar sesión
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