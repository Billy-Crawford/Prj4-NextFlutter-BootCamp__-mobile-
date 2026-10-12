import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../core/providers.dart';
import '../../article_detail/presentation/article_detail_screen.dart';
import '../../favorites/presentation/favorites_screen.dart';
import '../domain/article.dart';

class ArticleCard extends ConsumerWidget {
  final Article article;
  final VoidCallback onTap;
  final bool isFeatured;

  const ArticleCard({
    super.key,
    required this.article,
    required this.onTap,
    this.isFeatured = false,
  });

  String _formatDate(String? dateStr) {
    if (dateStr == null || dateStr.isEmpty) return '';
    try {
      final parsed = DateTime.parse(dateStr);
      final now = DateTime.now();
      final diff = now.difference(parsed);

      if (diff.inMinutes < 60) {
        return 'Il y a ${diff.inMinutes.clamp(1, 60)} min';
      } else if (diff.inHours < 24) {
        return 'Il y a ${diff.inHours} h';
      } else if (diff.inDays < 7) {
        return 'Il y a ${diff.inDays} j';
      }
      return DateFormat('dd MMM yyyy', 'fr_FR').format(parsed);
    } catch (_) {
      try {
        final parsed = DateTime.parse(dateStr);
        return DateFormat('dd/MM/yyyy').format(parsed);
      } catch (_) {
        return dateStr;
      }
    }
  }

  int _calculateReadingTime(String content) {
    final words = content.trim().split(RegExp(r'\s+')).length;
    final minutes = (words / 150).ceil();
    return minutes < 1 ? 1 : minutes;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isFavAsync = ref.watch(isFavoriteProvider(article.id));
    final readingTime = _calculateReadingTime('${article.description} ${article.content}');
    final formattedDate = _formatDate(article.publishedAt);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Card(
      margin: EdgeInsets.symmetric(
        horizontal: 16,
        vertical: isFeatured ? 10 : 7,
      ),
      elevation: isFeatured ? 3 : 0,
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image header with Hero transition
            if (article.imageUrl != null && article.imageUrl!.isNotEmpty)
              Stack(
                children: [
                  Hero(
                    tag: 'article-img-${article.id}',
                    child: AspectRatio(
                      aspectRatio: isFeatured ? 16 / 9 : 16 / 8.5,
                      child: Image.network(
                        article.imageUrl!,
                        fit: BoxFit.cover,
                        cacheWidth: isFeatured ? 1080 : 720,
                        loadingBuilder: (context, child, loadingProgress) {
                          if (loadingProgress == null) return child;
                          return Container(
                            color: isDark ? const Color(0xFF1E293B) : const Color(0xFFE2E8F0),
                            child: const Center(
                              child: SizedBox(
                                width: 24,
                                height: 24,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              ),
                            ),
                          );
                        },
                        errorBuilder: (ctx, error, stackTrace) => Container(
                          color: isDark ? const Color(0xFF1E293B) : const Color(0xFFF1F5F9),
                          child: Center(
                            child: Icon(
                              Icons.image_not_supported_outlined,
                              size: 44,
                              color: isDark ? Colors.white30 : Colors.black26,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  // Source pill on image
                  Positioned(
                    top: 12,
                    left: 12,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.65),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Colors.white24, width: 0.8),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.circle, size: 7, color: Color(0xFF38BDF8)),
                          const SizedBox(width: 5),
                          Text(
                            article.source.isNotEmpty ? article.source : 'Actualité',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  // Reading time pill
                  Positioned(
                    bottom: 12,
                    right: 12,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.65),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.schedule, size: 12, color: Colors.white70),
                          const SizedBox(width: 4),
                          Text(
                            '$readingTime min',
                            style: const TextStyle(color: Colors.white, fontSize: 11),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),

            // Text Content & Actions
            Padding(
              padding: const EdgeInsets.all(14.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Date & Quick Actions row
                  Row(
                    children: [
                      if (article.imageUrl == null || article.imageUrl!.isEmpty) ...[
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: theme.primaryColor.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            article.source.isNotEmpty ? article.source : 'Actualité',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: theme.primaryColor,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                      ],
                      if (formattedDate.isNotEmpty)
                        Text(
                          formattedDate,
                          style: TextStyle(
                            fontSize: 12,
                            color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      const Spacer(),
                      // Favorite button
                      isFavAsync.maybeWhen(
                        data: (isFav) => Semantics(
                          button: true,
                          label: isFav ? 'Retirer des favoris' : 'Ajouter aux favoris',
                          child: InkWell(
                            borderRadius: BorderRadius.circular(20),
                            onTap: () async {
                              final favRepo = ref.read(favoriteRepositoryProvider);
                              if (isFav) {
                                await favRepo.removeFavorite(article.id);
                              } else {
                                await favRepo.addFavorite(article.id);
                              }
                              ref.invalidate(isFavoriteProvider(article.id));
                              ref.invalidate(favoritesListProvider);
                            },
                            child: Padding(
                              padding: const EdgeInsets.all(4.0),
                              child: Icon(
                                isFav ? Icons.favorite : Icons.favorite_border,
                                size: 20,
                                color: isFav ? Colors.redAccent : (isDark ? Colors.white60 : Colors.black45),
                              ),
                            ),
                          ),
                        ),
                        orElse: () => const SizedBox.shrink(),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),

                  // Title
                  Text(
                    article.title,
                    style: TextStyle(
                      fontSize: isFeatured ? 18 : 16,
                      fontWeight: FontWeight.bold,
                      height: 1.3,
                      letterSpacing: -0.3,
                    ),
                    maxLines: isFeatured ? 3 : 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 6),

                  // Description
                  if (article.description.isNotEmpty)
                    Text(
                      article.description,
                      style: TextStyle(
                        fontSize: 13,
                        color: isDark ? const Color(0xFFCBD5E1) : const Color(0xFF475569),
                        height: 1.4,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
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
