import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/school_provider.dart';
import '../../providers/transfer_provider.dart';
import '../../providers/notification_provider.dart';
import '../../models/transfer_request_model.dart';

class TransferRequestsScreen extends StatefulWidget {
  const TransferRequestsScreen({super.key});

  @override
  State<TransferRequestsScreen> createState() => _TransferRequestsScreenState();
}

class _TransferRequestsScreenState extends State<TransferRequestsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<TransferProvider>(context, listen: false).loadTransfers();
    });
  }

  Future<void> _acceptRelease(TransferRequestModel transfer) async {
    final transferProvider = Provider.of<TransferProvider>(context, listen: false);
    final notificationProvider = Provider.of<NotificationProvider>(context, listen: false);

    await transferProvider.acceptByCurrentSchool(transfer.id);

    // Notificar al deportista
    await notificationProvider.addNotification(
      userId: transfer.athleteId,
      title: 'Traslado aprobado',
      message: transfer.type == 'free_agent'
          ? 'Tu escuela te ha liberado. Ahora eres agente libre.'
          : 'Tu escuela actual aprobó tu traslado. Esperando aprobación de la nueva escuela.',
      type: 'transfer',
      relatedId: transfer.id,
    );

    if (!mounted) return;
    _showMessage('Solicitud aprobada');
  }

  Future<void> _rejectTransfer(TransferRequestModel transfer) async {
    final transferProvider = Provider.of<TransferProvider>(context, listen: false);
    final notificationProvider = Provider.of<NotificationProvider>(context, listen: false);

    await transferProvider.rejectTransfer(transfer.id);

    await notificationProvider.addNotification(
      userId: transfer.athleteId,
      title: 'Traslado rechazado',
      message: 'Tu solicitud de ${transfer.type == 'free_agent' ? 'quedar como agente libre' : 'traslado'} fue rechazada.',
      type: 'transfer',
      relatedId: transfer.id,
    );

    if (!mounted) return;
    _showMessage('Solicitud rechazada');
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
    final transferProvider = Provider.of<TransferProvider>(context);

    final schoolId = schoolProvider.school?.id ?? authProvider.schoolId ?? '';
    final pendingRequests = schoolId.isNotEmpty
        ? transferProvider.getPendingForCurrentSchool(schoolId)
        : <TransferRequestModel>[];

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF5F7FA),
        elevation: 0,
        title: const Text(
          'Solicitudes de Traslado',
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
                '${pendingRequests.length} solicitud${pendingRequests.length == 1 ? '' : 'es'} pendiente${pendingRequests.length == 1 ? '' : 's'}',
                style: const TextStyle(
                  fontSize: 16,
                  color: Color(0xFF6B7280),
                ),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: transferProvider.isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : pendingRequests.isEmpty
                        ? _buildEmptyState()
                        : ListView.builder(
                            itemCount: pendingRequests.length,
                            itemBuilder: (context, index) {
                              final transfer = pendingRequests[index];
                              return _buildTransferCard(transfer);
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
            Icons.swap_horiz_outlined,
            size: 80,
            color: const Color(0xFFD1D5DB),
          ),
          const SizedBox(height: 16),
          const Text(
            'No hay solicitudes de traslado',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF6B7280),
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Cuando un deportista solicite un traslado, aparecerá aquí.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Color(0xFF9CA3AF),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTransferCard(TransferRequestModel transfer) {
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
                    color: const Color(0xFFFEF3C7),
                    borderRadius: BorderRadius.circular(25),
                  ),
                  child: const Icon(
                    Icons.swap_horiz,
                    color: Color(0xFFD97706),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        transfer.athleteName,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1F2937),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        transfer.type == 'free_agent'
                            ? 'Solicita quedar como agente libre'
                            : 'Solicita traslado a otra escuela',
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
                    onPressed: () => _rejectTransfer(transfer),
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
                    onPressed: () => _acceptRelease(transfer),
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
}