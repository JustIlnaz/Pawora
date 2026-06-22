import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/admin_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/loading_state.dart';
import '../widgets/error_state.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = Provider.of<AdminProvider>(context, listen: false);
      provider.fetchStats();
      provider.fetchOrders();
    });
  }

  @override
  Widget build(BuildContext context) {
    final adminProvider = context.watch<AdminProvider>();

    return Scaffold(
      appBar: AppBar(title: const Text('Панель управления')),
      body: adminProvider.isLoading
          ? const LoadingState()
          : adminProvider.error != null
              ? ErrorState(
                  message: adminProvider.error!,
                  onRetry: () => adminProvider.fetchStats(),
                )
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      GridView.count(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        crossAxisCount: 2,
                        crossAxisSpacing: AppSpacing.md,
                        mainAxisSpacing: AppSpacing.md,
                        childAspectRatio: 1.2,
                        children: [
                          _buildStatCard(
                            context,
                            'Всего заказов',
                            '${adminProvider.totalOrders}',
                            Icons.shopping_bag,
                            () => Navigator.pushNamed(context, '/admin/orders'),
                          ),
                          _buildStatCard(
                            context,
                            'Выручка',
                            '${adminProvider.totalRevenue.toStringAsFixed(0)} ₽',
                            Icons.attach_money,
                          ),
                          _buildStatCard(
                            context,
                            'Товары',
                            '${adminProvider.totalProducts}',
                            Icons.inventory_2,
                            () => Navigator.pushNamed(context, '/admin/products'),
                          ),
                          _buildStatCard(
                            context,
                            'Клиенты',
                            '${adminProvider.totalClients}',
                            Icons.people,
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.xl),
                      Text('Последние заказы', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
                      const SizedBox(height: AppSpacing.md),
                      adminProvider.allOrders.isEmpty
                          ? const Center(child: Text('Нет последних заказов для отображения.', style: TextStyle(color: AppColors.onSurfaceVariant)))
                          : ListView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: adminProvider.allOrders.length > 5 ? 5 : adminProvider.allOrders.length,
                              itemBuilder: (context, index) {
                                final order = adminProvider.allOrders[index];
                                return Card(
                                  margin: const EdgeInsets.only(bottom: AppSpacing.md),
                                  child: ListTile(
                                    title: Text('Заказ #${order.id.substring(0, 8)}', style: const TextStyle(fontWeight: FontWeight.bold)),
                                    subtitle: Text('${order.totalAmount.toStringAsFixed(2)} ₽ • ${order.items.length} товар(ов)'),
                                    trailing: _buildStatusBadge(order.status),
                                    onTap: () => Navigator.pushNamed(context, '/admin/orders'),
                                  ),
                                );
                              },
                            ),
                    ],
                  ),
                ),
    );
  }

  Widget _buildStatCard(BuildContext context, String label, String value, IconData icon, [VoidCallback? onTap]) {
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: const BoxDecoration(
                  color: AppColors.primaryContainer,
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: AppColors.onPrimaryContainer),
              ),
              const SizedBox(height: 8),
              Text(value, style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold)),
              Text(label, style: Theme.of(context).textTheme.labelSmall?.copyWith(color: AppColors.onSurfaceVariant)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusBadge(String status) {
    Color color;
    String label;
    switch (status) {
      case 'New':
        color = Colors.blue;
        label = 'Новый';
        break;
      case 'InProgress':
        color = Colors.orange;
        label = 'В обработке';
        break;
      case 'Delivered':
        color = Colors.green;
        label = 'Доставлен';
        break;
      case 'Cancelled':
        color = Colors.red;
        label = 'Отменен';
        break;
      default:
        color = Colors.grey;
        label = status;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.5)),
      ),
      child: Text(
        label,
        style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.bold),
      ),
    );
  }
}
