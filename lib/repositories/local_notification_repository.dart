import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/notification_model.dart';
import 'notification_repository.dart';

class LocalNotificationRepository implements NotificationRepository {
  static const _notificationsKey = 'rolla_notifications';

  @override
  Future<List<NotificationModel>> getNotifications() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getString(_notificationsKey);
    if (data == null) return [];
    final decoded = jsonDecode(data) as List<dynamic>;
    return decoded
        .map(
          (entry) => NotificationModel.fromJson(entry as Map<String, dynamic>),
        )
        .toList();
  }

  @override
  Future<void> saveNotifications(List<NotificationModel> notifications) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _notificationsKey,
      jsonEncode(
        notifications.map((notification) => notification.toJson()).toList(),
      ),
    );
  }
}
