import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/event_model.dart';
import 'event_repository.dart';

class LocalEventRepository implements EventRepository {
  static const _eventsKey = 'rolla_events';
  static const _cachedEventsKey = 'cached_events';

  @override
  Future<List<EventModel>> getEvents() => _readEvents(_eventsKey);

  @override
  Future<void> saveEvents(List<EventModel> events) {
    return _writeEvents(_eventsKey, events);
  }

  @override
  Future<List<EventModel>?> getCachedEvents() async {
    final prefs = await SharedPreferences.getInstance();
    if (!prefs.containsKey(_cachedEventsKey)) return null;
    return _readEvents(_cachedEventsKey);
  }

  @override
  Future<void> saveCachedEvents(List<EventModel> events) {
    return _writeEvents(_cachedEventsKey, events);
  }

  Future<List<EventModel>> _readEvents(String key) async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getString(key);
    if (data == null) return [];
    final decoded = jsonDecode(data) as List<dynamic>;
    return decoded
        .map((entry) => EventModel.fromJson(entry as Map<String, dynamic>))
        .toList();
  }

  Future<void> _writeEvents(String key, List<EventModel> events) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      key,
      jsonEncode(events.map((event) => event.toJson()).toList()),
    );
  }
}
