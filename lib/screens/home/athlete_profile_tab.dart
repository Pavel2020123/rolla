import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/athlete_provider.dart';
import '../profile/edit_profile_screen.dart';

class AthleteProfileTab extends StatelessWidget {
  const AthleteProfileTab({super.key});

  @override
  Widget build(BuildContext context) {
    // Escuchamos el estado global
    final provider = context.watch<AthleteProvider>();

    if (provider.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    final athlete = provider.athlete;

    if (athlete == null) {
      return const Center(child: Text('No hay datos del perfil'));
    }

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 16),
            // Avatar dinámico con iniciales
            CircleAvatar(
              radius: 50,
              backgroundColor: const Color(0xFFEFF6FF),
              child: Text(
                athlete.initials,
                style: const TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2563EB),
                ),
              ),
            ),
            const SizedBox(height: 16),
            
            // Nombre completo y rol
            Text(
              athlete.fullName,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1F2937),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              athlete.role,
              style: const TextStyle(
                fontSize: 16,
                color: Color(0xFF6B7280),
              ),
            ),
            const SizedBox(height: 32),

            // Tarjeta de detalles
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFE5E7EB)),
              ),
              child: Column(
                children: [
                  _buildProfileRow(Icons.school_outlined, 'Club / Escuela', athlete.schoolName),
                  const Divider(height: 24, color: Color(0xFFF3F4F6)),
                  _buildProfileRow(Icons.category_outlined, 'Categoría', athlete.category),
                  const Divider(height: 24, color: Color(0xFFF3F4F6)),
                  _buildProfileRow(Icons.trending_up, 'Nivel', athlete.level),
                ],
              ),
            ),
            const SizedBox(height: 32),
            
            // Botón de editar perfil 
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const EditProfileScreen()),
                  );
                },
                icon: const Icon(Icons.edit, color: Colors.white),
                label: const Text(
                  'Editar Perfil',
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2563EB),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Widget auxiliar para mantener el código limpio
  Widget _buildProfileRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: const Color(0xFFF9FAFB),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, size: 20, color: const Color(0xFF6B7280)),
        ),
        const SizedBox(width: 16),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: const TextStyle(
                fontSize: 12,
                color: Color(0xFF9CA3AF),
              ),
            ),
            Text(
              value,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: Color(0xFF374151),
              ),
            ),
          ],
        ),
      ],
    );
  }
}