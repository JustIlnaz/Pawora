import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/admin_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/loading_state.dart';
import '../widgets/error_state.dart';
import '../widgets/empty_state.dart';

class AdminOrdersScreen extends StatefulWidget {
  const AdminOrdersScreen({super.key});

  @override
  State<AdminOrdersScreen> createState() => _AdminOrdersScreenState();
}

class _AdminOrdersScreenState extends State<AdminOrdersScreen> {
  String _selectedFilter = 'Все';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<AdminProvider>(context, listen: false).fetchOrders();
    });
  }

  @override
  Widget build(BuildContext context) {
    final adminProvider = context.watch<AdminProvider>();

    // Filter orders locally based on tab
    final filteredOrders = adminProvider.allOrders.where((order) {
      if (_selectedFilter == 'Все') return true;
      if (_selectedFilter == 'Новые') return order.status == 'New';
      if (_selectedFilter == 'В обработке') return order.status == 'InProgress';
      if (_selectedFilter == 'Доставленные') return order.status == 'Delivered';
      if (_selectedFilter == 'Отмененные') return order.status == 'Cancelled';
      return true;
    }).toList();

    return Scaffold(
      appBar: AppBar(title: const Text('Управление заказами')),
      body: Column(
        children: [
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Row(
              children: [
                _buildFilterChip('Все'),
                _buildFilterChip('Новые'),
                _buildFilterChip('В обработке'),
                _buildFilterChip('Доставленные'),
                _buildFilterChip('Отмененные'),
              ],
            ),
          ),
          Expanded(
            child: adminProvider.isLoading
                ? const LoadingState()
                : adminProvider.error != null
                    ? ErrorState(
                        message: adminProvider.error!,
                        onRetry: () => adminProvider.fetchOrders(),
                      )
                    : filteredOrders.isEmpty
                        ? const EmptyState(
                            icon: Icons.receipt_long,
                            message: 'Заказы в этой категории отсутствуют.',
                          )
                        : ListView.builder(
                            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
                            itemCount: filteredOrders.length,
                            itemBuilder: (context, index) {
                              final order = filteredOrders[index];
                              return Card(
                                margin: const EdgeInsets.only(bottom: AppSpacing.md),
                                child: Padding(
                                  padding: const EdgeInsets.all(AppSpacing.md),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            'Заказ #${order.id.substring(0, 8)}',
                                            style: const TextStyle(fontWeight: FontWeight.bold),
                                          ),
                                          _buildStatusBadge(order.status),
                                        ],
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        'Дата: ${DateFormat('dd.MM.yyyy HH:mm').format(DateTime.parse(order.createdAt).toLocal())}',
                                        style: const TextStyle(color: AppColors.onSurfaceVariant, fontSize: 12),
                                      ),
                                      if (order.address != null) ...[
                                        const SizedBox(height: 4),
                                        Text(
                                          'Адрес: ${order.address}',
                                          style: const TextStyle(color: AppColors.onSurfaceVariant, fontSize: 12),
                                        ),
                                      ],
                                      const Divider(height: AppSpacing.lg),
                                      // Render items in order
                                      ...order.items.map((item) => Padding(
                                            padding: const EdgeInsets.symmetric(vertical: 2.0),
                                            child: Row(
                                              children: [
                                                Text(
                                                  '${item.quantity}x ${item.productName ?? 'Товар'}',
                                                  style: const TextStyle(fontSize: 13),
                                                ),
                                                const Spacer(),
                                                Text(
                                                  '${(item.unitPrice * item.quantity).toStringAsFixed(2)} ₽',
                                                  style: const TextStyle(fontSize: 13),
                                                ),
                                              ],
                                            ),
                                          )),
                                      const Divider(height: AppSpacing.lg),
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            'Итого: ${order.totalAmount.toStringAsFixed(2)} ₽',
                                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                                          ),
                                          // Dropdown to update status
                                          DropdownButton<String>(
                                            value: order.status,
                                            dropdownColor: AppColors.surfaceContainerHigh,
                                            underline: const SizedBox(),
                                            style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold, fontSize: 13),
                                            icon: const Icon(Icons.arrow_drop_down, color: AppColors.primary),
                                            items: const [
                                              DropdownMenuItem(value: 'New', child: Text('Новый')),
                                              DropdownMenuItem(value: 'InProgress', child: Text('В обработке')),
                                              DropdownMenuItem(value: 'Delivered', child: Text('Доставлен')),
                                              DropdownMenuItem(value: 'Cancelled', child: Text('Отменен')),
                                            ],
                                            onChanged: (newStatus) {
                                              if (newStatus != null) {
                                                adminProvider.updateOrderStatus(order.id, newStatus);
                                              }
                                            },
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label) {
    final isSelected = _selectedFilter == label;
    return Container(
      margin: const EdgeInsets.only(right: AppSpacing.sm),
      child: FilterChip(
        label: Text(label),
        selected: isSelected,
        onSelected: (_) {
          setState(() {
            _selectedFilter = label;
          });
        },
        backgroundColor: AppColors.surfaceContainerHigh,
        selectedColor: AppColors.primaryContainer,
        labelStyle: TextStyle(color: isSelected ? AppColors.onPrimaryContainer : AppColors.onSurface),
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
