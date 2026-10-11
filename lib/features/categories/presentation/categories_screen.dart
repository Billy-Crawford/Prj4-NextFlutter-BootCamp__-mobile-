import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/providers.dart';
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

  @override
  Widget build(BuildContext context) {
    final categoriesAsync = ref.watch(categoriesProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Catégories'),
      ),
      body: categoriesAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(child: Text('Erreur: ${err.toString()}')),
        data: (categories) {
          if (categories.isEmpty) {
            return const Center(child: Text('Aucune catégorie disponible.'));
          }

          // Initialisation de la catégorie sélectionnée par défaut
          _selectedCategoryId ??= categories.first.id;

          final categoryNewsAsync =
              ref.watch(categoryNewsProvider(_selectedCategoryId!));

          return Column(
            children: [
              SizedBox(
                height: 54,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  itemCount: categories.length,
                  separatorBuilder: (context, index) => const SizedBox(width: 8),
                  itemBuilder: (context, index) {
                    final cat = categories[index];
                    final isSelected = cat.id == _selectedCategoryId;

                    return ChoiceChip(
                      label: Text(cat.name),
                      selected: isSelected,
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
              Expanded(
                child: categoryNewsAsync.when(
                  loading: () => const Center(child: CircularProgressIndicator()),
                  error: (err, _) => Center(child: Text('Erreur: ${err.toString()}')),
                  data: (result) {
                    if (result.articles.isEmpty) {
                      return const Center(
                        child: Text(
                          'Aucun article dans cette catégorie pour le moment.',
                          style: TextStyle(color: Colors.grey),
                        ),
                      );
                    }

                    return Column(
                      children: [
                        if (result.isFromCache)
                          Container(
                            width: double.infinity,
                            color: Colors.amber.shade100,
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                            child: Row(
                              children: [
                                Icon(Icons.offline_bolt, size: 16, color: Colors.amber.shade900),
                                const SizedBox(width: 8),
                                Text(
                                  'Données affichées depuis le cache local',
                                  style: TextStyle(fontSize: 12, color: Colors.amber.shade900),
                                ),
                              ],
                            ),
                          ),
                        Expanded(
                          child: ListView.builder(
                            itemCount: result.articles.length,
                            itemBuilder: (context, index) {
                              final article = result.articles[index];
                              return ArticleCard(
                                article: article,
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => ArticleDetailScreen(articleId: article.id),
                                    ),
                                  );
                                },
                              );
                            },
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
