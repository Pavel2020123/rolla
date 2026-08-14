import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/transfer_provider.dart';
import '../../providers/notification_provider.dart';

class RequestTransferScreen extends StatefulWidget {
  const RequestTransferScreen({super.key});

  @override
  State<RequestTransferScreen> createState() => _RequestTransferScreenState();
}

class _RequestTransferScreenState extends State<RequestTransferScreen> {
  final _reasonController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _reasonController.dispose();
    super.dispose();
  }

  Future<void> _requestFreeAgent() async {
    await _submitTransfer(type: 'free_agent');
  }

  Future<void> _submitTransfer({required String type, String? targetSchoolId, String? targetSchoolName}) async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final transferProvider = Provider.of<TransferProvider>(context, listen: false);
    final notificationProvider = Provider.of<NotificationProvider>(context, listen: false);

    final athleteId = authProvider.user?['id'] ?? '';
    final athleteName = authProvider.user?['fullName'] ?? '';
    final athleteEmail = authProvider.user?['email'] ?? '';
    final currentSchoolId = authProvider.schoolId ?? '';
    final currentSchoolName = authProvider.schoolName ?? '';

    if (currentSchoolId.isEmpty) {
      _showMessage('No perteneces a ninguna escuela');
      return;
    }

    setState(() => _isLoading = true);

    final success = await transferProvider.requestTransfer(
      athleteId: athleteId,
      athleteName: athleteName,
      athleteEmail: athleteEmail,
      currentSchoolId: currentSchoolId,
      currentSchoolName: currentSchoolName,
      targetSchoolId: targetSchoolId,
      targetSchoolName: targetSchoolName,
      type: type,
    );

    setState(() => _isLoading = false);

    if (!mounted) return;

    if (success) {
      // Notificar al entrenador de la escuela actual
      // En demo usamos un ID fijo para el entrenador, en producción se buscaría por schoolId
      await notificationProvider.addNotification(
        userId: 'coach_$currentSchoolId', // ID del entrenador
        title: 'Solicitud de traslado',
        message: '$athleteName solicitó ${type == 'free_agent' ? 'quedar como agente libre' : 'un traslado'}',
        type: 'transfer',
      );

      _showMessage('Solicitud enviada correctamente');
      Navigator.pop(context);
    } else {
      _showMessage('Ya tienes una solicitud de traslado activa');
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final hasSchool = authProvider.hasSchool;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF5F7FA),
        elevation: 0,
        title: const Text(
          'Solicitar Traslado',
          style: TextStyle(
            color: Color(0xFF1F2937),
            fontWeight: FontWeight.bold,
          ),
        ),
        iconTheme: const IconThemeData(color: Color(0xFF1F2937)),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (!hasSchool) ...[
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFEF3C7),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFFFCD34D)),
                  ),
                  child: const Column(
                    children: [
                      Icon(Icons.info_outline, color: Color(0xFFD97706)),
                      SizedBox(height: 8),
                      Text(
                        'No perteneces a ninguna escuela',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF92400E),
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Para solicitar un traslado, primero debes estar en una escuela.',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Color(0xFFA16207)),
                      ),
                    ],
                  ),
                ),
              ] else ...[
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFFE5E7EB)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Escuela actual',
                        style: TextStyle(
                          fontSize: 12,
                          color: Color(0xFF9CA3AF),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        authProvider.schoolName ?? 'Sin escuela',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1F2937),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),

                const Text(
                  '¿Qué deseas hacer?',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1F2937),
                  ),
                ),
                const SizedBox(height: 16),

                // Opción 1: Quedar como agente libre
                _buildOptionCard(
                  title: 'Quedar como agente libre',
                  description: 'Solicita que tu escuela actual te libere para poder unirte a otra.',
                  icon: Icons.person_outline,
                  color: const Color(0xFF2563EB),
                  onTap: _isLoading ? null : _requestFreeAgent,
                ),
                const SizedBox(height: 16),

                // Opción 2: Trasladarse a otra escuela (para futuro)
                _buildOptionCard(
                  title: 'Solicitar traslado a otra escuela',
                  description: 'Próximamente: selecciona la escuela destino.',
                  icon: Icons.swap_horiz,
                  color: const Color(0xFF10B981),
                  onTap: () => _showMessage('Función en desarrollo'),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOptionCard({
    required String title,
    required String description,
    required IconData icon,
    required Color color,
    required VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFE5E7EB)),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 28),
            ),
            const SizedBox(width: 16),
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
                    description,
                    style: const TextStyle(
                      fontSize: 13,
                      color: Color(0xFF6B7280),
                    ),
                  ),
                ],
              ),
            ),
            if (_isLoading)
              const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            else
              const Icon(
                Icons.arrow_forward_ios,
                color: Color(0xFF9CA3AF),
                size: 16,
              ),
          ],
        ),
      ),
    );
  }
}