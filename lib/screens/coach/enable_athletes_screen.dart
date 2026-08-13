import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/event_provider.dart';
import '../../providers/school_provider.dart';
import '../../providers/school_request_provider.dart';
import '../../models/event_model.dart';
import '../../models/school_request_model.dart';

class EnableAthletesScreen extends StatefulWidget {
  final String eventId;

  const EnableAthletesScreen({super.key, required this.eventId});

  @override
  State<EnableAthletesScreen> createState() => _EnableAthletesScreenState();
}

class _EnableAthletesScreenState extends State<EnableAthletesScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<EventProvider>(context, listen: false).loadEvents();
      Provider.of<SchoolRequestProvider>(context, listen: false).loadRequests();
    });
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final schoolProvider = Provider.of<SchoolProvider>(context);
    final eventProvider = Provider.of<EventProvider>(context);
    final requestProvider = Provider.of<SchoolRequestProvider>(context);

    final schoolId = schoolProvider.school?.id ?? authProvider.schoolId ?? '';
    final event = eventProvider.events.firstWhere(
      (e) => e.id == widget.eventId,
      orElse: () => eventProvider.events.first,
    );

    final acceptedAthletes = schoolId.isNotEmpty
        ? requestProvider.getAcceptedAthletesForSchool(schoolId)
        : <SchoolRequestModel>[];

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF5F7FA),
        elevation: 0,
        title: const Text(
          'Habilitar Deportistas',
          style: TextStyle(
            color: Color(0xFF1F2937),
            fontWeight: FontWeight.bold,
          ),
        ),
        iconTheme: const IconThemeData(color: Color(0xFF1F2937)),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Info del evento
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFE5E7EB)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
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
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Text(
                '${acceptedAthletes.length} deportista${acceptedAthletes.length == 1 ? '' : 's'} en tu escuela',
                style: const TextStyle(
                  fontSize: 16,
                  color: Color(0xFF6B7280),
                ),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: acceptedAthletes.isEmpty
                    ? _buildEmptyState()
                    : ListView.builder(
                        itemCount: acceptedAthletes.length,
                        itemBuilder: (context, index) {
                          final athlete = acceptedAthletes[index];
                          final isEnabled = event.enabledAthletes.contains(athlete.athleteId);

                          return Card(
                            margin: const EdgeInsets.only(bottom: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: ListTile(
                              leading: Container(
                                width: 48,
                                height: 48,
                                decoration: BoxDecoration(
                                  color: isEnabled
                                      ? const Color(0xFFDEF7EC)
                                      : const Color(0xFFF3F4F6),
                                  borderRadius: BorderRadius.circular(24),
                                ),
                                child: Icon(
                                  Icons.person,
                                  color: isEnabled
                                      ? const Color(0xFF10B981)
                                      : const Color(0xFF9CA3AF),
                                ),
                              ),
                              title: Text(
                                athlete.athleteName,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF1F2937),
                                ),
                              ),
                              subtitle: Text(
                                isEnabled ? 'Habilitado para este evento' : 'No habilitado',
                                style: TextStyle(
                                  color: isEnabled
                                      ? const Color(0xFF10B981)
                                      : const Color(0xFF9CA3AF),
                                  fontSize: 13,
                                ),
                              ),
                              trailing: Switch(
                                value: isEnabled,
                                activeColor: const Color(0xFF2563EB),
                                onChanged: (value) async {
                                  await eventProvider.toggleAthleteForEvent(
                                    event.id,
                                    athlete.athleteId,
                                  );
                                },
                              ),
                            ),
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.people_outline,
            size: 64,
            color: const Color(0xFFD1D5DB),
          ),
          const SizedBox(height: 16),
          const Text(
            'No hay deportistas en tu escuela',
            style: TextStyle(
              color: Color(0xFF9CA3AF),
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Acepta solicitudes de ingreso primero.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Color(0xFF9CA3AF),
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}