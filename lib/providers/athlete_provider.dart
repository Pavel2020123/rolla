import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/athlete_model.dart';
import '../models/event_model.dart';
import '../models/result_model.dart';
import '../models/user_model.dart';
import '../services/mock_service.dart';

class AthleteProvider extends ChangeNotifier {
  AthleteModel? _athlete;
  List<EventModel> _events = [];
  List<ResultModel> _results = [];
  bool _isLoading = false;

  // Getters
  AthleteModel? get athlete => _athlete;
  List<EventModel> get events => List.unmodifiable(_events);
  List<ResultModel> get results => List.unmodifiable(_results);
  bool get isLoading => _isLoading;

  /// Carga inicial de datos priorizando la memoria local (SharedPreferences)
  Future<void> fetchAllData() async {
    _isLoading = true;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();

      // --- Carga del Perfil: primero intenta usuario real, luego cache, luego mock ---
      final String? userData = prefs.getString('rolla_user');
      final String? cachedData = prefs.getString('cached_athlete');

      if (userData != null) {
        final user = UserModel.fromJson(
          jsonDecode(userData) as Map<String, dynamic>,
        );
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
      } else if (cachedData != null) {
        final Map<String, dynamic> decodedData = jsonDecode(cachedData);
        _athlete = AthleteModel.fromJson(decodedData);
      } else {
        _athlete = await MockService.getAthleteProfile();
      }

      // --- Carga de Eventos (Cache o Mock) ---
      final String? cachedEvents = prefs.getString('cached_events');
      if (cachedEvents != null) {
        final List<dynamic> decodedEvents = jsonDecode(cachedEvents);
        _events = decodedEvents.map((e) => EventModel.fromJson(e)).toList();
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
      final prefs = await SharedPreferences.getInstance();
      final String athleteJson = jsonEncode(_athlete!.toJson());
      await prefs.setString('cached_athlete', athleteJson);
    }
  }

  /// Guarda una copia pública del perfil para que entrenadores la vean
  Future<void> _savePublicProfile() async {
    if (_athlete?.email == null) return;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      'rolla_public_profile_${_athlete!.email}',
      jsonEncode(_athlete!.toJson()),
    );
  }

  /// Guarda la lista de eventos en la memoria del dispositivo
  Future<void> _saveEventsToCache() async {
    final prefs = await SharedPreferences.getInstance();
    final String eventsJson = jsonEncode(
      _events.map((e) => e.toJson()).toList(),
    );
    await prefs.setString('cached_events', eventsJson);
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
