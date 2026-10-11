import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/providers.dart';
import '../../favorites/presentation/favorites_screen.dart';
import '../../news/domain/article.dart';

final articleDetailProvider =
    FutureProvider.family.autoDispose<Article, String>((ref, articleId) async {
  final repo = ref.watch(newsRepositoryProvider);
  return repo.getArticleDetail(articleId);
});

final isFavoriteProvider =
    FutureProvider.family.autoDispose<bool, String>((ref, articleId) async {
  final repo = ref.watch(favoriteRepositoryProvider);
  return repo.isFavorite(articleId);
});

class ArticleDetailScreen extends ConsumerStatefulWidget {
  final String articleId;

  const ArticleDetailScreen({super.key, required this.articleId});

  @override
  ConsumerState<ArticleDetailScreen> createState() => _ArticleDetailScreenState();
}

class _ArticleDetailScreenState extends ConsumerState<ArticleDetailScreen> {
  double _fontScale = 1.0;

  Future<void> _openUrl(BuildContext context, String urlStr) async {
    final uri = Uri.tryParse(urlStr);
    if (uri != null && await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Impossible d\'ouvrir le lien source.')),
        );
      }
    }
  }

  void _shareArticle(Article article) {
    Clipboard.setData(ClipboardData(text: '${article.title}\n\n${article.url}'));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Row(
          children: [
            Icon(Icons.check_circle, color: Colors.white, size: 20),
            SizedBox(width: 8),
            Text('Lien de l\'article copié dans le presse-papier !'),
          ],
        ),
        backgroundColor: Theme.of(context).primaryColor,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  int _calculateReadingTime(String content) {
    final words = content.trim().split(RegExp(r'\s+')).length;
    final minutes = (words / 150).ceil();
    return minutes < 1 ? 1 : minutes;
  }

  @override
  Widget build(BuildContext context) {
    final articleAsync = ref.watch(articleDetailProvider(widget.articleId));
    final favAsync = ref.watch(isFavoriteProvider(widget.articleId));
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Détail'),
        actions: [
          // Font size adjust
          IconButton(
            icon: const Icon(Icons.format_size),
            tooltip: 'Taille du texte',
            onPressed: () {
              setState(() {
                if (_fontScale >= 1.3) {
                  _fontScale = 0.9;
                } else {
                  _fontScale += 0.15;
                }
              });
            },
          ),
          // Share button
          articleAsync.maybeWhen(
            data: (article) => IconButton(
              icon: const Icon(Icons.share_outlined),
              tooltip: 'Partager',
              onPressed: () => _shareArticle(article),
            ),
            orElse: () => const SizedBox.shrink(),
          ),
          // Favorite button
          favAsync.maybeWhen(
            data: (isFav) => IconButton(
              icon: Icon(
                isFav ? Icons.favorite : Icons.favorite_border,
                color: isFav ? Colors.redAccent : null,
              ),
              tooltip: isFav ? 'Retirer des favoris' : 'Ajouter aux favoris',
              onPressed: () async {
                final favRepo = ref.read(favoriteRepositoryProvider);
                if (isFav) {
                  await favRepo.removeFavorite(widget.articleId);
                } else {
                  await favRepo.addFavorite(widget.articleId);
                }
                ref.invalidate(isFavoriteProvider(widget.articleId));
                ref.invalidate(favoritesListProvider);
              },
            ),
            orElse: () => const SizedBox.shrink(),
          ),
        ],
      ),
      body: articleAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, size: 48, color: Colors.redAccent),
                const SizedBox(height: 12),
                Text('Erreur: ${err.toString()}', textAlign: TextAlign.center),
                const SizedBox(height: 16),
                ElevatedButton.icon(
                  onPressed: () => ref.refresh(articleDetailProvider(widget.articleId)),
                  icon: const Icon(Icons.refresh),
                  label: const Text('Réessayer'),
                ),
              ],
            ),
          ),
        ),
        data: (article) {
          String formattedDate = '';
          if (article.publishedAt != null) {
            try {
              final parsed = DateTime.parse(article.publishedAt!);
              formattedDate = DateFormat('dd MMMM yyyy à HH:mm', 'fr_FR').format(parsed);
            } catch (_) {
              try {
                final parsed = DateTime.parse(article.publishedAt!);
                formattedDate = DateFormat('dd/MM/yyyy HH:mm').format(parsed);
              } catch (_) {
                formattedDate = article.publishedAt!;
              }
            }
          }

          final readingTime = _calculateReadingTime('${article.description} ${article.content}');

          return SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 18.0, vertical: 12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Source, category & reading time row
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: theme.primaryColor.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        article.source.isNotEmpty ? article.source : 'Actualité',
                        style: TextStyle(
                          color: theme.primaryColor,
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0xFF1E293B) : const Color(0xFFE2E8F0),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.schedule, size: 12, color: isDark ? Colors.white70 : Colors.black54),
                          const SizedBox(width: 4),
                          Text(
                            '$readingTime min de lecture',
                            style: TextStyle(
                              fontSize: 11,
                              color: isDark ? Colors.white70 : Colors.black87,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // Article Title
                Text(
                  article.title,
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w800,
                    height: 1.25,
                    letterSpacing: -0.5,
                    fontSize: (theme.textTheme.headlineSmall?.fontSize ?? 24) * _fontScale,
                  ),
                ),
                const SizedBox(height: 10),

                // Date
                if (formattedDate.isNotEmpty)
                  Row(
                    children: [
                      Icon(Icons.calendar_today_outlined, size: 14, color: isDark ? Colors.white60 : Colors.black45),
                      const SizedBox(width: 6),
                      Text(
                        formattedDate,
                        style: TextStyle(
                          color: isDark ? Colors.white60 : Colors.black54,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                const SizedBox(height: 16),

                // Hero Image
                if (article.imageUrl != null && article.imageUrl!.isNotEmpty)
                  ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: Hero(
                      tag: 'article-img-${article.id}',
                      child: Image.network(
                        article.imageUrl!,
                        width: double.infinity,
                        fit: BoxFit.cover,
                        errorBuilder: (ctx, err, st) => const SizedBox.shrink(),
                      ),
                    ),
                  ),
                const SizedBox(height: 20),

                // Standfirst / Description Quote Box
                if (article.description.isNotEmpty)
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF131D31) : const Color(0xFFF1F5F9),
                      borderRadius: BorderRadius.circular(14),
                      border: Border(
                        left: BorderSide(
                          color: theme.primaryColor,
                          width: 4,
                        ),
                      ),
                    ),
                    child: Text(
                      article.description,
                      style: TextStyle(
                        fontSize: 15 * _fontScale,
                        fontStyle: FontStyle.italic,
                        height: 1.5,
                        color: isDark ? const Color(0xFFE2E8F0) : const Color(0xFF334155),
                      ),
                    ),
                  ),
                const SizedBox(height: 20),

                // Full Content
                Text(
                  article.content,
                  style: TextStyle(
                    fontSize: 16 * _fontScale,
                    height: 1.7,
                    letterSpacing: 0.1,
                  ),
                ),
                const SizedBox(height: 36),

                // Bottom Action Button
                if (article.url.isNotEmpty)
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton.icon(
                      icon: const Icon(Icons.open_in_browser),
                      label: const Text('Lire l\'article complet à la source'),
                      style: FilledButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      onPressed: () => _openUrl(context, article.url),
                    ),
                  ),
                const SizedBox(height: 24),
              ],
            ),
          );
        },
      ),
    );
  }
}
