import 'package:flutter/material.dart';
import '../../models/school_request_model.dart';
import 'package:provider/provider.dart';
import 'package:rolla/providers/school_request_provider.dart';
import '../../providers/auth_provider.dart';
import 'coach_events_screen.dart';
import '../../providers/school_provider.dart';
import '../auth/splash_screen.dart';
import 'create_event_screen.dart';
import 'create_school_screen.dart';
import 'school_requests_screen.dart';
import 'join_school_screen.dart';
import '../../providers/event_provider.dart';

class CoachMainScreen extends StatefulWidget {
  const CoachMainScreen({super.key});

  @override
  State<CoachMainScreen> createState() => _CoachMainScreenState();
}

class _CoachMainScreenState extends State<CoachMainScreen> {
  int _selectedIndex = 0;

  @override
void initState() {
  super.initState();
  WidgetsBinding.instance.addPostFrameCallback((_) {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final ownerId = authProvider.user?['id'] ?? '';

    if (ownerId.isNotEmpty) {
      Provider.of<SchoolProvider>(context, listen: false)
          .loadSchool(ownerId);
    }

    Provider.of<EventProvider>(context, listen: false).loadEvents();
    Provider.of<SchoolRequestProvider>(context, listen: false).loadRequests();
  });
}

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<SchoolProvider>(
      builder: (context, schoolProvider, child) {
        if (schoolProvider.isLoading) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final hasSchool = schoolProvider.hasSchool;

        final screens = [
          _CoachHomeTab(hasSchool: hasSchool),
          _CoachSchoolTab(hasSchool: hasSchool),
          const _CoachAthletesTab(),
          const _CoachProfileTab(),
        ];

        return Scaffold(
          backgroundColor: const Color(0xFFF5F7FA),
          body: screens[_selectedIndex],
          bottomNavigationBar: Container(
            decoration: BoxDecoration(
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 10,
                  offset: const Offset(0, -5),
                ),
              ],
            ),
            child: BottomNavigationBar(
              currentIndex: _selectedIndex,
              onTap: _onItemTapped,
              type: BottomNavigationBarType.fixed,
              backgroundColor: Colors.white,
              selectedItemColor: const Color(0xFF2563EB),
              unselectedItemColor: const Color(0xFF9CA3AF),
              selectedFontSize: 12,
              unselectedFontSize: 12,
              elevation: 0,
              items: const [
                BottomNavigationBarItem(
                  icon: Padding(
                    padding: EdgeInsets.only(bottom: 4.0),
                    child: Icon(Icons.dashboard_outlined),
                  ),
                  activeIcon: Padding(
                    padding: EdgeInsets.only(bottom: 4.0),
                    child: Icon(Icons.dashboard),
                  ),
                  label: 'Panel',
                ),
                BottomNavigationBarItem(
                  icon: Padding(
                    padding: EdgeInsets.only(bottom: 4.0),
                    child: Icon(Icons.school_outlined),
                  ),
                  activeIcon: Padding(
                    padding: EdgeInsets.only(bottom: 4.0),
                    child: Icon(Icons.school),
                  ),
                  label: 'Escuela',
                ),
                BottomNavigationBarItem(
                  icon: Padding(
                    padding: EdgeInsets.only(bottom: 4.0),
                    child: Icon(Icons.people_outlined),
                  ),
                  activeIcon: Padding(
                    padding: EdgeInsets.only(bottom: 4.0),
                    child: Icon(Icons.people),
                  ),
                  label: 'Deportistas',
                ),
                BottomNavigationBarItem(
                  icon: Padding(
                    padding: EdgeInsets.only(bottom: 4.0),
                    child: Icon(Icons.person_outline),
                  ),
                  activeIcon: Padding(
                    padding: EdgeInsets.only(bottom: 4.0),
                    child: Icon(Icons.person),
                  ),
                  label: 'Perfil',
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

// ============================================================
// PESTAÑA: PANEL (HOME)
// ============================================================
class _CoachHomeTab extends StatelessWidget {
  final bool hasSchool;

  const _CoachHomeTab({required this.hasSchool});

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final schoolProvider = Provider.of<SchoolProvider>(context);
    final userName = authProvider.user?['fullName'] ?? 'Entrenador';
    final school = schoolProvider.school;

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Hola, $userName 👋',
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1F2937),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              hasSchool
                  ? (school?.name ?? 'Panel de entrenador')
                  : 'Aún no tienes escuela asignada',
              style: const TextStyle(
                fontSize: 16,
                color: Color(0xFF6B7280),
              ),
            ),
            const SizedBox(height: 32),

            if (!hasSchool) ...[
              // Estado: SIN ESCUELA
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: const Color(0xFFFEF3C7),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFFCD34D)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.info_outline, color: Color(0xFFD97706)),
                        SizedBox(width: 8),
                        Text(
                          'Sin escuela',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF92400E),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Para acceder a todas las funciones necesitas estar vinculado a una escuela.',
                      style: TextStyle(
                        color: Color(0xFFA16207),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const CreateSchoolScreen(),
                                ),
                              );
                            },
                            icon: const Icon(Icons.add_business, size: 18),
                            label: const Text('Crear'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF2563EB),
                              foregroundColor: Colors.white,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const JoinSchoolScreen(),
                                ),
                              );
                            },
                            icon: const Icon(Icons.group_add, size: 18),
                            label: const Text('Vincularme'),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: const Color(0xFF2563EB),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
            ] else ...[
              // Estado: CON ESCUELA → Tarjetas de resumen
                            Row(
                children: [
                  Expanded(
                    child: Consumer<SchoolRequestProvider>(
                      builder: (context, reqProvider, child) {
                        final schoolId = schoolProvider.school?.id ?? '';
                        final count = schoolId.isNotEmpty
                            ? reqProvider.getAcceptedAthletesForSchool(schoolId).length
                            : 0;
                        return _buildStatCard(
                          title: 'Deportistas',
                          value: count.toString(),
                          icon: Icons.people,
                          color: const Color(0xFF2563EB),
                        );
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                                    Expanded(
                    child: Consumer<EventProvider>(
                      builder: (context, eventProvider, child) {
                        final schoolId = schoolProvider.school?.id ?? '';
                        final count = schoolId.isNotEmpty
                            ? eventProvider.getEventsBySchool(schoolId).length
                            : 0;
                        return _buildStatCard(
                          title: 'Eventos',
                          value: count.toString(),
                          icon: Icons.event,
                          color: const Color(0xFF10B981),
                        );
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _buildStatCard(
                      title: 'Inscripciones',
                      value: '0',
                      icon: Icons.how_to_reg,
                      color: const Color(0xFFF59E0B),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildStatCard(
                      title: 'Solicitudes',
                      value: '0',
                      icon: Icons.swap_horiz,
                      color: const Color(0xFFEF4444),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),
            ],

                        const Text(
              'Accesos rápidos',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1F2937),
              ),
            ),
            const SizedBox(height: 16),

            if (hasSchool) ...[
              _buildQuickActionCard(
                title: 'Crear Evento',
                subtitle: 'Organiza un nuevo evento deportivo',
                icon: Icons.add_circle_outline,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const CreateEventScreen(),
                    ),
                  );
                },
              ),
              const SizedBox(height: 12),
              _buildQuickActionCard(
                title: 'Ver Deportistas',
                subtitle: 'Gestiona tus deportistas',
                icon: Icons.people_outline,
                onTap: () {},
              ),
              const SizedBox(height: 12),
              // NUEVO: Acceso a solicitudes con badge
              Consumer<SchoolRequestProvider>(
                builder: (context, reqProvider, child) {
                  final pendingCount = reqProvider.pendingCount;
                  return _buildQuickActionCard(
                    title: 'Solicitudes de Ingreso',
                    subtitle: pendingCount > 0
                        ? '$pendingCount solicitud${pendingCount == 1 ? '' : 'es'} pendiente${pendingCount == 1 ? '' : 's'}'
                        : 'Ver solicitudes de deportistas',
                    icon: Icons.swap_horiz,
                    badge: pendingCount > 0 ? pendingCount.toString() : null,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const SchoolRequestsScreen(),
                        ),
                      );
                    },
                  );
                },
              ),
                            const SizedBox(height: 12),
                            Consumer<EventProvider>(
                builder: (context, eventProvider, child) {
                  final schoolId = schoolProvider.school?.id ?? '';
                  final eventCount = schoolId.isNotEmpty
                      ? eventProvider.getEventsBySchool(schoolId).length
                      : 0;

                  return _buildQuickActionCard(
                    title: 'Mis Eventos',
                    subtitle: eventCount > 0
                        ? '$eventCount evento${eventCount == 1 ? '' : 's'} publicado${eventCount == 1 ? '' : 's'}'
                        : 'Ver y gestionar eventos de tu escuela',
                    icon: Icons.event_note_outlined,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const CoachEventsScreen(),
                        ),
                      );
                    },
                  );
                },
              ),
            ] else ...[
              _buildQuickActionCard(
                title: 'Crear Escuela',
                subtitle: 'Registra una nueva escuela en Rolla',
                icon: Icons.add_business_outlined,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const CreateSchoolScreen(),
                    ),
                  );
                },
              ),
              const SizedBox(height: 12),
              _buildQuickActionCard(
                title: 'Buscar Escuela',
                subtitle: 'Encuentra tu escuela y solicita unirte',
                icon: Icons.search,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const JoinSchoolScreen(),
                    ),
                  );
                },
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1F2937),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: const TextStyle(
              fontSize: 12,
              color: Color(0xFF6B7280),
            ),
          ),
        ],
      ),
    );
  }

    Widget _buildQuickActionCard({
    required String title,
    required String subtitle,
    required IconData icon,
    String? badge,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFE5E7EB)),
        ),
        child: Row(
          children: [
            Stack(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEFF6FF),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, color: const Color(0xFF2563EB)),
                ),
                if (badge != null)
                  Positioned(
                    right: 0,
                    top: 0,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(
                        color: Color(0xFFEF4444),
                        shape: BoxShape.circle,
                      ),
                      constraints: const BoxConstraints(
                        minWidth: 18,
                        minHeight: 18,
                      ),
                      child: Text(
                        badge,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1F2937),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Color(0xFF6B7280),
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios,
                color: Color(0xFF9CA3AF), size: 16),
          ],
        ),
      ),
    );
  }
}

// ============================================================
// PESTAÑA: MI ESCUELA
// ============================================================
class _CoachSchoolTab extends StatelessWidget {
  final bool hasSchool;

  const _CoachSchoolTab({required this.hasSchool});

  @override
  Widget build(BuildContext context) {
    final schoolProvider = Provider.of<SchoolProvider>(context);
    final school = schoolProvider.school;

    if (!hasSchool || school == null) {
      return SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 40),
              Icon(
                Icons.school_outlined,
                size: 80,
                color: const Color(0xFFD1D5DB),
              ),
              const SizedBox(height: 24),
              const Text(
                'No tienes una escuela',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1F2937),
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Crea una nueva escuela o solicita unirte a una existente.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  color: Color(0xFF6B7280),
                ),
              ),
              const SizedBox(height: 32),
              ElevatedButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const CreateSchoolScreen(),
                    ),
                  );
                },
                icon: const Icon(Icons.add_business),
                label: const Text('Crear Escuela'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2563EB),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 16,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              OutlinedButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const JoinSchoolScreen(),
                    ),
                  );
                },
                icon: const Icon(Icons.group_add),
                label: const Text('Vincularme a una escuela'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: const Color(0xFF2563EB),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 16,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    // Tiene escuela → mostrar datos
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Mi Escuela',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1F2937),
              ),
            ),
            const SizedBox(height: 24),
            Center(
              child: Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  color: const Color(0xFFEFF6FF),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: const Icon(
                  Icons.school,
                  size: 50,
                  color: Color(0xFF2563EB),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Center(
              child: Text(
                school.name,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1F2937),
                ),
              ),
            ),
            const SizedBox(height: 24),
            _buildInfoRow(Icons.location_city, 'Ciudad', school.city),
            _buildInfoRow(Icons.place, 'Dirección', school.address),
            _buildInfoRow(Icons.phone, 'Teléfono', school.phone),
            if (school.email.isNotEmpty)
              _buildInfoRow(Icons.email, 'Correo', school.email),
            if (school.description.isNotEmpty)
              _buildInfoRow(
                  Icons.description, 'Descripción', school.description),
            if (school.info != null && school.info!.isNotEmpty)
              _buildInfoRow(Icons.info, 'Información', school.info!),
            const SizedBox(height: 24),
            Center(
              child: Text(
                'Creada el ${_formatDate(school.createdAt)}',
                style: const TextStyle(
                  fontSize: 12,
                  color: Color(0xFF9CA3AF),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: const Color(0xFF2563EB)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF9CA3AF),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 15,
                    color: Color(0xFF1F2937),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}

// ============================================================
// PESTAÑA: DEPORTISTAS
// ============================================================
class _CoachAthletesTab extends StatefulWidget {
  const _CoachAthletesTab();

  @override
  State<_CoachAthletesTab> createState() => _CoachAthletesTabState();
}

class _CoachAthletesTabState extends State<_CoachAthletesTab> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<SchoolRequestProvider>(context, listen: false).loadRequests();
    });
  }

  @override
  Widget build(BuildContext context) {
    final schoolProvider = Provider.of<SchoolProvider>(context);
    final requestProvider = Provider.of<SchoolRequestProvider>(context);
    final authProvider = Provider.of<AuthProvider>(context);

    final hasSchool = schoolProvider.hasSchool;
    final schoolId = schoolProvider.school?.id ?? authProvider.schoolId ?? '';
    final acceptedAthletes = schoolId.isNotEmpty
        ? requestProvider.getAcceptedAthletesForSchool(schoolId)
        : <SchoolRequestModel>[];

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Deportistas',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1F2937),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              hasSchool
                  ? '${acceptedAthletes.length} deportista${acceptedAthletes.length == 1 ? '' : 's'} en tu escuela'
                  : 'Primero necesitas tener una escuela',
              style: const TextStyle(
                fontSize: 16,
                color: Color(0xFF6B7280),
              ),
            ),
            const SizedBox(height: 24),
            if (!hasSchool)
              Center(
                child: Column(
                  children: [
                    const Icon(
                      Icons.lock_outline,
                      size: 48,
                      color: Color(0xFFD1D5DB),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Función no disponible',
                      style: TextStyle(
                        color: Color(0xFF9CA3AF),
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const CreateSchoolScreen(),
                          ),
                        );
                      },
                      child: const Text('Crear escuela'),
                    ),
                  ],
                ),
              )
            else if (acceptedAthletes.isEmpty)
              Center(
                child: Column(
                  children: [
                    Icon(
                      Icons.people_outline,
                      size: 64,
                      color: const Color(0xFFD1D5DB),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'No hay deportistas en tu escuela',
                      style: TextStyle(
                        color: Color(0xFF9CA3AF),
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Los deportistas aparecerán aquí cuando aceptes sus solicitudes de ingreso.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Color(0xFF9CA3AF),
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              )
            else
              Expanded(
                child: ListView.builder(
                  itemCount: acceptedAthletes.length,
                  itemBuilder: (context, index) {
                    final athlete = acceptedAthletes[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: ListTile(
                        leading: Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            color: const Color(0xFFEFF6FF),
                            borderRadius: BorderRadius.circular(24),
                          ),
                          child: const Icon(
                            Icons.person,
                            color: Color(0xFF2563EB),
                          ),
                        ),
                        title: Text(
                          athlete.athleteName,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1F2937),
                          ),
                        ),
                        subtitle: const Text(
                          'Deportista activo',
                          style: TextStyle(
                            color: Color(0xFF10B981),
                            fontSize: 13,
                          ),
                        ),
                        trailing: const Icon(
                          Icons.arrow_forward_ios,
                          size: 16,
                          color: Color(0xFF9CA3AF),
                        ),
                        onTap: () {
                          // Aquí podremos ver el perfil del deportista luego
                        },
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

// ============================================================
// PESTAÑA: PERFIL
// ============================================================
class _CoachProfileTab extends StatelessWidget {
  const _CoachProfileTab();

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final schoolProvider = Provider.of<SchoolProvider>(context);
    final userName = authProvider.user?['fullName'] ?? 'Entrenador';
    final userEmail = authProvider.user?['email'] ?? '';

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Perfil',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1F2937),
              ),
            ),
            const SizedBox(height: 24),
            Center(
              child: Column(
                children: [
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: const Color(0xFFEFF6FF),
                      borderRadius: BorderRadius.circular(40),
                    ),
                    child: const Icon(
                      Icons.sports_outlined,
                      size: 40,
                      color: Color(0xFF2563EB),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    userName,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1F2937),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    userEmail,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Color(0xFF6B7280),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFEFF6FF),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Text(
                      'Entrenador',
                      style: TextStyle(
                        color: Color(0xFF2563EB),
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            _buildProfileOption(
              icon: Icons.school_outlined,
              title: 'Mi Escuela',
              subtitle: schoolProvider.school?.name ?? 'Sin escuela',
              onTap: () {},
            ),
            if (!schoolProvider.hasSchool) ...[
              _buildProfileOption(
                icon: Icons.add_business_outlined,
                title: 'Crear escuela',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const CreateSchoolScreen(),
                    ),
                  );
                },
              ),
              _buildProfileOption(
                icon: Icons.group_add_outlined,
                title: 'Vincularme a escuela',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const JoinSchoolScreen(),
                    ),
                  );
                },
              ),
            ],
            _buildProfileOption(
              icon: Icons.settings_outlined,
              title: 'Configuración',
              onTap: () {},
            ),
            _buildProfileOption(
              icon: Icons.help_outline,
              title: 'Ayuda y soporte',
              onTap: () {},
            ),
            _buildProfileOption(
              icon: Icons.logout,
              title: 'Cerrar sesión',
              textColor: Colors.red,
              iconColor: Colors.red,
              onTap: () => _showLogoutDialog(context),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileOption({
    required IconData icon,
    required String title,
    String? subtitle,
    required VoidCallback onTap,
    Color? textColor,
    Color? iconColor,
  }) {
    return ListTile(
      leading: Icon(icon, color: iconColor ?? const Color(0xFF6B7280)),
      title: Text(
        title,
        style: TextStyle(
          color: textColor ?? const Color(0xFF1F2937),
          fontWeight: FontWeight.w500,
        ),
      ),
      subtitle: subtitle != null
          ? Text(
              subtitle,
              style: const TextStyle(
                fontSize: 12,
                color: Color(0xFF9CA3AF),
              ),
            )
          : null,
      trailing: const Icon(Icons.arrow_forward_ios,
          size: 16, color: Color(0xFF9CA3AF)),
      onTap: onTap,
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cerrar sesión'),
        content: const Text('¿Estás seguro de que deseas cerrar sesión?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () async {
              final authProvider =
                  Provider.of<AuthProvider>(context, listen: false);
              final schoolProvider =
                  Provider.of<SchoolProvider>(context, listen: false);

              await authProvider.logout();
              schoolProvider.clear();

              if (context.mounted) {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (_) => const SplashScreen()),
                  (route) => false,
                );
              }
            },
            child: const Text(
              'Cerrar sesión',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }
}