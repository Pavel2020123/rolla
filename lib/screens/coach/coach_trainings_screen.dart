import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/school_provider.dart';
import '../../providers/training_provider.dart';
import '../../providers/school_request_provider.dart';
import '../../models/training_model.dart';
import 'create_training_screen.dart';

class CoachTrainingsScreen extends StatefulWidget {
  const CoachTrainingsScreen({super.key});

  @override
  State<CoachTrainingsScreen> createState() => _CoachTrainingsScreenState();
}

class _CoachTrainingsScreenState extends State<CoachTrainingsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<TrainingProvider>(context, listen: false).loadTrainings();
      Provider.of<SchoolRequestProvider>(context, listen: false).loadRequests();
    });
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final schoolProvider = Provider.of<SchoolProvider>(context);
    final trainingProvider = Provider.of<TrainingProvider>(context);
    final requestProvider = Provider.of<SchoolRequestProvider>(context);

    final schoolId = schoolProvider.school?.id ?? authProvider.schoolId ?? '';
    final trainings = schoolId.isNotEmpty
        ? trainingProvider.getUpcomingTrainings(schoolId)
        : [];

    final totalAthletes = schoolId.isNotEmpty
        ? requestProvider.getAcceptedAthletesForSchool(schoolId).length
        : 0;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF5F7FA),
        elevation: 0,
        title: const Text(
          'Entrenamientos',
          style: TextStyle(
            color: Color(0xFF1F2937),
            fontWeight: FontWeight.bold,
          ),
        ),
        iconTheme: const IconThemeData(color: Color(0xFF1F2937)),
        actions: [
          IconButton(
            icon: const Icon(Icons.add, color: Color(0xFF2563EB)),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const CreateTrainingScreen(),
                ),
              );
            },
          ),
        ],
      ),
      body: SafeArea(
        child: trainingProvider.isLoading
            ? const Center(child: CircularProgressIndicator())
            : Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${trainings.length} entrenamiento${trainings.length == 1 ? '' : 's'} programado${trainings.length == 1 ? '' : 's'}',
                      style: const TextStyle(
                        fontSize: 16,
                        color: Color(0xFF6B7280),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Expanded(
                      child: trainings.isEmpty
                          ? _buildEmptyState()
                          : ListView.builder(
                              itemCount: trainings.length,
                              itemBuilder: (context, index) {
                                final training = trainings[index];
                                return _buildTrainingCard(
                                  context,
                                  training,
                                  totalAthletes,
                                );
                              },
                            ),
                    ),
                  ],
                ),
              ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => const CreateTrainingScreen(),
            ),
          );
        },
        backgroundColor: const Color(0xFF2563EB),
        icon: const Icon(Icons.add),
        label: const Text('Nuevo'),
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
            'Programa tu primer entrenamiento.',
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
    int totalAthletes,
  ) {
    final pending = totalAthletes - training.confirmedCount - training.declinedCount;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: ExpansionTile(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        collapsedShape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          training.title,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
            color: Color(0xFF1F2937),
          ),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Row(
            children: [
              const Icon(Icons.calendar_today, size: 14, color: Color(0xFF9CA3AF)),
              const SizedBox(width: 4),
              Text(
                '${_formatDate(training.date)} ${training.time ?? ''}',
                style: const TextStyle(fontSize: 13, color: Color(0xFF6B7280)),
              ),
            ],
          ),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildMiniChip('${training.confirmedCount}', const Color(0xFF10B981)),
            const SizedBox(width: 6),
            _buildMiniChip('${training.declinedCount}', const Color(0xFFEF4444)),
            const SizedBox(width: 6),
            _buildMiniChip('$pending', const Color(0xFF9CA3AF)),
          ],
        ),
        children: [
          const Divider(height: 1, indent: 16, endIndent: 16),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.place_outlined, size: 16, color: Color(0xFF9CA3AF)),
                    const SizedBox(width: 6),
                    Text(
                      training.location,
                      style: const TextStyle(color: Color(0xFF6B7280)),
                    ),
                  ],
                ),
                if (training.description != null && training.description!.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Text(
                    training.description!,
                    style: const TextStyle(color: Color(0xFF6B7280), fontSize: 14),
                  ),
                ],
                const SizedBox(height: 16),
                const Text(
                  'Asistencias',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: Color(0xFF1F2937),
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildStatColumn('Confirmaron', training.confirmedCount, const Color(0xFF10B981)),
                    _buildStatColumn('No van', training.declinedCount, const Color(0xFFEF4444)),
                    _buildStatColumn('Sin responder', pending, const Color(0xFF9CA3AF)),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMiniChip(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildStatColumn(String label, int value, Color color) {
    return Column(
      children: [
        Text(
          value.toString(),
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: Color(0xFF6B7280),
          ),
        ),
      ],
    );
  }
}