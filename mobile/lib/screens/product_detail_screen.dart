import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:provider/provider.dart';
import '../models/product.dart';
import '../providers/cart_provider.dart';
import '../providers/favorite_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/custom_button.dart';
import 'package:dio/dio.dart';
import '../services/api_client.dart';
import '../services/review_service.dart';
import '../models/review.dart';
import '../providers/auth_provider.dart';

class ProductDetailScreen extends StatefulWidget {
  const ProductDetailScreen({super.key});

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  int _quantity = 1;

  final _reviewService = ReviewService();
  List<Review>? _reviews;
  String? _reviewError;
  bool _isLoadingReviews = true;
  bool _reviewsFetched = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_reviewsFetched) {
      final product = ModalRoute.of(context)!.settings.arguments as Product;
      _fetchReviews(product.id);
      _reviewsFetched = true;
    }
  }

  Future<void> _fetchReviews(String productId) async {
    try {
      final reviews = await _reviewService.getProductReviews(productId);
      if (mounted) {
        setState(() {
          _reviews = reviews;
          _isLoadingReviews = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _reviewError = 'Не удалось загрузить отзывы';
          _isLoadingReviews = false;
        });
      }
    }
  }

  Future<void> _submitReview(String productId, int rating, String comment) async {
    try {
      final newReview = await _reviewService.createReview(productId, rating, comment);
      if (mounted) {
        setState(() {
          _reviews?.insert(0, newReview);
        });
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Отзыв успешно добавлен')));
      }
    } catch (e) {
      if (mounted) {
        String msg = 'Ошибка при добавлении отзыва';
        if (e is DioException) {
          final data = e.response?.data;
          if (data is Map && data['error'] != null) {
            msg = data['error']['message'] ?? msg;
          } else {
            msg = 'HTTP ${e.response?.statusCode}: ${e.message}';
          }
        }
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg), duration: const Duration(seconds: 5)));
      }
    }
  }

  void _showAddReviewDialog(String productId) {
    int rating = 5;
    final commentController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text('Оставить отзыв'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(5, (index) {
                      return IconButton(
                        icon: Icon(
                          index < rating ? Icons.star : Icons.star_border,
                          color: Colors.amber,
                          size: 32,
                        ),
                        onPressed: () {
                          setDialogState(() => rating = index + 1);
                        },
                      );
                    }),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  TextField(
                    controller: commentController,
                    decoration: const InputDecoration(
                      hintText: 'Поделитесь впечатлениями...',
                      border: OutlineInputBorder(),
                    ),
                    maxLines: 3,
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Отмена'),
                ),
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    _submitReview(productId, rating, commentController.text);
                  },
                  child: const Text('Отправить'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> _submitAdminReply(Review review, String replyText) async {
    try {
      final updatedReview = await _reviewService.replyToReview(review.productId, review.id, replyText);
      if (mounted) {
        setState(() {
          final idx = _reviews!.indexWhere((r) => r.id == review.id);
          if (idx != -1) _reviews![idx] = updatedReview;
        });
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Ответ успешно добавлен')));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Ошибка при добавлении ответа')));
      }
    }
  }

  void _showReplyDialog(Review review) {
    final replyController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Ответить на отзыв'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${review.userName ?? 'Пользователь'}: ${review.comment ?? ''}',
                style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant, fontStyle: FontStyle.italic),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: AppSpacing.md),
              TextField(
                controller: replyController,
                decoration: const InputDecoration(
                  hintText: 'Ваш ответ...',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
                autofocus: true,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Отмена'),
            ),
            ElevatedButton(
              onPressed: () {
                final text = replyController.text.trim();
                if (text.isEmpty) return;
                Navigator.pop(context);
                _submitAdminReply(review, text);
              },
              child: const Text('Отправить'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildReviewsSection() {
    if (_isLoadingReviews) {
      return const Center(child: Padding(padding: EdgeInsets.all(16), child: CircularProgressIndicator()));
    }
    if (_reviewError != null) {
      return Text(_reviewError!, style: TextStyle(color: Theme.of(context).colorScheme.error));
    }
    if (_reviews == null || _reviews!.isEmpty) {
      return Text('Пока нет отзывов. Будьте первым!', style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant));
    }

    return Column(
      children: _reviews!.map((review) {
        final isAdmin = context.read<AuthProvider>().isAdmin;
        return Card(
          margin: const EdgeInsets.only(bottom: AppSpacing.md),
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // User info row
                Row(
                  children: [
                    CircleAvatar(
                      backgroundImage: review.userAvatarUrl != null ? NetworkImage(ApiClient.getFullImageUrl(review.userAvatarUrl)) : null,
                      child: review.userAvatarUrl == null ? const Icon(Icons.person) : null,
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(review.userName ?? 'Пользователь', style: const TextStyle(fontWeight: FontWeight.bold)),
                          Text(
                            DateTime.parse(review.createdAt).toLocal().toString().split(' ')[0],
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant),
                          ),
                        ],
                      ),
                    ),
                    Row(
                      children: List.generate(5, (index) {
                        return Icon(
                          index < review.rating ? Icons.star : Icons.star_border,
                          color: Colors.amber,
                          size: 16,
                        );
                      }),
                    ),
                  ],
                ),
                // Review comment
                if (review.comment != null && review.comment!.isNotEmpty) ...[
                  const SizedBox(height: AppSpacing.sm),
                  Text(review.comment!),
                ],
                // Admin reply (if exists)
                if (review.adminReply != null && review.adminReply!.isNotEmpty) ...[
                  const SizedBox(height: AppSpacing.md),
                  Container(
                    padding: const EdgeInsets.all(AppSpacing.md),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primaryContainer.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(8),
                      border: Border(
                        left: BorderSide(
                          color: Theme.of(context).colorScheme.primary,
                          width: 3,
                        ),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.admin_panel_settings, size: 16, color: Theme.of(context).colorScheme.primary),
                            const SizedBox(width: 4),
                            Text(
                              'Ответ администратора',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Theme.of(context).colorScheme.primary,
                                fontSize: 12,
                              ),
                            ),
                            if (review.adminReplyCreatedAt != null) ...[
                              const Spacer(),
                              Text(
                                DateTime.parse(review.adminReplyCreatedAt!).toLocal().toString().split(' ')[0],
                                style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant),
                              ),
                            ],
                          ],
                        ),
                        const SizedBox(height: AppSpacing.xs),
                        Text(review.adminReply!),
                      ],
                    ),
                  ),
                ],
                // Admin reply button (only if admin and no reply yet)
                if (isAdmin && (review.adminReply == null || review.adminReply!.isEmpty)) ...[
                  const SizedBox(height: AppSpacing.sm),
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton.icon(
                      onPressed: () => _showReplyDialog(review),
                      icon: const Icon(Icons.reply, size: 16),
                      label: const Text('Ответить'),
                      style: TextButton.styleFrom(
                        foregroundColor: Theme.of(context).colorScheme.primary,
                        textStyle: const TextStyle(fontSize: 13),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final product = ModalRoute.of(context)!.settings.arguments as Product;

    final favoriteProvider = context.watch<FavoriteProvider>();

    return Scaffold(
      body: Stack(
        children: [
          CustomScrollView(
            slivers: [
              SliverAppBar(
                expandedHeight: 300,
                pinned: true,
                flexibleSpace: FlexibleSpaceBar(
                  background: Stack(
                    fit: StackFit.expand,
                    children: [
                      product.imageUrl != null && product.imageUrl!.isNotEmpty
                          ? CachedNetworkImage(
                              imageUrl: ApiClient.getFullImageUrl(product.imageUrl),
                              fit: BoxFit.cover,
                              placeholder: (context, url) => Container(color: Theme.of(context).colorScheme.surfaceContainerHighest),
                              errorWidget: (context, url, error) => Container(color: Theme.of(context).colorScheme.surfaceContainerHighest, child: const Icon(Icons.image_not_supported)),
                            )
                          : Container(color: Theme.of(context).colorScheme.surfaceContainerHighest, child: const Icon(Icons.image, size: 64)),
                      Positioned(
                        bottom: 0,
                        left: 0,
                        right: 0,
                        height: 100,
                        child: Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.bottomCenter,
                              end: Alignment.topCenter,
                              colors: [
                                Theme.of(context).scaffoldBackgroundColor,
                                Theme.of(context).scaffoldBackgroundColor.withValues(alpha: 0.0),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                actions: [
                  IconButton(
                    icon: Icon(
                      favoriteProvider.isFavorite(product.id)
                          ? Icons.favorite
                          : Icons.favorite_border,
                      color: favoriteProvider.isFavorite(product.id)
                          ? Theme.of(context).colorScheme.primary
                          : null,
                    ),
                    onPressed: () => favoriteProvider.toggleFavorite(product.id),
                  ),
                ],
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(product.name, style: Theme.of(context).textTheme.headlineMedium),
                      const SizedBox(height: AppSpacing.sm),
                      Row(
                        children: [
                          Text(
                            '${(product.discountPrice ?? product.price).toStringAsFixed(2)} ₽',
                            style: Theme.of(context).textTheme.headlineMedium?.copyWith(color: Theme.of(context).colorScheme.primary),
                          ),
                          if (product.discountPrice != null) ...[
                            const SizedBox(width: AppSpacing.sm),
                            Text(
                              '${product.price.toStringAsFixed(2)} ₽',
                              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                color: Theme.of(context).colorScheme.onSurfaceVariant,
                                decoration: TextDecoration.lineThrough,
                              ),
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      Builder(
                        builder: (context) {
                          double displayRating = product.rating;
                          int displayCount = product.reviewCount;

                          if (_reviews != null) {
                            displayCount = _reviews!.length;
                            if (displayCount > 0) {
                              displayRating = _reviews!.map((r) => r.rating).reduce((a, b) => a + b) / displayCount;
                            } else {
                              displayRating = 0.0;
                            }
                          }

                          return Row(
                            children: [
                              const Icon(Icons.star, color: Colors.amber, size: 20),
                              const SizedBox(width: 4),
                              Text('${displayRating.toStringAsFixed(1)} ($displayCount отзывов)'),
                              const Spacer(),
                              if (product.stock > 0)
                                Text(
                                  'Осталось: ${product.stock} шт.',
                                  style: TextStyle(color: Theme.of(context).colorScheme.primary, fontWeight: FontWeight.bold),
                                ),
                            ],
                          );
                        }
                      ),
                      const SizedBox(height: AppSpacing.lg),
                      Text('Описание', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
                      const SizedBox(height: AppSpacing.sm),
                      Text(
                        product.description ?? 'Описание отсутствует.',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant),
                      ),
                      const SizedBox(height: AppSpacing.xl),
                      if (product.stock > 0) ...[
                        Row(
                          children: [
                            Text('Количество (в наличии: ${product.stock} шт.)', style: Theme.of(context).textTheme.titleMedium),
                            const Spacer(),
                            IconButton(
                              icon: const Icon(Icons.remove_circle_outline),
                              onPressed: () {
                                if (_quantity > 1) setState(() => _quantity--);
                              },
                            ),
                            Text('$_quantity', style: Theme.of(context).textTheme.titleMedium),
                            IconButton(
                              icon: const Icon(Icons.add_circle_outline),
                              onPressed: () {
                                if (_quantity < product.stock) setState(() => _quantity++);
                              },
                            ),
                          ],
                        ),
                      ] else ...[
                        Container(
                          padding: const EdgeInsets.all(AppSpacing.md),
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.errorContainer.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Theme.of(context).colorScheme.errorContainer),
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.info_outline, color: Theme.of(context).colorScheme.error),
                              SizedBox(width: 8),
                              Text(
                                'Товар закончился',
                                style: TextStyle(
                                  color: Theme.of(context).colorScheme.error,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                      const SizedBox(height: AppSpacing.lg),
                      Builder(
                        builder: (context) {
                          int displayCount = product.reviewCount;
                          if (_reviews != null) {
                            displayCount = _reviews!.length;
                          }
                          return Row(
                            children: [
                              Text('Отзывы ($displayCount)', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
                              const Spacer(),
                              if (context.watch<AuthProvider>().isAuthenticated)
                                TextButton.icon(
                                  onPressed: () => _showAddReviewDialog(product.id),
                                  icon: const Icon(Icons.add_comment),
                                  label: const Text('Оставить отзыв'),
                                ),
                            ],
                          );
                        }
                      ),
                      const SizedBox(height: AppSpacing.md),
                      _buildReviewsSection(),
                      const SizedBox(height: 100), // padding for bottom button
                    ],
                  ),
                ),
              ),
            ],
          ),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceContainer,
                boxShadow: [
                  BoxShadow(color: Colors.black26, offset: Offset(0, -2), blurRadius: 4),
                ],
              ),
              child: SafeArea(
                child: PrimaryButton(
                  text: product.stock > 0 ? 'Добавить в корзину' : 'Нет в наличии',
                  onPressed: product.stock > 0
                      ? () {
                          final cartProvider = Provider.of<CartProvider>(context, listen: false);
                          for (int i = 0; i < _quantity; i++) {
                            cartProvider.addToCart(product);
                          }
                          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Добавлено в корзину')));
                          Navigator.pop(context);
                        }
                      : null,

                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
