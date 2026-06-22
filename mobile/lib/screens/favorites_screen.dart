import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/favorite_provider.dart';
import '../providers/product_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/product_card.dart';
import '../widgets/empty_state.dart';

class FavoritesScreen extends StatelessWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final favoriteProvider = context.watch<FavoriteProvider>();
    final productProvider = context.watch<ProductProvider>();

    // Filter all products in store by whether their ID is in favoriteIds list
    final favoriteProducts = productProvider.products
        .where((p) => favoriteProvider.isFavorite(p.id))
        .toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Избранное'),
      ),
      body: favoriteProducts.isEmpty
          ? const Center(
              child: EmptyState(
                icon: Icons.favorite_border,
                message: 'В избранном пока пусто.\nДобавляйте товары, нажимая на сердечко!',
              ),
            )
          : GridView.builder(
              padding: const EdgeInsets.all(AppSpacing.md),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 0.75,
                crossAxisSpacing: AppSpacing.md,
                mainAxisSpacing: AppSpacing.md,
              ),
              itemCount: favoriteProducts.length,
              itemBuilder: (context, index) {
                final product = favoriteProducts[index];
                return ProductCard(
                  product: product,
                  onTap: () => Navigator.pushNamed(
                    context,
                    '/product',
                    arguments: product,
                  ),
                );
              },
            ),
    );
  }
}
