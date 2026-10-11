import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/providers.dart';
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

class ArticleDetailScreen extends ConsumerWidget {
  final String articleId;

  const ArticleDetailScreen({super.key, required this.articleId});

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

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final articleAsync = ref.watch(articleDetailProvider(articleId));
    final favAsync = ref.watch(isFavoriteProvider(articleId));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Détail de l\'article'),
        actions: [
          favAsync.when(
            data: (isFav) => IconButton(
              icon: Icon(
                isFav ? Icons.favorite : Icons.favorite_border,
                color: isFav ? Colors.redAccent : null,
              ),
              tooltip: isFav ? 'Retirer des favoris' : 'Ajouter aux favoris',
              onPressed: () async {
                final favRepo = ref.read(favoriteRepositoryProvider);
                if (isFav) {
                  await favRepo.removeFavorite(articleId);
                } else {
                  await favRepo.addFavorite(articleId);
                }
                ref.invalidate(isFavoriteProvider(articleId));
              },
            ),
            loading: () => const SizedBox.shrink(),
            error: (e, st) => const SizedBox.shrink(),
          ),
        ],
      ),
      body: articleAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(child: Text('Erreur: ${err.toString()}')),
        data: (article) {
          String formattedDate = '';
          if (article.publishedAt != null) {
            try {
              final parsed = DateTime.parse(article.publishedAt!);
              formattedDate = DateFormat('dd/MM/yyyy à HH:mm').format(parsed);
            } catch (_) {
              formattedDate = article.publishedAt!;
            }
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (article.imageUrl != null && article.imageUrl!.isNotEmpty)
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.network(
                      article.imageUrl!,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      errorBuilder: (ctx, err, st) => const SizedBox.shrink(),
                    ),
                  ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Chip(
                      label: Text(
                        article.source,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                    const Spacer(),
                    if (formattedDate.isNotEmpty)
                      Text(
                        formattedDate,
                        style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
                      ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  article.title,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 16),
                Text(
                  article.description,
                  style: const TextStyle(
                    fontSize: 16,
                    fontStyle: FontStyle.italic,
                    color: Colors.black87,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  article.content,
                  style: const TextStyle(fontSize: 15, height: 1.6),
                ),
                const SizedBox(height: 32),
                if (article.url.isNotEmpty)
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      icon: const Icon(Icons.open_in_browser),
                      label: const Text('Consulter l\'article original'),
                      onPressed: () => _openUrl(context, article.url),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}
