import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:news_app/core/cache/local_database.dart';
import 'package:news_app/core/errors/exceptions.dart';
import 'package:news_app/core/network/api_client.dart';
import 'package:news_app/core/providers/locale_provider.dart';
import 'package:news_app/core/theme/app_theme.dart';
import 'package:news_app/features/categories/data/category_repository.dart';
import 'package:news_app/features/categories/domain/category.dart';
import 'package:news_app/features/news/data/news_repository_impl.dart';
import 'package:news_app/features/news/domain/article.dart';
import 'package:sqflite/sqflite.dart';

// Fakes / Mocks
class FakeApiClient extends Fake implements ApiClient {
  @override
  final Dio dio;
  FakeApiClient(this.dio);
}

class FakeLocalDatabase extends Fake implements LocalDatabase {
  final Database _db;
  FakeLocalDatabase(this._db);

  @override
  Future<Database> get database async => _db;
}

class FakeDatabase extends Fake implements Database {
  List<Map<String, dynamic>> storedArticles = [];
  List<Map<String, dynamic>> storedCategories = [];

  @override
  Batch batch() => FakeBatch(this);

  @override
  Future<List<Map<String, dynamic>>> query(
    String table, {
    bool? distinct,
    List<String>? columns,
    String? where,
    List<Object?>? whereArgs,
    String? groupBy,
    String? having,
    String? orderBy,
    int? limit,
    int? offset,
  }) async {
    if (table == 'categories') {
      return storedCategories;
    }
    if (where != null && whereArgs != null && whereArgs.isNotEmpty) {
      final categoryId = whereArgs.first as String;
      return storedArticles.where((a) => a['category_id'] == categoryId).toList();
    }
    return storedArticles;
  }
}

class FakeBatch extends Fake implements Batch {
  final FakeDatabase db;
  FakeBatch(this.db);

  @override
  void insert(String table, Map<String, Object?> values,
      {String? nullColumnHack, ConflictAlgorithm? conflictAlgorithm}) {
    if (table == 'categories') {
      db.storedCategories.add(Map<String, dynamic>.from(values));
    } else {
      db.storedArticles.add(Map<String, dynamic>.from(values));
    }
  }

  @override
  Future<List<Object?>> commit({
    bool? exclusive,
    bool? noResult,
    bool? continueOnError,
  }) async {
    return [];
  }
}

class MockDioAdapter implements HttpClientAdapter {
  ResponseBody? responseToReturn;
  DioException? errorToThrow;

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<List<int>>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    if (errorToThrow != null) {
      throw errorToThrow!;
    }
    return responseToReturn!;
  }

  @override
  void close({bool force = false}) {}
}

void main() {
  late MockDioAdapter mockAdapter;
  late Dio dio;
  late FakeDatabase fakeDb;
  late NewsRepositoryImpl newsRepository;
  late CategoryRepository categoryRepository;

  setUp(() {
    mockAdapter = MockDioAdapter();
    dio = Dio(BaseOptions())..httpClientAdapter = mockAdapter;
    fakeDb = FakeDatabase();

    newsRepository = NewsRepositoryImpl(
      apiClient: FakeApiClient(dio),
      localDatabase: FakeLocalDatabase(fakeDb),
    );

    categoryRepository = CategoryRepository(
      apiClient: FakeApiClient(dio),
      localDatabase: FakeLocalDatabase(fakeDb),
    );
  });

  group('Suite Complète Tests Unitaires (>= 10 tests)', () {
    final sampleArticleMap = {
      'id': 'art-unit-1',
      'title': 'Test Article Titre',
      'description': 'Description détaillée pour le test unitaire',
      'content': 'Contenu complet de l\'article pour la validation de modèle.',
      'source': 'Le Figaro',
      'url': 'https://example.com/art-1',
      'category_id': 'technology',
      'image_url': 'https://example.com/cover.jpg',
      'published_at': '2026-10-12T10:00:00Z',
    };

    // 1. Article Serialization: fromJson
    test('1. Article.fromJson instancie correctement un article complet', () {
      final article = Article.fromJson(sampleArticleMap);
      expect(article.id, 'art-unit-1');
      expect(article.title, 'Test Article Titre');
      expect(article.source, 'Le Figaro');
      expect(article.categoryId, 'technology');
    });

    // 2. Article Serialization: toMap
    test('2. Article.toMap produit une map fidèle compatible SQLite', () {
      final article = Article.fromJson(sampleArticleMap);
      final map = article.toMap();
      expect(map['id'], 'art-unit-1');
      expect(map['title'], 'Test Article Titre');
      expect(map['category_id'], 'technology');
    });

    // 3. Category Serialization: fromJson & toMap
    test('3. Category model gère fromJson et toMap correctement', () {
      final json = {'id': 'tech', 'name': 'Technologie', 'description': 'Actu high-tech'};
      final cat = Category.fromJson(json);
      expect(cat.id, 'tech');
      expect(cat.name, 'Technologie');

      final map = cat.toMap();
      expect(map['description'], 'Actu high-tech');
    });

    // 4. NewsRepository: Succès réseau avec alimentation du cache
    test('4. NewsRepository: succès réseau charge les données et alimente le cache', () async {
      mockAdapter.responseToReturn = ResponseBody.fromString(
        '{"success": true, "data": {"articles": [${_toJsonString(sampleArticleMap)}]}}',
        200,
        headers: {Headers.contentTypeHeader: [Headers.jsonContentType]},
      );

      final result = await newsRepository.getNews();
      expect(result.isFromCache, isFalse);
      expect(result.articles.length, 1);
      expect(result.articles.first.id, 'art-unit-1');
      expect(fakeDb.storedArticles.length, 1);
    });

    // 5. NewsRepository: Fallback cache hors-ligne
    test('5. NewsRepository: fallback sur cache local en cas de coupure réseau', () async {
      fakeDb.storedArticles.add(sampleArticleMap);
      mockAdapter.errorToThrow = DioException(
        requestOptions: RequestOptions(path: '/news'),
        type: DioExceptionType.connectionError,
      );

      final result = await newsRepository.getNews();
      expect(result.isFromCache, isTrue);
      expect(result.articles.length, 1);
      expect(result.articles.first.id, 'art-unit-1');
    });

    // 6. NewsRepository: Exception réseau explicite si cache vide
    test('6. NewsRepository: lève NetworkException si échec réseau et aucun cache', () async {
      fakeDb.storedArticles.clear();
      mockAdapter.errorToThrow = DioException(
        requestOptions: RequestOptions(path: '/news'),
        type: DioExceptionType.connectionTimeout,
      );

      expect(
        () async => await newsRepository.getNews(),
        throwsA(isA<NetworkException>()),
      );
    });

    // 7. NewsRepository: Filtrage d'articles par catégorie
    test('7. NewsRepository: getNews avec categoryId filtre avec succès', () async {
      mockAdapter.responseToReturn = ResponseBody.fromString(
        '{"success": true, "data": {"articles": [${_toJsonString(sampleArticleMap)}]}}',
        200,
        headers: {Headers.contentTypeHeader: [Headers.jsonContentType]},
      );

      final result = await newsRepository.getNews(categoryId: 'technology');
      expect(result.articles.length, 1);
      expect(result.articles.first.categoryId, 'technology');
    });

    // 8. CategoryRepository: Succès réseau et mise en cache
    test('8. CategoryRepository: getCategories charge depuis l\'API et sauvegarde localement', () async {
      mockAdapter.responseToReturn = ResponseBody.fromString(
        '{"success": true, "data": {"categories": [{"id": "business", "name": "Économie", "description": "Finance"}]}}',
        200,
        headers: {Headers.contentTypeHeader: [Headers.jsonContentType]},
      );

      final categories = await categoryRepository.getCategories();
      expect(categories.length, 1);
      expect(categories.first.id, 'business');
      expect(fakeDb.storedCategories.length, 1);
    });

    // 9. CategoryRepository: Fallback cache en cas d'erreur API
    test('9. CategoryRepository: fallback cache local si API indisponible', () async {
      fakeDb.storedCategories.add({'id': 'science', 'name': 'Sciences', 'description': 'Espace'});
      mockAdapter.errorToThrow = DioException(
        requestOptions: RequestOptions(path: '/categories'),
        type: DioExceptionType.badResponse,
      );

      final categories = await categoryRepository.getCategories();
      expect(categories.length, 1);
      expect(categories.first.id, 'science');
    });

    // 10. ThemeModeNotifier: Gestion et basculement dynamique du thème
    test('10. ThemeModeNotifier: cycle correctly entre clair, sombre et système', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final notifier = container.read(themeModeProvider.notifier);
      expect(container.read(themeModeProvider), ThemeMode.system);

      notifier.toggle();
      expect(container.read(themeModeProvider), ThemeMode.dark);

      notifier.toggle();
      expect(container.read(themeModeProvider), ThemeMode.light);

      notifier.setTheme(ThemeMode.dark);
      expect(container.read(themeModeProvider), ThemeMode.dark);
    });

    // 11. LocaleNotifier: Internationalisation FR / EN et toggle
    test('11. LocaleNotifier: initialise en FR, permet le toggle et le changement de locale', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final notifier = container.read(localeProvider.notifier);
      expect(container.read(localeProvider), const Locale('fr'));

      notifier.toggleLocale();
      expect(container.read(localeProvider), const Locale('en'));

      notifier.setLocale(const Locale('fr'));
      expect(container.read(localeProvider), const Locale('fr'));
    });
  });
}

String _toJsonString(Map<String, dynamic> map) {
  final entries = map.entries.map((e) => '"${e.key}": "${e.value}"').join(',');
  return '{$entries}';
}
