import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'dart:async';
import '../models/order.dart';
import '../providers/order_provider.dart';
import '../providers/product_provider.dart';
import '../theme/app_theme.dart';

class OrderCard extends StatefulWidget {
  final Order order;
  final VoidCallback? onTap;

  const OrderCard({super.key, required this.order, this.onTap});

  @override
  State<OrderCard> createState() => _OrderCardState();
}

class _OrderCardState extends State<OrderCard> {
  Timer? _timer;
  int _secondsRemaining = 0;

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  @override
  void didUpdateWidget(OrderCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.order.status != widget.order.status) {
      _startTimer();
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startTimer() {
    _timer?.cancel();
    
    if (widget.order.status.toLowerCase() != 'new') {
      setState(() {
        _secondsRemaining = 0;
      });
      return;
    }

    _calculateRemainingTime();

    if (_secondsRemaining > 0) {
      _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
        if (!mounted) return;
        _calculateRemainingTime();
        if (_secondsRemaining <= 0) {
          timer.cancel();
        }
      });
    }
  }

  void _calculateRemainingTime() {
    final createdAt = DateTime.tryParse(widget.order.createdAt)?.toUtc();
    if (createdAt != null) {
      final difference = DateTime.now().toUtc().difference(createdAt);
      setState(() {
        _secondsRemaining = 120 - difference.inSeconds;
      });
    } else {
      setState(() {
        _secondsRemaining = 0;
      });
    }
  }

  void _cancelOrder() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Отмена заказа'),
        content: const Text('Вы действительно хотите отменить этот заказ?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text('Нет', style: TextStyle(color: Theme.of(context).colorScheme.onSurface)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text('Да, отменить', style: TextStyle(color: Theme.of(context).colorScheme.error)),
          ),
        ],
      ),
    );

    if (confirm == true && mounted) {
      try {
        final orderProvider = Provider.of<OrderProvider>(context, listen: false);
        await orderProvider.updateOrderStatus(widget.order.id, 'Cancelled');
        if (mounted) {
          final productProvider = Provider.of<ProductProvider>(context, listen: false);
          for (var item in widget.order.items) {
             productProvider.increaseStockLocally(item.productId, item.quantity);
          }
          
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Заказ успешно отменен')),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Не удалось отменить заказ: $e')),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final date = DateTime.tryParse(widget.order.createdAt);
    final dateString = date != null ? DateFormat.yMMMd().format(date) : widget.order.createdAt;
    
    return Card(
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      child: InkWell(
        onTap: widget.onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Заказ #${widget.order.id.substring(0, 8)}',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  _buildStatusChip(widget.order.status),
                ],
              ),
              const SizedBox(height: 8),
              Text(dateString, style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant)),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${widget.order.items.length} товар(ов)',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  Text(
                    '${widget.order.totalAmount.toStringAsFixed(2)} ₽',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(color: Theme.of(context).colorScheme.primary, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              if (widget.order.status.toLowerCase() == 'new' && _secondsRemaining > 0) ...[
                const SizedBox(height: 8),
                const Divider(),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.timer_outlined, size: 16, color: Theme.of(context).colorScheme.primary),
                        const SizedBox(width: 4),
                        Text(
                          'Отмена доступна: ${_secondsRemaining ~/ 60}:${(_secondsRemaining % 60).toString().padLeft(2, '0')}',
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.primary,
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    TextButton.icon(
                      onPressed: _cancelOrder,
                      icon: Icon(Icons.cancel_outlined, size: 16, color: Theme.of(context).colorScheme.error),
                      label: Text('Отменить', style: TextStyle(color: Theme.of(context).colorScheme.error)),
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusChip(String status) {
    Color bgColor;
    Color textColor = Colors.white;
    String statusRu;
    switch (status.toLowerCase()) {
      case 'new':
        bgColor = Colors.blue;
        statusRu = 'Новый';
        break;
      case 'inprogress':
        bgColor = Colors.amber;
        statusRu = 'В процессе';
        break;
      case 'delivered':
        bgColor = Colors.green;
        statusRu = 'Доставлен';
        break;
      case 'cancelled':
        bgColor = Colors.red;
        statusRu = 'Отменен';
        break;
      default:
        bgColor = Theme.of(context).colorScheme.surfaceContainerHighest;
        textColor = Theme.of(context).colorScheme.onSurface;
        statusRu = status;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        statusRu,
        style: TextStyle(color: textColor, fontSize: 12, fontWeight: FontWeight.w600),
      ),
    );
  }
}
