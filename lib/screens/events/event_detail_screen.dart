import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/athlete_provider.dart';

class EventDetailScreen extends StatelessWidget {
  final String eventId;

  const EventDetailScreen({super.key, required this.eventId});

  @override
  Widget build(BuildContext context) {
    // Escuchamos el estado global para mantener el evento actualizado
    final provider = context.watch<AthleteProvider>();
    
    // Buscamos el evento específico por su ID
    final event = provider.events.firstWhere(
      (e) => e.id == eventId,
      // Si por alguna razón no lo encuentra, devolvemos el primero para no romper la app
      orElse: () => provider.events.first, 
    );

    final formattedDate = "${event.date.day} / ${event.date.month} / ${event.date.year}";

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
                  // Encabezado del evento
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
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            event.category,
                            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 12),
                          ),
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
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Información detallada
                  const Text('Información General', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 16),
                  
                  _buildInfoRow(Icons.calendar_today, 'Fecha', formattedDate),
                  const Divider(height: 24),
                  _buildInfoRow(Icons.location_on_outlined, 'Ubicación', event.location),
                  const Divider(height: 24),
                  _buildInfoRow(Icons.info_outline, 'Estado actual', event.status),
                  
                  const SizedBox(height: 32),
                  const Text('Requisitos Técnicos', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
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
          
          // Botón inferior fijo para Inscribirse / Cancelar
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border(top: BorderSide(color: Colors.grey.shade200)),
            ),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  // Cambiamos el estado de inscripción usando el Provider
                  context.read<AthleteProvider>().toggleEventRegistration(event.id);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: event.isRegistered ? const Color(0xFFFEE2E2) : const Color(0xFF2563EB),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                ),
                child: Text(
                  event.isRegistered ? 'Cancelar Inscripción' : 'Inscribirme al Evento',
                  style: TextStyle(
                    fontSize: 16, 
                    fontWeight: FontWeight.bold, 
                    color: event.isRegistered ? const Color(0xFF991B1B) : Colors.white
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
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: const TextStyle(color: Color(0xFF6B7280), fontSize: 13)),
            Text(subtitle, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
          ],
        ),
      ],
    );
  }
}