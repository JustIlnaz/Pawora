import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../models/product.dart';
import '../theme/app_theme.dart';
import '../services/api_client.dart';

class ProductCard extends StatelessWidget {
  final Product product;
  final VoidCallback onTap;

  const ProductCard({super.key, required this.product, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                child: product.imageUrl != null && product.imageUrl!.isNotEmpty
                    ? CachedNetworkImage(
                        imageUrl: ApiClient.getFullImageUrl(product.imageUrl),
                        fit: BoxFit.cover,
                        width: double.infinity,
                        placeholder: (context, url) => Container(color: Theme.of(context).colorScheme.surfaceContainerHighest),
                        errorWidget: (context, url, error) => Icon(Icons.image_not_supported, color: Theme.of(context).colorScheme.onSurfaceVariant),
                      )
                    : Container(
                        width: double.infinity,
                        color: Theme.of(context).colorScheme.surfaceContainerHighest,
                        child: Icon(Icons.image, color: Theme.of(context).colorScheme.onSurfaceVariant),
                      ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(AppSpacing.sm),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.name,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Theme.of(context).colorScheme.onSurface),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Text(
                        '${(product.discountPrice ?? product.price).toStringAsFixed(2)} ₽',
                        style: Theme.of(context).textTheme.labelLarge?.copyWith(color: Theme.of(context).colorScheme.primary),
                      ),
                      if (product.discountPrice != null) ...[
                        const SizedBox(width: 4),
                        Text(
                          '${product.price.toStringAsFixed(2)} ₽',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Theme.of(context).colorScheme.onSurfaceVariant,
                            decoration: TextDecoration.lineThrough,
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.star, size: 14, color: Colors.amber),
                      const SizedBox(width: 2),
                      Text(
                        product.rating.toStringAsFixed(1),
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant),
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
  }
}
