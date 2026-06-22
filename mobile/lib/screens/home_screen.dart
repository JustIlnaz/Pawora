import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/product_provider.dart';
import '../providers/auth_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/product_card.dart';
import '../widgets/category_chip.dart';
import '../widgets/custom_text_field.dart';
import '../widgets/loading_state.dart';
import '../widgets/error_state.dart';
import '../models/category.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String? _selectedCategoryId;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = Provider.of<ProductProvider>(context, listen: false);
      provider.fetchCategories();
      provider.fetchProducts();
    });
  }

  Category _createAllCategory() {
    return Category(id: 'all', name: 'All', sortOrder: 0);
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().user;
    final productProvider = context.watch<ProductProvider>();

    return Scaffold(
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverAppBar(
              floating: true,
              automaticallyImplyLeading: false,
              title: Text('PAWORA', style: Theme.of(context).textTheme.displayLarge?.copyWith(fontSize: 24, color: AppColors.primary)),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.md),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Привет, ${user?.fullName ?? 'Гость'}!', style: Theme.of(context).textTheme.headlineMedium),
                    const SizedBox(height: AppSpacing.md),
                    CustomTextField(
                      label: 'Поиск товаров...',
                      prefixIcon: Icons.search,
                      readOnly: true,
                      onTap: () => Navigator.pushNamed(context, '/search'),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(AppSpacing.lg),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(colors: [AppColors.primaryContainer, AppColors.primary]),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Специальные предложения', style: Theme.of(context).textTheme.titleLarge?.copyWith(color: AppColors.onPrimaryContainer, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 8),
                          Text('Скидки до 50% на корма премиум-класса', style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.onPrimaryContainer)),
                        ],
                      ),
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    Text('Категории', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
                    const SizedBox(height: AppSpacing.md),
                    if (productProvider.categories.isNotEmpty)
                      SizedBox(
                        height: 40,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: productProvider.categories.length + 1,
                          itemBuilder: (context, index) {
                            if (index == 0) {
                              return CategoryChip(
                                category: _createAllCategory(),
                                isSelected: _selectedCategoryId == null,
                                onTap: () {
                                  setState(() => _selectedCategoryId = null);
                                  productProvider.fetchProducts();
                                },
                              );
                            }
                            final cat = productProvider.categories[index - 1];
                            return CategoryChip(
                              category: cat,
                              isSelected: _selectedCategoryId == cat.id,
                              onTap: () {
                                  setState(() => _selectedCategoryId = cat.id);
                                  productProvider.fetchProducts(categoryId: cat.id);
                              },
                            );
                          },
                        ),
                      ),
                    const SizedBox(height: AppSpacing.lg),
                    Text('Популярные товары', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
                    const SizedBox(height: AppSpacing.md),
                  ],
                ),
              ),
            ),
            if (productProvider.isLoading)
              const SliverToBoxAdapter(child: LoadingState())
            else if (productProvider.error != null)
              SliverToBoxAdapter(child: ErrorState(message: productProvider.error!, onRetry: () => productProvider.fetchProducts(categoryId: _selectedCategoryId)))
            else
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
                sliver: SliverGrid(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 0.75,
                    crossAxisSpacing: AppSpacing.md,
                    mainAxisSpacing: AppSpacing.md,
                  ),
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final product = productProvider.customerProducts[index];
                      return ProductCard(
                        product: product,
                        onTap: () => Navigator.pushNamed(context, '/product', arguments: product),
                      );
                    },
                    childCount: productProvider.customerProducts.length,
                  ),
                ),
              ),
            const SliverToBoxAdapter(child: SizedBox(height: AppSpacing.xl)),
          ],
        ),
      ),
    );
  }
}
