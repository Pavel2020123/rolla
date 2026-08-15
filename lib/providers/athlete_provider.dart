import 'package:flutter/material.dart';
import '../models/athlete_model.dart';
import '../models/event_model.dart';
import '../models/result_model.dart';
import '../repositories/auth_repository.dart';
import '../repositories/event_repository.dart';
import '../repositories/local_auth_repository.dart';
import '../repositories/local_event_repository.dart';
import '../services/mock_service.dart';

class AthleteProvider extends ChangeNotifier {
  final AuthRepository _authRepository;
  final EventRepository _eventRepository;
  AthleteModel? _athlete;
  List<EventModel> _events = [];
  List<ResultModel> _results = [];
  bool _isLoading = false;

  AthleteProvider({
    AuthRepository? authRepository,
    EventRepository? eventRepository,
  }) : _authRepository = authRepository ?? LocalAuthRepository(),
       _eventRepository = eventRepository ?? LocalEventRepository();

  // Getters
  AthleteModel? get athlete => _athlete;
  List<EventModel> get events => List.unmodifiable(_events);
  List<ResultModel> get results => List.unmodifiable(_results);
  bool get isLoading => _isLoading;

  /// Carga inicial de datos priorizando el repositorio local
  Future<void> fetchAllData() async {
    _isLoading = true;
    notifyListeners();

    try {
      // --- Carga del Perfil: primero intenta usuario real, luego cache, luego mock ---
      final user = await _authRepository.getCurrentUser();
      final cachedAthlete = await _authRepository.getCachedAthlete();

      if (user != null) {
        _athlete = AthleteModel(
          id: user.id,
          firstName: user.firstName.isNotEmpty ? user.firstName : 'Usuario',
          lastName: user.lastName,
          role: user.role ?? 'Deportista',
          schoolName: user.schoolName ?? 'Sin escuela',
          category: user.category,
          level: user.level,
          modality: user.modality,
          photoUrl: user.photoUrl,
          birthDate: user.birthDate,
          email: user.email,
          participationsCount: user.participationsCount,
          goldMedals: user.goldMedals,
          silverMedals: user.silverMedals,
          bronzeMedals: user.bronzeMedals,
        );
      } else if (cachedAthlete != null) {
        _athlete = cachedAthlete;
      } else {
        _athlete = await MockService.getAthleteProfile();
      }

      // --- Carga de Eventos (Cache o Mock) ---
      final cachedEvents = await _eventRepository.getCachedEvents();
      if (cachedEvents != null) {
        _events = cachedEvents;
      } else {
        _events = await MockService.getEvents();
      }

      // --- Carga de Resultados ---
      _results = await MockService.getResultsHistory();

      // Recalcular medallas desde resultados reales
      recalculateMedalsFromResults();
    } catch (e) {
      debugPrint('Error cargando datos: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Ejemplo de acción global: Inscribirse/desinscribirse a un evento
  void toggleEventRegistration(String eventId) {
    final index = _events.indexWhere((e) => e.id == eventId);
    if (index != -1) {
      final currentEvent = _events[index];
      _events[index] = currentEvent.copyWith(
        status: !currentEvent.isRegistered
            ? 'Inscrito'
            : 'Inscripciones Abiertas',
        isRegistered: !currentEvent.isRegistered,
      );

      notifyListeners();
      _saveEventsToCache();
    }
  }

  /// Actualizar los datos básicos del perfil del deportista y persistirlos
  void updateAthleteProfile({
    required String firstName,
    required String lastName,
    required String schoolName,
    required String category,
    String? level,
    String? modality,
    String? photoUrl,
    DateTime? birthDate,
  }) {
    if (_athlete != null) {
      _athlete = AthleteModel(
        id: _athlete!.id,
        firstName: firstName,
        lastName: lastName,
        role: _athlete!.role,
        schoolName: schoolName,
        category: category,
        level: level ?? _athlete!.level,
        modality: modality ?? _athlete!.modality,
        photoUrl: photoUrl ?? _athlete!.photoUrl,
        birthDate: birthDate ?? _athlete!.birthDate,
        email: _athlete!.email,
        participationsCount: _athlete!.participationsCount,
        goldMedals: _athlete!.goldMedals,
        silverMedals: _athlete!.silverMedals,
        bronzeMedals: _athlete!.bronzeMedals,
      );

      notifyListeners();
      _saveAthleteToCache();
      _savePublicProfile();
    }
  }

  /// Guarda el perfil del deportista en la memoria del dispositivo
  Future<void> _saveAthleteToCache() async {
    if (_athlete != null) {
      await _authRepository.saveCachedAthlete(_athlete!);
    }
  }

  /// Guarda una copia pública del perfil para que entrenadores la vean
  Future<void> _savePublicProfile() async {
    if (_athlete != null) {
      await _authRepository.savePublicAthlete(_athlete!);
    }
  }

  Future<AthleteModel?> getPublicAthlete(String email) {
    return _authRepository.getPublicAthlete(email);
  }

  /// Guarda la lista de eventos en la memoria del dispositivo
  Future<void> _saveEventsToCache() async {
    await _eventRepository.saveCachedEvents(_events);
  }

  /// Recalcula oro/plata/bronce desde la lista de resultados reales
  void recalculateMedalsFromResults() {
    if (_athlete == null) return;

    int gold = 0, silver = 0, bronze = 0;
    for (var r in _results) {
      switch (r.medalType) {
        case MedalType.gold:
          gold++;
          break;
        case MedalType.silver:
          silver++;
          break;
        case MedalType.bronze:
          bronze++;
          break;
        default:
          break;
      }
    }

    _athlete = _athlete!.copyWith(
      goldMedals: gold,
      silverMedals: silver,
      bronzeMedals: bronze,
    );

    notifyListeners();
    _saveAthleteToCache();
  }
}
