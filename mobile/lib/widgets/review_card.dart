import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/review.dart';
import '../theme/app_theme.dart';

class ReviewCard extends StatelessWidget {
  final Review review;

  const ReviewCard({super.key, required this.review});

  @override
  Widget build(BuildContext context) {
    final date = DateTime.tryParse(review.createdAt);
    final dateString = date != null ? DateFormat.yMMMd().format(date) : review.createdAt;

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            backgroundImage: review.userAvatarUrl != null ? NetworkImage(review.userAvatarUrl!) : null,
            backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest,
            child: review.userAvatarUrl == null ? Icon(Icons.person, color: Theme.of(context).colorScheme.onSurfaceVariant) : null,
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      review.userName ?? 'Пользователь',
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    Text(
                      dateString,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: List.generate(5, (index) {
                    return Icon(
                      index < review.rating ? Icons.star : Icons.star_border,
                      size: 16,
                      color: Colors.amber,
                    );
                  }),
                ),
                if (review.comment != null && review.comment!.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Text(
                    review.comment!,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Theme.of(context).colorScheme.onSurface),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
