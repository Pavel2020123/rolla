import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/school_request_model.dart';
import 'auth_provider.dart';

class SchoolRequestProvider extends ChangeNotifier {
  List<SchoolRequestModel> _requests = [];
  bool _isLoading = false;

  List<SchoolRequestModel> get requests => List.unmodifiable(_requests);
  List<SchoolRequestModel> get pendingRequests =>
      _requests.where((r) => r.status == 'pending').toList();
  bool get isLoading => _isLoading;
  int get pendingCount => pendingRequests.length;

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

  Future<bool> sendRequest({
    required String athleteId,
    required String athleteName,
    required String athleteEmail, // NUEVO
    required String schoolId,
    required String schoolName,
  }) async {
    try {
      final existing = _requests.firstWhere(
        (r) =>
            r.athleteId == athleteId &&
            r.schoolId == schoolId &&
            r.status == 'pending',
        orElse: () => SchoolRequestModel(
          id: '',
          athleteId: '',
          athleteName: '',
          athleteEmail: '',
          schoolId: '',
          schoolName: '',
          createdAt: DateTime.now(),
        ),
      );

      if (existing.id.isNotEmpty) {
        return false;
      }

      final newRequest = SchoolRequestModel(
        id: 'req_${DateTime.now().millisecondsSinceEpoch}',
        athleteId: athleteId,
        athleteName: athleteName,
        athleteEmail: athleteEmail,
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

  Future<void> acceptRequest(String requestId) async {
    final index = _requests.indexWhere((r) => r.id == requestId);
    if (index != -1) {
      final request = _requests[index];

      // NUEVO: Asignar escuela al deportista en su cuenta
      if (request.athleteEmail.isNotEmpty) {
        await AuthProvider.assignSchoolToUser(
          request.athleteEmail,
          request.schoolId,
          request.schoolName,
        );
      }

      _requests[index] = SchoolRequestModel(
        id: request.id,
        athleteId: request.athleteId,
        athleteName: request.athleteName,
        athleteEmail: request.athleteEmail,
        schoolId: request.schoolId,
        schoolName: request.schoolName,
        status: 'accepted',
        createdAt: request.createdAt,
        respondedAt: DateTime.now(),
      );
      await _saveRequests();
      notifyListeners();
    }
  }

  Future<void> rejectRequest(String requestId) async {
    final index = _requests.indexWhere((r) => r.id == requestId);
    if (index != -1) {
      final request = _requests[index];
      _requests[index] = SchoolRequestModel(
        id: request.id,
        athleteId: request.athleteId,
        athleteName: request.athleteName,
        athleteEmail: request.athleteEmail,
        schoolId: request.schoolId,
        schoolName: request.schoolName,
        status: 'rejected',
        createdAt: request.createdAt,
        respondedAt: DateTime.now(),
      );
      await _saveRequests();
      notifyListeners();
    }
  }

  List<SchoolRequestModel> getPendingRequestsForSchool(String schoolId) {
    return _requests
        .where((r) => r.schoolId == schoolId && r.status == 'pending')
        .toList();
  }

    /// Obtener deportistas aceptados en una escuela
  List<SchoolRequestModel> getAcceptedAthletesForSchool(String schoolId) {
    return _requests
        .where((r) => r.schoolId == schoolId && r.status == 'accepted')
        .toList();
  }

  bool hasPendingRequest(String athleteId, String schoolId) {
    return _requests.any(
      (r) =>
          r.athleteId == athleteId &&
          r.schoolId == schoolId &&
          r.status == 'pending',
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