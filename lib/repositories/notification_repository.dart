import '../models/notification_model.dart';

abstract class NotificationRepository {
  Future<List<NotificationModel>> getNotifications();

  Future<void> saveNotifications(List<NotificationModel> notifications);
}
