import '../models/training_model.dart';

abstract class TrainingRepository {
  Future<List<TrainingModel>> getTrainings();

  Future<void> saveTrainings(List<TrainingModel> trainings);
}
