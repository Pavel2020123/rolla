import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/event_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/event_provider.dart';
import '../../providers/notification_provider.dart';
import '../events/event_detail_screen.dart';
import '../athlete/find_school_screen.dart';

class AthleteEventsTab extends StatefulWidget {
  const AthleteEventsTab({super.key});

  @override
  State<AthleteEventsTab> createState() => _AthleteEventsTabState();
}

class _AthleteEventsTabState extends State<AthleteEventsTab> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<EventProvider>(context, listen: false).loadEvents();
    });
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final eventProvider = Provider.of<EventProvider>(context);

    final hasSchool = authProvider.hasSchool;
    final schoolId = authProvider.schoolId ?? '';
    final athleteId = authProvider.user?['id'] ?? '';

    final events = hasSchool && schoolId.isNotEmpty
        ? eventProvider.getEnabledEventsForAthlete(schoolId, athleteId)
        : <EventModel>[];

    final allSchoolEvents = hasSchool && schoolId.isNotEmpty
        ? eventProvider.getPublishedEventsBySchool(schoolId)
        : <EventModel>[];

    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.all(24.0),
        children: [
          const Text(
            'Próximos Eventos',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1F2937),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            hasSchool
                ? 'Eventos habilitados para ti'
                : 'Primero necesitas pertenecer a una escuela',
            style: const TextStyle(
              fontSize: 14,
              color: Color(0xFF6B7280),
            ),
          ),
          const SizedBox(height: 24),

          if (!hasSchool) ...[
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFFFEF3C7),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFFCD34D)),
              ),
              child: Column(
                children: [
                  const Icon(Icons.info_outline, color: Color(0xFFD97706)),
                  const SizedBox(height: 8),
                  const Text(
                    'No perteneces a ninguna escuela',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF92400E),
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Para ver eventos, primero debes estar en una escuela.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Color(0xFFA16207)),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const FindSchoolScreen(),
                        ),
                      );
                    },
                    icon: const Icon(Icons.search, size: 18),
                    label: const Text('Buscar escuela'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2563EB),
                      foregroundColor: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ]

          else if (events.isEmpty && allSchoolEvents.isEmpty) ...[
            const Center(
              child: Column(
                children: [
                  Icon(
                    Icons.event_busy_outlined,
                    size: 64,
                    color: Color(0xFFD1D5DB),
                  ),
                  SizedBox(height: 16),
                  Text(
                    'No hay eventos disponibles',
                    style: TextStyle(
                      color: Color(0xFF9CA3AF),
                      fontSize: 16,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Tu escuela aún no ha publicado eventos.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Color(0xFF9CA3AF),
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
          ]

          else if (events.isEmpty && allSchoolEvents.isNotEmpty) ...[
            const Center(
              child: Column(
                children: [
                  Icon(
                    Icons.lock_outline,
                    size: 64,
                    color: Color(0xFFD1D5DB),
                  ),
                  SizedBox(height: 16),
                  Text(
                    'No tienes eventos habilitados',
                    style: TextStyle(
                      color: Color(0xFF9CA3AF),
                      fontSize: 16,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Tu entrenador debe habilitarte para los eventos.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Color(0xFF9CA3AF),
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
          ]

          else ...[
            ...events.map((event) => Padding(
                  padding: const EdgeInsets.only(bottom: 16.0),
                  child: _buildEventCard(context, event),
                )),
          ],
        ],
      ),
    );
  }

  Widget _buildEventCard(BuildContext context, EventModel event) {
    final formattedDate = "${event.date.day}/${event.date.month}/${event.date.year}";
    final eventProvider = Provider.of<EventProvider>(context, listen: false);
    final notificationProvider = Provider.of<NotificationProvider>(context, listen: false);
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => EventDetailScreen(eventId: event.id),
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFE5E7EB)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: const BoxDecoration(
                color: Color(0xFFF9FAFB),
                borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.calendar_month, size: 16, color: Color(0xFF6B7280)),
                      const SizedBox(width: 8),
                      Text(
                        formattedDate,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF4B5563),
                        ),
                      ),
                    ],
                  ),
                  InkWell(
                    onTap: () async {
                      if (!event.isRegistered) {
                        final success = await eventProvider.registerToEvent(event.id);
                        if (success) {
                          // Notificar al entrenador
                          await notificationProvider.addNotification(
                            userId: event.creatorId,
                            title: 'Nueva inscripción',
                            message: '${authProvider.user?['fullName'] ?? 'Un deportista'} se inscribió a ${event.title}',
                            type: 'registration',
                            relatedId: event.id,
                          );

                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('¡Te has inscrito con éxito!'),
                                duration: Duration(seconds: 2),
                                behavior: SnackBarBehavior.floating,
                              ),
                            );
                          }
                        }
                      }
                    },
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: event.isRegistered
                            ? const Color(0xFFDEF7EC)
                            : const Color(0xFFE1EFFE),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: event.isRegistered
                              ? const Color(0xFF31C48D)
                              : const Color(0xFF3F83F8),
                          width: 1,
                        ),
                      ),
                      child: Text(
                        event.isRegistered ? 'Inscrito' : 'Inscribirme',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: event.isRegistered
                              ? const Color(0xFF03543F)
                              : const Color(0xFF1E429F),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    event.title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1F2937),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      const Icon(Icons.location_on_outlined, size: 16, color: Color(0xFF9CA3AF)),
                      const SizedBox(width: 6),
                      Text(
                        event.location,
                        style: const TextStyle(fontSize: 14, color: Color(0xFF6B7280)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.category_outlined, size: 16, color: Color(0xFF9CA3AF)),
                      const SizedBox(width: 6),
                      Text(
                        '${event.category} • ${event.modality}',
                        style: const TextStyle(fontSize: 14, color: Color(0xFF6B7280)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.attach_money, size: 16, color: Color(0xFF9CA3AF)),
                      const SizedBox(width: 6),
                      Text(
                        '\$${event.price.toStringAsFixed(0)}',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF1F2937),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}