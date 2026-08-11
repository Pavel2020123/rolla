import 'package:flutter/material.dart';
import 'coach_main_screen.dart';

class JoinSchoolScreen extends StatefulWidget {
  const JoinSchoolScreen({super.key});

  @override
  State<JoinSchoolScreen> createState() => _JoinSchoolScreenState();
}

class _JoinSchoolScreenState extends State<JoinSchoolScreen> {
  final _searchController = TextEditingController();
  bool _isSearching = false;

  // Lista mock de escuelas disponibles (después vendrá del backend)
  final List<Map<String, String>> _mockSchools = [
    {
      'id': 'sch_001',
      'name': 'Rolla Skating Academy',
      'city': 'Valledupar',
    },
    {
      'id': 'sch_002',
      'name': 'Valledupar Skate Club',
      'city': 'Valledupar',
    },
    {
      'id': 'sch_003',
      'name': 'Patines del Norte',
      'city': 'Bogotá',
    },
  ];

  List<Map<String, String>> _filteredSchools = [];

  @override
  void initState() {
    super.initState();
    _filteredSchools = List.from(_mockSchools);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _search(String query) {
    setState(() {
      if (query.isEmpty) {
        _filteredSchools = List.from(_mockSchools);
      } else {
        _filteredSchools = _mockSchools
            .where((s) =>
                s['name']!.toLowerCase().contains(query.toLowerCase()) ||
                s['city']!.toLowerCase().contains(query.toLowerCase()))
            .toList();
      }
    });
  }

  Future<void> _requestJoin(String schoolId, String schoolName) async {
    setState(() => _isSearching = true);

    // Simular petición al backend
    await Future.delayed(const Duration(seconds: 1));

    setState(() => _isSearching = false);

    if (!mounted) return;

    // Mostrar confirmación
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Solicitud enviada'),
        content: Text(
            'Tu solicitud para unirte a "$schoolName" ha sido enviada. El entrenador principal debe aprobarla.'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (_) => const CoachMainScreen()),
                (route) => false,
              );
            },
            child: const Text('Entendido'),
          ),
        ],
      ),
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
            // Barra de búsqueda
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: TextField(
                controller: _searchController,
                onChanged: _search,
                decoration: InputDecoration(
                  hintText: 'Buscar por nombre o ciudad...',
                  prefixIcon: const Icon(Icons.search),
                  suffixIcon: _searchController.text.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: () {
                            _searchController.clear();
                            _search('');
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

            // Lista de escuelas
            Expanded(
              child: _isSearching
                  ? const Center(child: CircularProgressIndicator())
                  : _filteredSchools.isEmpty
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
                            return Card(
                              margin: const EdgeInsets.only(bottom: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: ListTile(
                                leading: Container(
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
                                title: Text(
                                  school['name']!,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                subtitle: Text(
                                  '📍 ${school['city']}',
                                  style: const TextStyle(
                                    color: Color(0xFF6B7280),
                                  ),
                                ),
                                trailing: ElevatedButton(
                                  onPressed: () => _requestJoin(
                                    school['id']!,
                                    school['name']!,
                                  ),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFF2563EB),
                                    foregroundColor: Colors.white,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                  ),
                                  child: const Text('Solicitar'),
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