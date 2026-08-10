import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/result_model.dart';
import '../../providers/athlete_provider.dart';

class AthleteHistoryTab extends StatelessWidget {
  const AthleteHistoryTab({super.key});

  @override
  Widget build(BuildContext context) {
    // Escuchamos el estado global
    final provider = context.watch<AthleteProvider>();

    if (provider.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    final results = provider.results;

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
            'Tu trayectoria y logros en competencias anteriores',
            style: TextStyle(
              fontSize: 14,
              color: Color(0xFF6B7280),
            ),
          ),
          const SizedBox(height: 24),
          
          if (results.isEmpty)
            const Center(
              child: Text(
                'No hay resultados registrados aún.',
                style: TextStyle(color: Color(0xFF6B7280)),
              ),
            ),
            
          // Iteramos sobre la lista de resultados del Provider
          ...results.map((result) => Padding(
                padding: const EdgeInsets.only(bottom: 16.0),
                child: _buildResultCard(result),
              )),
        ],
      ),
    );
  }

  Widget _buildResultCard(ResultModel result) {
    final formattedDate = "${result.date.day} / ${result.date.month} / ${result.date.year}";
    
    // Lógica para definir el color e ícono según la medalla
    Color medalColor;
    IconData medalIcon;

    switch (result.medalType) {
      case MedalType.gold:
        medalColor = const Color(0xFFFBBF24); // Amarillo / Oro
        medalIcon = Icons.emoji_events;
        break;
      case MedalType.silver:
        medalColor = const Color(0xFF9CA3AF); // Gris / Plata
        medalIcon = Icons.emoji_events;
        break;
      case MedalType.bronze:
        medalColor = const Color(0xFFB45309); // Naranja oscuro / Bronce
        medalIcon = Icons.emoji_events;
        break;
      case MedalType.none:
      default:
        medalColor = const Color(0xFFE5E7EB); // Gris claro / Sin medalla
        medalIcon = Icons.workspace_premium;
        break;
    }

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      padding: const EdgeInsets.all(16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Círculo con el ícono de la medalla
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: result.showMedal ? medalColor.withValues(alpha: 0.15) : const Color(0xFFF9FAFB),
              shape: BoxShape.circle,
            ),
            child: Icon(
              medalIcon,
              color: result.showMedal ? medalColor : const Color(0xFF9CA3AF),
              size: 28,
            ),
          ),
          const SizedBox(width: 16),
          
          // Información del resultado
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  result.title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1F2937),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '$formattedDate • ${result.modality}',
                  style: const TextStyle(
                    fontSize: 13,
                    color: Color(0xFF6B7280),
                  ),
                ),
                const SizedBox(height: 12),
                
                // Etiquetas de Posición y Tiempo (si existe)
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF3F4F6),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        result.position,
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF4B5563),
                        ),
                      ),
                    ),
                    if (result.time != null) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: const Color(0xFFEFF6FF),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.timer_outlined, size: 12, color: Color(0xFF2563EB)),
                            const SizedBox(width: 4),
                            Text(
                              result.time!,
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF1E429F),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}