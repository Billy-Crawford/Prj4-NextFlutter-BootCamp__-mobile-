import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:news_app/core/cache/local_database.dart';
import 'package:news_app/core/errors/exceptions.dart';
import 'package:news_app/core/network/api_client.dart';
import 'package:news_app/features/news/data/news_repository_impl.dart';
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
    db.storedArticles.add(Map<String, dynamic>.from(values));
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
  late NewsRepositoryImpl repository;
  late MockDioAdapter mockAdapter;
  late Dio dio;
  late FakeDatabase fakeDb;

  setUp(() {
    mockAdapter = MockDioAdapter();
    dio = Dio(BaseOptions())..httpClientAdapter = mockAdapter;
    fakeDb = FakeDatabase();

    repository = NewsRepositoryImpl(
      apiClient: FakeApiClient(dio),
      localDatabase: FakeLocalDatabase(fakeDb),
    );
  });

  group('NewsRepository Unit Tests (Exigence Cahier des Charges)', () {
    final sampleArticleMap = {
      'id': 'art-test-1',
      'title': 'Test Title',
      'description': 'Test Description',
      'content': 'Test Content',
      'source': 'Test Source',
      'url': 'https://example.com',
      'category_id': 'tech',
      'image_url': 'https://example.com/img.png',
      'published_at': '2026-03-15T00:00:00Z',
    };

    // TEST 1 : Succès réseau -> retourne les données de l'API et met à jour le cache SQLite
    test('1. Succès réseau : retourne les données de l\'API et met à jour le cache local', () async {
      mockAdapter.responseToReturn = ResponseBody.fromString(
        '{"success": true, "data": {"articles": [${_toJsonString(sampleArticleMap)}]}}',
        200,
        headers: {
          Headers.contentTypeHeader: [Headers.jsonContentType],
        },
      );

      final result = await repository.getNews();

      expect(result.isFromCache, isFalse);
      expect(result.articles.length, 1);
      expect(result.articles.first.id, 'art-test-1');
      // Vérification que le cache SQLite a été alimenté
      expect(fakeDb.storedArticles.length, 1);
      expect(fakeDb.storedArticles.first['id'], 'art-test-1');
    });

    // TEST 2 : Échec réseau avec cache disponible -> retourne les données locales du cache
    test('2. Échec réseau avec cache disponible : retourne les données locales du cache', () async {
      // Pré-remplir le cache SQLite
      fakeDb.storedArticles.add(sampleArticleMap);

      mockAdapter.errorToThrow = DioException(
        requestOptions: RequestOptions(path: '/news'),
        type: DioExceptionType.connectionError,
        message: 'No internet connection',
      );

      final result = await repository.getNews();

      expect(result.isFromCache, isTrue);
      expect(result.articles.length, 1);
      expect(result.articles.first.id, 'art-test-1');
    });

    // TEST 3 : Échec réseau sans cache -> propage une NetworkException exploitable
    test('3. Échec réseau sans cache : propage une exception exploitable pour la présentation', () async {
      fakeDb.storedArticles.clear();

      mockAdapter.errorToThrow = DioException(
        requestOptions: RequestOptions(path: '/news'),
        type: DioExceptionType.connectionTimeout,
        message: 'Timeout exceeded',
      );

      expect(
        () async => await repository.getNews(),
        throwsA(isA<NetworkException>()),
      );
    });
  });
}

String _toJsonString(Map<String, dynamic> map) {
  final entries = map.entries.map((e) => '"${e.key}": "${e.value}"').join(',');
  return '{$entries}';
}
