import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/providers.dart';
import '../../../core/widgets/shimmer_loading.dart';
import '../../article_detail/presentation/article_detail_screen.dart';
import '../../news/domain/article.dart';
import '../../news/presentation/article_card.dart';

final favoritesListProvider =
    FutureProvider.autoDispose<List<Article>>((ref) async {
  final repo = ref.watch(favoriteRepositoryProvider);
  return repo.getFavorites();
});

class FavoritesScreen extends ConsumerWidget {
  final VoidCallback? onExplore;

  const FavoritesScreen({super.key, this.onExplore});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final favoritesAsync = ref.watch(favoritesListProvider);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return favoritesAsync.when(
      loading: () => ListView.builder(
        itemCount: 3,
        padding: const EdgeInsets.only(top: 16),
        itemBuilder: (context, index) => const ArticleCardSkeleton(),
      ),
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
              FilledButton(
                onPressed: () => ref.refresh(favoritesListProvider),
                child: const Text('Réessayer'),
              ),
            ],
          ),
        ),
      ),
      data: (favorites) {
        if (favorites.isEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(32.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.redAccent.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.favorite_border_rounded,
                      size: 56,
                      color: Colors.redAccent,
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Aucun article favori',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Enregistrez vos articles préférés pour les retrouver rapidement même hors ligne.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14,
                      color: isDark ? Colors.white60 : Colors.black54,
                    ),
                  ),
                  const SizedBox(height: 24),
                  if (onExplore != null)
                    FilledButton.icon(
                      onPressed: onExplore,
                      icon: const Icon(Icons.explore_outlined),
                      label: const Text('Explorer les actualités'),
                    ),
                ],
              ),
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: () async => ref.refresh(favoritesListProvider),
          child: CustomScrollView(
            slivers: [
              // Header summary
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
                  child: Row(
                    children: [
                      Text(
                        'Articles sauvegardés',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: isDark ? Colors.white70 : Colors.black87,
                        ),
                      ),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: theme.primaryColor.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          '${favorites.length}',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: theme.primaryColor,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Favorites list with Dismissible for quick removal
              SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final article = favorites[index];
                    return Dismissible(
                      key: Key('fav-${article.id}'),
                      direction: DismissDirection.endToStart,
                      background: Container(
                        margin: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.red.shade600,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        alignment: Alignment.centerRight,
                        padding: const EdgeInsets.only(right: 20),
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Icon(Icons.delete_outline,
                                color: Colors.white, size: 24),
                            SizedBox(width: 8),
                            Text(
                              'Supprimer',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ),
                      onDismissed: (_) async {
                        final repo = ref.read(favoriteRepositoryProvider);
                        await repo.removeFavorite(article.id);
                        ref.invalidate(isFavoriteProvider(article.id));
                        ref.invalidate(favoritesListProvider);

                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('"${article.title}" retiré des favoris'),
                              action: SnackBarAction(
                                label: 'Annuler',
                                onPressed: () async {
                                  await repo.addFavorite(article.id);
                                  ref.invalidate(isFavoriteProvider(article.id));
                                  ref.invalidate(favoritesListProvider);
                                },
                              ),
                            ),
                          );
                        }
                      },
                      child: ArticleCard(
                        article: article,
                        onTap: () async {
                          await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) =>
                                  ArticleDetailScreen(articleId: article.id),
                            ),
                          );
                          ref.invalidate(favoritesListProvider);
                        },
                      ),
                    );
                  },
                  childCount: favorites.length,
                ),
              ),

              const SliverToBoxAdapter(
                child: SizedBox(height: 24),
              ),
            ],
          ),
        );
      },
    );
  }
}
