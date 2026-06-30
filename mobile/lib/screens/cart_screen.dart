import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../providers/cart_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/empty_state.dart';
import '../widgets/custom_button.dart';
import '../services/api_client.dart';

class CartScreen extends StatelessWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final cartProvider = context.watch<CartProvider>();

    return Scaffold(
      appBar: AppBar(title: const Text('Моя корзина')),
      body: cartProvider.items.isEmpty
          ? const EmptyState(icon: Icons.shopping_cart_outlined, message: 'Ваша корзина пуста')
          : Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.all(AppSpacing.md),
                    itemCount: cartProvider.items.length,
                    itemBuilder: (context, index) {
                      final item = cartProvider.items[index];
                      return Card(
                        margin: const EdgeInsets.only(bottom: AppSpacing.md),
                        child: Padding(
                          padding: const EdgeInsets.all(AppSpacing.sm),
                          child: Row(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: item.product.imageUrl != null && item.product.imageUrl!.isNotEmpty
                                    ? CachedNetworkImage(
                                        imageUrl: ApiClient.getFullImageUrl(item.product.imageUrl!),
                                        width: 80,
                                        height: 80,
                                        fit: BoxFit.cover,
                                        placeholder: (context, url) => Container(color: Theme.of(context).colorScheme.surfaceContainerHighest),
                                        errorWidget: (context, url, error) => const Icon(Icons.image_not_supported),
                                      )
                                    : Container(width: 80, height: 80, color: Theme.of(context).colorScheme.surfaceContainerHighest, child: const Icon(Icons.image)),
                              ),
                              const SizedBox(width: AppSpacing.md),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(item.product.name, style: Theme.of(context).textTheme.titleMedium, maxLines: 1, overflow: TextOverflow.ellipsis),
                                    const SizedBox(height: 4),
                                    Text(
                                      '${(item.product.discountPrice ?? item.product.price).toStringAsFixed(2)} ₽',
                                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Theme.of(context).colorScheme.primary),
                                    ),
                                    const SizedBox(height: 8),
                                    Row(
                                      children: [
                                        InkWell(
                                          onTap: () => cartProvider.updateQuantity(item.product.id, item.quantity - 1),
                                          child: const Icon(Icons.remove_circle_outline, size: 24),
                                        ),
                                        const SizedBox(width: 12),
                                        Text('${item.quantity}', style: Theme.of(context).textTheme.bodyLarge),
                                        const SizedBox(width: 12),
                                        InkWell(
                                          onTap: () => cartProvider.updateQuantity(item.product.id, item.quantity + 1),
                                          child: const Icon(Icons.add_circle_outline, size: 24),
                                        ),
                                        const Spacer(),
                                        IconButton(
                                          icon: Icon(Icons.delete_outline, color: Theme.of(context).colorScheme.error),
                                          onPressed: () => cartProvider.removeFromCart(item.product.id),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surfaceContainer,
                    boxShadow: [BoxShadow(color: Colors.black26, offset: Offset(0, -2), blurRadius: 4)],
                  ),
                  child: SafeArea(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('Стоимость товаров'),
                            Text('${cartProvider.totalAmount.toStringAsFixed(2)} ₽'),
                          ],
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('Доставка'),
                            Text('${cartProvider.deliveryFee.toStringAsFixed(2)} ₽'),
                          ],
                        ),
                        const Divider(height: AppSpacing.lg),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('Итого', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
                            Text('${(cartProvider.totalAmount + cartProvider.deliveryFee).toStringAsFixed(2)} ₽', style: Theme.of(context).textTheme.titleLarge?.copyWith(color: Theme.of(context).colorScheme.primary, fontWeight: FontWeight.bold)),
                          ],
                        ),
                        const SizedBox(height: AppSpacing.lg),
                        PrimaryButton(
                          text: 'Перейти к оформлению',
                          onPressed: () => Navigator.pushNamed(context, '/checkout'),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}
