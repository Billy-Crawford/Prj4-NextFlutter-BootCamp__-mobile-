import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'cache/local_database.dart';
import 'network/api_client.dart';
import '../features/categories/data/category_repository.dart';
import '../features/favorites/data/favorite_repository.dart';
import '../features/news/data/news_repository_impl.dart';
import '../features/news/domain/news_repository.dart';

// Core Providers
final localDatabaseProvider = Provider<LocalDatabase>((ref) {
  return LocalDatabase.instance;
});

final apiClientProvider = Provider<ApiClient>((ref) {
  return ApiClient();
});

// Repositories Providers
final newsRepositoryProvider = Provider<NewsRepository>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  final localDatabase = ref.watch(localDatabaseProvider);
  return NewsRepositoryImpl(apiClient: apiClient, localDatabase: localDatabase);
});

final categoryRepositoryProvider = Provider<CategoryRepository>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  final localDatabase = ref.watch(localDatabaseProvider);
  return CategoryRepository(apiClient: apiClient, localDatabase: localDatabase);
});

final favoriteRepositoryProvider = Provider<FavoriteRepository>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  final localDatabase = ref.watch(localDatabaseProvider);
  return FavoriteRepository(apiClient: apiClient, localDatabase: localDatabase);
});
