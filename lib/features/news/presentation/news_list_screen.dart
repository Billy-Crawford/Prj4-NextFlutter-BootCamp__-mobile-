import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/providers.dart';
import '../../../core/widgets/shimmer_loading.dart';
import '../../article_detail/presentation/article_detail_screen.dart';
import '../../categories/presentation/categories_screen.dart';
import '../domain/news_repository.dart';
import 'article_card.dart';

class SelectedFeedCategoryNotifier extends Notifier<String?> {
  @override
  String? build() => null;

  void select(String? id) {
    state = id;
  }
}

final selectedFeedCategoryProvider =
    NotifierProvider<SelectedFeedCategoryNotifier, String?>(
        SelectedFeedCategoryNotifier.new);

final feedNewsProvider = FutureProvider.autoDispose<NewsResult>((ref) async {
  final categoryId = ref.watch(selectedFeedCategoryProvider);
  final repository = ref.watch(newsRepositoryProvider);
  return repository.getNews(categoryId: categoryId);
});

class NewsListScreen extends ConsumerWidget {
  const NewsListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final newsAsync = ref.watch(feedNewsProvider);
    final categoriesAsync = ref.watch(categoriesProvider);
    final selectedCategory = ref.watch(selectedFeedCategoryProvider);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Column(
      children: [
        // Horizontal Category Filter Pills
        categoriesAsync.maybeWhen(
          data: (categories) => Container(
            height: 52,
            padding: const EdgeInsets.symmetric(vertical: 6),
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              children: [
                // "Tous" pill
                Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: FilterChip(
                    label: const Text('Toutes'),
                    selected: selectedCategory == null,
                    showCheckmark: false,
                    selectedColor: theme.primaryColor,
                    labelStyle: TextStyle(
                      color: selectedCategory == null
                          ? Colors.white
                          : (isDark ? Colors.white70 : Colors.black87),
                      fontWeight: selectedCategory == null
                          ? FontWeight.bold
                          : FontWeight.w500,
                      fontSize: 13,
                    ),
                    onSelected: (_) {
                      ref
                          .read(selectedFeedCategoryProvider.notifier)
                          .select(null);
                    },
                  ),
                ),
                ...categories.map(
                  (cat) => Padding(
                    padding: const EdgeInsets.only(right: 8.0),
                    child: FilterChip(
                      label: Text(cat.name),
                      selected: selectedCategory == cat.id,
                      showCheckmark: false,
                      selectedColor: theme.primaryColor,
                      labelStyle: TextStyle(
                        color: selectedCategory == cat.id
                            ? Colors.white
                            : (isDark ? Colors.white70 : Colors.black87),
                        fontWeight: selectedCategory == cat.id
                            ? FontWeight.bold
                            : FontWeight.w500,
                        fontSize: 13,
                      ),
                      onSelected: (selected) {
                        ref
                            .read(selectedFeedCategoryProvider.notifier)
                            .select(selected ? cat.id : null);
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
          orElse: () => const SizedBox.shrink(),
        ),

        // Main Feed Body
        Expanded(
          child: newsAsync.when(
            loading: () => ListView.builder(
              itemCount: 4,
              padding: const EdgeInsets.only(top: 8),
              itemBuilder: (context, index) => const ArticleCardSkeleton(),
            ),
            error: (err, _) => Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.wifi_off_rounded,
                        size: 52, color: Colors.redAccent),
                    const SizedBox(height: 14),
                    Text(
                      'Impossible de charger les actualités.',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      err.toString(),
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 13,
                        color: isDark ? Colors.white60 : Colors.black54,
                      ),
                    ),
                    const SizedBox(height: 18),
                    FilledButton.icon(
                      onPressed: () => ref.refresh(feedNewsProvider),
                      icon: const Icon(Icons.refresh),
                      label: const Text('Réessayer'),
                    ),
                  ],
                ),
              ),
            ),
            data: (result) {
              if (result.articles.isEmpty) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(32.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.feed_outlined,
                            size: 64, color: Colors.grey.shade400),
                        const SizedBox(height: 16),
                        const Text(
                          'Aucune actualité trouvée',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Tentez de sélectionner une autre catégorie ou rafraîchissez.',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.grey.shade600),
                        ),
                      ],
                    ),
                  ),
                );
              }

              return RefreshIndicator(
                onRefresh: () async => ref.refresh(feedNewsProvider),
                child: CustomScrollView(
                  slivers: [
                    // Offline Notice Banner
                    if (result.isFromCache)
                      SliverToBoxAdapter(
                        child: Container(
                          margin: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 8),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 8),
                          decoration: BoxDecoration(
                            color: Colors.amber.shade500.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                                color: Colors.amber.shade600, width: 1),
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.offline_bolt_rounded,
                                  size: 18, color: Colors.amber.shade800),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  'Mode hors ligne : articles issus du cache SQLite local.',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: isDark
                                        ? Colors.amber.shade200
                                        : Colors.amber.shade900,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                    // First item as "Featured Headline"
                    SliverToBoxAdapter(
                      child: ArticleCard(
                        article: result.articles.first,
                        isFeatured: true,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => ArticleDetailScreen(
                                articleId: result.articles.first.id,
                              ),
                            ),
                          );
                        },
                      ),
                    ),

                    // Section Divider
                    if (result.articles.length > 1)
                      SliverToBoxAdapter(
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(18, 12, 18, 4),
                          child: Row(
                            children: [
                              const Text(
                                'Dernières parutions',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: -0.3,
                                ),
                              ),
                              const Spacer(),
                              Text(
                                '${result.articles.length} articles',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: isDark ? Colors.white54 : Colors.black45,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                    // Remaining Articles List
                    SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          final article = result.articles[index + 1];
                          return ArticleCard(
                            article: article,
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => ArticleDetailScreen(
                                    articleId: article.id,
                                  ),
                                ),
                              );
                            },
                          );
                        },
                        childCount: result.articles.length - 1,
                      ),
                    ),

                    const SliverToBoxAdapter(
                      child: SizedBox(height: 24),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
