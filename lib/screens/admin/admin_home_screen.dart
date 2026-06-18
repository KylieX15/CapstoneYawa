import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/auth_provider.dart';
import '../../utils/app_theme.dart';
import 'create_staff_screen.dart';

class AdminHomeScreen extends ConsumerWidget {
  const AdminHomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Sign Out',
            onPressed: () => ref.read(authServiceProvider).signOut(),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Dindo's Restaurant",
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppTheme.primaryColor,
                  ),
            ),
            const SizedBox(height: 4),
            Text('Admin Control Panel',
                style: TextStyle(color: Colors.grey[600])),
            const SizedBox(height: 24),
            _MenuCard(
              icon: Icons.restaurant_menu,
              title: 'Menu Management',
              subtitle: 'Add, edit, and remove menu items',
              color: Colors.orange,
            ),
            const SizedBox(height: 12),
            _MenuCard(
              icon: Icons.receipt_long,
              title: 'Order Dashboard',
              subtitle: 'View and manage incoming orders',
              color: Colors.blue,
            ),
            const SizedBox(height: 12),
            _MenuCard(
              icon: Icons.inventory_2,
              title: 'Inventory',
              subtitle: 'Toggle sold-out status per item',
              color: Colors.green,
            ),
            const SizedBox(height: 12),
            _MenuCard(
              icon: Icons.manage_accounts,
              title: 'Manage Accounts',
              subtitle: 'Create employee and rider accounts',
              color: Colors.purple,
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (_) => const CreateStaffScreen()),
              ),
            ),
          ],
        ),
      ),
      backgroundColor: AppTheme.backgroundColor,
    );
  }
}

class _MenuCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final VoidCallback? onTap;

  const _MenuCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: color.withValues(alpha: 0.12),
          child: Icon(icon, color: color),
        ),
        title: Text(title,
            style: const TextStyle(fontWeight: FontWeight.w600)),
        subtitle: Text(subtitle),
        trailing:
            const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
        onTap: onTap,
      ),
    );
  }
}
