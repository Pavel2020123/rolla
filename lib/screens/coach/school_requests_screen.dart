import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/school_provider.dart';
import '../../providers/school_request_provider.dart';
import '../../providers/notification_provider.dart'; // 🔥 Import agregado
import '../../models/school_request_model.dart';

class SchoolRequestsScreen extends StatefulWidget {
  const SchoolRequestsScreen({super.key});

  @override
  State<SchoolRequestsScreen> createState() => _SchoolRequestsScreenState();
}

class _SchoolRequestsScreenState extends State<SchoolRequestsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<SchoolRequestProvider>(context, listen: false).loadRequests();
    });
  }

  // 🔥 7A: Modificado para notificar cuando se ACEPTA
  Future<void> _acceptRequest(SchoolRequestModel request) async {
    final requestProvider =
        Provider.of<SchoolRequestProvider>(context, listen: false);
    final notificationProvider =
        Provider.of<NotificationProvider>(context, listen: false);

    await requestProvider.acceptRequest(request.id);

    // Notificar al deportista
    await notificationProvider.addNotification(
      userId: request.athleteId,
      title: '¡Solicitud aceptada!',
      message: 'Has sido aceptado en ${request.schoolName}. Bienvenido.',
      type: 'request',
      relatedId: request.id,
    );

    if (!mounted) return;
    _showMessage('${request.athleteName} ha sido aceptado en la escuela');
  }

  // 🔥 7B: Modificado para notificar cuando se RECHAZA
  Future<void> _rejectRequest(SchoolRequestModel request) async {
    final requestProvider =
        Provider.of<SchoolRequestProvider>(context, listen: false);
    final notificationProvider =
        Provider.of<NotificationProvider>(context, listen: false);

    await requestProvider.rejectRequest(request.id);

    // Notificar al deportista
    await notificationProvider.addNotification(
      userId: request.athleteId,
      title: 'Solicitud rechazada',
      message: 'Tu solicitud para unirte a ${request.schoolName} fue rechazada.',
      type: 'request',
      relatedId: request.id,
    );

    if (!mounted) return;
    _showMessage('Solicitud de ${request.athleteName} rechazada');
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final schoolProvider = Provider.of<SchoolProvider>(context);
    final requestProvider = Provider.of<SchoolRequestProvider>(context);

    final schoolId = schoolProvider.school?.id ?? authProvider.schoolId ?? '';
    final pendingRequests = schoolId.isNotEmpty
        ? requestProvider.getPendingRequestsForSchool(schoolId)
        : <SchoolRequestModel>[];

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF5F7FA),
        elevation: 0,
        title: const Text(
          'Solicitudes de Ingreso',
          style: TextStyle(
            color: Color(0xFF1F2937),
            fontWeight: FontWeight.bold,
          ),
        ),
        iconTheme: const IconThemeData(color: Color(0xFF1F2937)),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Tienes ${pendingRequests.length} solicitud${pendingRequests.length == 1 ? '' : 'es'} pendiente${pendingRequests.length == 1 ? '' : 's'}',
                style: const TextStyle(
                  fontSize: 16,
                  color: Color(0xFF6B7280),
                ),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: requestProvider.isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : pendingRequests.isEmpty
                        ? _buildEmptyState()
                        : ListView.builder(
                            itemCount: pendingRequests.length,
                            itemBuilder: (context, index) {
                              final request = pendingRequests[index];
                              return _buildRequestCard(request);
                            },
                          ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.inbox_outlined,
            size: 80,
            color: const Color(0xFFD1D5DB),
          ),
          const SizedBox(height: 16),
          const Text(
            'No hay solicitudes pendientes',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF6B7280),
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Cuando un deportista solicite ingresar a tu escuela, aparecerá aquí.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Color(0xFF9CA3AF),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRequestCard(SchoolRequestModel request) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: const Color(0xFFEFF6FF),
                    borderRadius: BorderRadius.circular(25),
                  ),
                  child: const Icon(
                    Icons.person,
                    color: Color(0xFF2563EB),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        request.athleteName,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1F2937),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Solicitó ingreso el ${_formatDate(request.createdAt)}',
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
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => _rejectRequest(request),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFFEF4444),
                      side: const BorderSide(color: Color(0xFFEF4444)),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: const Text('Rechazar'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => _acceptRequest(request),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF10B981),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: const Text('Aceptar'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}