import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/inventory_provider.dart';
import '../models/food_item.dart';

class InventoryGridScreen extends StatelessWidget {
  const InventoryGridScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Inventory'),
        backgroundColor: const Color(0xFF6366F1),
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () {
              // Show filter dialog
            },
          ),
        ],
      ),
      body: Consumer<InventoryProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.items.isEmpty) {
            return const Center(
              child: Text('No items found. Add some food!'),
            );
          }

          return GridView.builder(
            padding: const EdgeInsets.all(16),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 0.75,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
            ),
            itemCount: provider.items.length,
            itemBuilder: (context, index) {
              final item = provider.items[index];
              return _FoodItemCard(item: item);
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Navigate to add item screen
        },
        backgroundColor: const Color(0xFF6366F1),
        child: const Icon(Icons.add),
      ),
    );
  }
}

class _FoodItemCard extends StatelessWidget {
  final FoodItem item;

  const _FoodItemCard({required this.item});

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image or placeholder
          Expanded(
            flex: 3,
            child: Container(
              color: Colors.grey.shade200,
              child: Center(
                child: Icon(
                  _getCategoryIcon(item.category),
                  size: 48,
                  color: Colors.grey.shade400,
                ),
              ),
            ),
          ),

          // Info
          Expanded(
            flex: 2,
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    item.name,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    '${item.quantity} ${item.unit}',
                    style: TextStyle(
                      color: Colors.grey.shade600,
                      fontSize: 14,
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _ExpiryBadge(days: item.daysUntilExpiry),
                      _LocationIcon(location: item.storageLocation),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  IconData _getCategoryIcon(String category) {
    switch (category.toLowerCase()) {
      case 'meat':
        return Icons.restaurant;
      case 'seafood':
        return Icons.set_meal;
      case 'dairy':
        return Icons.egg_alt;
      case 'vegetables':
        return Icons.eco;
      case 'fruit':
        return Icons.apple;
      case 'grains':
        return Icons.grain;
      case 'nuts':
        return Icons.nutrition;
      default:
        return Icons.food_bank;
    }
  }
}

class _ExpiryBadge extends StatelessWidget {
  final int? days;

  const _ExpiryBadge({this.days});

  @override
  Widget build(BuildContext context) {
    if (days == null) {
      return const SizedBox.shrink();
    }

    Color color;
    String text;

    if (days! < 0) {
      color = Colors.red;
      text = 'Expired';
    } else if (days! == 0) {
      color = Colors.orange;
      text = 'Today';
    } else if (days! <= 3) {
      color = Colors.orange;
      text = '$days d';
    } else {
      color = Colors.green;
      text = '$days d';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _LocationIcon extends StatelessWidget {
  final String location;

  const _LocationIcon({required this.location});

  @override
  Widget build(BuildContext context) {
    IconData icon;
    Color color;

    switch (location) {
      case 'dry':
        icon = Icons.warehouse;
        color = Colors.orange;
        break;
      case 'fridge':
        icon = Icons.kitchen;
        color = Colors.blue;
        break;
      case 'freezer':
        icon = Icons.ac_unit;
        color = Colors.cyan;
        break;
      default:
        icon = Icons.help;
        color = Colors.grey;
    }

    return Icon(icon, color: color, size: 20);
  }
}
