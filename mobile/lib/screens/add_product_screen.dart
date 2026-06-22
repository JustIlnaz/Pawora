import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import '../providers/product_provider.dart';
import '../providers/shop_provider.dart';
import '../services/upload_service.dart';
import '../theme/app_theme.dart';
import '../widgets/custom_button.dart';
import '../widgets/custom_text_field.dart';

class AddProductScreen extends StatefulWidget {
  const AddProductScreen({super.key});

  @override
  State<AddProductScreen> createState() => _AddProductScreenState();
}

class _AddProductScreenState extends State<AddProductScreen> {
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _priceController = TextEditingController();
  final _stockController = TextEditingController();

  String? _selectedCategoryId;
  String? _selectedShopId;
  XFile? _imageFile;
  final ImagePicker _picker = ImagePicker();
  final UploadService _uploadService = UploadService();
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<ProductProvider>(context, listen: false).fetchCategories();
      Provider.of<ShopProvider>(context, listen: false).fetchShops();
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    _stockController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    try {
      final XFile? pickedFile = await _picker.pickImage(source: ImageSource.gallery);
      if (pickedFile != null) {
        setState(() {
          _imageFile = pickedFile;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Ошибка при выборе изображения')),
        );
      }
    }
  }

  void _submit() async {
    if (_nameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Введите название товара')));
      return;
    }
    if (_priceController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Введите цену')));
      return;
    }
    if (_selectedCategoryId == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Выберите категорию')));
      return;
    }
    if (_selectedShopId == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Выберите магазин')));
      return;
    }

    final productProvider = Provider.of<ProductProvider>(context, listen: false);

    setState(() {
      _isSaving = true;
    });

    try {
      String? imageUrl;
      if (_imageFile != null) {
        imageUrl = await _uploadService.uploadImage(_imageFile!);
      }

      final price = double.tryParse(_priceController.text) ?? 0.0;
      final stock = int.tryParse(_stockController.text) ?? 0;

      final productData = {
        'name': _nameController.text.trim(),
        'description': _descriptionController.text.trim().isEmpty ? null : _descriptionController.text.trim(),
        'price': price,
        'stock': stock,
        'categoryId': _selectedCategoryId,
        'shopId': _selectedShopId,
        'imageUrl': imageUrl,
      };

      await productProvider.createProduct(productData);

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Товар успешно добавлен')));
      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Ошибка при добавлении товара: $e')),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  String _getRussianCategoryName(String name) {
    switch (name.toLowerCase()) {
      case 'all': return 'Все';
      case 'food': return 'Корма';
      case 'toys': return 'Игрушки';
      case 'healthcare': return 'Здоровье';
      case 'accessories': return 'Аксессуары';
      case 'grooming': return 'Груминг';
      case 'clothing': return 'Одежда';
      default: return name;
    }
  }

  IconData _getCategoryIcon(String? iconName) {
    switch (iconName) {
      case 'pets': return Icons.pets;
      case 'food': return Icons.restaurant;
      case 'toys': return Icons.toys;
      case 'health_and_safety': return Icons.health_and_safety;
      case 'content_cut': return Icons.content_cut;
      case 'checkroom': return Icons.checkroom;
      default: return Icons.category;
    }
  }

  Widget _buildCustomSelector({
    required String label,
    required String? selectedValue,
    required String hint,
    required IconData defaultIcon,
    required VoidCallback onTap,
    required String? displayText,
    IconData? selectedIcon,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppColors.onSurfaceVariant,
                fontWeight: FontWeight.w500,
              ),
        ),
        const SizedBox(height: 8),
        InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Ink(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            decoration: BoxDecoration(
              color: AppColors.surfaceContainerHigh,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.outlineVariant),
            ),
            child: Row(
              children: [
                Icon(
                  selectedValue != null ? (selectedIcon ?? defaultIcon) : defaultIcon,
                  color: selectedValue != null ? AppColors.primary : AppColors.onSurfaceVariant,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    selectedValue != null ? displayText! : hint,
                    style: TextStyle(
                      color: selectedValue != null ? AppColors.onSurface : AppColors.onSurfaceVariant,
                      fontSize: 16,
                    ),
                  ),
                ),
                const Icon(
                  Icons.keyboard_arrow_down,
                  color: AppColors.onSurfaceVariant,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  void _showCategorySelector(BuildContext context, ProductProvider productProvider) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surfaceContainerLow,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: AppSpacing.md),
              Container(
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.outlineVariant,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              Text(
                'Выберите категорию',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: AppSpacing.md),
              Flexible(
                child: ListView.builder(
                  shrinkWrap: true,
                  physics: const BouncingScrollPhysics(),
                  itemCount: productProvider.categories.length,
                  itemBuilder: (context, index) {
                    final cat = productProvider.categories[index];
                    final isSelected = cat.id == _selectedCategoryId;
                    return ListTile(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 4),
                      leading: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: isSelected ? AppColors.primaryContainer : AppColors.surfaceContainerHigh,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(
                          _getCategoryIcon(cat.iconName),
                          color: isSelected ? AppColors.onPrimaryContainer : AppColors.onSurfaceVariant,
                          size: 20,
                        ),
                      ),
                      title: Text(
                        _getRussianCategoryName(cat.name),
                        style: TextStyle(
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                          color: isSelected ? AppColors.primary : AppColors.onSurface,
                        ),
                      ),
                      trailing: isSelected
                          ? const Icon(Icons.check_circle, color: AppColors.primary)
                          : null,
                      onTap: () {
                        setState(() {
                          _selectedCategoryId = cat.id;
                        });
                        Navigator.pop(context);
                      },
                    );
                  },
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
            ],
          ),
        );
      },
    );
  }

  void _showShopSelector(BuildContext context, ShopProvider shopProvider) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surfaceContainerLow,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: AppSpacing.md),
              Container(
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.outlineVariant,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              Text(
                'Выберите магазин',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: AppSpacing.md),
              Flexible(
                child: ListView.builder(
                  shrinkWrap: true,
                  physics: const BouncingScrollPhysics(),
                  itemCount: shopProvider.shops.length,
                  itemBuilder: (context, index) {
                    final shop = shopProvider.shops[index];
                    final isSelected = shop.id == _selectedShopId;
                    return ListTile(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 4),
                      leading: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: isSelected ? AppColors.primaryContainer : AppColors.surfaceContainerHigh,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(
                          Icons.storefront,
                          color: isSelected ? AppColors.onPrimaryContainer : AppColors.onSurfaceVariant,
                          size: 20,
                        ),
                      ),
                      title: Text(
                        shop.name,
                        style: TextStyle(
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                          color: isSelected ? AppColors.primary : AppColors.onSurface,
                        ),
                      ),
                      subtitle: Text(
                        shop.address,
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.onSurfaceVariant,
                        ),
                      ),
                      trailing: isSelected
                          ? const Icon(Icons.check_circle, color: AppColors.primary)
                          : null,
                      onTap: () {
                        setState(() {
                          _selectedShopId = shop.id;
                        });
                        Navigator.pop(context);
                      },
                    );
                  },
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final productProvider = context.watch<ProductProvider>();
    final shopProvider = context.watch<ShopProvider>();

    return Scaffold(
      appBar: AppBar(title: const Text('Добавить товар')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: GestureDetector(
                  onTap: _pickImage,
                  child: Container(
                    width: double.infinity,
                    height: 180,
                    decoration: BoxDecoration(
                      color: AppColors.surfaceContainerHigh,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.outlineVariant),
                    ),
                    child: _imageFile != null
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(16),
                            child: Image.file(
                              File(_imageFile!.path),
                              fit: BoxFit.cover,
                            ),
                          )
                        : const Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.add_a_photo_outlined, size: 40, color: AppColors.onSurfaceVariant),
                              SizedBox(height: 8),
                              Text('Добавить фото товара', style: TextStyle(color: AppColors.onSurfaceVariant)),
                            ],
                          ),
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              CustomTextField(
                label: 'Название товара',
                hint: 'Введите название',
                controller: _nameController,
                prefixIcon: Icons.shopping_bag_outlined,
              ),
              CustomTextField(
                label: 'Описание',
                hint: 'Введите описание товара',
                controller: _descriptionController,
                prefixIcon: Icons.description_outlined,
              ),
              Row(
                children: [
                  Expanded(
                    child: CustomTextField(
                      label: 'Цена (₽)',
                      hint: '0.00',
                      controller: _priceController,
                      prefixIcon: Icons.payments_outlined,
                      keyboardType: TextInputType.number,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: CustomTextField(
                      label: 'Количество',
                      hint: '0',
                      controller: _stockController,
                      prefixIcon: Icons.inventory_2_outlined,
                      keyboardType: TextInputType.number,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.sm),
              _buildCustomSelector(
                label: 'Категория',
                selectedValue: _selectedCategoryId,
                hint: 'Выберите категорию',
                defaultIcon: Icons.category_outlined,
                displayText: _selectedCategoryId != null && productProvider.categories.isNotEmpty
                    ? _getRussianCategoryName(
                        productProvider.categories
                            .firstWhere((cat) => cat.id == _selectedCategoryId,
                                orElse: () => productProvider.categories.first)
                            .name,
                      )
                    : null,
                selectedIcon: _selectedCategoryId != null && productProvider.categories.isNotEmpty
                    ? _getCategoryIcon(
                        productProvider.categories
                            .firstWhere((cat) => cat.id == _selectedCategoryId,
                                orElse: () => productProvider.categories.first)
                            .iconName,
                      )
                    : null,
                onTap: () => _showCategorySelector(context, productProvider),
              ),
              const SizedBox(height: AppSpacing.md),
              _buildCustomSelector(
                label: 'Магазин',
                selectedValue: _selectedShopId,
                hint: 'Выберите магазин',
                defaultIcon: Icons.storefront,
                displayText: _selectedShopId != null && shopProvider.shops.isNotEmpty
                    ? shopProvider.shops
                        .firstWhere((shop) => shop.id == _selectedShopId,
                            orElse: () => shopProvider.shops.first)
                        .name
                    : null,
                onTap: () => _showShopSelector(context, shopProvider),
              ),
              const SizedBox(height: AppSpacing.xl),
              PrimaryButton(
                text: 'Добавить товар',
                onPressed: _isSaving ? null : _submit,
                isLoading: _isSaving,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
