import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/school_request_provider.dart';

class FindSchoolScreen extends StatefulWidget {
  const FindSchoolScreen({super.key});

  @override
  State<FindSchoolScreen> createState() => _FindSchoolScreenState();
}

class _FindSchoolScreenState extends State<FindSchoolScreen> {
  final _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<SchoolRequestProvider>(context, listen: false).loadRequests();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<Map<String, String>> get _availableSchools => [
        {
          'id': 'sch_demo_001',
          'name': 'Rolla Skating Academy',
          'city': 'Valledupar',
          'address': 'Calle 10 # 15-20',
        },
        {
          'id': 'sch_demo_002',
          'name': 'Valledupar Skate Club',
          'city': 'Valledupar',
          'address': 'Avenida Circunvalar',
        },
        {
          'id': 'sch_demo_003',
          'name': 'Patines del Norte',
          'city': 'Bogotá',
          'address': 'Carrera 7 # 45-30',
        },
        {
          'id': 'sch_demo_004',
          'name': 'Club de Patinaje Costa Caribe',
          'city': 'Santa Marta',
          'address': 'Calle 22 # 8-15',
        },
      ];

  List<Map<String, String>> get _filteredSchools {
    if (_searchQuery.isEmpty) return _availableSchools;
    return _availableSchools.where((s) {
      final query = _searchQuery.toLowerCase();
      return s['name']!.toLowerCase().contains(query) ||
          s['city']!.toLowerCase().contains(query);
    }).toList();
  }

  Future<void> _requestJoin(Map<String, String> school) async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final requestProvider =
        Provider.of<SchoolRequestProvider>(context, listen: false);

    final athleteId = authProvider.user?['id'] ?? '';
    final athleteName = authProvider.user?['fullName'] ?? 'Deportista';
    final athleteEmail = authProvider.user?['email'] ?? '';

    if (athleteId.isEmpty || athleteEmail.isEmpty) {
      _showMessage('Error: no se pudo identificar al deportista');
      return;
    }

    final success = await requestProvider.sendRequest(
      athleteId: athleteId,
      athleteName: athleteName,
      athleteEmail: athleteEmail, // NUEVO
      schoolId: school['id']!,
      schoolName: school['name']!,
    );

    if (!mounted) return;

    if (success) {
      _showMessage('Solicitud enviada a ${school['name']}');
    } else {
      _showMessage('Ya tienes una solicitud pendiente para esta escuela');
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final requestProvider = Provider.of<SchoolRequestProvider>(context);
    final authProvider = Provider.of<AuthProvider>(context);
    final athleteId = authProvider.user?['id'] ?? '';

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF5F7FA),
        elevation: 0,
        title: const Text(
          'Buscar Escuela',
          style: TextStyle(
            color: Color(0xFF1F2937),
            fontWeight: FontWeight.bold,
          ),
        ),
        iconTheme: const IconThemeData(color: Color(0xFF1F2937)),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: TextField(
                controller: _searchController,
                onChanged: (value) => setState(() => _searchQuery = value),
                decoration: InputDecoration(
                  hintText: 'Buscar por nombre o ciudad...',
                  prefixIcon: const Icon(Icons.search),
                  suffixIcon: _searchController.text.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: () {
                            _searchController.clear();
                            setState(() => _searchQuery = '');
                          },
                        )
                      : null,
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),
            Expanded(
              child: _filteredSchools.isEmpty
                  ? const Center(
                      child: Text(
                        'No se encontraron escuelas',
                        style: TextStyle(color: Color(0xFF6B7280)),
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: _filteredSchools.length,
                      itemBuilder: (context, index) {
                        final school = _filteredSchools[index];
                        final hasPending = requestProvider.hasPendingRequest(
                          athleteId,
                          school['id']!,
                        );

                        return Card(
                          margin: const EdgeInsets.only(bottom: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(10),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFEFF6FF),
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      child: const Icon(
                                        Icons.school,
                                        color: Color(0xFF2563EB),
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            school['name']!,
                                            style: const TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          const SizedBox(height: 2),
                                          Text(
                                            '📍 ${school['city']} • ${school['address']}',
                                            style: const TextStyle(
                                              fontSize: 13,
                                              color: Color(0xFF6B7280),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                SizedBox(
                                  width: double.infinity,
                                  child: ElevatedButton.icon(
                                    onPressed: hasPending
                                        ? null
                                        : () => _requestJoin(school),
                                    icon: Icon(
                                      hasPending
                                          ? Icons.hourglass_top
                                          : Icons.send,
                                      size: 18,
                                    ),
                                    label: Text(
                                      hasPending
                                          ? 'Solicitud enviada'
                                          : 'Solicitar ingreso',
                                    ),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: hasPending
                                          ? const Color(0xFF9CA3AF)
                                          : const Color(0xFF2563EB),
                                      foregroundColor: Colors.white,
                                      disabledBackgroundColor:
                                          const Color(0xFFD1D5DB),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}