import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/order_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/order_card.dart';
import '../widgets/loading_state.dart';
import '../widgets/empty_state.dart';
import '../widgets/error_state.dart';

class OrderHistoryScreen extends StatefulWidget {
  const OrderHistoryScreen({super.key});

  @override
  State<OrderHistoryScreen> createState() => _OrderHistoryScreenState();
}

class _OrderHistoryScreenState extends State<OrderHistoryScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<OrderProvider>(context, listen: false).fetchOrders();
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<OrderProvider>();

    return Scaffold(
      appBar: AppBar(title: const Text('Мои заказы')),
      body: _buildContent(provider),
    );
  }

  Widget _buildContent(OrderProvider provider) {
    if (provider.isLoading) {
      return const LoadingState(itemCount: 4);
    } else if (provider.error != null) {
      return ErrorState(message: provider.error!, onRetry: () => provider.fetchOrders());
    } else if (provider.orders.isEmpty) {
      return const EmptyState(icon: Icons.receipt_long, message: 'У вас пока нет заказов');
    }

    return ListView.builder(
      padding: const EdgeInsets.all(AppSpacing.md),
      itemCount: provider.orders.length,
      itemBuilder: (context, index) {
        return OrderCard(order: provider.orders[index]);
      },
    );
  }
}
