import '../models/athlete_model.dart';
import '../models/event_model.dart';
import '../models/result_model.dart';

class MockService {
  // Simula un tiempo de respuesta de red (500 ms)
  static const Duration _delay = Duration(milliseconds: 500);

  /// Obtener información del deportista actual
  static Future<AthleteModel> getAthleteProfile() async {
    await Future.delayed(_delay);
    return AthleteModel(
      id: 'ath_001',
      firstName: 'Juan',
      lastName: 'Pérez',
      role: 'Deportista',
      schoolName: 'Rolla Skating Academy',
      category: 'Prejuvenil',
      level: 'Semiprofesional',
      participationsCount: 18,
      goldMedals: 4,
      silverMedals: 3,
      bronzeMedals: 2,
    );
  }

  /// Obtener lista de próximos eventos
  static Future<List<EventModel>> getEvents() async {
    await Future.delayed(_delay);
    return [
      EventModel(
        id: 'evt_001',
        title: 'Copa Valledupar de Patinaje',
        date: DateTime(2026, 8, 15),
        location: 'Patinódromo Municipal',
        category: 'Prejuvenil',
        status: 'Inscrito',
        isRegistered: true,
      ),
      EventModel(
        id: 'evt_002',
        title: 'Torneo Departamental del Cesar',
        date: DateTime(2026, 8, 28),
        location: 'Complejo Deportivo',
        category: 'Todas las categorías',
        status: 'Inscripciones Abiertas',
        isRegistered: false,
      ),
      EventModel(
        id: 'evt_003',
        title: 'Festival de Verano - Velocidad',
        date: DateTime(2026, 9, 12),
        location: 'Pista Los Almendros',
        category: 'Prejuvenil / Juvenil',
        status: 'Próximamente',
        isRegistered: false,
      ),
    ];
  }

  /// Obtener historial de resultados deportivos
  static Future<List<ResultModel>> getResultsHistory() async {
    await Future.delayed(_delay);
    return [
      ResultModel(
        id: 'res_001',
        title: 'Válida Nacional de Transición',
        date: DateTime(2026, 5, 10),
        modality: '200m Meta contra meta',
        position: '1er Puesto',
        time: '19.45s',
        medalType: MedalType.gold,
      ),
      ResultModel(
        id: 'res_002',
        title: 'Campeonato Departamental',
        date: DateTime(2026, 3, 22),
        modality: 'Puntos + Eliminación',
        position: '3er Puesto',
        time: null,
        medalType: MedalType.bronze,
      ),
      ResultModel(
        id: 'res_003',
        title: 'Festival Nacional Interclubes',
        date: DateTime(2025, 11, 15),
        modality: '100m Carriles',
        position: '2do Puesto',
        time: '10.82s',
        medalType: MedalType.silver,
      ),
      ResultModel(
        id: 'res_004',
        title: 'Copa Región Caribe',
        date: DateTime(2025, 9, 4),
        modality: 'Prueba de Relevos',
        position: '4to Puesto',
        time: '1:45.30',
        medalType: MedalType.none,
      ),
    ];
  }
}