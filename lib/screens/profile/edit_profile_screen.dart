import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/athlete_provider.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  
  // Controladores para los campos de texto
  late TextEditingController _firstNameController;
  late TextEditingController _lastNameController;
  late TextEditingController _schoolController;
  
  // Variable para el dropdown (menú desplegable)
  String? _selectedCategory;

  final List<String> _categories = [
    'Iniciación',
    'Párvulos',
    'Infantil',
    'Transición',
    'Prejuvenil',
    'Juvenil',
    'Mayores'
  ];

  @override
  void initState() {
    super.initState();
    // Cargamos los datos actuales del Provider al abrir la pantalla
    final athlete = context.read<AthleteProvider>().athlete;
    
    _firstNameController = TextEditingController(text: athlete?.firstName ?? '');
    _lastNameController = TextEditingController(text: athlete?.lastName ?? '');
    _schoolController = TextEditingController(text: athlete?.schoolName ?? '');
    _selectedCategory = athlete?.category;
    
    // Si la categoría actual no está en la lista (por si acaso), agregamos la primera
    if (_selectedCategory != null && !_categories.contains(_selectedCategory)) {
      _categories.add(_selectedCategory!);
    }
  }

  @override
  void dispose() {
    // Es buena práctica limpiar los controladores al cerrar la pantalla
    _firstNameController.dispose();
    _lastNameController.dispose();
    _schoolController.dispose();
    super.dispose();
  }

  void _saveProfile() {
    if (_formKey.currentState!.validate()) {
      // Guardamos en el Provider
      context.read<AthleteProvider>().updateAthleteProfile(
        firstName: _firstNameController.text.trim(),
        lastName: _lastNameController.text.trim(),
        schoolName: _schoolController.text.trim(),
        category: _selectedCategory ?? 'Prejuvenil',
      );

      // Regresamos a la pantalla anterior
      Navigator.pop(context);
      
      // Mostramos un mensaje de éxito
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Perfil actualizado correctamente'),
          backgroundColor: Color(0xFF31C48D),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: const Text(
          'Editar Perfil',
          style: TextStyle(color: Color(0xFF1F2937), fontWeight: FontWeight.bold),
        ),
        iconTheme: const IconThemeData(color: Color(0xFF1F2937)),
        elevation: 0,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildLabel('Nombres'),
              _buildTextField(
                controller: _firstNameController,
                hintText: 'Ej. Juan',
                icon: Icons.person_outline,
              ),
              const SizedBox(height: 20),
              
              _buildLabel('Apellidos'),
              _buildTextField(
                controller: _lastNameController,
                hintText: 'Ej. Pérez',
                icon: Icons.person_outline,
              ),
              const SizedBox(height: 20),

              _buildLabel('Club / Escuela'),
              _buildTextField(
                controller: _schoolController,
                hintText: 'Nombre de tu escuela de patinaje',
                icon: Icons.school_outlined,
              ),
              const SizedBox(height: 20),

              _buildLabel('Categoría Actual'),
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFD1D5DB)),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                child: DropdownButtonHideUnderline(
                  child: DropdownButtonFormField<String>(
                    initialValue: _selectedCategory,
                    decoration: const InputDecoration(border: InputBorder.none),
                    icon: const Icon(Icons.keyboard_arrow_down, color: Color(0xFF6B7280)),
                    items: _categories.map((String category) {
                      return DropdownMenuItem(
                        value: category,
                        child: Text(category),
                      );
                    }).toList(),
                    onChanged: (String? newValue) {
                      setState(() {
                        _selectedCategory = newValue;
                      });
                    },
                  ),
                ),
              ),
              const SizedBox(height: 40),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _saveProfile,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2563EB),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Guardar Cambios',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0, left: 4.0),
      child: Text(
        text,
        style: const TextStyle(fontWeight: FontWeight.w600, color: Color(0xFF374151)),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hintText,
    required IconData icon,
  }) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        hintText: hintText,
        prefixIcon: Icon(icon, color: const Color(0xFF9CA3AF)),
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFD1D5DB)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFD1D5DB)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF2563EB), width: 2),
        ),
      ),
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return 'Este campo es obligatorio';
        }
        return null;
      },
    );
  }
}