import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rolla/screens/athlete/find_school_screen.dart';
import '../../providers/athlete_provider.dart';
import '../../providers/auth_provider.dart';
import '../auth/splash_screen.dart';
import '../profile/edit_profile_screen.dart';
import '../athlete/request_transfer_screen.dart';
import '../athlete/school_history_screen.dart';

class AthleteProfileTab extends StatelessWidget {
  const AthleteProfileTab({super.key});

  String _formatDate(DateTime? date) {
    if (date == null) return 'No registrada';
    return '${date.day}/${date.month}/${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    final athleteProvider = context.watch<AthleteProvider>();
    final authProvider = context.watch<AuthProvider>();
    final athlete = athleteProvider.athlete;
    final hasSchool = authProvider.hasSchool;

    if (athleteProvider.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Perfil',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1F2937),
              ),
            ),
            const SizedBox(height: 24),
            if (athlete != null) ...[
              // AVATAR + NOMBRE + INFO
              Center(
                child: Column(
                  children: [
                    // FOTO O INICIALES
                    Container(
                      width: 90,
                      height: 90,
                      decoration: BoxDecoration(
                        color: const Color(0xFFEFF6FF),
                        borderRadius: BorderRadius.circular(45),
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
                                  fontSize: 32,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF2563EB),
                                ),
                              ),
                            )
                          : null,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      athlete.fullName,
                      style: const TextStyle(
                        fontSize: 20,
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
                    const SizedBox(height: 12),
                    // CHIPS DE INFO
                    Wrap(
                      spacing: 8,
                      alignment: WrapAlignment.center,
                      children: [
                        _buildChip(athlete.category, Icons.category),
                        _buildChip(athlete.level, Icons.trending_up),
                        if (athlete.modality != null)
                          _buildChip(athlete.modality!, Icons.sports),
                      ],
                    ),
                    if (athlete.birthDate != null) ...[
                      const SizedBox(height: 8),
                      Text(
                        'Nacimiento: ${_formatDate(athlete.birthDate)}',
                        style: const TextStyle(
                          fontSize: 12,
                          color: Color(0xFF9CA3AF),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 32),

              // MEDALLERO
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
                      'Medallero',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildMedalItem('Oro', athlete.goldMedals.toString(), const Color(0xFFFBBF24)),
                        _buildMedalItem('Plata', athlete.silverMedals.toString(), const Color(0xFFD1D5DB)),
                        _buildMedalItem('Bronce', athlete.bronzeMedals.toString(), const Color(0xFFB45309)),
                        _buildMedalItem('Total', athlete.totalMedals.toString(), Colors.white),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              // OPCIONES DEL MENÚ
              _buildProfileOption(
                icon: Icons.edit_outlined,
                title: 'Editar perfil',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const EditProfileScreen(),
                    ),
                  );
                },
              ),
              _buildProfileOption(
                icon: Icons.school_outlined,
                title: 'Mi escuela',
                subtitle: hasSchool
                    ? (authProvider.schoolName ?? 'Sin escuela')
                    : 'No perteneces a ninguna escuela',
                onTap: () {
                  if (!hasSchool) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const FindSchoolScreen(),
                      ),
                    );
                  }
                },
              ),
              _buildProfileOption(
                icon: Icons.swap_horiz_outlined,
                title: 'Solicitar traslado',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const RequestTransferScreen(),
                    ),
                  );
                },
              ),
              _buildProfileOption(
                icon: Icons.history_outlined,
                title: 'Historial de escuelas',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const SchoolHistoryScreen(),
                    ),
                  );
                },
              ),
              _buildProfileOption(
                icon: Icons.settings_outlined,
                title: 'Configuración',
                onTap: () {},
              ),
              _buildProfileOption(
                icon: Icons.help_outline,
                title: 'Ayuda y soporte',
                onTap: () {},
              ),
              _buildProfileOption(
                icon: Icons.logout,
                title: 'Cerrar sesión',
                textColor: Colors.red,
                iconColor: Colors.red,
                onTap: () => _showLogoutDialog(context),
              ),
            ] else ...[
              const Center(
                child: Text(
                  'No se pudo cargar el perfil',
                  style: TextStyle(color: Color(0xFF6B7280)),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildChip(String label, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFFEFF6FF),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: const Color(0xFF2563EB)),
          const SizedBox(width: 4),
          Text(
            label,
            style: const TextStyle(
              color: Color(0xFF2563EB),
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMedalItem(String label, String value, Color color) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            color: color,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  Widget _buildProfileOption({
    required IconData icon,
    required String title,
    String? subtitle,
    required VoidCallback onTap,
    Color? textColor,
    Color? iconColor,
  }) {
    return ListTile(
      leading: Icon(icon, color: iconColor ?? const Color(0xFF6B7280)),
      title: Text(
        title,
        style: TextStyle(
          color: textColor ?? const Color(0xFF1F2937),
          fontWeight: FontWeight.w500,
        ),
      ),
      subtitle: subtitle != null
          ? Text(
              subtitle,
              style: const TextStyle(
                fontSize: 12,
                color: Color(0xFF9CA3AF),
              ),
            )
          : null,
      trailing: const Icon(Icons.arrow_forward_ios,
          size: 16, color: Color(0xFF9CA3AF)),
      onTap: onTap,
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cerrar sesión'),
        content: const Text('¿Estás seguro de que deseas cerrar sesión?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () async {
              final authProvider =
                  Provider.of<AuthProvider>(context, listen: false);
              await authProvider.logout();

              if (context.mounted) {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (_) => const SplashScreen()),
                  (route) => false,
                );
              }
            },
            child: const Text(
              'Cerrar sesión',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }
}