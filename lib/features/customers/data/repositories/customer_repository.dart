import 'package:smart_invoice_pro/core/services/database_helper.dart';
import 'package:smart_invoice_pro/features/customers/domain/models/customer_model.dart';

class CustomerRepository {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  Future<int> create(Customer customer) async {
    print('CustomerRepository: Creating customer ${customer.name}');
    try {
      final db = await _dbHelper.database;
      final id = await db.insert('customers', customer.toMap());
      print('CustomerRepository: Customer created with ID: $id');
      return id;
    } catch (e) {
      print('CustomerRepository: Error creating customer: $e');
      rethrow;
    }
  }

  Future<Customer?> read(int id) async {
    try {
      final db = await _dbHelper.database;
      final maps = await db.query(
        'customers',
        columns: ['id', 'name', 'email', 'phone', 'address'],
        where: 'id = ?',
        whereArgs: [id],
      );

      if (maps.isNotEmpty) {
        return Customer.fromMap(maps.first);
      } else {
        return null;
      }
    } catch (e) {
      print('CustomerRepository: Error reading customer: $e');
      rethrow;
    }
  }

  Future<List<Customer>> readAll() async {
    print('CustomerRepository: Reading all customers');
    try {
      final db = await _dbHelper.database;
      final result = await db.query('customers', orderBy: 'name ASC');
      print('CustomerRepository: Found ${result.length} customers');
      return result.map((json) => Customer.fromMap(json)).toList();
    } catch (e) {
      print('CustomerRepository: Error reading all customers: $e');
      rethrow;
    }
  }

  Future<int> update(Customer customer) async {
    print('CustomerRepository: Updating customer ${customer.id}');
    try {
      final db = await _dbHelper.database;
      return await db.update(
        'customers',
        customer.toMap(),
        where: 'id = ?',
        whereArgs: [customer.id],
      );
    } catch (e) {
      print('CustomerRepository: Error updating customer: $e');
      rethrow;
    }
  }

  Future<int> delete(int id) async {
    print('CustomerRepository: Deleting customer $id');
    try {
      final db = await _dbHelper.database;
      return await db.delete(
        'customers',
        where: 'id = ?',
        whereArgs: [id],
      );
    } catch (e) {
      print('CustomerRepository: Error deleting customer: $e');
      rethrow;
    }
  }
}
