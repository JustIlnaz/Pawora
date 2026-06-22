import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../models/shop.dart';
import '../theme/app_theme.dart';
import '../services/api_client.dart';

class ShopCard extends StatelessWidget {
  final Shop shop;
  final VoidCallback onTap;

  const ShopCard({super.key, required this.shop, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.horizontal(left: Radius.circular(12)),
              child: shop.imageUrl != null && shop.imageUrl!.isNotEmpty
                  ? CachedNetworkImage(
                      imageUrl: ApiClient.getFullImageUrl(shop.imageUrl),
                      width: 100,
                      height: 100,
                      fit: BoxFit.cover,
                      placeholder: (context, url) => Container(width: 100, height: 100, color: AppColors.surfaceContainerHighest),
                      errorWidget: (context, url, error) => Container(width: 100, height: 100, color: AppColors.surfaceContainerHighest, child: const Icon(Icons.store, color: AppColors.onSurfaceVariant)),
                    )
                  : Container(width: 100, height: 100, color: AppColors.surfaceContainerHighest, child: const Icon(Icons.store, color: AppColors.onSurfaceVariant)),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.sm),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      shop.name,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(color: AppColors.onSurface, fontWeight: FontWeight.bold),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      shop.address,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.onSurfaceVariant),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(Icons.star, size: 16, color: Colors.amber),
                        const SizedBox(width: 4),
                        Text(
                          shop.rating.toStringAsFixed(1),
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.onSurface),
                        ),
                        const Spacer(),
                        if (shop.distance != null)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: AppColors.primaryContainer,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              '${shop.distance!.toStringAsFixed(1)} км',
                              style: Theme.of(context).textTheme.labelSmall?.copyWith(color: AppColors.onPrimaryContainer),
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
