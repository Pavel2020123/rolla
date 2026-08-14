import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../../providers/athlete_provider.dart';
import '../../providers/auth_provider.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _picker = ImagePicker();

  late TextEditingController _firstNameController;
  late TextEditingController _lastNameController;

  String? _selectedCategory;
  String? _selectedLevel;
  String? _selectedModality;
  DateTime? _birthDate;
  File? _selectedImage;
  String? _existingPhotoUrl;

  final List<String> _categories = [
    'Iniciación',
    'Párvulos',
    'Infantil',
    'Transición',
    'Prejuvenil',
    'Juvenil',
    'Mayores'
  ];

  final List<String> _levels = [
    'Principiante',
    'Intermedio',
    'Avanzado',
    'Semiprofesional',
    'Profesional'
  ];

  final List<String> _modalities = [
    'Velocidad',
    'Figuras',
    'Libre',
    'Salto',
    'Patinaje Artístico',
    'Hockey',
    'Otra'
  ];

  @override
  void initState() {
    super.initState();
    final athlete = context.read<AthleteProvider>().athlete;

    _firstNameController = TextEditingController(text: athlete?.firstName ?? '');
    _lastNameController = TextEditingController(text: athlete?.lastName ?? '');
    _selectedCategory = athlete?.category;
    _selectedLevel = athlete?.level;
    _selectedModality = athlete?.modality ?? 'Velocidad';
    _birthDate = athlete?.birthDate;
    _existingPhotoUrl = athlete?.photoUrl;
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 800,
      maxHeight: 800,
      imageQuality: 85,
    );
    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path);
      });
    }
  }

  Future<void> _pickBirthDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _birthDate ?? DateTime(2010, 1, 1),
      firstDate: DateTime(1950),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF2563EB),
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() => _birthDate = picked);
    }
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    final firstName = _firstNameController.text.trim();
    final lastName = _lastNameController.text.trim();

    // Guardar en AthleteProvider
    context.read<AthleteProvider>().updateAthleteProfile(
      firstName: firstName,
      lastName: lastName,
      schoolName: context.read<AthleteProvider>().athlete?.schoolName ?? 'Sin escuela',
      category: _selectedCategory ?? 'Prejuvenil',
      level: _selectedLevel ?? 'Principiante',
      modality: _selectedModality,
      photoUrl: _selectedImage?.path ?? _existingPhotoUrl,
      birthDate: _birthDate,
    );

    // También guardar en AuthProvider para sincronizar
    await context.read<AuthProvider>().updateAthleteProfile(
      firstName: firstName,
      lastName: lastName,
      category: _selectedCategory,
      level: _selectedLevel,
      modality: _selectedModality,
      photoUrl: _selectedImage?.path ?? _existingPhotoUrl,
      birthDate: _birthDate,
    );

    if (mounted) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Perfil actualizado correctamente'),
          backgroundColor: Color(0xFF31C48D),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0, left: 4.0),
      child: Text(
        text,
        style: const TextStyle(
          fontWeight: FontWeight.w600,
          color: Color(0xFF374151),
          fontSize: 14,
        ),
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

  Widget _buildDropdown({
    required String? value,
    required List<String> items,
    required String hint,
    required IconData icon,
    required void Function(String?) onChanged,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFD1D5DB)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: DropdownButtonHideUnderline(
        child: DropdownButtonFormField<String>(
          value: value,
          decoration: const InputDecoration(border: InputBorder.none),
          icon: const Icon(Icons.keyboard_arrow_down, color: Color(0xFF6B7280)),
          hint: Text(hint, style: const TextStyle(color: Color(0xFF9CA3AF))),
          items: items.map((String item) {
            return DropdownMenuItem<String>(
              value: item,
              child: Text(item),
            );
          }).toList(),
          onChanged: onChanged,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Selecciona una opción';
            }
            return null;
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final athlete = context.watch<AthleteProvider>().athlete;

    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: const Text(
          'Editar Perfil',
          style: TextStyle(
            color: Color(0xFF1F2937),
            fontWeight: FontWeight.bold,
          ),
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
              // FOTO DE PERFIL
              Center(
                child: Stack(
                  children: [
                    Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        color: const Color(0xFFEFF6FF),
                        borderRadius: BorderRadius.circular(50),
                        border: Border.all(color: const Color(0xFF2563EB), width: 2),
                        image: _selectedImage != null
                            ? DecorationImage(
                                image: FileImage(_selectedImage!),
                                fit: BoxFit.cover,
                              )
                            : _existingPhotoUrl != null
                                ? DecorationImage(
                                    image: FileImage(File(_existingPhotoUrl!)),
                                    fit: BoxFit.cover,
                                  )
                                : null,
                      ),
                      child: (_selectedImage == null && _existingPhotoUrl == null)
                          ? Center(
                              child: Text(
                                athlete?.initials ?? '??',
                                style: const TextStyle(
                                  fontSize: 32,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF2563EB),
                                ),
                              ),
                            )
                          : null,
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: GestureDetector(
                        onTap: _pickImage,
                        child: Container(
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            color: const Color(0xFF2563EB),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: Colors.white, width: 2),
                          ),
                          child: const Icon(
                            Icons.camera_alt,
                            color: Colors.white,
                            size: 16,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              // NOMBRES
              _buildLabel('Nombres'),
              _buildTextField(
                controller: _firstNameController,
                hintText: 'Ej. Juan',
                icon: Icons.person_outline,
              ),
              const SizedBox(height: 20),

              // APELLIDOS
              _buildLabel('Apellidos'),
              _buildTextField(
                controller: _lastNameController,
                hintText: 'Ej. Pérez',
                icon: Icons.person_outline,
              ),
              const SizedBox(height: 20),

              // FECHA DE NACIMIENTO
              _buildLabel('Fecha de nacimiento'),
              InkWell(
                onTap: _pickBirthDate,
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFFD1D5DB)),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                  child: Row(
                    children: [
                      const Icon(Icons.cake_outlined, color: Color(0xFF9CA3AF)),
                      const SizedBox(width: 12),
                      Text(
                        _birthDate != null
                            ? '${_birthDate!.day}/${_birthDate!.month}/${_birthDate!.year}'
                            : 'Selecciona tu fecha de nacimiento',
                        style: TextStyle(
                          color: _birthDate != null
                              ? const Color(0xFF1F2937)
                              : const Color(0xFF9CA3AF),
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // CATEGORÍA
              _buildLabel('Categoría'),
              _buildDropdown(
                value: _selectedCategory,
                items: _categories,
                hint: 'Selecciona categoría',
                icon: Icons.category_outlined,
                onChanged: (val) => setState(() => _selectedCategory = val),
              ),
              const SizedBox(height: 20),

              // NIVEL
              _buildLabel('Nivel'),
              _buildDropdown(
                value: _selectedLevel,
                items: _levels,
                hint: 'Selecciona nivel',
                icon: Icons.trending_up_outlined,
                onChanged: (val) => setState(() => _selectedLevel = val),
              ),
              const SizedBox(height: 20),

              // MODALIDAD
              _buildLabel('Modalidad'),
              _buildDropdown(
                value: _selectedModality,
                items: _modalities,
                hint: 'Selecciona modalidad',
                icon: Icons.sports_outlined,
                onChanged: (val) => setState(() => _selectedModality = val),
              ),
              const SizedBox(height: 40),

              // BOTÓN GUARDAR
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
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
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