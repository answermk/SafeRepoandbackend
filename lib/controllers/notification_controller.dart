import 'package:flutter/foundation.dart';
import '../services/notification_service.dart';
import '../core/models/notification_model.dart';

/// Notification Controller
/// Manages notification state and operations
class NotificationController extends ChangeNotifier {
  List<NotificationModel> _notifications = [];
  bool _isLoading = false;
  String? _error;
  int _unreadCount = 0;

  List<NotificationModel> get notifications => _notifications;
  bool get isLoading => _isLoading;
  String? get error => _error;
  int get unreadCount => _unreadCount;

  /// Load notifications
  Future<void> loadNotifications({bool refresh = false}) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final result = await NotificationService.getNotifications();

      if (result['success'] == true) {
        final data = result['data'] as List;
        _notifications = data.map((json) => NotificationModel.fromJson(json)).toList();
        _isLoading = false;
        await loadUnreadCount();
        notifyListeners();
      } else {
        _error = result['error'] ?? 'Failed to load notifications';
        _isLoading = false;
        notifyListeners();
      }
    } catch (e) {
      _error = 'An error occurred: ${e.toString()}';
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Load unread count
  Future<void> loadUnreadCount() async {
    try {
      final result = await NotificationService.getUnreadCount();
      if (result['success'] == true) {
        _unreadCount = result['count'] ?? 0;
        notifyListeners();
      }
    } catch (e) {
      // Ignore errors
    }
  }

  /// Mark notification as read
  Future<void> markAsRead(String notificationId) async {
    try {
      final result = await NotificationService.markAsRead(notificationId);
      if (result['success'] == true) {
        final index = _notifications.indexWhere((n) => n.id == notificationId);
        if (index != -1) {
          _notifications[index] = NotificationModel(
            id: _notifications[index].id,
            userId: _notifications[index].userId,
            type: _notifications[index].type,
            title: _notifications[index].title,
            message: _notifications[index].message,
            data: _notifications[index].data,
            isRead: true,
            priority: _notifications[index].priority,
            createdAt: _notifications[index].createdAt,
          );
          await loadUnreadCount();
          notifyListeners();
        }
      }
    } catch (e) {
      // Ignore errors
    }
  }

  /// Clear error
  void clearError() {
    _error = null;
    notifyListeners();
  }
}

