import '../domain/article.dart';

abstract class NewsRepository {
  /// Fetches articles from remote API or local SQLite cache on failure
  /// [forceRefresh] bypasses reading cache first
  Future<NewsResult> getNews({String? categoryId, bool forceRefresh = false});

  /// Fetches a single article detail
  Future<Article> getArticleDetail(String articleId);

  /// Searches articles with given query
  Future<List<Article>> searchArticles(String query);
}

class NewsResult {
  final List<Article> articles;
  final bool isFromCache;

  const NewsResult({
    required this.articles,
    this.isFromCache = false,
  });
}
