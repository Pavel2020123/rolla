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
    /// Obtener lista de próximos eventos
  static Future<List<EventModel>> getEvents() async {
    await Future.delayed(_delay);
    return [
      EventModel(
        id: 'evt_001',
        schoolId: 'sch_demo_001',
        creatorId: 'usr_coach_001',
        title: 'Copa Valledupar de Patinaje',
        description: 'Competencia anual de patinaje en el Patinódromo Municipal de Valledupar.',
        date: DateTime(2026, 8, 15),
        time: '8:00 AM',
        location: 'Patinódromo Municipal',
        category: 'Prejuvenil',
        modality: 'Velocidad',
        price: 50000,
        deadline: DateTime(2026, 8, 10),
        maxSlots: 50,
        status: 'published',
        enabledAthletes: const ['ath_001'],
        isRegistered: true,
      ),
      EventModel(
        id: 'evt_002',
        schoolId: 'sch_demo_001',
        creatorId: 'usr_coach_001',
        title: 'Torneo Departamental del Cesar',
        description: 'Torneo oficial del departamento con todas las categorías.',
        date: DateTime(2026, 8, 28),
        time: '9:00 AM',
        location: 'Complejo Deportivo',
        category: 'Todas las categorías',
        modality: 'Varias',
        price: 75000,
        deadline: DateTime(2026, 8, 20),
        maxSlots: 100,
        status: 'published',
        enabledAthletes: const [],
        isRegistered: false,
      ),
      EventModel(
        id: 'evt_003',
        schoolId: 'sch_demo_001',
        creatorId: 'usr_coach_001',
        title: 'Festival de Verano - Velocidad',
        description: 'Festival deportivo de verano con pruebas de velocidad.',
        date: DateTime(2026, 9, 12),
        time: '7:00 AM',
        location: 'Pista Los Almendros',
        category: 'Prejuvenil / Juvenil',
        modality: 'Velocidad',
        price: 40000,
        deadline: DateTime(2026, 9, 5),
        maxSlots: 80,
        status: 'published',
        enabledAthletes: const [],
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