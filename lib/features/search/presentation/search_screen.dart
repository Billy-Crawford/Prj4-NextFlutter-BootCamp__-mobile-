import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/providers.dart';
import '../../../core/widgets/shimmer_loading.dart';
import '../../article_detail/presentation/article_detail_screen.dart';
import '../../news/domain/article.dart';
import '../../news/presentation/article_card.dart';

final searchResultsProvider =
    FutureProvider.family.autoDispose<List<Article>, String>((ref, query) async {
  if (query.trim().isEmpty) return [];
  final repo = ref.watch(newsRepositoryProvider);
  return repo.searchArticles(query.trim());
});

class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({super.key});

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  final _searchController = TextEditingController();
  String _activeQuery = '';

  final List<String> _suggestedTopics = const [
    'Intelligence Artificielle',
    'Flutter',
    'Économie',
    'Technologie',
    'Innovation',
    'Cloud',
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _submitSearch(String query) {
    final text = query.trim();
    if (text.isNotEmpty) {
      _searchController.text = text;
      setState(() {
        _activeQuery = text;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final searchAsync = _activeQuery.isEmpty
        ? null
        : ref.watch(searchResultsProvider(_activeQuery));
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Column(
      children: [
        // Search Input Bar
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
          child: TextField(
            controller: _searchController,
            textInputAction: TextInputAction.search,
            onSubmitted: _submitSearch,
            decoration: InputDecoration(
              hintText: 'Rechercher un sujet ou mot-clé...',
              prefixIcon: const Icon(Icons.search_rounded),
              suffixIcon: _searchController.text.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear_rounded),
                      onPressed: () {
                        _searchController.clear();
                        setState(() {
                          _activeQuery = '';
                        });
                      },
                    )
                  : null,
            ),
          ),
        ),

        // Suggested Topics Row
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
          child: SizedBox(
            height: 38,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: _suggestedTopics.length,
              separatorBuilder: (context, index) => const SizedBox(width: 8),
              itemBuilder: (context, index) {
                final topic = _suggestedTopics[index];
                final isSelected = _activeQuery.toLowerCase() == topic.toLowerCase();

                return ActionChip(
                  label: Text(
                    topic,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      color: isSelected
                          ? Colors.white
                          : (isDark ? Colors.white70 : Colors.black87),
                    ),
                  ),
                  backgroundColor: isSelected ? theme.primaryColor : null,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  onPressed: () => _submitSearch(topic),
                );
              },
            ),
          ),
        ),
        const SizedBox(height: 6),

        // Search Results Body
        Expanded(
          child: _activeQuery.isEmpty
              ? Center(
                  child: SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsets.all(32.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.manage_search_rounded,
                            size: 68,
                            color: isDark ? Colors.white24 : Colors.black12,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Explorez des milliers d\'actualités',
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Entrez un mot-clé ou choisissez une suggestion ci-dessus pour lancer votre recherche.',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 13,
                              color: isDark ? Colors.white54 : Colors.black54,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                )
              : searchAsync!.when(
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
                          Text('Erreur: ${err.toString()}',
                              textAlign: TextAlign.center),
                          const SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: () => ref.refresh(
                                searchResultsProvider(_activeQuery)),
                            child: const Text('Réessayer'),
                          ),
                        ],
                      ),
                    ),
                  ),
                  data: (articles) {
                    if (articles.isEmpty) {
                      return Center(
                        child: Padding(
                          padding: const EdgeInsets.all(32.0),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.search_off_rounded,
                                  size: 64, color: Colors.grey.shade400),
                              const SizedBox(height: 16),
                              Text(
                                'Aucun résultat pour "$_activeQuery"',
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 8),
                              const Text(
                                'Essayez avec un autre terme ou vérifiez l\'orthographe.',
                                textAlign: TextAlign.center,
                                style: TextStyle(color: Colors.grey),
                              ),
                            ],
                          ),
                        ),
                      );
                    }

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.fromLTRB(18, 8, 18, 4),
                          child: Text(
                            '${articles.length} résultat${articles.length > 1 ? 's' : ''} trouvé${articles.length > 1 ? 's' : ''}',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: isDark ? Colors.white60 : Colors.black54,
                            ),
                          ),
                        ),
                        Expanded(
                          child: ListView.builder(
                            itemCount: articles.length,
                            itemBuilder: (context, index) {
                              final article = articles[index];
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
                        ),
                      ],
                    );
                  },
                ),
        ),
      ],
    );
  }
}
