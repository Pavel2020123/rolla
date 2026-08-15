import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/event_provider.dart';
import '../../providers/school_provider.dart';
import '../../providers/school_request_provider.dart';
import '../../providers/notification_provider.dart';
import '../../providers/payment_provider.dart';

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
      Provider.of<PaymentProvider>(context, listen: false).loadPayments();
    });
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final schoolProvider = Provider.of<SchoolProvider>(context);
    final eventProvider = Provider.of<EventProvider>(context);
    final requestProvider = Provider.of<SchoolRequestProvider>(context);
    final paymentProvider = Provider.of<PaymentProvider>(context);

    final schoolId = schoolProvider.school?.id ?? authProvider.schoolId ?? '';
    final event = eventProvider.events.firstWhere(
      (e) => e.id == widget.eventId,
      orElse: () => eventProvider.events.first,
    );

    final acceptedAthletes = schoolId.isNotEmpty
        ? requestProvider.getAcceptedAthletesForSchool(schoolId)
        : [];

    final paidCount = acceptedAthletes.where((a) {
      return paymentProvider.hasPaid(a.athleteId, event.id);
    }).length;

    final enabledCount = event.enabledAthletes.length;

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
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        _buildStatChip('$paidCount pagados', const Color(0xFF10B981)),
                        const SizedBox(width: 8),
                        _buildStatChip('$enabledCount habilitados', const Color(0xFF2563EB)),
                      ],
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
                          final hasPaid = paymentProvider.hasPaid(athlete.athleteId, event.id);

                          return Card(
                            margin: const EdgeInsets.only(bottom: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: ListTile(
                              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const SizedBox(height: 4),
                                  Text(
                                    isEnabled
                                        ? 'Habilitado para este evento'
                                        : 'No habilitado',
                                    style: TextStyle(
                                      color: isEnabled
                                          ? const Color(0xFF10B981)
                                          : const Color(0xFF9CA3AF),
                                      fontSize: 13,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Row(
                                    children: [
                                      Icon(
                                        hasPaid ? Icons.check_circle : Icons.pending,
                                        size: 14,
                                        color: hasPaid
                                            ? const Color(0xFF10B981)
                                            : const Color(0xFFF59E0B),
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        hasPaid ? 'Pago completado' : 'Pago pendiente',
                                        style: TextStyle(
                                          color: hasPaid
                                              ? const Color(0xFF10B981)
                                              : const Color(0xFFF59E0B),
                                          fontSize: 12,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              trailing: Switch(
                                value: isEnabled,
                                activeThumbColor: const Color(0xFF2563EB),
                                onChanged: hasPaid
                                    ? (value) async {
                                        final eventProvider =
                                            Provider.of<EventProvider>(context, listen: false);
                                        final notificationProvider =
                                            Provider.of<NotificationProvider>(context, listen: false);

                                        await eventProvider.toggleAthleteForEvent(
                                          event.id,
                                          athlete.athleteId,
                                        );

                                        if (value) {
                                          await notificationProvider.addNotification(
                                            userId: athlete.athleteId,
                                            title: 'Habilitado para evento',
                                            message:
                                                'Tu entrenador te habilitó para participar en: ${event.title}',
                                            type: 'event',
                                            relatedId: event.id,
                                          );
                                        }
                                      }
                                    : (value) {
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          const SnackBar(
                                            content: Text(
                                              'No puedes habilitar a un deportista que aún no ha pagado la inscripción',
                                            ),
                                            backgroundColor: Color(0xFFF59E0B),
                                            behavior: SnackBarBehavior.floating,
                                          ),
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

  Widget _buildStatChip(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.people_outline,
            size: 64,
            color: Color(0xFFD1D5DB),
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
