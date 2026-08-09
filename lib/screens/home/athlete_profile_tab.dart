import 'package:flutter/material.dart';

class AthleteProfileTab extends StatelessWidget {
  const AthleteProfileTab({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Cabecera del Perfil (Foto y Nombre)
            Column(
              children: [
                Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    color: const Color(0xFFEFF6FF),
                    shape: BoxShape.circle,
                    border: Border.all(color: const Color(0xFF2563EB), width: 2),
                  ),
                  child: const Center(
                    child: Text(
                      'JP',
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF2563EB),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Juan Pérez',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1F2937),
                  ),
                ),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF3F4F6),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Text(
                    'Deportista',
                    style: TextStyle(
                      color: Color(0xFF4B5563),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 32),

            // Tarjeta de Información General
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFE5E7EB)),
              ),
              child: Column(
                children: [
                  _buildInfoRow('Escuela', 'Rolla Skating Academy', Icons.storefront_outlined),
                  const Divider(height: 24, color: Color(0xFFF3F4F6)),
                  _buildInfoRow('Categoría', 'Prejuvenil', Icons.category_outlined),
                  const Divider(height: 24, color: Color(0xFFF3F4F6)),
                  _buildInfoRow('Nivel', 'Semiprofesional', Icons.star_border),
                ],
              ),
            ),
            
            const SizedBox(height: 24),

            // Tarjeta de Estadísticas
            Row(
              children: [
                Expanded(
                  child: _buildStatBox('Participaciones', '18'),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildMedalsBox(),
                ),
              ],
            ),
            
            const SizedBox(height: 32),

            // Historial Deportivo
            const Text(
              'Historial deportivo',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1F2937),
              ),
            ),
            const SizedBox(height: 16),
            
            // Lista del Historial
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFE5E7EB)),
              ),
              child: Column(
                children: [
                  _buildHistoryItem(
                    '2026 - Actualidad',
                    'Rolla Skating Academy',
                    'Semiprofesional',
                    isFirst: true,
                  ),
                  const Divider(height: 1, color: Color(0xFFF3F4F6), indent: 48),
                  _buildHistoryItem(
                    '2024 - 2026',
                    'Valledupar Skate Club',
                    'Intermedio',
                  ),
                  const Divider(height: 1, color: Color(0xFFF3F4F6), indent: 48),
                  _buildHistoryItem(
                    '2022 - 2024',
                    'Escuela Los Patines',
                    'Principiante',
                    isLast: true,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, IconData icon) {
    return Row(
      children: [
        Icon(icon, color: const Color(0xFF9CA3AF), size: 20),
        const SizedBox(width: 12),
        Text(
          label,
          style: const TextStyle(color: Color(0xFF6B7280), fontSize: 14),
        ),
        const Spacer(),
        Text(
          value,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: Color(0xFF1F2937),
            fontSize: 14,
          ),
        ),
      ],
    );
  }

  Widget _buildStatBox(String title, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1F2937),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: const TextStyle(
              fontSize: 13,
              color: Color(0xFF6B7280),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMedalsBox() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: const [
              Text(
                '9',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1F2937),
                ),
              ),
              SizedBox(width: 4),
              Text(
                'Medallas',
                style: TextStyle(
                  fontSize: 13,
                  color: Color(0xFF6B7280),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: const [
              Text('🥇 4', style: TextStyle(fontSize: 12)),
              SizedBox(width: 8),
              Text('🥈 3', style: TextStyle(fontSize: 12)),
              SizedBox(width: 8),
              Text('🥉 2', style: TextStyle(fontSize: 12)),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildHistoryItem(String period, String school, String level, {bool isFirst = false, bool isLast = false}) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            children: [
              Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  color: isFirst ? const Color(0xFF2563EB) : const Color(0xFFD1D5DB),
                  shape: BoxShape.circle,
                ),
              ),
            ],
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  period,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2563EB),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  school,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1F2937),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  level,
                  style: const TextStyle(
                    fontSize: 14,
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