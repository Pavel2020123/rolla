import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_model.dart';

class AuthProvider extends ChangeNotifier {
  UserModel? _user;
  String? _role;
  bool _isLoading = false;

  UserModel? get user => _user;
  String? get role => _role;
  bool get isLoading => _isLoading;
  bool get isAuthenticated => _user != null;

  String? get schoolId => _user?.schoolId;
  String? get schoolName => _user?.schoolName;
  bool get hasSchool => _user?.schoolId?.isNotEmpty == true;

  Future<bool> checkSession() async {
    _isLoading = true;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      final String? userData = prefs.getString('rolla_user');
      final String? userRole = prefs.getString('rolla_role');

      if (userData != null && userRole != null) {
        _user = UserModel.fromJson(
          jsonDecode(userData) as Map<String, dynamic>,
        );
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

      final parts = fullName.trim().split(' ');
      final firstName = parts.first;
      final lastName = parts.length > 1 ? parts.sublist(1).join(' ') : '';

      final now = DateTime.now();
      final newUser = UserModel(
        id: 'usr_${now.millisecondsSinceEpoch}',
        fullName: fullName.trim(),
        firstName: firstName,
        lastName: lastName,
        email: email,
        password: password,
        createdAt: now,
      );

      await prefs.setString('rolla_user_$email', jsonEncode(newUser.toJson()));
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
          final storedUser = UserModel.fromJson(
            jsonDecode(userData) as Map<String, dynamic>,
          );
          final user = storedUser.copyWith(role: role);

          await prefs.setString('rolla_user_$email', jsonEncode(user.toJson()));
          _user = user;
          _role = role;

          await prefs.setString('rolla_user', jsonEncode(user.toJson()));
          await prefs.setString('rolla_role', role);
          notifyListeners();
        }
      }
    } catch (e) {
      debugPrint('Error asignando rol: $e');
    }
  }

  Future<bool> login({required String email, required String password}) async {
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

      final user = UserModel.fromJson(
        jsonDecode(userData) as Map<String, dynamic>,
      );

      if (user.password != password) {
        _isLoading = false;
        notifyListeners();
        return false;
      }

      if (user.role == null) {
        _isLoading = false;
        notifyListeners();
        return false;
      }

      _user = user;
      _role = user.role;

      await prefs.setString('rolla_user', jsonEncode(user.toJson()));
      await prefs.setString('rolla_role', user.role!);
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

  /// Asignar escuela al usuario actual + guardar historial
  Future<void> assignSchool(String schoolId, String schoolName) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? email = prefs.getString('rolla_current_email');

      if (email != null && _user != null) {
        final String userId = _user!.id;

        // Guardar escuela anterior en historial si tenía
        final String? prevSchoolId = _user!.schoolId;
        if (prevSchoolId != null && prevSchoolId.isNotEmpty) {
          final String? existingHistory = prefs.getString(
            'rolla_school_history_$userId',
          );
          List<dynamic> history = existingHistory != null
              ? jsonDecode(existingHistory)
              : [];

          // Cerrar entrada anterior
          for (var entry in history) {
            if (entry['leftAt'] == null) {
              entry['leftAt'] = DateTime.now().toIso8601String();
              entry['reason'] = 'transfer';
            }
          }

          // Nueva entrada
          history.add({
            'id': 'hist_${DateTime.now().millisecondsSinceEpoch}',
            'schoolId': schoolId,
            'schoolName': schoolName,
            'joinedAt': DateTime.now().toIso8601String(),
            'leftAt': null,
            'reason': null,
          });

          await prefs.setString(
            'rolla_school_history_$userId',
            jsonEncode(history),
          );
        } else {
          // Primera vez que entra a una escuela
          final String? existingHistory = prefs.getString(
            'rolla_school_history_$userId',
          );
          List<dynamic> history = existingHistory != null
              ? jsonDecode(existingHistory)
              : [];
          history.add({
            'id': 'hist_${DateTime.now().millisecondsSinceEpoch}',
            'schoolId': schoolId,
            'schoolName': schoolName,
            'joinedAt': DateTime.now().toIso8601String(),
            'leftAt': null,
            'reason': null,
          });
          await prefs.setString(
            'rolla_school_history_$userId',
            jsonEncode(history),
          );
        }

        _user = _user!.copyWith(schoolId: schoolId, schoolName: schoolName);

        await prefs.setString('rolla_user', jsonEncode(_user!.toJson()));
        await prefs.setString('rolla_user_$email', jsonEncode(_user!.toJson()));
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error asignando escuela: $e');
    }
  }

  /// Quitar escuela (quedar libre) + guardar historial
  Future<void> leaveSchool() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? email = prefs.getString('rolla_current_email');

      if (email != null && _user != null) {
        final String userId = _user!.id;
        final String? prevSchoolId = _user!.schoolId;

        if (prevSchoolId != null && prevSchoolId.isNotEmpty) {
          final String? existingHistory = prefs.getString(
            'rolla_school_history_$userId',
          );
          List<dynamic> history = existingHistory != null
              ? jsonDecode(existingHistory)
              : [];

          for (var entry in history) {
            if (entry['leftAt'] == null) {
              entry['leftAt'] = DateTime.now().toIso8601String();
              entry['reason'] = 'free_agent';
            }
          }

          await prefs.setString(
            'rolla_school_history_$userId',
            jsonEncode(history),
          );
        }

        _user = _user!.copyWith(schoolId: null, schoolName: null);

        await prefs.setString('rolla_user', jsonEncode(_user!.toJson()));
        await prefs.setString('rolla_user_$email', jsonEncode(_user!.toJson()));
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
        final storedUser = UserModel.fromJson(
          jsonDecode(userData) as Map<String, dynamic>,
        );
        final user = storedUser.copyWith(
          schoolId: schoolId.isEmpty ? null : schoolId,
          schoolName: schoolName.isEmpty ? null : schoolName,
        );
        await prefs.setString(
          'rolla_user_$userEmail',
          jsonEncode(user.toJson()),
        );

        // Si es el usuario actualmente logueado, actualizar sesión activa
        final currentEmail = prefs.getString('rolla_current_email');
        if (currentEmail == userEmail) {
          await prefs.setString('rolla_user', jsonEncode(user.toJson()));
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

  /// Actualizar datos deportivos del perfil
  Future<void> updateAthleteProfile({
    String? firstName,
    String? lastName,
    String? category,
    String? level,
    String? modality,
    String? photoUrl,
    DateTime? birthDate,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? email = prefs.getString('rolla_current_email');

      if (email != null && _user != null) {
        final updatedFirstName = firstName ?? _user!.firstName;
        final updatedLastName = lastName ?? _user!.lastName;
        _user = _user!.copyWith(
          firstName: updatedFirstName,
          lastName: updatedLastName,
          fullName: '$updatedFirstName $updatedLastName'.trim(),
          category: category,
          level: level,
          modality: modality,
          photoUrl: photoUrl ?? _user!.photoUrl,
          birthDate: birthDate ?? _user!.birthDate,
        );

        await prefs.setString('rolla_user', jsonEncode(_user!.toJson()));
        await prefs.setString('rolla_user_$email', jsonEncode(_user!.toJson()));
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error actualizando perfil deportivo: $e');
    }
  }
}
