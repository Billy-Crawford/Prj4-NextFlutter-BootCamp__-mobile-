import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/providers.dart';
import '../../../core/widgets/shimmer_loading.dart';
import '../../article_detail/presentation/article_detail_screen.dart';
import '../../categories/domain/category.dart';
import '../../news/domain/news_repository.dart';
import '../../news/presentation/article_card.dart';

final categoriesProvider = FutureProvider.autoDispose<List<Category>>((ref) async {
  final repo = ref.watch(categoryRepositoryProvider);
  return repo.getCategories();
});

final categoryNewsProvider =
    FutureProvider.family.autoDispose<NewsResult, String>((ref, categoryId) async {
  final repo = ref.watch(newsRepositoryProvider);
  return repo.getNews(categoryId: categoryId);
});

class CategoriesScreen extends ConsumerStatefulWidget {
  const CategoriesScreen({super.key});

  @override
  ConsumerState<CategoriesScreen> createState() => _CategoriesScreenState();
}

class _CategoriesScreenState extends ConsumerState<CategoriesScreen> {
  String? _selectedCategoryId;

  IconData _getCategoryIcon(String catId) {
    switch (catId.toLowerCase()) {
      case 'business':
        return Icons.trending_up_rounded;
      case 'technology':
        return Icons.memory_rounded;
      case 'science':
        return Icons.biotech_rounded;
      case 'health':
        return Icons.health_and_safety_rounded;
      case 'sports':
        return Icons.sports_basketball_rounded;
      case 'entertainment':
        return Icons.theaters_rounded;
      default:
        return Icons.newspaper_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    final categoriesAsync = ref.watch(categoriesProvider);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return categoriesAsync.when(
      loading: () => ListView.builder(
        itemCount: 4,
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
                onPressed: () => ref.refresh(categoriesProvider),
                child: const Text('Réessayer'),
              ),
            ],
          ),
        ),
      ),
      data: (categories) {
        if (categories.isEmpty) {
          return const Center(child: Text('Aucune catégorie disponible.'));
        }

        _selectedCategoryId ??= categories.first.id;
        final categoryNewsAsync =
            ref.watch(categoryNewsProvider(_selectedCategoryId!));

        return Column(
          children: [
            // Horizontal Categories Selector
            Container(
              height: 56,
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: categories.length,
                separatorBuilder: (context, index) => const SizedBox(width: 8),
                itemBuilder: (context, index) {
                  final cat = categories[index];
                  final isSelected = cat.id == _selectedCategoryId;

                  return FilterChip(
                    avatar: Icon(
                      _getCategoryIcon(cat.id),
                      size: 16,
                      color: isSelected
                          ? Colors.white
                          : (isDark ? Colors.white70 : Colors.black87),
                    ),
                    label: Text(cat.name),
                    selected: isSelected,
                    showCheckmark: false,
                    selectedColor: theme.primaryColor,
                    labelStyle: TextStyle(
                      color: isSelected
                          ? Colors.white
                          : (isDark ? Colors.white70 : Colors.black87),
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                      fontSize: 13,
                    ),
                    onSelected: (selected) {
                      if (selected) {
                        setState(() {
                          _selectedCategoryId = cat.id;
                        });
                      }
                    },
                  );
                },
              ),
            ),
            const Divider(height: 1),

            // Articles in Selected Category
            Expanded(
              child: categoryNewsAsync.when(
                loading: () => ListView.builder(
                  itemCount: 3,
                  padding: const EdgeInsets.only(top: 8),
                  itemBuilder: (context, index) => const ArticleCardSkeleton(),
                ),
                error: (err, _) => Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.error_outline,
                            size: 48, color: Colors.redAccent),
                        const SizedBox(height: 12),
                        Text('Erreur: ${err.toString()}'),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: () => ref.refresh(
                              categoryNewsProvider(_selectedCategoryId!)),
                          child: const Text('Réessayer'),
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
                            Icon(Icons.folder_open_rounded,
                                size: 64, color: Colors.grey.shade400),
                            const SizedBox(height: 16),
                            const Text(
                              'Aucun article dans cette catégorie',
                              style: TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 8),
                            const Text(
                              'Consultez une autre rubrique.',
                              style: TextStyle(color: Colors.grey),
                            ),
                          ],
                        ),
                      ),
                    );
                  }

                  return RefreshIndicator(
                    onRefresh: () async => ref.refresh(
                        categoryNewsProvider(_selectedCategoryId!)),
                    child: ListView.builder(
                      itemCount: result.articles.length,
                      padding: const EdgeInsets.only(top: 8, bottom: 24),
                      itemBuilder: (context, index) {
                        final article = result.articles[index];
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
                    ),
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }
}
