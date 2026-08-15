import 'package:flutter/material.dart';
import '../models/event_model.dart';
import '../repositories/event_repository.dart';
import '../repositories/local_event_repository.dart';

class EventProvider extends ChangeNotifier {
  final EventRepository _repository;
  List<EventModel> _events = [];
  bool _isLoading = false;

  EventProvider({EventRepository? repository})
    : _repository = repository ?? LocalEventRepository();

  List<EventModel> get events => List.unmodifiable(_events);
  bool get isLoading => _isLoading;

  /// Cargar eventos desde almacenamiento local
  Future<void> loadEvents() async {
    _isLoading = true;
    notifyListeners();

    try {
      _events = await _repository.getEvents();
    } catch (e) {
      debugPrint('Error cargando eventos: $e');
    }

    _isLoading = false;
    notifyListeners();
  }

  /// Crear un nuevo evento
  Future<bool> createEvent(EventModel event) async {
    try {
      _events.add(event);
      await _saveEvents();
      notifyListeners();
      return true;
    } catch (e) {
      debugPrint('Error creando evento: $e');
      return false;
    }
  }

  /// Obtener eventos de una escuela específica
  List<EventModel> getEventsBySchool(String schoolId) {
    return _events.where((e) => e.schoolId == schoolId).toList();
  }

  /// Obtener eventos publicados de una escuela
  List<EventModel> getPublishedEventsBySchool(String schoolId) {
    return _events
        .where((e) => e.schoolId == schoolId && e.status == 'published')
        .toList();
  }

  /// Obtener eventos habilitados para un deportista específico
  List<EventModel> getEnabledEventsForAthlete(
    String schoolId,
    String athleteId,
  ) {
    return _events.where((e) {
      if (e.schoolId != schoolId) return false;
      if (e.status != 'published') return false;
      return e.enabledAthletes.contains(athleteId);
    }).toList();
  }

  /// Habilitar/dehabilitar un deportista para un evento
  Future<void> toggleAthleteForEvent(String eventId, String athleteId) async {
    final index = _events.indexWhere((e) => e.id == eventId);
    if (index == -1) return;

    final event = _events[index];
    final enabled = List<String>.from(event.enabledAthletes);

    if (enabled.contains(athleteId)) {
      enabled.remove(athleteId);
    } else {
      enabled.add(athleteId);
    }

    _events[index] = event.copyWith(enabledAthletes: enabled);
    await _saveEvents();
    notifyListeners();
  }

  /// Inscribirse a un evento (deportista)
  Future<bool> registerToEvent(String eventId) async {
    final index = _events.indexWhere((e) => e.id == eventId);
    if (index == -1) return false;

    _events[index] = _events[index].copyWith(isRegistered: true);
    await _saveEvents();
    notifyListeners();
    return true;
  }

  /// Cambiar estado de un evento
  Future<void> updateEventStatus(String eventId, String newStatus) async {
    final index = _events.indexWhere((e) => e.id == eventId);
    if (index != -1) {
      _events[index] = _events[index].copyWith(status: newStatus);
      await _saveEvents();
      notifyListeners();
    }
  }

  Future<void> _saveEvents() async {
    await _repository.saveEvents(_events);
  }

  void clear() {
    _events = [];
    notifyListeners();
  }
}
