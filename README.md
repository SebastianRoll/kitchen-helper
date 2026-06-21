# Kitchen Helper

A Flutter app for visual food inventory management, recipe suggestions, and expiry tracking.

## Features

- **Visual Inventory**: Grid of food photos organized by storage location (Dry, Fridge, Freezer)
- **Categories**: Meat, Vegetables, Dairy, Grains, etc.
- **Quick Actions**: Tap to "eat" (consume), modify, or view expiry dates
- **Receipt Parsing**: Feed receipts, AI extracts items and adds to inventory
- **Recipe Suggestions**: Based on available ingredients
- **Expiry Alerts**: Notifications when items are close to expiring

## Tech Stack

- **Flutter** (cross-platform: Android, iOS, web)
- **SQLite** (local database)
- **Provider/Riverpod** (state management)
- **Image Picker** (food photos)

## Project Structure

```
lib/
├── main.dart
├── models/
│   ├── food_item.dart
│   ├── category.dart
│   └── storage_location.dart
├── screens/
│   ├── home_screen.dart
│   ├── inventory_grid_screen.dart
│   ├── add_item_screen.dart
│   ├── item_detail_screen.dart
│   └── recipe_suggestions_screen.dart
├── widgets/
│   ├── food_item_card.dart
│   ├── category_filter.dart
│   └── expiry_badge.dart
├── providers/
│   └── inventory_provider.dart
├── services/
│   ├── database_service.dart
│   ├── receipt_parser_service.dart
│   └── recipe_service.dart
└── utils/
    └── constants.dart
```

## Getting Started

1. Install Flutter: https://flutter.dev/docs/get-started/install
2. Run `flutter pub get`
3. Run `flutter run`

## Database Schema

### Food Items
- id (INTEGER PRIMARY KEY)
- name (TEXT)
- category (TEXT)
- storage_location (TEXT: dry, fridge, freezer)
- quantity (REAL)
- unit (TEXT: pcs, kg, g, ml, l)
- expiry_date (DATETIME)
- date_added (DATETIME)
- image_path (TEXT)
- notes (TEXT)
- consumed (BOOLEAN)

### Categories
- id (INTEGER PRIMARY KEY)
- name (TEXT)
- icon (TEXT)
- color (TEXT)

### Recipes
- id (INTEGER PRIMARY KEY)
- name (TEXT)
- ingredients (TEXT - JSON)
- instructions (TEXT)
- prep_time (INTEGER)
- difficulty (TEXT)
