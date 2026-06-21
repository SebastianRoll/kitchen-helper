# Product Specification - Kitchen Helper

## Overview

A mobile app for tracking food inventory across multiple storage locations, with visual organization, expiry tracking, and recipe suggestions based on available ingredients.

## Target Audience

- Home cooks who want to reduce food waste
- People with multiple freezers/storage locations
- Meal planners who want to use what they have

## Core Features

### 1. Visual Inventory Grid

**Display:**
- Grid of food items with photos
- Filter by storage location (All, Dry, Fridge, Freezer)
- Filter by category (Meat, Vegetables, Dairy, etc.)
- Sort by expiry date, date added, name

**Item Card:**
- Food photo (or placeholder icon)
- Name
- Quantity + unit
- Days until expiry (color-coded: green/yellow/red)
- Storage location icon

### 2. Add/Edit Items

**Manual Entry:**
- Name (with autocomplete from existing items)
- Category (dropdown with icons)
- Storage location (Dry/Fridge/Freezer)
- Quantity + unit
- Expiry date (date picker)
- Photo (camera or gallery)
- Notes

**Quick Actions:**
- "Eat" button (marks as consumed, removes from active inventory)
- "Edit" button
- "Delete" button

### 3. Receipt Parsing

**Input:**
- Camera photo of receipt
- Gallery image of receipt

**Processing:**
- OCR extracts text
- AI identifies food items
- User confirms/edits extracted items
- Items added to inventory with guessed categories

### 4. Recipe Suggestions

**Based on:**
- Items close to expiry
- Available ingredients
- Selected category filters

**Display:**
- Recipe name
- Match percentage (how many ingredients you have)
- Missing ingredients list
- Prep time
- Difficulty

### 5. Expiry Alerts

**Notifications:**
- Items expiring in 3 days
- Items expiring today
- Weekly summary of upcoming expiries

**Badge:**
- App icon badge with count of expiring items

## Data Model

### FoodItem
```dart
class FoodItem {
  final int id;
  final String name;
  final String category;
  final String storageLocation; // 'dry', 'fridge', 'freezer'
  final double quantity;
  final String unit;
  final DateTime? expiryDate;
  final DateTime dateAdded;
  final String? imagePath;
  final String? notes;
  final bool consumed;
}
```

### Category
```dart
class Category {
  final int id;
  final String name;
  final String icon;
  final String color;
}
```

### Recipe
```dart
class Recipe {
  final int id;
  final String name;
  final List<String> ingredients;
  final String instructions;
  final int prepTime;
  final String difficulty;
}
```

## Sample Data

See `assets/sample_data.json` for a starter dataset.

## Future Features

- [ ] Barcode scanning
- [ ] Shopping list generation
- [ ] Nutrition tracking
- [ ] Meal planning calendar
- [ ] Share inventory with family members
- [ ] Cloud sync across devices
