import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/product_provider.dart';
import '../services/api_client.dart';
import '../theme/app_theme.dart';
import '../widgets/empty_state.dart';
import '../widgets/loading_state.dart';
import '../models/product.dart';

class AdminProductsScreen extends StatefulWidget {
  const AdminProductsScreen({super.key});

  @override
  State<AdminProductsScreen> createState() => _AdminProductsScreenState();
}

class _AdminProductsScreenState extends State<AdminProductsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<ProductProvider>(context, listen: false).fetchProducts();
    });
  }

  void _confirmDelete(BuildContext context, String id, String name) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Удалить товар?'),
        content: Text('Вы действительно хотите удалить товар "$name"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Отмена'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(ctx);
              final provider = Provider.of<ProductProvider>(context, listen: false);
              await provider.deleteProduct(id);
              if (context.mounted) {
                if (provider.error != null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(provider.error!)),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Товар успешно удален')),
                  );
                }
              }
            },
            child: Text('Удалить', style: TextStyle(color: Theme.of(context).colorScheme.error)),
          ),
        ],
      ),
    );
  }

  void _editProductDialog(BuildContext context, Product product) {
    final priceController = TextEditingController(text: product.price.toString());
    final discountPriceController = TextEditingController(text: product.discountPrice?.toString() ?? '');
    final stockController = TextEditingController(text: product.stock.toString());

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Редактировать товар\n"${product.name}"', style: const TextStyle(fontSize: 16)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: priceController,
              decoration: const InputDecoration(labelText: 'Цена (₽)'),
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
            ),
            const SizedBox(height: AppSpacing.sm),
            TextField(
              controller: discountPriceController,
              decoration: const InputDecoration(labelText: 'Цена со скидкой (₽, необязательно)'),
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
            ),
            const SizedBox(height: AppSpacing.sm),
            TextField(
              controller: stockController,
              decoration: const InputDecoration(labelText: 'Количество (шт.)'),
              keyboardType: TextInputType.number,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('Отмена', style: TextStyle(color: Theme.of(context).colorScheme.onSurface)),
          ),
          TextButton(
            onPressed: () async {
              final priceStr = priceController.text.trim();
              final discountPriceStr = discountPriceController.text.trim();
              final stockStr = stockController.text.trim();

              final price = double.tryParse(priceStr);
              final discountPrice = discountPriceStr.isNotEmpty ? double.tryParse(discountPriceStr) : null;
              final stock = int.tryParse(stockStr);

              if (price == null || price <= 0) {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Пожалуйста, введите корректную цену')));
                return;
              }
              if (stock == null || stock < 0) {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Пожалуйста, введите корректное количество')));
                return;
              }

              Navigator.pop(ctx);

              final provider = Provider.of<ProductProvider>(context, listen: false);
              try {
                await provider.updateProduct(product.id, {
                  'name': product.name,
                  'description': product.description,
                  'imageUrl': product.imageUrl,
                  'shopId': product.shopId,
                  'categoryId': product.categoryId,
                  'price': price,
                  'discountPrice': discountPrice,
                  'stock': stock,
                });
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Параметры товара успешно обновлены')),
                  );
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Ошибка при обновлении: $e')),
                  );
                }
              }
            },
            child: Text('Сохранить', style: TextStyle(color: Theme.of(context).colorScheme.primary)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final productProvider = context.watch<ProductProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Управление товарами'),
      ),
      body: Builder(
        builder: (context) {
          if (productProvider.isLoading) {
            return const LoadingState();
          }

          if (productProvider.error != null) {
            return Center(
              child: Text(
                productProvider.error!,
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              ),
            );
          }

          if (productProvider.products.isEmpty) {
            return const EmptyState(
              icon: Icons.inventory_2_outlined,
              message: 'Товары пока не добавлены.',
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(AppSpacing.md),
            itemCount: productProvider.products.length,
            itemBuilder: (context, index) {
              final product = productProvider.products[index];
              return Card(
                margin: const EdgeInsets.only(bottom: AppSpacing.sm),
                child: ListTile(
                  leading: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Container(
                      width: 50,
                      height: 50,
                      color: Theme.of(context).colorScheme.surfaceContainerHighest,
                      child: product.imageUrl != null && product.imageUrl!.isNotEmpty
                          ? Image.network(
                              ApiClient.getFullImageUrl(product.imageUrl),
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) => Icon(Icons.shopping_bag, color: Theme.of(context).colorScheme.onSurfaceVariant),
                            )
                          : Icon(Icons.shopping_bag, color: Theme.of(context).colorScheme.onSurfaceVariant),
                    ),
                  ),
                  title: Text(
                    product.name,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(
                    '${product.price.toStringAsFixed(2)} ₽ • В наличии: ${product.stock} шт.',
                    style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant, fontSize: 12),
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: Icon(Icons.edit, color: Theme.of(context).colorScheme.primary),
                        onPressed: () => _editProductDialog(context, product),
                      ),
                      IconButton(
                        icon: Icon(Icons.delete, color: Theme.of(context).colorScheme.error),
                        onPressed: () => _confirmDelete(context, product.id, product.name),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.pushNamed(context, '/admin/products/add'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        child: Icon(Icons.add, color: Theme.of(context).colorScheme.onPrimary),
      ),
    );
  }
}
