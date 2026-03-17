import 'package:smart_invoice_pro/core/services/database_helper.dart';
import 'package:smart_invoice_pro/features/customers/domain/models/customer_model.dart';
import 'package:smart_invoice_pro/features/invoices/domain/models/invoice_model.dart';

class InvoiceRepository {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  Future<int> create(Invoice invoice) async {
    final db = await _dbHelper.database;
    
    // Insert Invoice
    final invoiceId = await db.insert('invoices', invoice.toMap());

    // Insert Items
    for (var item in invoice.items) {
      await db.insert('invoice_items', item.toMap(invoiceId));
    }

    return invoiceId;
  }

  Future<List<Invoice>> readAll() async {
    final db = await _dbHelper.database;
    
    // Get all invoices
    final invoiceMaps = await db.query('invoices', orderBy: 'date DESC');
    
    List<Invoice> invoices = [];

    for (var map in invoiceMaps) {
      final invoiceId = map['id'] as int;
      final customerId = map['customerId'] as int;

      // Get Customer Name
      final customerMaps = await db.query(
        'customers',
        columns: ['name'],
        where: 'id = ?',
        whereArgs: [customerId],
      );
      final customerName = customerMaps.isNotEmpty ? customerMaps.first['name'] as String : 'Unknown';

      // Get Items
      final itemMaps = await db.query(
        'invoice_items',
        where: 'invoiceId = ?',
        whereArgs: [invoiceId],
      );
      final items = itemMaps.map((json) => InvoiceItem.fromMap(json)).toList();

      invoices.add(Invoice.fromMap(map, items, customerName));
    }

    return invoices;
  }

  Future<Invoice?> read(int id) async {
    final db = await _dbHelper.database;
    
    final maps = await db.query(
      'invoices',
      where: 'id = ?',
      whereArgs: [id],
    );

    if (maps.isNotEmpty) {
      final map = maps.first;
      final customerId = map['customerId'] as int;

      // Get Customer Name
      final customerMaps = await db.query(
        'customers',
        columns: ['name'],
        where: 'id = ?',
        whereArgs: [customerId],
      );
      final customerName = customerMaps.isNotEmpty ? customerMaps.first['name'] as String : 'Unknown';

      // Get Items
      final itemMaps = await db.query(
        'invoice_items',
        where: 'invoiceId = ?',
        whereArgs: [id],
      );
      final items = itemMaps.map((json) => InvoiceItem.fromMap(json)).toList();

      return Invoice.fromMap(map, items, customerName);
    } else {
      return null;
    }
  }

  Future<int> delete(int id) async {
    final db = await _dbHelper.database;
    // Items will be deleted automatically due to CASCADE
    return await db.delete(
      'invoices',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<int> updateStatus(int id, String status) async {
    final db = await _dbHelper.database;
    return await db.update(
      'invoices',
      {'status': status},
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}
