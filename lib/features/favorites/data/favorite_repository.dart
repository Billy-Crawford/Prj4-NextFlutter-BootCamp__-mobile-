import 'package:firebase_auth/firebase_auth.dart';
import '../../../core/cache/local_database.dart';
import '../../../core/network/api_client.dart';
import '../../news/domain/article.dart';

class FavoriteRepository {
  final ApiClient apiClient;
  final LocalDatabase localDatabase;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  FavoriteRepository({
    required this.apiClient,
    required this.localDatabase,
  });

  String? get currentUserId => _auth.currentUser?.uid;

  Future<List<Article>> getFavorites() async {
    final uid = currentUserId;
    if (uid == null) return [];

    try {
      final response = await apiClient.dio.get('/favorites');
      if (response.statusCode == 200 && response.data['success'] == true) {
        final List list = response.data['data']['favorites'] ?? [];
        final articles = list.map((e) => Article.fromJson(e)).toList();

        // Update local user-isolated favorites cache
        final db = await localDatabase.database;
        await db.delete('favorites', where: 'user_id = ?', whereArgs: [uid]);
        final batch = db.batch();
        for (var a in articles) {
          batch.insert('favorites', {
            'user_id': uid,
            'article_id': a.id,
            'created_at': DateTime.now().toIso8601String(),
          });
          // Also save article details locally
          batch.insert('articles', {
            ...a.toMap(),
            'cached_at': DateTime.now().millisecondsSinceEpoch,
          });
        }
        await batch.commit(noResult: true);

        return articles;
      }
      return [];
    } catch (e) {
      // Read user favorites from local cache on network error
      try {
        final db = await localDatabase.database;
        final favRows = await db.query(
          'favorites',
          where: 'user_id = ?',
          whereArgs: [uid],
        );
        final articleIds = favRows.map((r) => r['article_id'] as String).toList();
        if (articleIds.isEmpty) return [];

        final placeholders = List.filled(articleIds.length, '?').join(',');
        final articleRows = await db.rawQuery(
          'SELECT * FROM articles WHERE id IN ($placeholders)',
          articleIds,
        );
        return articleRows.map((e) => Article.fromJson(e)).toList();
      } catch (_) {
        return [];
      }
    }
  }

  Future<bool> addFavorite(String articleId) async {
    final uid = currentUserId;
    if (uid == null) return false;

    try {
      final response = await apiClient.dio.post(
        '/favorites',
        data: {'article_id': articleId},
      );
      if (response.statusCode == 201 || response.statusCode == 200) {
        final db = await localDatabase.database;
        await db.insert('favorites', {
          'user_id': uid,
          'article_id': articleId,
          'created_at': DateTime.now().toIso8601String(),
        });
        return true;
      }
    } catch (_) {}
    return false;
  }

  Future<bool> removeFavorite(String articleId) async {
    final uid = currentUserId;
    if (uid == null) return false;

    try {
      final response = await apiClient.dio.delete('/favorites/$articleId');
      if (response.statusCode == 200) {
        final db = await localDatabase.database;
        await db.delete(
          'favorites',
          where: 'user_id = ? AND article_id = ?',
          whereArgs: [uid, articleId],
        );
        return true;
      }
    } catch (_) {}
    return false;
  }

  Future<bool> isFavorite(String articleId) async {
    final uid = currentUserId;
    if (uid == null) return false;

    try {
      final db = await localDatabase.database;
      final rows = await db.query(
        'favorites',
        where: 'user_id = ? AND article_id = ?',
        whereArgs: [uid, articleId],
      );
      return rows.isNotEmpty;
    } catch (_) {
      return false;
    }
  }
}
