import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/food_item.dart';
import '../models/category.dart';

class DatabaseService {
  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'kitchen_helper.db');

    return await openDatabase(
      path,
      version: 1,
      onCreate: _createTables,
    );
  }

  Future<void> _createTables(Database db, int version) async {
    await db.execute('''
      CREATE TABLE categories(
        id INTEGER PRIMARY KEY,
        name TEXT NOT NULL,
        icon TEXT NOT NULL,
        color TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE food_items(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        category TEXT NOT NULL,
        storage_location TEXT NOT NULL,
        quantity REAL NOT NULL,
        unit TEXT NOT NULL,
        expiry_date TEXT,
        date_added TEXT NOT NULL,
        image_path TEXT,
        notes TEXT,
        consumed INTEGER NOT NULL DEFAULT 0
      )
    ''');

    // Load sample data
    await _loadSampleData(db);
  }

  Future<void> _loadSampleData(Database db) async {
    final jsonString = await rootBundle.loadString('assets/sample_data.json');
    final data = json.decode(jsonString);

    // Insert categories
    for (final cat in data['categories']) {
      await db.insert('categories', cat);
    }

    // Insert food items
    for (final item in data['food_items']) {
      await db.insert('food_items', {
        'name': item['name'],
        'category': item['category'],
        'storage_location': item['storage_location'],
        'quantity': item['quantity'],
        'unit': item['unit'],
        'expiry_date': item['expiry_date'],
        'date_added': item['date_added'],
        'notes': item['notes'],
        'consumed': item['consumed'] ? 1 : 0,
      });
    }
  }

  // Food Items CRUD
  Future<List<FoodItem>> getFoodItems({
    String? storageLocation,
    String? category,
    bool includeConsumed = false,
  }) async {
    final db = await database;

    String whereClause = '';
    List<dynamic> whereArgs = [];

    if (!includeConsumed) {
      whereClause = 'consumed = 0';
    }

    if (storageLocation != null) {
      whereClause += whereClause.isNotEmpty ? ' AND ' : '';
      whereClause += 'storage_location = ?';
      whereArgs.add(storageLocation);
    }

    if (category != null) {
      whereClause += whereClause.isNotEmpty ? ' AND ' : '';
      whereClause += 'category = ?';
      whereArgs.add(category);
    }

    final maps = await db.query(
      'food_items',
      where: whereClause.isNotEmpty ? whereClause : null,
      whereArgs: whereArgs.isNotEmpty ? whereArgs : null,
      orderBy: 'expiry_date ASC',
    );

    return maps.map((map) => FoodItem.fromMap(map)).toList();
  }

  Future<int> insertFoodItem(FoodItem item) async {
    final db = await database;
    return await db.insert('food_items', item.toMap());
  }

  Future<int> updateFoodItem(FoodItem item) async {
    final db = await database;
    return await db.update(
      'food_items',
      item.toMap(),
      where: 'id = ?',
      whereArgs: [item.id],
    );
  }

  Future<int> deleteFoodItem(int id) async {
    final db = await database;
    return await db.delete(
      'food_items',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<int> markAsConsumed(int id) async {
    final db = await database;
    return await db.update(
      'food_items',
      {'consumed': 1},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Categories
  Future<List<Category>> getCategories() async {
    final db = await database;
    final maps = await db.query('categories');
    return maps.map((map) => Category.fromMap(map)).toList();
  }

  // Stats
  Future<Map<String, int>> getItemCountsByLocation() async {
    final db = await database;
    final result = await db.rawQuery('''
      SELECT storage_location, COUNT(*) as count 
      FROM food_items 
      WHERE consumed = 0 
      GROUP BY storage_location
    ''');

    return {
      for (var row in result)
        row['storage_location'] as String: row['count'] as int
    };
  }

  Future<List<FoodItem>> getExpiringItems(int days) async {
    final db = await database;
    final cutoff = DateTime.now().add(Duration(days: days)).toIso8601String();

    final maps = await db.query(
      'food_items',
      where: 'consumed = 0 AND expiry_date <= ? AND expiry_date >= ?',
      whereArgs: [cutoff, DateTime.now().toIso8601String()],
      orderBy: 'expiry_date ASC',
    );

    return maps.map((map) => FoodItem.fromMap(map)).toList();
  }
}
