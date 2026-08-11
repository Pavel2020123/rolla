import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/school_request_model.dart';

class SchoolRequestProvider extends ChangeNotifier {
  List<SchoolRequestModel> _requests = [];
  bool _isLoading = false;

  List<SchoolRequestModel> get requests => List.unmodifiable(_requests);
  List<SchoolRequestModel> get pendingRequests =>
      _requests.where((r) => r.status == 'pending').toList();
  bool get isLoading => _isLoading;
  int get pendingCount => pendingRequests.length;

  /// Cargar todas las solicitudes del almacenamiento
  Future<void> loadRequests() async {
    _isLoading = true;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      final String? data = prefs.getString('rolla_school_requests');
      if (data != null) {
        final List decoded = jsonDecode(data);
        _requests = decoded.map((e) => SchoolRequestModel.fromJson(e)).toList();
      }
    } catch (e) {
      debugPrint('Error cargando solicitudes: $e');
    }

    _isLoading = false;
    notifyListeners();
  }

  /// Enviar solicitud de ingreso (deportista)
  Future<bool> sendRequest({
    required String athleteId,
    required String athleteName,
    required String schoolId,
    required String schoolName,
  }) async {
    try {
      // Verificar que no haya una solicitud pendiente para la misma escuela
      final existing = _requests.firstWhere(
        (r) =>
            r.athleteId == athleteId &&
            r.schoolId == schoolId &&
            r.status == 'pending',
        orElse: () => SchoolRequestModel(
          id: '',
          athleteId: '',
          athleteName: '',
          schoolId: '',
          schoolName: '',
          createdAt: DateTime.now(),
        ),
      );

      if (existing.id.isNotEmpty) {
        return false; // Ya hay solicitud pendiente
      }

      final newRequest = SchoolRequestModel(
        id: 'req_${DateTime.now().millisecondsSinceEpoch}',
        athleteId: athleteId,
        athleteName: athleteName,
        schoolId: schoolId,
        schoolName: schoolName,
        status: 'pending',
        createdAt: DateTime.now(),
      );

      _requests.add(newRequest);
      await _saveRequests();
      notifyListeners();
      return true;
    } catch (e) {
      debugPrint('Error enviando solicitud: $e');
      return false;
    }
  }

  /// Aceptar solicitud (entrenador)
  Future<void> acceptRequest(String requestId) async {
    final index = _requests.indexWhere((r) => r.id == requestId);
    if (index != -1) {
      _requests[index] = SchoolRequestModel(
        id: _requests[index].id,
        athleteId: _requests[index].athleteId,
        athleteName: _requests[index].athleteName,
        schoolId: _requests[index].schoolId,
        schoolName: _requests[index].schoolName,
        status: 'accepted',
        createdAt: _requests[index].createdAt,
        respondedAt: DateTime.now(),
      );
      await _saveRequests();
      notifyListeners();
    }
  }

  /// Rechazar solicitud (entrenador)
  Future<void> rejectRequest(String requestId) async {
    final index = _requests.indexWhere((r) => r.id == requestId);
    if (index != -1) {
      _requests[index] = SchoolRequestModel(
        id: _requests[index].id,
        athleteId: _requests[index].athleteId,
        athleteName: _requests[index].athleteName,
        schoolId: _requests[index].schoolId,
        schoolName: _requests[index].schoolName,
        status: 'rejected',
        createdAt: _requests[index].createdAt,
        respondedAt: DateTime.now(),
      );
      await _saveRequests();
      notifyListeners();
    }
  }

  /// Obtener solicitudes de un deportista específico
  List<SchoolRequestModel> getRequestsByAthlete(String athleteId) {
    return _requests.where((r) => r.athleteId == athleteId).toList();
  }

  /// Obtener solicitudes pendientes para una escuela específica
  List<SchoolRequestModel> getPendingRequestsForSchool(String schoolId) {
    return _requests
        .where((r) => r.schoolId == schoolId && r.status == 'pending')
        .toList();
  }

  /// Verificar si un deportista tiene solicitud pendiente para una escuela
  bool hasPendingRequest(String athleteId, String schoolId) {
    return _requests.any(
      (r) =>
          r.athleteId == athleteId &&
          r.schoolId == schoolId &&
          r.status == 'pending',
    );
  }

  /// Verificar si un deportista fue aceptado en una escuela
  bool isAcceptedInSchool(String athleteId, String schoolId) {
    return _requests.any(
      (r) =>
          r.athleteId == athleteId &&
          r.schoolId == schoolId &&
          r.status == 'accepted',
    );
  }

  Future<void> _saveRequests() async {
    final prefs = await SharedPreferences.getInstance();
    final String data = jsonEncode(_requests.map((r) => r.toJson()).toList());
    await prefs.setString('rolla_school_requests', data);
  }

  void clear() {
    _requests = [];
    notifyListeners();
  }
}