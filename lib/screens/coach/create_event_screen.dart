import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/school_provider.dart';
import '../../providers/event_provider.dart';
import '../../models/event_model.dart';

class CreateEventScreen extends StatefulWidget {
  const CreateEventScreen({super.key});

  @override
  State<CreateEventScreen> createState() => _CreateEventScreenState();
}

class _CreateEventScreenState extends State<CreateEventScreen> {
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _locationController = TextEditingController();
  final _categoryController = TextEditingController();
  final _modalityController = TextEditingController();
  final _priceController = TextEditingController();
  final _maxSlotsController = TextEditingController();

  DateTime _selectedDate = DateTime.now().add(const Duration(days: 7));
  TimeOfDay _selectedTime = const TimeOfDay(hour: 8, minute: 0);
  DateTime? _deadlineDate;

  bool _isLoading = false;

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _locationController.dispose();
    _categoryController.dispose();
    _modalityController.dispose();
    _priceController.dispose();
    _maxSlotsController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime(2030),
    );
    if (picked != null) {
      setState(() => _selectedDate = picked);
    }
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
    );
    if (picked != null) {
      setState(() => _selectedTime = picked);
    }
  }

  Future<void> _pickDeadline() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _deadlineDate ?? DateTime.now().add(const Duration(days: 3)),
      firstDate: DateTime.now(),
      lastDate: _selectedDate,
    );
    if (picked != null) {
      setState(() => _deadlineDate = picked);
    }
  }

  Future<void> _createEvent() async {
    final title = _titleController.text.trim();
    final description = _descriptionController.text.trim();
    final location = _locationController.text.trim();
    final category = _categoryController.text.trim();
    final modality = _modalityController.text.trim();
    final priceText = _priceController.text.trim();
    final maxSlotsText = _maxSlotsController.text.trim();

    if (title.isEmpty || location.isEmpty || category.isEmpty || modality.isEmpty || priceText.isEmpty) {
      _showMessage('Por favor completa los campos obligatorios');
      return;
    }

    final price = double.tryParse(priceText) ?? 0;
    final maxSlots = int.tryParse(maxSlotsText);

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final schoolProvider = Provider.of<SchoolProvider>(context, listen: false);
    final eventProvider = Provider.of<EventProvider>(context, listen: false);

    final creatorId = authProvider.user?['id'] ?? '';
    final schoolId = schoolProvider.school?.id ?? authProvider.schoolId ?? '';

    if (schoolId.isEmpty) {
      _showMessage('Error: no se encontró tu escuela');
      return;
    }

    setState(() => _isLoading = true);

    final newEvent = EventModel(
      id: 'evt_${DateTime.now().millisecondsSinceEpoch}',
      schoolId: schoolId,
      creatorId: creatorId,
      title: title,
      description: description,
      date: _selectedDate,
      time: '${_selectedTime.hour.toString().padLeft(2, '0')}:${_selectedTime.minute.toString().padLeft(2, '0')}',
      location: location,
      category: category,
      modality: modality,
      price: price,
      deadline: _deadlineDate,
      maxSlots: maxSlots,
      status: 'published', // En demo publicamos directo, luego será 'pending'
      enabledAthletes: const [],
      isRegistered: false,
    );

    final success = await eventProvider.createEvent(newEvent);

    setState(() => _isLoading = false);

    if (!mounted) return;

    if (success) {
      _showMessage('Evento creado exitosamente');
      Navigator.pop(context);
    } else {
      _showMessage('Error al crear el evento');
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF5F7FA),
        elevation: 0,
        title: const Text(
          'Crear Evento',
          style: TextStyle(
            color: Color(0xFF1F2937),
            fontWeight: FontWeight.bold,
          ),
        ),
        iconTheme: const IconThemeData(color: Color(0xFF1F2937)),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'Información del evento',
                style: TextStyle(
                  fontSize: 16,
                  color: Color(0xFF6B7280),
                ),
              ),
              const SizedBox(height: 24),

              // Título
              TextField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: 'Nombre del evento *',
                  hintText: 'Ej. Copa Valledupar 2026',
                  prefixIcon: Icon(Icons.event_outlined),
                ),
              ),
              const SizedBox(height: 16),

              // Descripción
              TextField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Descripción',
                  hintText: 'Detalles del evento',
                  prefixIcon: Icon(Icons.description_outlined),
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 16),

              // Fecha
              InkWell(
                onTap: _pickDate,
                child: InputDecorator(
                  decoration: const InputDecoration(
                    labelText: 'Fecha del evento *',
                    prefixIcon: Icon(Icons.calendar_today_outlined),
                  ),
                  child: Text(
                    '${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}',
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Hora
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

              // Lugar
              TextField(
                controller: _locationController,
                decoration: const InputDecoration(
                  labelText: 'Lugar *',
                  hintText: 'Ej. Patinódromo Municipal',
                  prefixIcon: Icon(Icons.place_outlined),
                ),
              ),
              const SizedBox(height: 16),

              // Categoría
              TextField(
                controller: _categoryController,
                decoration: const InputDecoration(
                  labelText: 'Categoría *',
                  hintText: 'Ej. Prejuvenil, Juvenil, etc.',
                  prefixIcon: Icon(Icons.category_outlined),
                ),
              ),
              const SizedBox(height: 16),

              // Modalidad
              TextField(
                controller: _modalityController,
                decoration: const InputDecoration(
                  labelText: 'Modalidad *',
                  hintText: 'Ej. Velocidad, Figuras, etc.',
                  prefixIcon: Icon(Icons.sports_outlined),
                ),
              ),
              const SizedBox(height: 16),

              // Precio
              TextField(
                controller: _priceController,
                decoration: const InputDecoration(
                  labelText: 'Precio de inscripción *',
                  hintText: 'Ej. 50000',
                  prefixIcon: Icon(Icons.attach_money_outlined),
                  prefixText: '\$ ',
                ),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 16),

              // Fecha límite
              InkWell(
                onTap: _pickDeadline,
                child: InputDecorator(
                  decoration: const InputDecoration(
                    labelText: 'Fecha límite de inscripción',
                    prefixIcon: Icon(Icons.timer_outlined),
                  ),
                  child: Text(
                    _deadlineDate != null
                        ? '${_deadlineDate!.day}/${_deadlineDate!.month}/${_deadlineDate!.year}'
                        : 'Sin fecha límite',
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Cupos
              TextField(
                controller: _maxSlotsController,
                decoration: const InputDecoration(
                  labelText: 'Cupos máximos',
                  hintText: 'Ej. 50',
                  prefixIcon: Icon(Icons.people_outline),
                ),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 32),

              // Botón crear
              ElevatedButton(
                onPressed: _isLoading ? null : _createEvent,
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
                        'Crear Evento',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}