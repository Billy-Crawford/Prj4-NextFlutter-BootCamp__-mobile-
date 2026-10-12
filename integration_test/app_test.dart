import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:news_app/core/providers.dart';
import 'package:news_app/core/providers/locale_provider.dart';
import 'package:news_app/core/theme/app_theme.dart';
import 'package:news_app/features/categories/domain/category.dart';
import 'package:news_app/features/categories/presentation/categories_screen.dart';
import 'package:news_app/features/home/presentation/home_screen.dart';
import 'package:news_app/features/news/domain/article.dart';
import 'package:news_app/features/news/domain/news_repository.dart';
import 'package:news_app/features/news/presentation/news_list_screen.dart';
import 'package:news_app/features/search/presentation/search_screen.dart';
import 'package:news_app/l10n/generated/app_localizations.dart';

// Fake Repository for predictable hermetic integration testing
class FakeTestNewsRepository implements NewsRepository {
  @override
  Future<NewsResult> getNews({String? categoryId, bool forceRefresh = false}) async {
    return NewsResult(
      articles: [
        const Article(
          id: 'int-art-1',
          title: 'Nouvelle Révolution IA en 2026',
          description: 'L\'intelligence artificielle transforme l\'ingénierie logicielle.',
          content: 'Analyse détaillée des gains de productivité et des architectures modernes.',
          source: 'TechPulse Media',
          url: 'https://example.com/ai-2026',
          categoryId: 'technology',
          imageUrl: '',
          publishedAt: '2026-10-12T09:00:00Z',
        ),
      ],
      isFromCache: false,
    );
  }

  @override
  Future<Article> getArticleDetail(String articleId) async {
    return const Article(
      id: 'int-art-1',
      title: 'Nouvelle Révolution IA en 2026',
      description: 'L\'intelligence artificielle transforme l\'ingénierie logicielle.',
      content: 'Contenu complet.',
      source: 'TechPulse Media',
      url: 'https://example.com/ai-2026',
      categoryId: 'technology',
    );
  }

  @override
  Future<List<Article>> searchArticles(String query) async {
    return [];
  }
}

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  Widget buildIntegrationApp() {
    return ProviderScope(
      overrides: [
        newsRepositoryProvider.overrideWithValue(FakeTestNewsRepository()),
        categoriesProvider.overrideWith((ref) async => [
          const Category(id: 'tech', name: 'Technologie', description: 'Tech actu'),
        ]),
      ],
      child: Consumer(
        builder: (context, ref, _) {
          final locale = ref.watch(localeProvider);
          final themeMode = ref.watch(themeModeProvider);

          return MaterialApp(
            title: 'NewsPulse Integration Test',
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: themeMode,
            locale: locale,
            localizationsDelegates: const [
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: const [Locale('fr'), Locale('en')],
            home: const HomeScreen(),
          );
        },
      ),
    );
  }

  group('NewsPulse Integration Tests (E2E & Navigation)', () {
    // TEST 1 : Navigation fluide à travers les 4 sections principales
    testWidgets('1. Navigation complète à travers les 4 onglets sans jank ni crash', (tester) async {
      await tester.pumpWidget(buildIntegrationApp());
      await tester.pumpAndSettle();

      // Vérifie l'écran d'accueil initial (Actualités)
      expect(find.byType(HomeScreen), findsOneWidget);
      expect(find.byType(NewsListScreen), findsOneWidget);

      // 1. Basculer vers Recherche
      await tester.tap(find.byIcon(Icons.search_rounded));
      await tester.pumpAndSettle();
      expect(find.byType(SearchScreen), findsOneWidget);

      // 2. Basculer vers Catégories
      await tester.tap(find.byIcon(Icons.category_outlined));
      await tester.pumpAndSettle();
      expect(find.byType(CategoriesScreen), findsOneWidget);

      // 3. Basculer vers Favoris
      await tester.tap(find.byIcon(Icons.favorite_border_rounded));
      await tester.pumpAndSettle();

      // 4. Retour vers Actualités
      await tester.tap(find.byIcon(Icons.newspaper_outlined));
      await tester.pumpAndSettle();
      expect(find.byType(NewsListScreen), findsOneWidget);
    });

    // TEST 2 : Basculement dynamique de langue (FR -> EN -> FR) avec mise à jour instantanée
    testWidgets('2. Basculement dynamique de la langue (FR <-> EN) en temps réel', (tester) async {
      await tester.pumpWidget(buildIntegrationApp());
      await tester.pumpAndSettle();

      // Vérifie l'affichage initial en français (bouton "FR")
      final langButtonFr = find.text('FR');
      expect(langButtonFr, findsOneWidget);

      // Tape pour basculer en Anglais
      await tester.tap(langButtonFr);
      await tester.pumpAndSettle();

      // Doit afficher "EN" et les textes en anglais
      expect(find.text('EN'), findsOneWidget);
      expect(find.text('News'), findsWidgets);

      // Tape pour revenir en Français
      await tester.tap(find.text('EN'));
      await tester.pumpAndSettle();

      // Doit être revenu en "FR"
      expect(find.text('FR'), findsOneWidget);
      expect(find.text('Actualités'), findsWidgets);
    });
  });
}
