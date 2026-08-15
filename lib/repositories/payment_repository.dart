import '../models/payment_model.dart';

abstract class PaymentRepository {
  Future<List<PaymentModel>> getPayments();

  Future<void> savePayments(List<PaymentModel> payments);
}
