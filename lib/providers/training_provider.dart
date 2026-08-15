import 'package:flutter/material.dart';
import '../models/training_model.dart';
import '../repositories/local_training_repository.dart';
import '../repositories/training_repository.dart';

class TrainingProvider extends ChangeNotifier {
  final TrainingRepository _repository;
  List<TrainingModel> _trainings = [];
  bool _isLoading = false;

  TrainingProvider({TrainingRepository? repository})
    : _repository = repository ?? LocalTrainingRepository();

  List<TrainingModel> get trainings => List.unmodifiable(_trainings);
  bool get isLoading => _isLoading;

  /// Entrenamientos de una escuela
  List<TrainingModel> getTrainingsBySchool(String schoolId) {
    return _trainings.where((t) => t.schoolId == schoolId).toList()
      ..sort((a, b) => b.date.compareTo(a.date));
  }

  /// Entrenamientos futuros de una escuela
  List<TrainingModel> getUpcomingTrainings(String schoolId) {
    final now = DateTime.now();
    return _trainings
        .where(
          (t) =>
              t.schoolId == schoolId &&
              t.date.isAfter(now.subtract(const Duration(days: 1))),
        )
        .toList()
      ..sort((a, b) => a.date.compareTo(b.date));
  }

  Future<void> loadTrainings() async {
    _isLoading = true;
    notifyListeners();

    try {
      _trainings = await _repository.getTrainings();
    } catch (e) {
      debugPrint('Error cargando entrenamientos: $e');
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<bool> createTraining(TrainingModel training) async {
    try {
      _trainings.add(training);
      await _saveTrainings();
      notifyListeners();
      return true;
    } catch (e) {
      debugPrint('Error creando entrenamiento: $e');
      return false;
    }
  }

  /// Confirmar asistencia
  Future<bool> confirmAttendance(String trainingId, String athleteId) async {
    final index = _trainings.indexWhere((t) => t.id == trainingId);
    if (index == -1) return false;

    final training = _trainings[index];
    final confirmed = List<String>.from(training.confirmedAthletes);
    final declined = List<String>.from(training.declinedAthletes);

    confirmed.add(athleteId);
    declined.remove(athleteId);

    _trainings[index] = training.copyWith(
      confirmedAthletes: confirmed,
      declinedAthletes: declined,
    );

    await _saveTrainings();
    notifyListeners();
    return true;
  }

  /// Declinar asistencia
  Future<bool> declineAttendance(String trainingId, String athleteId) async {
    final index = _trainings.indexWhere((t) => t.id == trainingId);
    if (index == -1) return false;

    final training = _trainings[index];
    final confirmed = List<String>.from(training.confirmedAthletes);
    final declined = List<String>.from(training.declinedAthletes);

    declined.add(athleteId);
    confirmed.remove(athleteId);

    _trainings[index] = training.copyWith(
      confirmedAthletes: confirmed,
      declinedAthletes: declined,
    );

    await _saveTrainings();
    notifyListeners();
    return true;
  }

  Future<void> _saveTrainings() async {
    await _repository.saveTrainings(_trainings);
  }

  void clear() {
    _trainings = [];
    notifyListeners();
  }
}
