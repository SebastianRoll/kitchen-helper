import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/inventory_provider.dart';
import 'inventory_grid_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => InventoryProvider()..loadItems()..loadCategories(),
      child: const _HomeScreenContent(),
    );
  }
}

class _HomeScreenContent extends StatelessWidget {
  const _HomeScreenContent();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Kitchen Helper'),
        backgroundColor: const Color(0xFF6366F1),
        foregroundColor: Colors.white,
      ),
      body: Consumer<InventoryProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Stats Cards
                _buildStatsRow(provider),
                const SizedBox(height: 24),

                // Quick Filters
                _buildQuickFilters(context, provider),
                const SizedBox(height: 24),

                // Expiring Soon
                if (provider.expiringItems.isNotEmpty) ...[
                  _buildSectionTitle('Expiring Soon ⚠️'),
                  const SizedBox(height: 12),
                  _buildExpiringList(provider),
                  const SizedBox(height: 24),
                ],

                // Recent Items
                _buildSectionTitle('Recent Items'),
                const SizedBox(height: 12),
                _buildRecentItems(provider),
              ],
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const InventoryGridScreen()),
          );
        },
        backgroundColor: const Color(0xFF6366F1),
        icon: const Icon(Icons.grid_view),
        label: const Text('View All'),
      ),
    );
  }

  Widget _buildStatsRow(InventoryProvider provider) {
    final dryCount = provider.items.where((i) => i.storageLocation == 'dry').length;
    final fridgeCount = provider.items.where((i) => i.storageLocation == 'fridge').length;
    final freezerCount = provider.items.where((i) => i.storageLocation == 'freezer').length;

    return Row(
      children: [
        Expanded(child: _StatCard('Dry', dryCount, Icons.warehouse, Colors.orange)),
        const SizedBox(width: 12),
        Expanded(child: _StatCard('Fridge', fridgeCount, Icons.kitchen, Colors.blue)),
        const SizedBox(width: 12),
        Expanded(child: _StatCard('Freezer', freezerCount, Icons.ac_unit, Colors.cyan)),
      ],
    );
  }

  Widget _buildQuickFilters(BuildContext context, InventoryProvider provider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('Quick Filters'),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            _FilterChip('All', null, null, provider),
            _FilterChip('Dry', 'dry', null, provider),
            _FilterChip('Fridge', 'fridge', null, provider),
            _FilterChip('Freezer', 'freezer', null, provider),
          ],
        ),
      ],
    );
  }

  Widget _buildExpiringList(InventoryProvider provider) {
    return SizedBox(
      height: 120,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: provider.expiringItems.length,
        itemBuilder: (context, index) {
          final item = provider.expiringItems[index];
          return _ExpiringCard(item);
        },
      ),
    );
  }

  Widget _buildRecentItems(InventoryProvider provider) {
    final recent = provider.items.take(5).toList();
    return Column(
      children: recent.map((item) => _RecentItemTile(item)).toList(),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.bold,
        color: Color(0xFF1F1F1F),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final int count;
  final IconData icon;
  final Color color;

  const _StatCard(this.label, this.count, this.icon, this.color);

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Icon(icon, color: color, size: 32),
            const SizedBox(height: 8),
            Text(
              count.toString(),
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(label, style: TextStyle(color: Colors.grey.shade600)),
          ],
        ),
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final String? location;
  final String? category;
  final InventoryProvider provider;

  const _FilterChip(this.label, this.location, this.category, this.provider);

  @override
  Widget build(BuildContext context) {
    final isSelected = provider.selectedLocation == location &&
        provider.selectedCategory == category;

    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (_) {
        if (isSelected) {
          provider.clearFilters();
        } else {
          provider.setLocationFilter(location);
        }
      },
      selectedColor: const Color(0xFF6366F1).withOpacity(0.2),
      checkmarkColor: const Color(0xFF6366F1),
    );
  }
}

class _ExpiringCard extends StatelessWidget {
  final dynamic item;

  const _ExpiringCard(this.item);

  @override
  Widget build(BuildContext context) {
    final days = item.daysUntilExpiry;
    final isExpired = item.isExpired;

    return Card(
      margin: const EdgeInsets.only(right: 12),
      color: isExpired ? Colors.red.shade50 : Colors.orange.shade50,
      child: Container(
        width: 150,
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              item.name,
              style: const TextStyle(fontWeight: FontWeight.bold),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 8),
            Text(
              isExpired
                  ? 'Expired!'
                  : days == 0
                      ? 'Today'
                      : '$days days left',
              style: TextStyle(
                color: isExpired ? Colors.red : Colors.orange.shade800,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RecentItemTile extends StatelessWidget {
  final dynamic item;

  const _RecentItemTile(this.item);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: _getLocationColor(item.storageLocation),
        child: Icon(
          _getLocationIcon(item.storageLocation),
          color: Colors.white,
          size: 20,
        ),
      ),
      title: Text(item.name),
      subtitle: Text('${item.quantity} ${item.unit}'),
      trailing: item.expiryDate != null
          ? Chip(
              label: Text(
                '${item.daysUntilExpiry}d',
                style: const TextStyle(fontSize: 12),
              ),
              backgroundColor: _getExpiryColor(item.daysUntilExpiry),
            )
          : null,
    );
  }

  Color _getLocationColor(String location) {
    switch (location) {
      case 'dry':
        return Colors.orange;
      case 'fridge':
        return Colors.blue;
      case 'freezer':
        return Colors.cyan;
      default:
        return Colors.grey;
    }
  }

  IconData _getLocationIcon(String location) {
    switch (location) {
      case 'dry':
        return Icons.warehouse;
      case 'fridge':
        return Icons.kitchen;
      case 'freezer':
        return Icons.ac_unit;
      default:
        return Icons.help;
    }
  }

  Color? _getExpiryColor(int? days) {
    if (days == null) return null;
    if (days < 0) return Colors.red.shade100;
    if (days <= 3) return Colors.orange.shade100;
    return Colors.green.shade100;
  }
}
