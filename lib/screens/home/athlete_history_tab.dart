import 'package:flutter/material.dart';

class AthleteHistoryTab extends StatelessWidget {
  const AthleteHistoryTab({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.all(24.0),
        children: [
          const Text(
            'Historial de Resultados',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1F2937),
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Revisa tu desempeño en competencias anteriores',
            style: TextStyle(
              fontSize: 14,
              color: Color(0xFF6B7280),
            ),
          ),
          const SizedBox(height: 24),

          // Resumen rápido
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFEFF6FF),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFBFDBFE)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildSummaryStat('🥇', 'Oro', '4'),
                _buildSummaryStat('🥈', 'Plata', '3'),
                _buildSummaryStat('🥉', 'Bronce', '2'),
              ],
            ),
          ),
          
          const SizedBox(height: 24),

          // Lista de resultados pasados
          _buildResultCard(
            title: 'Válida Nacional de Transición',
            date: '10 May 2026',
            modality: '200m Meta contra meta',
            position: '1er Puesto',
            time: '19.45s',
            medalColor: const Color(0xFFFFD700),
          ),
          const SizedBox(height: 16),
          _buildResultCard(
            title: 'Campeonato Departamental',
            date: '22 Mar 2026',
            modality: 'Puntos + Eliminación',
            position: '3er Puesto',
            time: 'N/A',
            medalColor: const Color(0xFFCD7F32),
          ),
          const SizedBox(height: 16),
          _buildResultCard(
            title: 'Festival Nacional Interclubes',
            date: '15 Nov 2025',
            modality: '100m Carriles',
            position: '2do Puesto',
            time: '10.82s',
            medalColor: const Color(0xFFC0C0C0),
          ),
          const SizedBox(height: 16),
          _buildResultCard(
            title: 'Copa Región Caribe',
            date: '04 Sep 2025',
            modality: 'Prueba de Relevos',
            position: '4to Puesto',
            time: '1:45.30',
            medalColor: Colors.transparent,
            showMedal: false,
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryStat(String emoji, String label, String count) {
    return Column(
      children: [
        Text(emoji, style: const TextStyle(fontSize: 24)),
        const SizedBox(height: 4),
        Text(
          count,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1E3A8A),
          ),
        ),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: Color(0xFF3B82F6),
          ),
        ),
      ],
    );
  }

  Widget _buildResultCard({
    required String title,
    required String date,
    required String modality,
    required String position,
    required String time,
    required Color medalColor,
    bool showMedal = true,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE5E7EB)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Círculo del trofeo/medalla
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: showMedal ? medalColor.withOpacity(0.1) : const Color(0xFFF3F4F6),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Icon(
                  showMedal ? Icons.emoji_events : Icons.sports_score,
                  color: showMedal ? medalColor : const Color(0xFF9CA3AF),
                  size: 24,
                ),
              ),
            ),
            const SizedBox(width: 16),
            
            // Detalles del resultado
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1F2937),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    date,
                    style: const TextStyle(
                      fontSize: 13,
                      color: Color(0xFF6B7280),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 8),
                    child: Divider(height: 1, color: Color(0xFFF3F4F6)),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Modalidad',
                            style: TextStyle(fontSize: 12, color: Color(0xFF9CA3AF)),
                          ),
                          Text(
                            modality,
                            style: const TextStyle(fontSize: 13, color: Color(0xFF4B5563)),
                          ),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            position,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: showMedal ? const Color(0xFF1F2937) : const Color(0xFF6B7280),
                            ),
                          ),
                          Text(
                            time != 'N/A' ? '⏱ $time' : '--',
                            style: const TextStyle(fontSize: 12, color: Color(0xFF6B7280)),
                          ),
                        ],
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