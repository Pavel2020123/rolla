import 'package:flutter/material.dart';
import '../models/athlete_model.dart';
import '../models/event_model.dart';
import '../models/result_model.dart';
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

  /// Carga inicial de todos los datos desde el MockService
  Future<void> fetchAllData() async {
    _isLoading = true;
    notifyListeners();

    try {
      final resultsFuture = Future.wait([
        MockService.getAthleteProfile(),
        MockService.getEvents(),
        MockService.getResultsHistory(),
      ]);

      final response = await resultsFuture;
      
      _athlete = response[0] as AthleteModel;
      _events = response[1] as List<EventModel>;
      _results = response[2] as List<ResultModel>;
    } catch (e) {
      debugPrint('Error cargando datos: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Ejemplo de acción global: Inscribirse a un evento
  void toggleEventRegistration(String eventId) {
    final index = _events.indexWhere((e) => e.id == eventId);
    if (index != -1) {
      final currentEvent = _events[index];
      _events[index] = EventModel(
        id: currentEvent.id,
        title: currentEvent.title,
        date: currentEvent.date,
        location: currentEvent.location,
        category: currentEvent.category,
        status: !currentEvent.isRegistered ? 'Inscrito' : 'Inscripciones Abiertas',
        isRegistered: !currentEvent.isRegistered,
      );
      notifyListeners(); // Esto actualizará la UI en cualquier pantalla que escuche
    }
  }
}