import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/payment_model.dart';
import 'payment_repository.dart';

class LocalPaymentRepository implements PaymentRepository {
  static const _paymentsKey = 'rolla_payments';

  @override
  Future<List<PaymentModel>> getPayments() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getString(_paymentsKey);
    if (data == null) return [];
    final decoded = jsonDecode(data) as List<dynamic>;
    return decoded
        .map((entry) => PaymentModel.fromJson(entry as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<void> savePayments(List<PaymentModel> payments) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _paymentsKey,
      jsonEncode(payments.map((payment) => payment.toJson()).toList()),
    );
  }
}
