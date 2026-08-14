import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// Providers
import '../../providers/athlete_provider.dart';
import '../../providers/notification_provider.dart';
import '../../providers/auth_provider.dart'; // Importante para obtener el user['id']

// Pantallas (Tabs)
import '../notifications_screen.dart';
import 'athlete_home_tab.dart';
import 'athlete_history_tab.dart';
import 'athlete_events_tab.dart';
import 'athlete_trainings_tab.dart';
import 'athlete_profile_tab.dart';

class AthleteMainScreen extends StatefulWidget {
  const AthleteMainScreen({super.key});

  @override
  State<AthleteMainScreen> createState() => _AthleteMainScreenState();
}

class _AthleteMainScreenState extends State<AthleteMainScreen> {
  int _selectedIndex = 0;

  // Lista con 6 pantallas para incluir Entrenos y Notificaciones
  final List<Widget> _screens = [
    const AthleteHomeTab(),
    const AthleteEventsTab(),
    const AthleteTrainingsTab(),
    const AthleteHistoryTab(),
    const NotificationsScreen(),
    const AthleteProfileTab(),
  ];

  @override
  void initState() {
    super.initState();
    // 🔥 ESTA ES LA LÍNEA CLAVE: cargar los datos al entrar
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<AthleteProvider>(context, listen: false).fetchAllData();
      Provider.of<NotificationProvider>(context, listen: false).loadNotifications();
    });
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      body: _screens[_selectedIndex],
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
        child: Consumer<NotificationProvider>(
          builder: (context, notifProvider, child) {
            // Obtenemos el ID del usuario actual de forma segura
            final userId = Provider.of<AuthProvider>(context).user?['id'] ?? '';
            final unreadCount = notifProvider.getUnreadCountForUser(userId);

            return BottomNavigationBar(
              currentIndex: _selectedIndex,
              onTap: _onItemTapped,
              type: BottomNavigationBarType.fixed,
              backgroundColor: Colors.white,
              selectedItemColor: const Color(0xFF2563EB),
              unselectedItemColor: const Color(0xFF9CA3AF),
              selectedFontSize: 12,
              unselectedFontSize: 12,
              elevation: 0,
              items: [
                const BottomNavigationBarItem(
                  icon: Padding(
                    padding: EdgeInsets.only(bottom: 4.0),
                    child: Icon(Icons.home_outlined),
                  ),
                  activeIcon: Padding(
                    padding: EdgeInsets.only(bottom: 4.0),
                    child: Icon(Icons.home),
                  ),
                  label: 'Inicio',
                ),
                const BottomNavigationBarItem(
                  icon: Padding(
                    padding: EdgeInsets.only(bottom: 4.0),
                    child: Icon(Icons.calendar_today_outlined),
                  ),
                  activeIcon: Padding(
                    padding: EdgeInsets.only(bottom: 4.0),
                    child: Icon(Icons.calendar_today),
                  ),
                  label: 'Eventos',
                ),
                const BottomNavigationBarItem(
                  icon: Padding(
                    padding: EdgeInsets.only(bottom: 4.0),
                    child: Icon(Icons.fitness_center_outlined),
                  ),
                  activeIcon: Padding(
                    padding: EdgeInsets.only(bottom: 4.0),
                    child: Icon(Icons.fitness_center),
                  ),
                  label: 'Entrenos',
                ),
                const BottomNavigationBarItem(
                  icon: Padding(
                    padding: EdgeInsets.only(bottom: 4.0),
                    child: Icon(Icons.history_outlined),
                  ),
                  activeIcon: Padding(
                    padding: EdgeInsets.only(bottom: 4.0),
                    child: Icon(Icons.history),
                  ),
                  label: 'Historial',
                ),
                BottomNavigationBarItem(
                  icon: Padding(
                    padding: const EdgeInsets.only(bottom: 4.0),
                    child: Stack(
                      children: [
                        const Icon(Icons.notifications_outlined),
                        if (unreadCount > 0)
                          Positioned(
                            right: 0,
                            top: 0,
                            child: Container(
                              padding: const EdgeInsets.all(2),
                              decoration: const BoxDecoration(
                                color: Color(0xFFEF4444),
                                shape: BoxShape.circle,
                              ),
                              constraints: const BoxConstraints(
                                minWidth: 14,
                                minHeight: 14,
                              ),
                              child: Text(
                                unreadCount > 9 ? '9+' : '$unreadCount',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 8,
                                  fontWeight: FontWeight.bold,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                  activeIcon: Padding(
                    padding: const EdgeInsets.only(bottom: 4.0),
                    child: Stack(
                      children: [
                        const Icon(Icons.notifications),
                        if (unreadCount > 0)
                          Positioned(
                            right: 0,
                            top: 0,
                            child: Container(
                              padding: const EdgeInsets.all(2),
                              decoration: const BoxDecoration(
                                color: Color(0xFFEF4444),
                                shape: BoxShape.circle,
                              ),
                              constraints: const BoxConstraints(
                                minWidth: 14,
                                minHeight: 14,
                              ),
                              child: Text(
                                unreadCount > 9 ? '9+' : '$unreadCount',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 8,
                                  fontWeight: FontWeight.bold,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                  label: 'Notificaciones',
                ),
                const BottomNavigationBarItem(
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
            );
          },
        ),
      ),
    );
  }
}