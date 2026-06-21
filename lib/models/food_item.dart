class FoodItem {
  final int? id;
  final String name;
  final String category;
  final String storageLocation;
  final double quantity;
  final String unit;
  final DateTime? expiryDate;
  final DateTime dateAdded;
  final String? imagePath;
  final String? notes;
  final bool consumed;

  FoodItem({
    this.id,
    required this.name,
    required this.category,
    required this.storageLocation,
    required this.quantity,
    required this.unit,
    this.expiryDate,
    required this.dateAdded,
    this.imagePath,
    this.notes,
    this.consumed = false,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'category': category,
      'storage_location': storageLocation,
      'quantity': quantity,
      'unit': unit,
      'expiry_date': expiryDate?.toIso8601String(),
      'date_added': dateAdded.toIso8601String(),
      'image_path': imagePath,
      'notes': notes,
      'consumed': consumed ? 1 : 0,
    };
  }

  factory FoodItem.fromMap(Map<String, dynamic> map) {
    return FoodItem(
      id: map['id'] as int?,
      name: map['name'] as String,
      category: map['category'] as String,
      storageLocation: map['storage_location'] as String,
      quantity: map['quantity'] as double,
      unit: map['unit'] as String,
      expiryDate: map['expiry_date'] != null
          ? DateTime.parse(map['expiry_date'] as String)
          : null,
      dateAdded: DateTime.parse(map['date_added'] as String),
      imagePath: map['image_path'] as String?,
      notes: map['notes'] as String?,
      consumed: (map['consumed'] as int) == 1,
    );
  }

  FoodItem copyWith({
    int? id,
    String? name,
    String? category,
    String? storageLocation,
    double? quantity,
    String? unit,
    DateTime? expiryDate,
    DateTime? dateAdded,
    String? imagePath,
    String? notes,
    bool? consumed,
  }) {
    return FoodItem(
      id: id ?? this.id,
      name: name ?? this.name,
      category: category ?? this.category,
      storageLocation: storageLocation ?? this.storageLocation,
      quantity: quantity ?? this.quantity,
      unit: unit ?? this.unit,
      expiryDate: expiryDate ?? this.expiryDate,
      dateAdded: dateAdded ?? this.dateAdded,
      imagePath: imagePath ?? this.imagePath,
      notes: notes ?? this.notes,
      consumed: consumed ?? this.consumed,
    );
  }

  int? get daysUntilExpiry {
    if (expiryDate == null) return null;
    return expiryDate!.difference(DateTime.now()).inDays;
  }

  bool get isExpiringSoon {
    final days = daysUntilExpiry;
    return days != null && days <= 3 && days >= 0;
  }

  bool get isExpired {
    final days = daysUntilExpiry;
    return days != null && days < 0;
  }
}
