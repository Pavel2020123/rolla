import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/school_history_model.dart';

class SchoolHistoryProvider extends ChangeNotifier {
  List<SchoolHistoryModel> _history = [];
  bool _isLoading = false;

  List<SchoolHistoryModel> get history => List.unmodifiable(_history);
  bool get isLoading => _isLoading;

  /// Cargar historial del usuario
  Future<void> loadHistory(String userId) async {
    _isLoading = true;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      final String? data = prefs.getString('rolla_school_history_$userId');
      if (data != null) {
        final List<dynamic> decoded = jsonDecode(data);
        _history = decoded.map((e) => SchoolHistoryModel.fromJson(e)).toList()
          ..sort((a, b) => b.joinedAt.compareTo(a.joinedAt));
      }
    } catch (e) {
      debugPrint('Error cargando historial de escuelas: $e');
    }

    _isLoading = false;
    notifyListeners();
  }

  /// Registrar ingreso a una escuela
  Future<void> recordJoin({
    required String userId,
    required String schoolId,
    required String schoolName,
  }) async {
    // Cerrar escuela anterior si existe
    final currentIndex = _history.indexWhere((h) => h.isCurrent);
    if (currentIndex != -1) {
      _history[currentIndex] = _history[currentIndex].copyWith(
        leftAt: DateTime.now(),
        reason: 'transfer',
      );
    }

    final newEntry = SchoolHistoryModel(
      id: 'hist_${DateTime.now().millisecondsSinceEpoch}',
      schoolId: schoolId,
      schoolName: schoolName,
      joinedAt: DateTime.now(),
    );

    _history.add(newEntry);
    await _saveHistory(userId);
    notifyListeners();
  }

  /// Registrar salida de escuela (quedar libre)
  Future<void> recordLeave({
    required String userId,
    required String reason,
  }) async {
    final currentIndex = _history.indexWhere((h) => h.isCurrent);
    if (currentIndex != -1) {
      _history[currentIndex] = _history[currentIndex].copyWith(
        leftAt: DateTime.now(),
        reason: reason,
      );
      await _saveHistory(userId);
      notifyListeners();
    }
  }

  /// Obtener escuela actual
  SchoolHistoryModel? get currentSchool {
    try {
      return _history.firstWhere((h) => h.isCurrent);
    } catch (_) {
      return null;
    }
  }

  Future<void> _saveHistory(String userId) async {
    final prefs = await SharedPreferences.getInstance();
    final String data = jsonEncode(_history.map((h) => h.toJson()).toList());
    await prefs.setString('rolla_school_history_$userId', data);
  }

  void clear() {
    _history = [];
    notifyListeners();
  }
}