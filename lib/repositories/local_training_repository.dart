import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/training_model.dart';
import 'training_repository.dart';

class LocalTrainingRepository implements TrainingRepository {
  static const _trainingsKey = 'rolla_trainings';

  @override
  Future<List<TrainingModel>> getTrainings() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getString(_trainingsKey);
    if (data == null) return [];
    final decoded = jsonDecode(data) as List<dynamic>;
    return decoded
        .map((entry) => TrainingModel.fromJson(entry as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<void> saveTrainings(List<TrainingModel> trainings) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _trainingsKey,
      jsonEncode(trainings.map((training) => training.toJson()).toList()),
    );
  }
}
