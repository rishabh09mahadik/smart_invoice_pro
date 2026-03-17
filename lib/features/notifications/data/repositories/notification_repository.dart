import 'package:smart_invoice_pro/core/services/database_helper.dart';
import 'package:smart_invoice_pro/features/notifications/domain/models/notification_model.dart';

class NotificationRepository {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  Future<int> create(AppNotification notification) async {
    final db = await _dbHelper.database;
    return await db.insert('notifications', notification.toMap());
  }

  Future<List<AppNotification>> readAll() async {
    final db = await _dbHelper.database;
    final maps = await db.query('notifications', orderBy: 'timestamp DESC');
    return maps.map((json) => AppNotification.fromMap(json)).toList();
  }

  Future<int> markAsRead(int id) async {
    final db = await _dbHelper.database;
    return await db.update(
      'notifications',
      {'isRead': 1},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<int> markAllAsRead() async {
    final db = await _dbHelper.database;
    return await db.update(
      'notifications',
      {'isRead': 1},
    );
  }
}
