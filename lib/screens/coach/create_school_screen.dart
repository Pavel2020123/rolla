import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/school_provider.dart';
import 'coach_main_screen.dart';

class CreateSchoolScreen extends StatefulWidget {
  const CreateSchoolScreen({super.key});

  @override
  State<CreateSchoolScreen> createState() => _CreateSchoolScreenState();
}

class _CreateSchoolScreenState extends State<CreateSchoolScreen> {
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _cityController = TextEditingController();
  final _addressController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _infoController = TextEditingController();

  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _cityController.dispose();
    _addressController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _infoController.dispose();
    super.dispose();
  }

  Future<void> _createSchool() async {
    final name = _nameController.text.trim();
    final description = _descriptionController.text.trim();
    final city = _cityController.text.trim();
    final address = _addressController.text.trim();
    final phone = _phoneController.text.trim();
    final email = _emailController.text.trim();
    final info = _infoController.text.trim();

    if (name.isEmpty || city.isEmpty || address.isEmpty || phone.isEmpty) {
      _showMessage('Por favor completa los campos obligatorios');
      return;
    }

    setState(() => _isLoading = true);

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final ownerId = authProvider.user?.id ?? '';

    final schoolProvider = Provider.of<SchoolProvider>(context, listen: false);
    final success = await schoolProvider.createSchool(
      ownerId: ownerId,
      name: name,
      description: description,
      city: city,
      address: address,
      phone: phone,
      email: email,
      info: info.isNotEmpty ? info : null,
    );

    setState(() => _isLoading = false);

    if (!mounted) return;

    if (success) {
  _showMessage('¡Escuela creada exitosamente!');
  Navigator.pushAndRemoveUntil(
    context,
    MaterialPageRoute(builder: (_) => const CoachMainScreen()),
    (route) => false,
  );
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
          'Crear Escuela',
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
                'Datos de la escuela',
                style: TextStyle(
                  fontSize: 16,
                  color: Color(0xFF6B7280),
                ),
              ),
              const SizedBox(height: 24),

              // Nombre
              TextField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Nombre de la escuela *',
                  hintText: 'Ej. Rolla Skating Academy',
                  prefixIcon: Icon(Icons.school_outlined),
                ),
              ),
              const SizedBox(height: 16),

              // Descripción
              TextField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Descripción',
                  hintText: 'Breve descripción de la escuela',
                  prefixIcon: Icon(Icons.description_outlined),
                ),
                maxLines: 2,
              ),
              const SizedBox(height: 16),

              // Ciudad
              TextField(
                controller: _cityController,
                decoration: const InputDecoration(
                  labelText: 'Ciudad *',
                  hintText: 'Ej. Valledupar',
                  prefixIcon: Icon(Icons.location_city_outlined),
                ),
              ),
              const SizedBox(height: 16),

              // Dirección
              TextField(
                controller: _addressController,
                decoration: const InputDecoration(
                  labelText: 'Dirección *',
                  hintText: 'Ej. Calle 10 # 15-20',
                  prefixIcon: Icon(Icons.place_outlined),
                ),
              ),
              const SizedBox(height: 16),

              // Teléfono
              TextField(
                controller: _phoneController,
                decoration: const InputDecoration(
                  labelText: 'Teléfono *',
                  hintText: 'Ej. 300 123 4567',
                  prefixIcon: Icon(Icons.phone_outlined),
                ),
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 16),

              // Correo
              TextField(
                controller: _emailController,
                decoration: const InputDecoration(
                  labelText: 'Correo de contacto',
                  hintText: 'escuela@correo.com',
                  prefixIcon: Icon(Icons.email_outlined),
                ),
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 16),

              // Información adicional
              TextField(
                controller: _infoController,
                decoration: const InputDecoration(
                  labelText: 'Información adicional',
                  hintText: 'Horarios, reglas, etc.',
                  prefixIcon: Icon(Icons.info_outline),
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 32),

              // Botón crear
              ElevatedButton(
                onPressed: _isLoading ? null : _createSchool,
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
                        'Crear Escuela',
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
