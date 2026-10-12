import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:news_app/core/widgets/shimmer_loading.dart';
import 'package:news_app/features/categories/presentation/categories_screen.dart';
import 'package:news_app/features/home/presentation/home_screen.dart';
import 'package:news_app/features/news/domain/article.dart';
import 'package:news_app/features/news/presentation/article_card.dart';
import 'package:news_app/features/search/presentation/search_screen.dart';
import 'package:news_app/l10n/generated/app_localizations.dart';

void main() {
  const sampleArticle = Article(
    id: 'test-widget-1',
    title: 'Flutter 3.38 Production Release',
    description: 'Une version majeure pour le développement cross-platform.',
    content: 'Contenu complet détaillant toutes les nouvelles fonctionnalités.',
    source: 'TechCrunch',
    url: 'https://example.com/flutter-release',
    categoryId: 'tech',
    imageUrl: '',
    publishedAt: '2026-10-12T08:00:00Z',
  );

  Widget createTestWidget(Widget child, {List<dynamic> overrides = const []}) {
    return ProviderScope(
      overrides: overrides.cast(),
      child: MaterialApp(
        locale: const Locale('fr'),
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: const [Locale('fr'), Locale('en')],
        home: Scaffold(body: child),
      ),
    );
  }

  group('Suite Complète Tests Widgets (>= 5 tests)', () {
    // 1. ShimmerLoading & ArticleCardSkeleton
    testWidgets('1. ArticleCardSkeleton rend les composants de chargement shimmer', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: ArticleCardSkeleton()),
        ),
      );

      expect(find.byType(ArticleCardSkeleton), findsOneWidget);
      expect(find.byType(ShimmerLoading), findsOneWidget);
    });

    // 2. ArticleCard content & layout
    testWidgets('2. ArticleCard affiche correctement les données d\'un article', (tester) async {
      await tester.pumpWidget(
        createTestWidget(
          ArticleCard(
            article: sampleArticle,
            onTap: () {},
          ),
        ),
      );

      expect(find.text('Flutter 3.38 Production Release'), findsOneWidget);
      expect(find.text('TechCrunch'), findsOneWidget);
      expect(find.text('Une version majeure pour le développement cross-platform.'), findsOneWidget);
    });

    // 3. ArticleCard interaction (callback onTap)
    testWidgets('3. ArticleCard déclenche le callback onTap lorsqu\'on clique dessus', (tester) async {
      bool tapped = false;

      await tester.pumpWidget(
        createTestWidget(
          ArticleCard(
            article: sampleArticle,
            onTap: () {
              tapped = true;
            },
          ),
        ),
      );

      await tester.tap(find.byType(ArticleCard));
      await tester.pumpAndSettle();

      expect(tapped, isTrue);
    });

    // 4. SearchScreen: champ de recherche et suggestions
    testWidgets('4. SearchScreen affiche le champ de recherche et les suggestions', (tester) async {
      await tester.pumpWidget(
        createTestWidget(const SearchScreen()),
      );

      expect(find.byType(TextField), findsOneWidget);
      expect(find.text('Rechercher un sujet ou mot-clé...'), findsOneWidget);
      expect(find.text('Intelligence Artificielle'), findsOneWidget);
    });

    // 5. CategoriesScreen: affichage des chips ou filtres
    testWidgets('5. CategoriesScreen se construit correctement', (tester) async {
      await tester.pumpWidget(
        createTestWidget(
          const CategoriesScreen(),
          overrides: [
            categoriesProvider.overrideWith((ref) async => []),
          ],
        ),
      );

      await tester.pumpAndSettle();
      expect(find.byType(CategoriesScreen), findsOneWidget);
    });

    // 6. HomeScreen: NavigationBar et destinations
    testWidgets('6. HomeScreen affiche la barre de navigation et ses destinations', (tester) async {
      await tester.pumpWidget(
        createTestWidget(
          const HomeScreen(),
          overrides: [
            categoriesProvider.overrideWith((ref) async => []),
          ],
        ),
      );

      expect(find.byType(NavigationBar), findsOneWidget);
      expect(find.byType(NavigationDestination), findsNWidgets(4));
      expect(find.byIcon(Icons.search_rounded), findsOneWidget);
      expect(find.byIcon(Icons.category_outlined), findsOneWidget);
      expect(find.byIcon(Icons.favorite_border_rounded), findsOneWidget);
    });
  });
}
