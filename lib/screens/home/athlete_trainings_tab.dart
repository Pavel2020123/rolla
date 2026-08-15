import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/training_provider.dart';
import '../../models/training_model.dart';

class AthleteTrainingsTab extends StatefulWidget {
  const AthleteTrainingsTab({super.key});

  @override
  State<AthleteTrainingsTab> createState() => _AthleteTrainingsTabState();
}

class _AthleteTrainingsTabState extends State<AthleteTrainingsTab> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<TrainingProvider>(context, listen: false).loadTrainings();
    });
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final tomorrow = DateTime(now.year, now.month, now.day + 1);
    final dateOnly = DateTime(date.year, date.month, date.day);

    if (dateOnly.isAtSameMomentAs(DateTime(now.year, now.month, now.day))) {
      return 'Hoy';
    } else if (dateOnly.isAtSameMomentAs(tomorrow)) {
      return 'Mañana';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final trainingProvider = Provider.of<TrainingProvider>(context);

    final hasSchool = authProvider.hasSchool;
    final schoolId = authProvider.schoolId ?? '';
    final athleteId = authProvider.user?.id ?? '';

    final trainings = hasSchool && schoolId.isNotEmpty
        ? trainingProvider.getUpcomingTrainings(schoolId)
        : [];

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Mis Entrenamientos',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1F2937),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              hasSchool
                  ? 'Entrenamientos programados por tu entrenador'
                  : 'Primero necesitas pertenecer a una escuela',
              style: const TextStyle(
                fontSize: 14,
                color: Color(0xFF6B7280),
              ),
            ),
            const SizedBox(height: 24),
            if (!hasSchool)
              _buildNoSchoolState()
            else if (trainings.isEmpty)
              _buildEmptyState()
            else
              Expanded(
                child: ListView.builder(
                  itemCount: trainings.length,
                  itemBuilder: (context, index) {
                    final training = trainings[index];
                    return _buildTrainingCard(context, training, athleteId);
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildNoSchoolState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.info_outline, size: 64, color: Color(0xFFD1D5DB)),
          const SizedBox(height: 16),
          const Text(
            'Sin escuela',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF6B7280),
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Únete a una escuela para ver tus entrenamientos.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Color(0xFF9CA3AF)),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.fitness_center_outlined,
            size: 80,
            color: Color(0xFFD1D5DB),
          ),
          const SizedBox(height: 16),
          const Text(
            'Sin entrenamientos',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF6B7280),
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Tu entrenador aún no ha programado entrenamientos.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Color(0xFF9CA3AF)),
          ),
        ],
      ),
    );
  }

  Widget _buildTrainingCard(
    BuildContext context,
    TrainingModel training,
    String athleteId,
  ) {
    final isConfirmed = training.isConfirmed(athleteId);
    final isDeclined = training.isDeclined(athleteId);

    Color statusColor;
    String statusText;
    IconData statusIcon;

    if (isConfirmed) {
      statusColor = const Color(0xFF10B981);
      statusText = 'Vas a asistir';
      statusIcon = Icons.check_circle;
    } else if (isDeclined) {
      statusColor = const Color(0xFFEF4444);
      statusText = 'No vas a asistir';
      statusIcon = Icons.cancel;
    } else {
      statusColor = const Color(0xFFF59E0B);
      statusText = 'Pendiente de confirmar';
      statusIcon = Icons.help_outline;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header con fecha destacada
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
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFF2563EB).withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        _formatDate(training.date),
                        style: const TextStyle(
                          color: Color(0xFF2563EB),
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    if (training.time != null) ...[
                      const SizedBox(width: 8),
                      Text(
                        training.time!,
                        style: const TextStyle(
                          fontSize: 13,
                          color: Color(0xFF6B7280),
                        ),
                      ),
                    ],
                  ],
                ),
                Row(
                  children: [
                    Icon(statusIcon, size: 16, color: statusColor),
                    const SizedBox(width: 4),
                    Text(
                      statusText,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: statusColor,
                      ),
                    ),
                  ],
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
                  training.title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1F2937),
                  ),
                ),
                if (training.description != null && training.description!.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Text(
                    training.description!,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Color(0xFF6B7280),
                    ),
                  ),
                ],
                const SizedBox(height: 12),
                Row(
                  children: [
                    const Icon(Icons.place_outlined, size: 16, color: Color(0xFF9CA3AF)),
                    const SizedBox(width: 6),
                    Text(
                      training.location,
                      style: const TextStyle(fontSize: 14, color: Color(0xFF6B7280)),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                // Botones de confirmación
                if (!isConfirmed && !isDeclined) ...[
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () => _confirm(context, training.id, athleteId),
                          icon: const Icon(Icons.check, size: 18),
                          label: const Text('Sí voy'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF10B981),
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () => _decline(context, training.id, athleteId),
                          icon: const Icon(Icons.close, size: 18),
                          label: const Text('No voy'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: const Color(0xFFEF4444),
                            side: const BorderSide(color: Color(0xFFEF4444)),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ] else ...[
                  // Cambiar respuesta
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: () => _changeResponse(context, training.id, athleteId, isConfirmed),
                      icon: const Icon(Icons.swap_horiz, size: 18),
                      label: Text(isConfirmed ? 'Cambiar a "No voy"' : 'Cambiar a "Sí voy"'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: const Color(0xFF6B7280),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _confirm(BuildContext context, String trainingId, String athleteId) async {
    final trainingProvider = context.read<TrainingProvider>();
    await trainingProvider.confirmAttendance(trainingId, athleteId);
  }

  Future<void> _decline(BuildContext context, String trainingId, String athleteId) async {
    final trainingProvider = context.read<TrainingProvider>();
    await trainingProvider.declineAttendance(trainingId, athleteId);
  }

  Future<void> _changeResponse(
    BuildContext context,
    String trainingId,
    String athleteId,
    bool currentlyConfirmed,
  ) async {
    final trainingProvider = context.read<TrainingProvider>();
    if (currentlyConfirmed) {
      await trainingProvider.declineAttendance(trainingId, athleteId);
    } else {
      await trainingProvider.confirmAttendance(trainingId, athleteId);
    }
  }
}
