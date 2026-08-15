import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/event_provider.dart';
import '../../providers/payment_provider.dart';
import '../../providers/notification_provider.dart';
import '../payment/payment_checkout_screen.dart';

class EventDetailScreen extends StatefulWidget {
  final String eventId;

  const EventDetailScreen({super.key, required this.eventId});

  @override
  State<EventDetailScreen> createState() => _EventDetailScreenState();
}

class _EventDetailScreenState extends State<EventDetailScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<EventProvider>(context, listen: false).loadEvents();
      Provider.of<PaymentProvider>(context, listen: false).loadPayments();
    });
  }

  @override
  Widget build(BuildContext context) {
    final eventProvider = Provider.of<EventProvider>(context);
    final paymentProvider = Provider.of<PaymentProvider>(context);
    final authProvider = Provider.of<AuthProvider>(context);

    final event = eventProvider.events.firstWhere(
      (e) => e.id == widget.eventId,
      orElse: () => eventProvider.events.first,
    );

    final athleteId = authProvider.user?.id ?? '';
    final hasPaid = paymentProvider.hasPaid(athleteId, event.id);
    final isRegistered = event.isRegistered;

    final formattedDate = "${event.date.day}/${event.date.month}/${event.date.year}";
    final deadlineText = event.deadline != null
        ? "${event.deadline!.day}/${event.deadline!.month}/${event.deadline!.year}"
        : 'Sin fecha límite';

    // Determinar estado del botón
    String buttonText;
    bool buttonEnabled;
    Color buttonColor;
    Color buttonTextColor;

    if (!isRegistered) {
      buttonText = 'Inscribirme al Evento';
      buttonEnabled = true;
      buttonColor = const Color(0xFF2563EB);
      buttonTextColor = Colors.white;
    } else if (!hasPaid) {
      buttonText = 'Completar pago';
      buttonEnabled = true;
      buttonColor = const Color(0xFFF59E0B);
      buttonTextColor = Colors.white;
    } else {
      buttonText = 'Inscripción completada';
      buttonEnabled = false;
      buttonColor = const Color(0xFFDEF7EC);
      buttonTextColor = const Color(0xFF03543F);
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Color(0xFF1F2937)),
        title: const Text(
          'Detalles del Evento',
          style: TextStyle(color: Color(0xFF1F2937), fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF2563EB), Color(0xFF1D4ED8)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                event.category,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                event.modality,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          event.title,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          event.description,
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.9),
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Estado de inscripción y pago
                  if (isRegistered) ...[
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: hasPaid ? const Color(0xFFDEF7EC) : const Color(0xFFFEF3C7),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: hasPaid ? const Color(0xFF31C48D) : const Color(0xFFFCD34D),
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            hasPaid ? Icons.check_circle : Icons.pending,
                            color: hasPaid ? const Color(0xFF03543F) : const Color(0xFFD97706),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  hasPaid ? 'Pago completado' : 'Pago pendiente',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: hasPaid
                                        ? const Color(0xFF03543F)
                                        : const Color(0xFF92400E),
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  hasPaid
                                      ? 'Tu inscripción está confirmada. Espera a que tu entrenador te habilite.'
                                      : 'Debes completar el pago para que tu entrenador te habilite.',
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: hasPaid
                                        ? const Color(0xFF03543F)
                                        : const Color(0xFFA16207),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],

                  const Text(
                    'Información General',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),

                  _buildInfoRow(Icons.calendar_today, 'Fecha', formattedDate),
                  if (event.time != null) ...[
                    const Divider(height: 24),
                    _buildInfoRow(Icons.access_time, 'Hora', event.time!),
                  ],
                  const Divider(height: 24),
                  _buildInfoRow(Icons.location_on_outlined, 'Ubicación', event.location),
                  const Divider(height: 24),
                  _buildInfoRow(Icons.attach_money, 'Precio', '\$${event.price.toStringAsFixed(0)}'),
                  const Divider(height: 24),
                  _buildInfoRow(Icons.timer_outlined, 'Fecha límite', deadlineText),
                  if (event.maxSlots != null) ...[
                    const Divider(height: 24),
                    _buildInfoRow(Icons.people_outline, 'Cupos máximos', '${event.maxSlots}'),
                  ],

                  const SizedBox(height: 32),
                  const Text(
                    'Requisitos Técnicos',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    '• Presentar documento de identidad original.\n'
                    '• Uniforme completo del club/escuela.\n'
                    '• Ruedas reglamentarias para la categoría.\n'
                    '• Llegar 1 hora antes del congresillo técnico.',
                    style: TextStyle(color: Color(0xFF4B5563), height: 1.5),
                  ),
                ],
              ),
            ),
          ),

          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border(top: BorderSide(color: Colors.grey.shade200)),
            ),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: buttonEnabled
                    ? () async {
                        if (!isRegistered) {
                          // Primera vez: crear pago e ir a checkout
                          final paymentProvider = context.read<PaymentProvider>();
                          final notificationProvider = context.read<NotificationProvider>();

                          final payment = await paymentProvider.createPayment(
                            eventId: event.id,
                            eventTitle: event.title,
                            athleteId: athleteId,
                            athleteName: authProvider.user?.fullName ?? 'Deportista',
                            athleteEmail: authProvider.user?.email ?? '',
                            schoolId: event.schoolId,
                            amount: event.price,
                          );

                          if (payment == null) {
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Ya tienes un pago pendiente para este evento'),
                                ),
                              );
                            }
                            return;
                          }

                          if (context.mounted) {
                            final result = await Navigator.push<bool>(
                              context,
                              MaterialPageRoute(
                                builder: (_) => PaymentCheckoutScreen(
                                  payment: payment,
                                  schoolName: authProvider.schoolName ?? 'Escuela',
                                ),
                              ),
                            );

                            if (result == true && context.mounted) {
                              await eventProvider.registerToEvent(event.id);
                              await notificationProvider.addNotification(
                                userId: event.creatorId,
                                title: 'Nueva inscripción pagada',
                                message:
                                    '${authProvider.user?.fullName ?? 'Un deportista'} pagó \$${event.price.toStringAsFixed(0)} e inscribió a ${event.title}',
                                type: 'payment',
                                relatedId: event.id,
                              );
                              setState(() {});
                            }
                          }
                        } else if (!hasPaid) {
                          // Ya inscrito pero sin pagar: ir a completar pago
                          final payment = paymentProvider.payments.firstWhere(
                            (p) => p.athleteId == athleteId && p.eventId == event.id,
                          );

                          if (context.mounted) {
                            final result = await Navigator.push<bool>(
                              context,
                              MaterialPageRoute(
                                builder: (_) => PaymentCheckoutScreen(
                                  payment: payment,
                                  schoolName: authProvider.schoolName ?? 'Escuela',
                                ),
                              ),
                            );

                            if (result == true && context.mounted) {
                              setState(() {});
                            }
                          }
                        }
                      }
                    : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: buttonColor,
                  disabledBackgroundColor: buttonColor,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                ),
                child: Text(
                  buttonText,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: buttonTextColor,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String title, String subtitle) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: const Color(0xFFEFF6FF),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: const Color(0xFF2563EB)),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(color: Color(0xFF6B7280), fontSize: 13),
              ),
              Text(
                subtitle,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
