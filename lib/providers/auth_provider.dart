import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:crypto/crypto.dart';
import '../models/school_history_model.dart';
import '../models/user_model.dart';
import '../repositories/auth_repository.dart';
import '../repositories/local_auth_repository.dart';
import '../repositories/local_school_repository.dart';
import '../repositories/school_repository.dart';

class AuthProvider extends ChangeNotifier {
  final AuthRepository _repository;
  final SchoolRepository _schoolRepository;
  UserModel? _user;
  String? _role;
  bool _isLoading = false;

  AuthProvider({AuthRepository? repository, SchoolRepository? schoolRepository})
    : _repository = repository ?? LocalAuthRepository(),
      _schoolRepository = schoolRepository ?? LocalSchoolRepository();

  UserModel? get user => _user;
  String? get role => _role;
  bool get isLoading => _isLoading;
  bool get isAuthenticated => _user != null;

  String? get schoolId => _user?.schoolId;
  String? get schoolName => _user?.schoolName;
  bool get hasSchool => _user?.schoolId?.isNotEmpty == true;

  String _hashPassword(String password) {
    return sha256.convert(utf8.encode(password)).toString();
  }

  Future<bool> checkSession() async {
    _isLoading = true;
    notifyListeners();

    try {
      final user = await _repository.getCurrentUser();
      final userRole = await _repository.getCurrentRole();

      if (user != null && userRole != null) {
        _user = user;
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
      if (await _repository.getUser(email) != null) {
        _isLoading = false;
        notifyListeners();
        return false;
      }

      final parts = fullName.trim().split(' ');
      final firstName = parts.first;
      final lastName = parts.length > 1 ? parts.sublist(1).join(' ') : '';

      final now = DateTime.now();
      final passwordHash = _hashPassword(password);
      final newUser = UserModel(
        id: 'usr_${now.millisecondsSinceEpoch}',
        fullName: fullName.trim(),
        firstName: firstName,
        lastName: lastName,
        email: email,
        password: passwordHash,
        createdAt: now,
      );

      await _repository.saveUser(newUser);
      await _repository.setCurrentEmail(email);

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
      final email = await _repository.getCurrentEmail();

      if (email != null) {
        final storedUser = await _repository.getUser(email);
        if (storedUser != null) {
          final user = storedUser.copyWith(role: role);

          await _repository.saveUser(user);
          await _repository.saveSession(user);
          _user = user;
          _role = role;
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
      var user = await _repository.getUser(email);
      if (user == null) {
        _isLoading = false;
        notifyListeners();
        return false;
      }

      final passwordHash = _hashPassword(password);
      final passwordIsValid = user.needsPasswordMigration
          ? user.passwordMatches(password)
          : user.passwordMatches(passwordHash);

      if (!passwordIsValid) {
        _isLoading = false;
        notifyListeners();
        return false;
      }

      if (user.role == null) {
        _isLoading = false;
        notifyListeners();
        return false;
      }

      if (user.needsPasswordMigration) {
        user = user.copyWith(password: passwordHash);
        await _repository.saveUser(user);
      }

      _user = user;
      _role = user.role;

      await _repository.saveSession(user);

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
      final email = await _repository.getCurrentEmail();

      if (email != null && _user != null) {
        final userId = _user!.id;
        final history = await _schoolRepository.getHistory(userId);
        final now = DateTime.now();

        // Guardar escuela anterior en historial si tenía
        final prevSchoolId = _user!.schoolId;
        if (prevSchoolId != null && prevSchoolId.isNotEmpty) {
          // Cerrar entrada anterior
          for (var index = 0; index < history.length; index++) {
            if (history[index].isCurrent) {
              history[index] = history[index].copyWith(
                leftAt: now,
                reason: 'transfer',
              );
            }
          }
        }

        history.add(
          SchoolHistoryModel(
            id: 'hist_${now.millisecondsSinceEpoch}',
            schoolId: schoolId,
            schoolName: schoolName,
            joinedAt: now,
          ),
        );
        await _schoolRepository.saveHistory(userId, history);

        _user = _user!.copyWith(schoolId: schoolId, schoolName: schoolName);
        await _repository.saveUser(_user!);
        await _repository.saveSession(_user!);
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error asignando escuela: $e');
    }
  }

  /// Quitar escuela (quedar libre) + guardar historial
  Future<void> leaveSchool() async {
    try {
      final email = await _repository.getCurrentEmail();

      if (email != null && _user != null) {
        final userId = _user!.id;
        final prevSchoolId = _user!.schoolId;

        if (prevSchoolId != null && prevSchoolId.isNotEmpty) {
          final history = await _schoolRepository.getHistory(userId);
          final now = DateTime.now();
          for (var index = 0; index < history.length; index++) {
            if (history[index].isCurrent) {
              history[index] = history[index].copyWith(
                leftAt: now,
                reason: 'free_agent',
              );
            }
          }
          await _schoolRepository.saveHistory(userId, history);
        }

        _user = _user!.copyWith(schoolId: null, schoolName: null);
        await _repository.saveUser(_user!);
        await _repository.saveSession(_user!);
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error saliendo de escuela: $e');
    }
  }

  Future<void> logout() async {
    try {
      await _repository.clearSession();

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
      final email = await _repository.getCurrentEmail();

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

        await _repository.saveUser(_user!);
        await _repository.saveSession(_user!);
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error actualizando perfil deportivo: $e');
    }
  }
}
