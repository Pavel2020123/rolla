import 'package:flutter_test/flutter_test.dart';
import 'package:rolla/models/event_model.dart';
import 'package:rolla/providers/event_provider.dart';
import 'package:rolla/repositories/event_repository.dart';

void main() {
  test('EventProvider funciona con una implementación en memoria', () async {
    final initialEvent = _event('event_1');
    final repository = InMemoryEventRepository([initialEvent]);
    final provider = EventProvider(repository: repository);

    await provider.loadEvents();
    expect(provider.events.single.id, initialEvent.id);

    final newEvent = _event('event_2');
    expect(await provider.createEvent(newEvent), isTrue);
    expect(repository.savedEvents.map((event) => event.id), [
      'event_1',
      'event_2',
    ]);
  });
}

class InMemoryEventRepository implements EventRepository {
  InMemoryEventRepository(List<EventModel> events)
    : savedEvents = List.of(events);

  List<EventModel> savedEvents;
  List<EventModel>? cachedEvents;

  @override
  Future<List<EventModel>> getEvents() async => List.of(savedEvents);

  @override
  Future<void> saveEvents(List<EventModel> events) async {
    savedEvents = List.of(events);
  }

  @override
  Future<List<EventModel>?> getCachedEvents() async {
    return cachedEvents == null ? null : List.of(cachedEvents!);
  }

  @override
  Future<void> saveCachedEvents(List<EventModel> events) async {
    cachedEvents = List.of(events);
  }
}

EventModel _event(String id) {
  return EventModel(
    id: id,
    schoolId: 'school_1',
    creatorId: 'coach_1',
    title: 'Evento $id',
    description: 'Evento de prueba',
    date: DateTime.utc(2026, 2, 1),
    location: 'Pista principal',
    category: 'Juvenil',
    modality: 'Velocidad',
    price: 50000,
  );
}
