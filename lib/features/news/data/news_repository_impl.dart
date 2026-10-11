import 'package:sqflite/sqflite.dart';
import '../../../core/cache/local_database.dart';
import '../../../core/errors/exceptions.dart';
import '../../../core/network/api_client.dart';
import '../domain/article.dart';
import '../domain/news_repository.dart';

class NewsRepositoryImpl implements NewsRepository {
  final ApiClient apiClient;
  final LocalDatabase localDatabase;

  NewsRepositoryImpl({
    required this.apiClient,
    required this.localDatabase,
  });

  @override
  Future<NewsResult> getNews({String? categoryId, bool forceRefresh = false}) async {
    try {
      final endpoint = categoryId != null
          ? '/categories/$categoryId/news'
          : '/news';

      final response = await apiClient.dio.get(endpoint);

      if (response.statusCode == 200 && response.data['success'] == true) {
        final List rawList = categoryId != null
            ? (response.data['data']['articles'] ?? [])
            : (response.data['data']['articles'] ?? []);

        final articles = rawList.map((e) => Article.fromJson(e)).toList();

        // 1. Mise à jour du cache SQLite
        await _saveArticlesToCache(articles);

        return NewsResult(articles: articles, isFromCache: false);
      } else {
        throw NetworkException('Échec de la récupération des actualités');
      }
    } catch (e) {
      // 2. Repli vers le cache SQLite en cas d'échec réseau
      final cachedArticles = await _getCachedArticles(categoryId: categoryId);
      if (cachedArticles.isNotEmpty) {
        return NewsResult(articles: cachedArticles, isFromCache: true);
      }

      // Si le cache est vide, on propage une erreur exploitable
      throw NetworkException(
        'Impossible de contacter le serveur et aucune donnée hors ligne disponible.',
        originalError: e,
      );
    }
  }

  @override
  Future<Article> getArticleDetail(String articleId) async {
    try {
      final response = await apiClient.dio.get('/news/$articleId');
      if (response.statusCode == 200 && response.data['success'] == true) {
        final article = Article.fromJson(response.data['data']);
        await _saveArticlesToCache([article]);
        return article;
      }
      throw NotFoundException('Article introuvable');
    } catch (e) {
      // Essai de lecture dans le cache SQLite
      final cached = await _getCachedArticleById(articleId);
      if (cached != null) {
        return cached;
      }
      throw NetworkException(
        'Article introuvable hors ligne.',
        originalError: e,
      );
    }
  }

  @override
  Future<List<Article>> searchArticles(String query) async {
    try {
      final response = await apiClient.dio.get('/search', queryParameters: {'q': query});
      if (response.statusCode == 200 && response.data['success'] == true) {
        final List rawList = response.data['data']['results'] ?? [];
        final results = rawList.map((e) => Article.fromJson(e)).toList();
        await _saveArticlesToCache(results);
        return results;
      }
      return [];
    } catch (e) {
      // Recherche locale dans le cache SQLite
      return await _searchCachedArticles(query);
    }
  }

  // --- SQLite Cache Operations ---

  Future<void> _saveArticlesToCache(List<Article> articles) async {
    try {
      final db = await localDatabase.database;
      final batch = db.batch();
      final now = DateTime.now().millisecondsSinceEpoch;

      for (final a in articles) {
        batch.insert(
          'articles',
          {
            ...a.toMap(),
            'cached_at': now,
          },
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
      }
      await batch.commit(noResult: true);
    } catch (_) {
      // Silent error on cache write failure to not block UI
    }
  }

  Future<List<Article>> _getCachedArticles({String? categoryId}) async {
    try {
      final db = await localDatabase.database;
      final List<Map<String, dynamic>> maps = categoryId != null
          ? await db.query('articles', where: 'category_id = ?', whereArgs: [categoryId])
          : await db.query('articles', orderBy: 'published_at DESC');

      return maps.map((e) => Article.fromJson(e)).toList();
    } catch (_) {
      return [];
    }
  }

  Future<Article?> _getCachedArticleById(String articleId) async {
    try {
      final db = await localDatabase.database;
      final List<Map<String, dynamic>> maps = await db.query(
        'articles',
        where: 'id = ?',
        whereArgs: [articleId],
        limit: 1,
      );
      if (maps.isNotEmpty) {
        return Article.fromJson(maps.first);
      }
    } catch (_) {}
    return null;
  }

  Future<List<Article>> _searchCachedArticles(String query) async {
    try {
      final db = await localDatabase.database;
      final pattern = '%${query.toLowerCase()}%';
      final List<Map<String, dynamic>> maps = await db.rawQuery('''
        SELECT * FROM articles
        WHERE LOWER(title) LIKE ? OR LOWER(description) LIKE ? OR LOWER(content) LIKE ?
      ''', [pattern, pattern, pattern]);

      return maps.map((e) => Article.fromJson(e)).toList();
    } catch (_) {
      return [];
    }
  }
}
