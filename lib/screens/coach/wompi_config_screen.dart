import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/school_provider.dart';

class WompiConfigScreen extends StatefulWidget {
  const WompiConfigScreen({super.key});

  @override
  State<WompiConfigScreen> createState() => _WompiConfigScreenState();
}

class _WompiConfigScreenState extends State<WompiConfigScreen> {
  final _publicKeyController = TextEditingController();
  final _privateKeyController = TextEditingController();
  final _integrityController = TextEditingController();
  bool _isLoading = false;
  bool _obscurePrivate = true;
  bool _obscureIntegrity = true;

  @override
  void initState() {
    super.initState();
    final school = context.read<SchoolProvider>().school;
    if (school?.wompiEnabled == true) {
      _publicKeyController.text = school?.wompiPublicKey ?? '';
      _privateKeyController.text = school?.wompiPrivateKey ?? '';
      _integrityController.text = school?.wompiIntegritySecret ?? '';
    }
  }

  @override
  void dispose() {
    _publicKeyController.dispose();
    _privateKeyController.dispose();
    _integrityController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final public = _publicKeyController.text.trim();
    final private = _privateKeyController.text.trim();
    final integrity = _integrityController.text.trim();

    if (public.isEmpty || private.isEmpty || integrity.isEmpty) {
      _showMessage('Completa todos los campos');
      return;
    }

    setState(() => _isLoading = true);

    final success = await context.read<SchoolProvider>().saveWompiConfig(
      publicKey: public,
      privateKey: private,
      integritySecret: integrity,
    );

    setState(() => _isLoading = false);

    if (!mounted) return;

    if (success) {
      _showMessage('Configuración guardada');
      Navigator.pop(context);
    } else {
      _showMessage('Error al guardar');
    }
  }

  void _showMessage(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  @override
  Widget build(BuildContext context) {
    final school = context.watch<SchoolProvider>().school;
    final isConfigured = school?.wompiEnabled == true;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF5F7FA),
        elevation: 0,
        title: const Text(
          'Configurar Wompi',
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
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: isConfigured
                      ? const Color(0xFFDEF7EC)
                      : const Color(0xFFFEF3C7),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isConfigured
                        ? const Color(0xFF31C48D)
                        : const Color(0xFFFCD34D),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      isConfigured ? Icons.check_circle : Icons.info_outline,
                      color: isConfigured
                          ? const Color(0xFF03543F)
                          : const Color(0xFFD97706),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        isConfigured
                            ? 'Wompi configurado. Los pagos irán directo a tu cuenta.'
                            : 'Aún no has configurado Wompi. Los deportistas no podrán pagar inscripciones.',
                        style: TextStyle(
                          color: isConfigured
                              ? const Color(0xFF03543F)
                              : const Color(0xFF92400E),
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              const Text(
                'Llaves de Wompi',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1F2937),
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Ingresa las llaves de tu cuenta Wompi. El dinero de las inscripciones irá directo a ti.',
                style: TextStyle(
                  fontSize: 14,
                  color: Color(0xFF6B7280),
                ),
              ),
              const SizedBox(height: 24),
              _buildField(
                label: 'Llave Pública',
                hint: 'pub_prod_... o pub_test_...',
                controller: _publicKeyController,
                icon: Icons.key_outlined,
                obscure: false,
              ),
              const SizedBox(height: 16),
              _buildField(
                label: 'Llave Privada',
                hint: 'prv_prod_... o prv_test_...',
                controller: _privateKeyController,
                icon: Icons.lock_outline,
                obscure: _obscurePrivate,
                onToggleObscure: () =>
                    setState(() => _obscurePrivate = !_obscurePrivate),
              ),
              const SizedBox(height: 16),
              _buildField(
                label: 'Secret de Integridad',
                hint: 'test_integrity_... o prod_integrity_...',
                controller: _integrityController,
                icon: Icons.verified_outlined,
                obscure: _obscureIntegrity,
                onToggleObscure: () =>
                    setState(() => _obscureIntegrity = !_obscureIntegrity),
              ),
              const SizedBox(height: 40),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _save,
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
                          'Guardar configuración',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildField({
    required String label,
    required String hint,
    required TextEditingController controller,
    required IconData icon,
    required bool obscure,
    VoidCallback? onToggleObscure,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            color: Color(0xFF374151),
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          obscureText: obscure,
          decoration: InputDecoration(
            hintText: hint,
            prefixIcon: Icon(icon, color: const Color(0xFF9CA3AF)),
            suffixIcon: onToggleObscure != null
                ? IconButton(
                    icon: Icon(
                      obscure ? Icons.visibility_off : Icons.visibility,
                      color: const Color(0xFF9CA3AF),
                    ),
                    onPressed: onToggleObscure,
                  )
                : null,
            filled: true,
            fillColor: Colors.white,
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
        ),
      ],
    );
  }
}