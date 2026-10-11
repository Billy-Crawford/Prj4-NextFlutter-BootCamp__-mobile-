import '../../../core/cache/local_database.dart';
import '../../../core/network/api_client.dart';
import '../../categories/domain/category.dart';

class CategoryRepository {
  final ApiClient apiClient;
  final LocalDatabase localDatabase;

  CategoryRepository({
    required this.apiClient,
    required this.localDatabase,
  });

  Future<List<Category>> getCategories() async {
    try {
      final response = await apiClient.dio.get('/categories');
      if (response.statusCode == 200 && response.data['success'] == true) {
        final List list = response.data['data']['categories'] ?? [];
        final categories = list.map((e) => Category.fromJson(e)).toList();

        // Cache categories locally
        final db = await localDatabase.database;
        final batch = db.batch();
        for (var c in categories) {
          batch.insert('categories', c.toMap());
        }
        await batch.commit(noResult: true);

        return categories;
      }
      return [];
    } catch (e) {
      // Read from local cache
      try {
        final db = await localDatabase.database;
        final maps = await db.query('categories');
        return maps.map((e) => Category.fromJson(e)).toList();
      } catch (_) {
        return [];
      }
    }
  }
}
