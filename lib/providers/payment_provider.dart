import 'package:flutter/material.dart';
import '../models/payment_model.dart';
import '../repositories/local_payment_repository.dart';
import '../repositories/payment_repository.dart';

class PaymentProvider extends ChangeNotifier {
  final PaymentRepository _repository;
  List<PaymentModel> _payments = [];
  bool _isLoading = false;

  PaymentProvider({PaymentRepository? repository})
    : _repository = repository ?? LocalPaymentRepository();

  List<PaymentModel> get payments => List.unmodifiable(_payments);
  bool get isLoading => _isLoading;

  /// Pagos de una escuela específica
  List<PaymentModel> getPaymentsBySchool(String schoolId) {
    return _payments.where((p) => p.schoolId == schoolId).toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  /// Pagos de un deportista específico
  List<PaymentModel> getPaymentsByAthlete(String athleteId) {
    return _payments.where((p) => p.athleteId == athleteId).toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  /// Verificar si un deportista ya pagó un evento
  bool hasPaid(String athleteId, String eventId) {
    return _payments.any(
      (p) => p.athleteId == athleteId && p.eventId == eventId && p.isPaid,
    );
  }

  /// Total recaudado por una escuela
  double getTotalCollectedBySchool(String schoolId) {
    return _payments
        .where((p) => p.schoolId == schoolId && p.isPaid)
        .fold(0, (sum, p) => sum + p.amount);
  }

  Future<void> loadPayments() async {
    _isLoading = true;
    notifyListeners();

    try {
      _payments = await _repository.getPayments();
    } catch (e) {
      debugPrint('Error cargando pagos: $e');
    }

    _isLoading = false;
    notifyListeners();
  }

  /// Crear pago pendiente (cuando el deportista toca "Inscribirme")
  Future<PaymentModel?> createPayment({
    required String eventId,
    required String eventTitle,
    required String athleteId,
    required String athleteName,
    required String athleteEmail,
    required String schoolId,
    required double amount,
  }) async {
    try {
      // Verificar que no exista ya uno pendiente para este evento y deportista
      final existing = _payments.firstWhere(
        (p) =>
            p.eventId == eventId &&
            p.athleteId == athleteId &&
            p.status == 'pending',
        orElse: () => PaymentModel(
          id: '',
          eventId: '',
          eventTitle: '',
          athleteId: '',
          athleteName: '',
          athleteEmail: '',
          schoolId: '',
          amount: 0,
          createdAt: DateTime.now(),
        ),
      );

      if (existing.id.isNotEmpty) {
        return existing; // Ya existe, devolverlo
      }

      final payment = PaymentModel(
        id: 'pay_${DateTime.now().millisecondsSinceEpoch}',
        eventId: eventId,
        eventTitle: eventTitle,
        athleteId: athleteId,
        athleteName: athleteName,
        athleteEmail: athleteEmail,
        schoolId: schoolId,
        amount: amount,
        status: 'pending',
        createdAt: DateTime.now(),
      );

      _payments.add(payment);
      await _savePayments();
      notifyListeners();
      return payment;
    } catch (e) {
      debugPrint('Error creando pago: $e');
      return null;
    }
  }

  /// Marcar pago como completado (después del checkout mock)
  Future<bool> completePayment(
    String paymentId, {
    String? reference,
    String? paymentMethod,
  }) async {
    final index = _payments.indexWhere((p) => p.id == paymentId);
    if (index == -1) return false;

    _payments[index] = _payments[index].copyWith(
      status: 'completed',
      paidAt: DateTime.now(),
      reference: reference,
      paymentMethod: paymentMethod,
    );

    await _savePayments();
    notifyListeners();
    return true;
  }

  Future<void> _savePayments() async {
    await _repository.savePayments(_payments);
  }

  void clear() {
    _payments = [];
    notifyListeners();
  }
}
