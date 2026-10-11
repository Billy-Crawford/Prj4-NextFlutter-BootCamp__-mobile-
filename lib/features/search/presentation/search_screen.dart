import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/providers.dart';
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

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onSearch() {
    final text = _searchController.text.trim();
    if (text.isNotEmpty) {
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

    return Scaffold(
      appBar: AppBar(
        title: const Text('Rechercher'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    textInputAction: TextInputAction.search,
                    onSubmitted: (_) => _onSearch(),
                    decoration: InputDecoration(
                      hintText: 'Rechercher par mot-clé (ex: Flutter, IA)...',
                      prefixIcon: const Icon(Icons.search),
                      suffixIcon: _searchController.text.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear),
                              onPressed: () {
                                _searchController.clear();
                                setState(() {
                                  _activeQuery = '';
                                });
                              },
                            )
                          : null,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: _onSearch,
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  ),
                  child: const Text('OK'),
                ),
              ],
            ),
          ),
          Expanded(
            child: _activeQuery.isEmpty
                ? const Center(
                    child: Text(
                      'Saisissez un terme pour lancer la recherche.',
                      style: TextStyle(color: Colors.grey),
                    ),
                  )
                : searchAsync!.when(
                    loading: () => const Center(child: CircularProgressIndicator()),
                    error: (err, _) => Center(
                      child: Text('Erreur: ${err.toString()}'),
                    ),
                    data: (articles) {
                      if (articles.isEmpty) {
                        return Center(
                          child: Text(
                            'Aucun résultat trouvé pour "$_activeQuery".',
                            style: const TextStyle(color: Colors.grey),
                          ),
                        );
                      }
                      return ListView.builder(
                        itemCount: articles.length,
                        itemBuilder: (context, index) {
                          final article = articles[index];
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
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
