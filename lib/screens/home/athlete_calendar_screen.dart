import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/event_provider.dart';
import '../../providers/training_provider.dart';
import '../../models/event_model.dart';
import '../../models/training_model.dart';

class AthleteCalendarScreen extends StatefulWidget {
  const AthleteCalendarScreen({super.key});

  @override
  State<AthleteCalendarScreen> createState() => _AthleteCalendarScreenState();
}

class _AthleteCalendarScreenState extends State<AthleteCalendarScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<EventProvider>(context, listen: false).loadEvents();
      Provider.of<TrainingProvider>(context, listen: false).loadTrainings();
    });
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final dateOnly = DateTime(date.year, date.month, date.day);

    if (dateOnly.isAtSameMomentAs(today)) return 'Hoy';
    if (dateOnly.isAtSameMomentAs(today.add(const Duration(days: 1)))) return 'Mañana';

    final days = ['Dom', 'Lun', 'Mar', 'Mié', 'Jue', 'Vie', 'Sáb'];
    final months = ['ene', 'feb', 'mar', 'abr', 'may', 'jun', 'jul', 'ago', 'sep', 'oct', 'nov', 'dic'];
    return '${days[date.weekday % 7]}, ${date.day} ${months[date.month - 1]}';
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final eventProvider = Provider.of<EventProvider>(context);
    final trainingProvider = Provider.of<TrainingProvider>(context);

    final athleteId = authProvider.user?.id ?? '';
    final schoolId = authProvider.schoolId ?? '';

    // Eventos habilitados para este deportista
    final events = schoolId.isNotEmpty
        ? eventProvider.getEnabledEventsForAthlete(schoolId, athleteId)
        : <EventModel>[];

    // Entrenamientos de la escuela
    final trainings = schoolId.isNotEmpty
        ? trainingProvider.getUpcomingTrainings(schoolId)
        : <TrainingModel>[];

    // Combinar y ordenar por fecha
    final items = <_CalendarItem>[];
    for (final e in events) {
      items.add(_CalendarItem(
        date: e.date,
        title: e.title,
        type: 'event',
        subtitle: '${e.location} • ${e.modality}',
        time: e.time,
      ));
    }
    for (final t in trainings) {
      items.add(_CalendarItem(
        date: t.date,
        title: t.title,
        type: 'training',
        subtitle: t.location,
        time: t.time,
      ));
    }
    items.sort((a, b) => a.date.compareTo(b.date));

    // Agrupar por fecha
    final grouped = <DateTime, List<_CalendarItem>>{};
    for (final item in items) {
      final key = DateTime(item.date.year, item.date.month, item.date.day);
      grouped.putIfAbsent(key, () => []).add(item);
    }
    final sortedDates = grouped.keys.toList()..sort();

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF5F7FA),
        elevation: 0,
        title: const Text(
          'Mi Agenda',
          style: TextStyle(
            color: Color(0xFF1F2937),
            fontWeight: FontWeight.bold,
          ),
        ),
        iconTheme: const IconThemeData(color: Color(0xFF1F2937)),
      ),
      body: SafeArea(
        child: items.isEmpty
            ? _buildEmptyState()
            : ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: sortedDates.length,
                itemBuilder: (context, index) {
                  final date = sortedDates[index];
                  final dayItems = grouped[date]!;
                  return _buildDaySection(date, dayItems);
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
          const Icon(Icons.event_busy_outlined, size: 80, color: Color(0xFFD1D5DB)),
          const SizedBox(height: 16),
          const Text(
            'Sin actividades',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF6B7280),
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'No tienes eventos ni entrenamientos programados.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Color(0xFF9CA3AF)),
          ),
        ],
      ),
    );
  }

  Widget _buildDaySection(DateTime date, List<_CalendarItem> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 12, top: 8),
          child: Text(
            _formatDate(date),
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1F2937),
            ),
          ),
        ),
        ...items.map((item) => _buildItemCard(item)),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildItemCard(_CalendarItem item) {
    final isEvent = item.type == 'event';
    final color = isEvent ? const Color(0xFF2563EB) : const Color(0xFF10B981);
    final icon = isEvent ? Icons.emoji_events_outlined : Icons.fitness_center_outlined;
    final label = isEvent ? 'Evento' : 'Entrenamiento';

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: color.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        label,
                        style: TextStyle(
                          color: color,
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    if (item.time != null) ...[
                      const SizedBox(width: 8),
                      Text(
                        item.time!,
                        style: const TextStyle(
                          fontSize: 12,
                          color: Color(0xFF9CA3AF),
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  item.title,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1F2937),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  item.subtitle,
                  style: const TextStyle(
                    fontSize: 13,
                    color: Color(0xFF6B7280),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _CalendarItem {
  final DateTime date;
  final String title;
  final String type;
  final String subtitle;
  final String? time;

  _CalendarItem({
    required this.date,
    required this.title,
    required this.type,
    required this.subtitle,
    this.time,
  });
}