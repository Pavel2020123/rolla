import 'package:flutter/material.dart';
import '../models/notification_model.dart';
import '../repositories/local_notification_repository.dart';
import '../repositories/notification_repository.dart';

class NotificationProvider extends ChangeNotifier {
  final NotificationRepository _repository;
  List<NotificationModel> _notifications = [];
  bool _isLoading = false;

  NotificationProvider({NotificationRepository? repository})
    : _repository = repository ?? LocalNotificationRepository();

  List<NotificationModel> get notifications =>
      List.unmodifiable(_notifications);
  bool get isLoading => _isLoading;

  /// Notificaciones no leídas
  int get unreadCount => _notifications.where((n) => !n.read).length;

  /// Notificaciones de un usuario específico
  List<NotificationModel> getNotificationsForUser(String userId) {
    return _notifications.where((n) => n.userId == userId).toList()
      ..sort((a, b) => b.date.compareTo(a.date));
  }

  /// Contador de no leídas para un usuario
  int getUnreadCountForUser(String userId) {
    return _notifications.where((n) => n.userId == userId && !n.read).length;
  }

  Future<void> loadNotifications() async {
    _isLoading = true;
    notifyListeners();

    try {
      _notifications = await _repository.getNotifications();
    } catch (e) {
      debugPrint('Error cargando notificaciones: $e');
    }

    _isLoading = false;
    notifyListeners();
  }

  /// Crear una nueva notificación
  Future<void> addNotification({
    required String userId,
    required String title,
    required String message,
    required String type,
    String? relatedId,
  }) async {
    final newNotification = NotificationModel(
      id: 'notif_${DateTime.now().millisecondsSinceEpoch}',
      userId: userId,
      title: title,
      message: message,
      type: type,
      read: false,
      date: DateTime.now(),
      relatedId: relatedId,
    );

    _notifications.add(newNotification);
    await _saveNotifications();
    notifyListeners();
  }

  /// Marcar como leída
  Future<void> markAsRead(String notificationId) async {
    final index = _notifications.indexWhere((n) => n.id == notificationId);
    if (index != -1) {
      _notifications[index] = NotificationModel(
        id: _notifications[index].id,
        userId: _notifications[index].userId,
        title: _notifications[index].title,
        message: _notifications[index].message,
        type: _notifications[index].type,
        read: true,
        date: _notifications[index].date,
        relatedId: _notifications[index].relatedId,
      );
      await _saveNotifications();
      notifyListeners();
    }
  }

  /// Marcar todas como leídas para un usuario
  Future<void> markAllAsRead(String userId) async {
    bool changed = false;
    for (int i = 0; i < _notifications.length; i++) {
      if (_notifications[i].userId == userId && !_notifications[i].read) {
        _notifications[i] = NotificationModel(
          id: _notifications[i].id,
          userId: _notifications[i].userId,
          title: _notifications[i].title,
          message: _notifications[i].message,
          type: _notifications[i].type,
          read: true,
          date: _notifications[i].date,
          relatedId: _notifications[i].relatedId,
        );
        changed = true;
      }
    }
    if (changed) {
      await _saveNotifications();
      notifyListeners();
    }
  }

  Future<void> _saveNotifications() async {
    await _repository.saveNotifications(_notifications);
  }

  void clear() {
    _notifications = [];
    notifyListeners();
  }
}
