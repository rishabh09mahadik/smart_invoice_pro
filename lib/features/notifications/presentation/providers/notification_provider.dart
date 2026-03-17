import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:smart_invoice_pro/features/notifications/data/repositories/notification_repository.dart';
import 'package:smart_invoice_pro/features/notifications/domain/models/notification_model.dart';

final notificationRepositoryProvider = Provider((ref) => NotificationRepository());

final notificationListProvider = StateNotifierProvider<NotificationListNotifier, AsyncValue<List<AppNotification>>>((ref) {
  final repository = ref.watch(notificationRepositoryProvider);
  return NotificationListNotifier(repository);
});

class NotificationListNotifier extends StateNotifier<AsyncValue<List<AppNotification>>> {
  final NotificationRepository _repository;

  NotificationListNotifier(this._repository) : super(const AsyncValue.loading()) {
    loadNotifications();
  }

  Future<void> loadNotifications() async {
    try {
      state = const AsyncValue.loading();
      final notifications = await _repository.readAll();
      state = AsyncValue.data(notifications);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<void> addNotification(AppNotification notification) async {
    try {
      await _repository.create(notification);
      await loadNotifications();
    } catch (e) {
      // Handle error
    }
  }

  Future<void> markAsRead(int id) async {
    try {
      await _repository.markAsRead(id);
      await loadNotifications();
    } catch (e) {
      // Handle error
    }
  }
  
  Future<void> markAllAsRead() async {
    try {
      await _repository.markAllAsRead();
      await loadNotifications();
    } catch (e) {
      // Handle error
    }
  }
}
