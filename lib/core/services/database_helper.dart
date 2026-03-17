import 'package:flutter/foundation.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:sqflite_common_ffi_web/sqflite_ffi_web.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    try {
      _database = await _initDB('smart_invoice.db');
      print('Database initialized successfully');
      return _database!;
    } catch (e) {
      print('Error initializing database: $e');
      rethrow;
    }
  }

  Future<Database> _initDB(String filePath) async {
    print('Initializing Database for Web: $kIsWeb');
    if (kIsWeb) {
      // Use global factory initialized in main.dart
      return await openDatabase(filePath, version: 3, onCreate: _createDB, onUpgrade: _onUpgrade);
    } else {
      // Use standard sqflite for mobile/desktop
      final dbPath = await getDatabasesPath();
      final path = join(dbPath, filePath);
      return await openDatabase(path, version: 3, onCreate: _createDB, onUpgrade: _onUpgrade);
    }
  }

  Future<void> _createDB(Database db, int version) async {
    print('Creating Database Tables...');
    const idType = 'INTEGER PRIMARY KEY AUTOINCREMENT';
    const textType = 'TEXT NOT NULL';
    const textNullable = 'TEXT';
    const realType = 'REAL NOT NULL';
    const integerType = 'INTEGER NOT NULL';

    // Customers Table
    await db.execute('''
      CREATE TABLE customers (
        id $idType,
        name $textType,
        email $textType,
        phone $textType,
        address $textType
      )
    ''');

    // Items Table
    await db.execute('''
      CREATE TABLE items (
        id $idType,
        name $textType,
        description $textNullable,
        price $realType,
        tax $realType
      )
    ''');

    // Invoices Table
    await db.execute('''
      CREATE TABLE invoices (
        id $idType,
        invoiceNumber $textType,
        customerId $integerType,
        date $textType,
        dueDate $textType,
        subtotal $realType,
        tax $realType,
        discount $realType,
        grandTotal $realType,
        status $textType,
        FOREIGN KEY (customerId) REFERENCES customers (id) ON DELETE CASCADE
      )
    ''');

    // Invoice Items Table
    await db.execute('''
      CREATE TABLE invoice_items (
        id $idType,
        invoiceId $integerType,
        itemName $textType,
        qty $integerType,
        price $realType,
        tax $realType,
        FOREIGN KEY (invoiceId) REFERENCES invoices (id) ON DELETE CASCADE
      )
    ''');

    // Notifications Table
    await db.execute('''
      CREATE TABLE notifications (
        id $idType,
        title $textType,
        message $textType,
        timestamp $textType,
        isRead $integerType,
        type $textType
      )
    ''');
    print('Database Tables Created');
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 3) {
      print('Upgrading Database to Version 3...');
      // Simple migration: drop and recreate (since we are in dev)
      await db.execute('DROP TABLE IF EXISTS invoice_items');
      await db.execute('DROP TABLE IF EXISTS invoices');
      await db.execute('DROP TABLE IF EXISTS items');
      await db.execute('DROP TABLE IF EXISTS customers');
      await db.execute('DROP TABLE IF EXISTS notifications');
      await _createDB(db, newVersion);
    }
  }

  Future<void> close() async {
    final db = await instance.database;
    db.close();
  }
}
