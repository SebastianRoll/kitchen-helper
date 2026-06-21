import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:path/path.dart';
import '../models/food_item.dart';
import '../models/category.dart' as app_category;

class DatabaseService {
  static Database? _database;
  List<FoodItem>? _webItems;
  List<app_category.Category>? _webCategories;

  bool get isWeb => kIsWeb;

  DatabaseService() {
    if (!isWeb && Platform.isLinux) {
      sqfliteFfiInit();
      databaseFactory = databaseFactoryFfi;
    }
  }

  Future<void> _initWebData() async {
    if (_webItems != null) return;

    final jsonString = await rootBundle.loadString('assets/sample_data.json');
    final data = json.decode(jsonString);

    _webCategories = (data['categories'] as List)
        .map((c) => app_category.Category.fromMap(c))
        .toList();

    _webItems = (data['food_items'] as List)
        .map((item) => FoodItem(
          id: item['id'],
          name: item['name'],
          category: item['category'],
          storageLocation: item['storage_location'],
          quantity: item['quantity'].toDouble(),
          unit: item['unit'],
          expiryDate: item['expiry_date'] != null
              ? DateTime.parse(item['expiry_date'])
              : null,
          dateAdded: DateTime.parse(item['date_added']),
          notes: item['notes'],
          consumed: item['consumed'] ?? false,
        ))
        .toList();
  }

  Future<Database> get database async {
    if (isWeb) throw UnsupportedError('SQLite not supported on web');
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

    await _loadSampleData(db);
  }

  Future<void> _loadSampleData(Database db) async {
    final jsonString = await rootBundle.loadString('assets/sample_data.json');
    final data = json.decode(jsonString);

    for (final cat in data['categories']) {
      await db.insert('categories', cat);
    }

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
    if (isWeb) {
      await _initWebData();
      var items = _webItems!;

      if (!includeConsumed) {
        items = items.where((i) => !i.consumed).toList();
      }

      if (storageLocation != null) {
        items = items.where((i) => i.storageLocation == storageLocation).toList();
      }

      if (category != null) {
        items = items.where((i) => i.category == category).toList();
      }

      items.sort((a, b) {
        if (a.expiryDate == null && b.expiryDate == null) return 0;
        if (a.expiryDate == null) return 1;
        if (b.expiryDate == null) return -1;
        return a.expiryDate!.compareTo(b.expiryDate!);
      });

      return items;
    }

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
    if (isWeb) {
      await _initWebData();
      final newId = (_webItems!.length + 1);
      _webItems!.add(item.copyWith(id: newId));
      return newId;
    }
    final db = await database;
    return await db.insert('food_items', item.toMap());
  }

  Future<int> updateFoodItem(FoodItem item) async {
    if (isWeb) {
      await _initWebData();
      final index = _webItems!.indexWhere((i) => i.id == item.id);
      if (index >= 0) _webItems![index] = item;
      return 1;
    }
    final db = await database;
    return await db.update(
      'food_items',
      item.toMap(),
      where: 'id = ?',
      whereArgs: [item.id],
    );
  }

  Future<int> deleteFoodItem(int id) async {
    if (isWeb) {
      await _initWebData();
      _webItems!.removeWhere((i) => i.id == id);
      return 1;
    }
    final db = await database;
    return await db.delete(
      'food_items',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<int> markAsConsumed(int id) async {
    if (isWeb) {
      await _initWebData();
      final index = _webItems!.indexWhere((i) => i.id == id);
      if (index >= 0) {
        _webItems![index] = _webItems![index].copyWith(consumed: true);
      }
      return 1;
    }
    final db = await database;
    return await db.update(
      'food_items',
      {'consumed': 1},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Categories
  Future<List<app_category.Category>> getCategories() async {
    if (isWeb) {
      await _initWebData();
      return _webCategories!;
    }
    final db = await database;
    final maps = await db.query('categories');
    return maps.map((map) => app_category.Category.fromMap(map)).toList();
  }

  // Stats
  Future<Map<String, int>> getItemCountsByLocation() async {
    final items = await getFoodItems();
    final counts = <String, int>{};
    for (final item in items) {
      counts[item.storageLocation] = (counts[item.storageLocation] ?? 0) + 1;
    }
    return counts;
  }

  Future<List<FoodItem>> getExpiringItems(int days) async {
    final items = await getFoodItems();
    final cutoff = DateTime.now().add(Duration(days: days));
    return items.where((item) {
      if (item.expiryDate == null) return false;
      return item.expiryDate!.isBefore(cutoff) &&
          item.expiryDate!.isAfter(DateTime.now());
    }).toList();
  }
}
