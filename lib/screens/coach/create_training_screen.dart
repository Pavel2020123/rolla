import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/school_provider.dart';
import '../../providers/training_provider.dart';
import '../../providers/notification_provider.dart';
import '../../providers/school_request_provider.dart';
import '../../models/training_model.dart';

class CreateTrainingScreen extends StatefulWidget {
  const CreateTrainingScreen({super.key});

  @override
  State<CreateTrainingScreen> createState() => _CreateTrainingScreenState();
}

class _CreateTrainingScreenState extends State<CreateTrainingScreen> {
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _locationController = TextEditingController();
  final _categoryController = TextEditingController();

  DateTime _selectedDate = DateTime.now().add(const Duration(days: 1));
  TimeOfDay _selectedTime = const TimeOfDay(hour: 16, minute: 0);

  bool _isLoading = false;

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _locationController.dispose();
    _categoryController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime(2030),
    );
    if (picked != null) setState(() => _selectedDate = picked);
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
    );
    if (picked != null) setState(() => _selectedTime = picked);
  }

  Future<void> _createTraining() async {
    final title = _titleController.text.trim();
    final location = _locationController.text.trim();

    if (title.isEmpty || location.isEmpty) {
      _showMessage('Completa los campos obligatorios');
      return;
    }

    final authProvider = context.read<AuthProvider>();
    final schoolProvider = context.read<SchoolProvider>();
    final trainingProvider = context.read<TrainingProvider>();
    final notificationProvider = context.read<NotificationProvider>();
    final requestProvider = context.read<SchoolRequestProvider>();

    final coachId = authProvider.user?.id ?? '';
    final schoolId = schoolProvider.school?.id ?? '';
    final formattedTime = _selectedTime.format(context);

    if (schoolId.isEmpty) {
      _showMessage('Error: no se encontró tu escuela');
      return;
    }

    setState(() => _isLoading = true);

    final training = TrainingModel(
      id: 'trn_${DateTime.now().millisecondsSinceEpoch}',
      schoolId: schoolId,
      coachId: coachId,
      title: title,
      description: _descriptionController.text.trim(),
      date: _selectedDate,
      time: '${_selectedTime.hour.toString().padLeft(2, '0')}:${_selectedTime.minute.toString().padLeft(2, '0')}',
      location: location,
      category: _categoryController.text.trim().isNotEmpty ? _categoryController.text.trim() : null,
      createdAt: DateTime.now(),
    );

    final success = await trainingProvider.createTraining(training);

    // Notificar a todos los deportistas de la escuela
    if (success) {
      final athletes = requestProvider.getAcceptedAthletesForSchool(schoolId);
      for (final athlete in athletes) {
        await notificationProvider.addNotification(
          userId: athlete.athleteId,
          title: 'Nuevo entrenamiento',
          message: 'Tu entrenador programó: $title para el ${_selectedDate.day}/${_selectedDate.month} a las $formattedTime',
          type: 'event',
          relatedId: training.id,
        );
      }
    }

    if (!mounted) return;
    setState(() => _isLoading = false);

    if (success) {
      _showMessage('Entrenamiento creado y notificado a los deportistas');
      Navigator.pop(context);
    } else {
      _showMessage('Error al crear el entrenamiento');
    }
  }

  void _showMessage(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF5F7FA),
        elevation: 0,
        title: const Text(
          'Programar Entrenamiento',
          style: TextStyle(
            color: Color(0xFF1F2937),
            fontWeight: FontWeight.bold,
          ),
        ),
        iconTheme: const IconThemeData(color: Color(0xFF1F2937)),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'Detalles del entrenamiento',
                style: TextStyle(
                  fontSize: 16,
                  color: Color(0xFF6B7280),
                ),
              ),
              const SizedBox(height: 24),

              TextField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: 'Título *',
                  hintText: 'Ej. Entrenamiento de velocidad',
                  prefixIcon: Icon(Icons.fitness_center_outlined),
                ),
              ),
              const SizedBox(height: 16),

              TextField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Descripción',
                  hintText: 'Detalles del entrenamiento',
                  prefixIcon: Icon(Icons.description_outlined),
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 16),

              InkWell(
                onTap: _pickDate,
                child: InputDecorator(
                  decoration: const InputDecoration(
                    labelText: 'Fecha *',
                    prefixIcon: Icon(Icons.calendar_today_outlined),
                  ),
                  child: Text(
                    '${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}',
                  ),
                ),
              ),
              const SizedBox(height: 16),

              InkWell(
                onTap: _pickTime,
                child: InputDecorator(
                  decoration: const InputDecoration(
                    labelText: 'Hora',
                    prefixIcon: Icon(Icons.access_time_outlined),
                  ),
                  child: Text(
                    '${_selectedTime.hour.toString().padLeft(2, '0')}:${_selectedTime.minute.toString().padLeft(2, '0')}',
                  ),
                ),
              ),
              const SizedBox(height: 16),

              TextField(
                controller: _locationController,
                decoration: const InputDecoration(
                  labelText: 'Lugar *',
                  hintText: 'Ej. Patinódromo Municipal',
                  prefixIcon: Icon(Icons.place_outlined),
                ),
              ),
              const SizedBox(height: 16),

              TextField(
                controller: _categoryController,
                decoration: const InputDecoration(
                  labelText: 'Categoría (opcional)',
                  hintText: 'Ej. Prejuvenil',
                  prefixIcon: Icon(Icons.category_outlined),
                ),
              ),
              const SizedBox(height: 32),

              ElevatedButton(
                onPressed: _isLoading ? null : _createTraining,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2563EB),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: _isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Text(
                        'Programar entrenamiento',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
