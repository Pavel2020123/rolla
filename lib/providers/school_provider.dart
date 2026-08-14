import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/school_model.dart';

class SchoolProvider extends ChangeNotifier {
  SchoolModel? _school;
  bool _isLoading = false;

  SchoolModel? get school => _school;
  bool get isLoading => _isLoading;
  bool get hasSchool => _school != null;

  /// Cargar escuela desde almacenamiento local
  Future<void> loadSchool(String ownerId) async {
    _isLoading = true;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      final String? schoolData = prefs.getString('rolla_school_$ownerId');

      if (schoolData != null) {
        final decoded = jsonDecode(schoolData);
        _school = SchoolModel.fromJson(decoded);
      }
    } catch (e) {
      debugPrint('Error cargando escuela: $e');
    }

    _isLoading = false;
    notifyListeners();
  }

  /// Crear una nueva escuela
    Future<bool> createSchool({
    required String ownerId,
    required String name,
    required String description,
    required String city,
    required String address,
    required String phone,
    required String email,
    String? info,
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      final newSchool = SchoolModel(
        id: 'sch_${DateTime.now().millisecondsSinceEpoch}',
        name: name,
        description: description,
        city: city,
        address: address,
        phone: phone,
        email: email,
        info: info,
        createdAt: DateTime.now(),
        ownerId: ownerId,
      );

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(
        'rolla_school_$ownerId',
        jsonEncode(newSchool.toJson()),
      );

      _school = newSchool;
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      debugPrint('Error creando escuela: $e');
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }



  /// Limpiar escuela (útil para logout)
  void clear() {
    _school = null;
    notifyListeners();
  }

    /// Guardar configuración de Wompi para la escuela
  Future<bool> saveWompiConfig({
    required String publicKey,
    required String privateKey,
    required String integritySecret,
  }) async {
    if (_school == null) return false;

    try {
      final updated = _school!.copyWith(
        wompiPublicKey: publicKey.trim(),
        wompiPrivateKey: privateKey.trim(),
        wompiIntegritySecret: integritySecret.trim(),
        wompiEnabled: true,
      );

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(
        'rolla_school_${updated.ownerId}',
        jsonEncode(updated.toJson()),
      );

      _school = updated;
      notifyListeners();
      return true;
    } catch (e) {
      debugPrint('Error guardando Wompi: $e');
      return false;
    }
  }

}