import 'package:flutter/material.dart';
import '../models/transfer_request_model.dart';
import '../repositories/auth_repository.dart';
import '../repositories/local_auth_repository.dart';
import '../repositories/local_school_repository.dart';
import '../repositories/school_repository.dart';

class TransferProvider extends ChangeNotifier {
  final SchoolRepository _repository;
  final AuthRepository _authRepository;
  List<TransferRequestModel> _transfers = [];
  bool _isLoading = false;

  TransferProvider({
    SchoolRepository? repository,
    AuthRepository? authRepository,
  }) : _repository = repository ?? LocalSchoolRepository(),
       _authRepository = authRepository ?? LocalAuthRepository();

  List<TransferRequestModel> get transfers => List.unmodifiable(_transfers);
  bool get isLoading => _isLoading;

  /// Solicitudes pendientes para una escuela (como escuela actual)
  List<TransferRequestModel> getPendingForCurrentSchool(String schoolId) {
    return _transfers
        .where((t) => t.currentSchoolId == schoolId && t.status == 'pending')
        .toList();
  }

  /// Solicitudes pendientes para una escuela (como escuela destino)
  List<TransferRequestModel> getPendingForTargetSchool(String schoolId) {
    return _transfers
        .where(
          (t) =>
              t.targetSchoolId == schoolId && t.status == 'accepted_by_current',
        )
        .toList();
  }

  /// Solicitudes de un deportista
  List<TransferRequestModel> getTransfersByAthlete(String athleteId) {
    return _transfers.where((t) => t.athleteId == athleteId).toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  Future<void> loadTransfers() async {
    _isLoading = true;
    notifyListeners();

    try {
      _transfers = await _repository.getTransfers();
    } catch (e) {
      debugPrint('Error cargando traslados: $e');
    }

    _isLoading = false;
    notifyListeners();
  }

  /// Solicitar traslado
  Future<bool> requestTransfer({
    required String athleteId,
    required String athleteName,
    required String athleteEmail,
    required String currentSchoolId,
    required String currentSchoolName,
    String? targetSchoolId,
    String? targetSchoolName,
    required String type,
  }) async {
    try {
      // Verificar que no haya una solicitud pendiente
      final existing = _transfers.firstWhere(
        (t) =>
            t.athleteId == athleteId &&
            (t.status == 'pending' || t.status == 'accepted_by_current'),
        orElse: () => TransferRequestModel(
          id: '',
          athleteId: '',
          athleteName: '',
          athleteEmail: '',
          currentSchoolId: '',
          currentSchoolName: '',
          type: '',
          createdAt: DateTime.now(),
        ),
      );

      if (existing.id.isNotEmpty) {
        return false; // Ya hay solicitud activa
      }

      final newTransfer = TransferRequestModel(
        id: 'trf_${DateTime.now().millisecondsSinceEpoch}',
        athleteId: athleteId,
        athleteName: athleteName,
        athleteEmail: athleteEmail,
        currentSchoolId: currentSchoolId,
        currentSchoolName: currentSchoolName,
        targetSchoolId: targetSchoolId,
        targetSchoolName: targetSchoolName,
        type: type,
        status: 'pending',
        createdAt: DateTime.now(),
      );

      _transfers.add(newTransfer);
      await _saveTransfers();
      notifyListeners();
      return true;
    } catch (e) {
      debugPrint('Error solicitando traslado: $e');
      return false;
    }
  }

  /// Escuela actual acepta liberar
  Future<void> acceptByCurrentSchool(String transferId) async {
    final index = _transfers.indexWhere((t) => t.id == transferId);
    if (index != -1) {
      final transfer = _transfers[index];
      _transfers[index] = TransferRequestModel(
        id: transfer.id,
        athleteId: transfer.athleteId,
        athleteName: transfer.athleteName,
        athleteEmail: transfer.athleteEmail,
        currentSchoolId: transfer.currentSchoolId,
        currentSchoolName: transfer.currentSchoolName,
        targetSchoolId: transfer.targetSchoolId,
        targetSchoolName: transfer.targetSchoolName,
        type: transfer.type,
        status: 'accepted_by_current',
        createdAt: transfer.createdAt,
        respondedAt: DateTime.now(),
      );
      await _saveTransfers();
      notifyListeners();
    }
  }

  /// Escuela destino acepta
  Future<void> acceptByTargetSchool(String transferId) async {
    final index = _transfers.indexWhere((t) => t.id == transferId);
    if (index != -1) {
      final transfer = _transfers[index];
      _transfers[index] = TransferRequestModel(
        id: transfer.id,
        athleteId: transfer.athleteId,
        athleteName: transfer.athleteName,
        athleteEmail: transfer.athleteEmail,
        currentSchoolId: transfer.currentSchoolId,
        currentSchoolName: transfer.currentSchoolName,
        targetSchoolId: transfer.targetSchoolId,
        targetSchoolName: transfer.targetSchoolName,
        type: transfer.type,
        status: 'completed',
        createdAt: transfer.createdAt,
        respondedAt: DateTime.now(),
      );

      // Si es traslado (no agente libre), asignar nueva escuela
      if (transfer.type == 'transfer' && transfer.targetSchoolId != null) {
        await _authRepository.assignSchoolToUser(
          email: transfer.athleteEmail,
          schoolId: transfer.targetSchoolId!,
          schoolName: transfer.targetSchoolName ?? 'Escuela',
        );
      } else if (transfer.type == 'free_agent') {
        // Quitar escuela (quedar libre)
        await _authRepository.assignSchoolToUser(
          email: transfer.athleteEmail,
          schoolId: null,
          schoolName: null,
        );
      }

      await _saveTransfers();
      notifyListeners();
    }
  }

  /// Rechazar solicitud
  Future<void> rejectTransfer(String transferId) async {
    final index = _transfers.indexWhere((t) => t.id == transferId);
    if (index != -1) {
      final transfer = _transfers[index];
      _transfers[index] = TransferRequestModel(
        id: transfer.id,
        athleteId: transfer.athleteId,
        athleteName: transfer.athleteName,
        athleteEmail: transfer.athleteEmail,
        currentSchoolId: transfer.currentSchoolId,
        currentSchoolName: transfer.currentSchoolName,
        targetSchoolId: transfer.targetSchoolId,
        targetSchoolName: transfer.targetSchoolName,
        type: transfer.type,
        status: 'rejected',
        createdAt: transfer.createdAt,
        respondedAt: DateTime.now(),
      );
      await _saveTransfers();
      notifyListeners();
    }
  }

  Future<void> _saveTransfers() async {
    await _repository.saveTransfers(_transfers);
  }

  void clear() {
    _transfers = [];
    notifyListeners();
  }
}
