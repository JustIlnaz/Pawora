import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../models/category.dart';

class CategoryChip extends StatelessWidget {
  final Category category;
  final bool isSelected;
  final VoidCallback onTap;

  const CategoryChip({
    super.key,
    required this.category,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(right: AppSpacing.sm),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primaryContainer : AppColors.surfaceContainerHigh,
          borderRadius: BorderRadius.circular(24),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (category.iconName != null) ...[
              Icon(
                _getIcon(category.iconName!),
                size: 16,
                color: isSelected ? AppColors.onPrimaryContainer : AppColors.onSurface,
              ),
              const SizedBox(width: 8),
            ],
            Text(
              _getRussianCategoryName(category.name),
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                color: isSelected ? AppColors.onPrimaryContainer : AppColors.onSurface,
              ),
            ),
          ],
        ),
      ),
    );
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

  IconData _getIcon(String name) {
    switch (name) {
      case 'pets': return Icons.pets;
      case 'food': return Icons.restaurant;
      case 'toys': return Icons.toys;
      case 'health_and_safety': return Icons.health_and_safety;
      case 'content_cut': return Icons.content_cut;
      case 'checkroom': return Icons.checkroom;
      default: return Icons.category;
    }
  }
}
