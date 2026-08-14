import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rolla/screens/athlete/find_school_screen.dart';
import '../../providers/athlete_provider.dart';
import '../../providers/auth_provider.dart';

class AthleteHomeTab extends StatelessWidget {
  const AthleteHomeTab({super.key});

  @override
  Widget build(BuildContext context) {
    final athleteProvider = context.watch<AthleteProvider>();
    final authProvider = context.watch<AuthProvider>();

    if (athleteProvider.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    final athlete = athleteProvider.athlete;
    final events = athleteProvider.events;
    final hasSchool = authProvider.hasSchool;

    if (athlete == null) {
      return const Center(child: Text('No se encontraron datos del deportista.'));
    }

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Saludo con foto real
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Hola, ${athlete.firstName} 👋',
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1F2937),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        hasSchool
                            ? (authProvider.schoolName ?? 'Sin escuela')
                            : 'Sin escuela asignada',
                        style: TextStyle(
                          fontSize: 14,
                          color: hasSchool
                              ? const Color(0xFF6B7280)
                              : const Color(0xFFD97706),
                        ),
                      ),
                      if (athlete.modality != null) ...[
                        const SizedBox(height: 4),
                        Text(
                          '${athlete.category} • ${athlete.level} • ${athlete.modality}',
                          style: const TextStyle(
                            fontSize: 12,
                            color: Color(0xFF9CA3AF),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                // AVATAR CON FOTO REAL
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    color: const Color(0xFFEFF6FF),
                    borderRadius: BorderRadius.circular(26),
                    border: Border.all(color: const Color(0xFF2563EB), width: 2),
                    image: athlete.photoUrl != null
                        ? DecorationImage(
                            image: FileImage(File(athlete.photoUrl!)),
                            fit: BoxFit.cover,
                          )
                        : null,
                  ),
                  child: athlete.photoUrl == null
                      ? Center(
                          child: Text(
                            athlete.initials,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                              color: Color(0xFF2563EB),
                            ),
                          ),
                        )
                      : null,
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Si NO tiene escuela, mostrar alerta
            if (!hasSchool) ...[
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: const Color(0xFFFEF3C7),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFFCD34D)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.info_outline, color: Color(0xFFD97706)),
                        SizedBox(width: 8),
                        Text(
                          'No perteneces a ninguna escuela',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF92400E),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Para inscribirte a eventos y gestionar tu perfil deportivo, necesitas pertenecer a una escuela.',
                      style: TextStyle(color: Color(0xFFA16207)),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
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
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
            ],

            // Resumen de temporada con medallero
            Container(
              padding: const EdgeInsets.all(20),
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
                  const Text(
                    'Resumen de Temporada',
                    style: TextStyle(color: Colors.white70, fontSize: 14),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildStatItem('Participaciones', athlete.participationsCount.toString()),
                      _buildStatItem('Oro', athlete.goldMedals.toString(), color: const Color(0xFFFBBF24)),
                      _buildStatItem('Plata', athlete.silverMedals.toString(), color: const Color(0xFFD1D5DB)),
                      _buildStatItem('Bronce', athlete.bronzeMedals.toString(), color: const Color(0xFFB45309)),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // Próximo evento
            const Text(
              'Próximo Evento',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1F2937),
              ),
            ),
            const SizedBox(height: 12),
            if (events.isNotEmpty) ...[
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFE5E7EB)),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFFEFF6FF),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.event, color: Color(0xFF2563EB)),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            events.first.title,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                              color: Color(0xFF1F2937),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${events.first.location} • ${events.first.modality}',
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
              ),
            ] else ...[
              const Text(
                'No hay eventos programados.',
                style: TextStyle(color: Color(0xFF6B7280)),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(String label, String value, {Color? color}) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            value,
            style: TextStyle(
              color: color ?? Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(color: Colors.white70, fontSize: 11),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}