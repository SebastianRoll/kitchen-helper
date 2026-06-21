import 'package:flutter/foundation.dart';
import '../models/food_item.dart';
import '../models/category.dart' as app_category;
import '../services/database_service.dart';
import '../services/database_service.dart';

class InventoryProvider extends ChangeNotifier {
  final DatabaseService _db = DatabaseService();

  InventoryProvider() {
    loadItems();
    loadCategories();
  }

  List<FoodItem> _items = [];
  List<app_category.Category> _categories = [];
  String? _selectedLocation;
  String? _selectedCategory;
  bool _isLoading = false;

  List<FoodItem> get items => _items;
  List<app_category.Category> get categories => _categories;
  String? get selectedLocation => _selectedLocation;
  String? get selectedCategory => _selectedCategory;
  bool get isLoading => _isLoading;

  Future<void> loadItems() async {
    _isLoading = true;
    notifyListeners();

    _items = await _db.getFoodItems(
      storageLocation: _selectedLocation,
      category: _selectedCategory,
    );

    _isLoading = false;
    notifyListeners();
  }

  Future<void> loadCategories() async {
    _categories = await _db.getCategories();
    notifyListeners();
  }

  void setLocationFilter(String? location) {
    _selectedLocation = location;
    loadItems();
  }

  void setCategoryFilter(String? category) {
    _selectedCategory = category;
    loadItems();
  }

  void clearFilters() {
    _selectedLocation = null;
    _selectedCategory = null;
    loadItems();
  }

  Future<void> addItem(FoodItem item) async {
    await _db.insertFoodItem(item);
    await loadItems();
  }

  Future<void> updateItem(FoodItem item) async {
    await _db.updateFoodItem(item);
    await loadItems();
  }

  Future<void> deleteItem(int id) async {
    await _db.deleteFoodItem(id);
    await loadItems();
  }

  Future<void> consumeItem(int id) async {
    await _db.markAsConsumed(id);
    await loadItems();
  }

  List<FoodItem> get expiringItems {
    return _items.where((item) => item.isExpiringSoon || item.isExpired).toList();
  }

  List<FoodItem> get itemsByLocation {
    if (_selectedLocation == null) return _items;
    return _items.where((item) => item.storageLocation == _selectedLocation).toList();
  }
}
