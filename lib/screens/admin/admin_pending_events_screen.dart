import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/event_provider.dart';
import '../../providers/notification_provider.dart';
import '../../providers/school_provider.dart';
import '../../models/event_model.dart';

class AdminPendingEventsScreen extends StatefulWidget {
  const AdminPendingEventsScreen({super.key});

  @override
  State<AdminPendingEventsScreen> createState() => _AdminPendingEventsScreenState();
}

class _AdminPendingEventsScreenState extends State<AdminPendingEventsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<EventProvider>(context, listen: false).loadEvents();
    });
  }

  @override
  Widget build(BuildContext context) {
    final eventProvider = Provider.of<EventProvider>(context);
    final pendingEvents = eventProvider.events
        .where((e) => e.status == 'pending' || e.status == 'draft')
        .toList()
      ..sort((a, b) => b.date.compareTo(a.date));

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF5F7FA),
        elevation: 0,
        title: const Text(
          'Eventos Pendientes',
          style: TextStyle(
            color: Color(0xFF1F2937),
            fontWeight: FontWeight.bold,
          ),
        ),
        iconTheme: const IconThemeData(color: Color(0xFF1F2937)),
      ),
      body: SafeArea(
        child: eventProvider.isLoading
            ? const Center(child: CircularProgressIndicator())
            : pendingEvents.isEmpty
                ? _buildEmptyState()
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: pendingEvents.length,
                    itemBuilder: (context, index) {
                      final event = pendingEvents[index];
                      return _buildEventCard(context, event);
                    },
                  ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.check_circle_outline, size: 80, color: Color(0xFFD1D5DB)),
          const SizedBox(height: 16),
          const Text(
            'Todo al día',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF6B7280),
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'No hay eventos esperando aprobación.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Color(0xFF9CA3AF)),
          ),
        ],
      ),
    );
  }

  Widget _buildEventCard(BuildContext context, EventModel event) {
    final formattedDate = '${event.date.day}/${event.date.month}/${event.date.year}';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFEF3C7),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text(
                    'Pendiente',
                    style: TextStyle(
                      color: Color(0xFF92400E),
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                Text(
                  '\$${event.price.toStringAsFixed(0)}',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2563EB),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              event.title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1F2937),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              '${event.category} • ${event.modality}',
              style: const TextStyle(
                fontSize: 14,
                color: Color(0xFF6B7280),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                const Icon(Icons.calendar_today, size: 14, color: Color(0xFF9CA3AF)),
                const SizedBox(width: 6),
                Text(
                  formattedDate,
                  style: const TextStyle(fontSize: 13, color: Color(0xFF6B7280)),
                ),
                const SizedBox(width: 16),
                const Icon(Icons.location_on_outlined, size: 14, color: Color(0xFF9CA3AF)),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    event.location,
                    style: const TextStyle(fontSize: 13, color: Color(0xFF6B7280)),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Divider(height: 1, color: Color(0xFFE5E7EB)),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _rejectEvent(context, event),
                    icon: const Icon(Icons.close, size: 18),
                    label: const Text('Rechazar'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFFEF4444),
                      side: const BorderSide(color: Color(0xFFEF4444)),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _approveEvent(context, event),
                    icon: const Icon(Icons.check, size: 18),
                    label: const Text('Aprobar'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF10B981),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _approveEvent(BuildContext context, EventModel event) async {
    final eventProvider = Provider.of<EventProvider>(context, listen: false);
    final notificationProvider = Provider.of<NotificationProvider>(context, listen: false);

    await eventProvider.updateEventStatus(event.id, 'published');

    // Notificar al entrenador creador
    await notificationProvider.addNotification(
      userId: event.creatorId,
      title: 'Evento aprobado',
      message: 'Tu evento "${event.title}" fue aprobado y ya está publicado.',
      type: 'event',
      relatedId: event.id,
    );

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Evento aprobado y publicado'),
          backgroundColor: Color(0xFF10B981),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  Future<void> _rejectEvent(BuildContext context, EventModel event) async {
    final eventProvider = Provider.of<EventProvider>(context, listen: false);
    final notificationProvider = Provider.of<NotificationProvider>(context, listen: false);

    await eventProvider.updateEventStatus(event.id, 'cancelled');

    // Notificar al entrenador creador
    await notificationProvider.addNotification(
      userId: event.creatorId,
      title: 'Evento rechazado',
      message: 'Tu evento "${event.title}" no fue aprobado. Contacta al administrador para más información.',
      type: 'event',
      relatedId: event.id,
    );

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Evento rechazado'),
          backgroundColor: Color(0xFFEF4444),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }
}