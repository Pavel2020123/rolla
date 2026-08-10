import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/event_model.dart';
import '../../providers/athlete_provider.dart';
import '../events/event_detail_screen.dart';

class AthleteEventsTab extends StatelessWidget {
  const AthleteEventsTab({super.key});

  @override
  Widget build(BuildContext context) {
    // 1. Escuchamos el estado global
    final provider = context.watch<AthleteProvider>();

    // 2. Manejamos el estado de carga
    if (provider.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    final events = provider.events;

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
          const Text(
            'Mantente al día con tu calendario competitivo',
            style: TextStyle(
              fontSize: 14,
              color: Color(0xFF6B7280),
            ),
          ),
          const SizedBox(height: 24),
          
          if (events.isEmpty)
            const Center(child: Text('No hay eventos disponibles')),
            
          // 3. Renderizamos las tarjetas dinámicamente
          ...events.map((event) => Padding(
                padding: const EdgeInsets.only(bottom: 16.0),
                child: _buildEventCard(context, event, provider),
              )),
        ],
      ),
    );
  }

  Widget _buildEventCard(BuildContext context, EventModel event, AthleteProvider provider) {
    final formattedDate = "${event.date.day} / ${event.date.month} / ${event.date.year}";

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
                  
                  // 4. Botón interactivo para cambiar el estado de inscripción
                  InkWell(
                    onTap: () {
                      provider.toggleEventRegistration(event.id);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(event.isRegistered 
                            ? 'Inscripción cancelada' 
                            : '¡Te has inscrito con éxito!'),
                          duration: const Duration(seconds: 2),
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    },
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: event.isRegistered ? const Color(0xFFDEF7EC) : const Color(0xFFE1EFFE),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: event.isRegistered ? const Color(0xFF31C48D) : const Color(0xFF3F83F8),
                          width: 1,
                        ),
                      ),
                      child: Text(
                        event.status,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: event.isRegistered ? const Color(0xFF03543F) : const Color(0xFF1E429F),
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
                        event.category,
                        style: const TextStyle(fontSize: 14, color: Color(0xFF6B7280)),
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