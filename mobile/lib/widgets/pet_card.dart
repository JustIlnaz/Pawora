import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../models/pet.dart';
import '../services/api_client.dart';
import '../theme/app_theme.dart';

class PetCard extends StatelessWidget {
  final Pet pet;

  const PetCard({super.key, required this.pet});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.pushNamed(
          context,
          '/add_pet',
          arguments: pet,
        );
      },
      child: Card(
        margin: const EdgeInsets.only(right: AppSpacing.md),
        child: Container(
          width: 140,
          padding: const EdgeInsets.all(AppSpacing.sm),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircleAvatar(
                radius: 30,
                backgroundColor: AppColors.surfaceContainerHighest,
                backgroundImage: pet.imageUrl != null && pet.imageUrl!.isNotEmpty
                    ? CachedNetworkImageProvider(ApiClient.getFullImageUrl(pet.imageUrl)) as ImageProvider
                    : null,
                child: (pet.imageUrl == null || pet.imageUrl!.isEmpty) ? const Icon(Icons.pets, color: AppColors.onSurfaceVariant, size: 30) : null,
              ),
              const SizedBox(height: 8),
              Text(
                pet.name,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              Text(
                pet.breed ?? pet.species,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.onSurfaceVariant),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              if (pet.birthDate != null)
                Text(
                  _getAge(pet.birthDate!),
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(color: AppColors.primary),
                ),
            ],
          ),
        ),
      ),
    );
  }

  String _getAge(String birthDate) {
    try {
      final date = DateTime.parse(birthDate);
      final now = DateTime.now();
      final difference = now.difference(date);
      final years = difference.inDays ~/ 365;
      if (years > 0) {
        if (years % 10 == 1 && years % 100 != 11) return '$years год';
        if ((years % 10 >= 2 && years % 10 <= 4) && (years % 100 < 10 || years % 100 >= 20)) return '$years года';
        return '$years лет';
      }
      final months = difference.inDays ~/ 30;
      if (months > 0) {
        if (months % 10 == 1 && months % 100 != 11) return '$months месяц';
        if ((months % 10 >= 2 && months % 10 <= 4) && (months % 100 < 10 || months % 100 >= 20)) return '$months месяца';
        return '$months месяцев';
      }
      return 'Малыш';
    } catch (e) {
      return '';
    }
  }
}
