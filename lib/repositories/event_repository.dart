import '../models/event_model.dart';

abstract class EventRepository {
  Future<List<EventModel>> getEvents();

  Future<void> saveEvents(List<EventModel> events);

  Future<List<EventModel>?> getCachedEvents();

  Future<void> saveCachedEvents(List<EventModel> events);
}
