import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/product_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/product_card.dart';
import '../widgets/loading_state.dart';
import '../widgets/empty_state.dart';
import '../widgets/error_state.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final _searchController = TextEditingController();
  String? _selectedCategoryId;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<ProductProvider>(context, listen: false).fetchCategories();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onSearch() {
    final query = _searchController.text;
    Provider.of<ProductProvider>(context, listen: false).fetchProducts(
      search: query.isNotEmpty ? query : null,
      categoryId: _selectedCategoryId,
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ProductProvider>();

    return Scaffold(
      appBar: AppBar(
        title: TextField(
          controller: _searchController,
          autofocus: true,
          decoration: InputDecoration(
            hintText: 'Поиск товаров...',
            border: InputBorder.none,
            enabledBorder: InputBorder.none,
            focusedBorder: InputBorder.none,
            fillColor: Colors.transparent,
            filled: false,
            suffixIcon: IconButton(
              icon: const Icon(Icons.clear),
              onPressed: () {
                _searchController.clear();
                _onSearch();
              },
            ),
          ),
          onSubmitted: (_) => _onSearch(),
        ),
      ),
      body: Column(
        children: [
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Row(
              children: [
                _buildFilterChip('Все', null, _selectedCategoryId == null),
                if (provider.categories.isNotEmpty)
                  ...provider.categories.map((cat) {
                    // Translate common categories to Russian for UI
                    String label = cat.name;
                    switch (cat.name.toLowerCase()) {
                      case 'food': label = 'Корма'; break;
                      case 'toys': label = 'Игрушки'; break;
                      case 'healthcare': label = 'Здоровье'; break;
                      case 'accessories': label = 'Аксессуары'; break;
                      case 'grooming': label = 'Груминг'; break;
                      case 'clothing': label = 'Одежда'; break;
                    }
                    return _buildFilterChip(label, cat.id, _selectedCategoryId == cat.id);
                  }),
              ],
            ),
          ),
          Expanded(
            child: _buildContent(provider),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, String? categoryId, bool isSelected) {
    return Container(
      margin: const EdgeInsets.only(right: AppSpacing.sm),
      child: FilterChip(
        label: Text(label),
        selected: isSelected,
        onSelected: (_) {
          setState(() {
            _selectedCategoryId = categoryId;
          });
          _onSearch();
        },
        backgroundColor: AppColors.surfaceContainerHigh,
        selectedColor: AppColors.primaryContainer,
        labelStyle: TextStyle(color: isSelected ? AppColors.onPrimaryContainer : AppColors.onSurface),
      ),
    );
  }

  Widget _buildContent(ProductProvider provider) {
    if (provider.isLoading) {
      return const LoadingState();
    } else if (provider.error != null) {
      return ErrorState(message: provider.error!, onRetry: () => _onSearch());
    } else if (provider.customerProducts.isEmpty) {
      return const EmptyState(icon: Icons.search_off, message: 'Товары не найдены');
    }

    return GridView.builder(
      padding: const EdgeInsets.all(AppSpacing.md),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.75,
        crossAxisSpacing: AppSpacing.md,
        mainAxisSpacing: AppSpacing.md,
      ),
      itemCount: provider.customerProducts.length,
      itemBuilder: (context, index) {
        final product = provider.customerProducts[index];
        return ProductCard(
          product: product,
          onTap: () => Navigator.pushNamed(context, '/product', arguments: product),
        );
      },
    );
  }
}
