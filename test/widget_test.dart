import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:news_app/core/theme/app_theme.dart';
import 'package:news_app/core/widgets/shimmer_loading.dart';
import 'package:news_app/features/news/domain/article.dart';
import 'package:news_app/features/news/presentation/article_card.dart';

void main() {
  group('ThemeModeNotifier', () {
    test('commence en mode system et permet le toggle', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      expect(container.read(themeModeProvider), ThemeMode.system);

      container.read(themeModeProvider.notifier).toggle();
      expect(container.read(themeModeProvider), ThemeMode.dark);

      container.read(themeModeProvider.notifier).toggle();
      expect(container.read(themeModeProvider), ThemeMode.light);

      container.read(themeModeProvider.notifier).setTheme(ThemeMode.dark);
      expect(container.read(themeModeProvider), ThemeMode.dark);
    });
  });

  group('ArticleCard & Shimmer Widgets', () {
    testWidgets('affiche les skeletons de chargement sans erreur', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ArticleCardSkeleton(),
          ),
        ),
      );

      expect(find.byType(ArticleCardSkeleton), findsOneWidget);
      expect(find.byType(ShimmerLoading), findsOneWidget);
    });

    testWidgets('affiche correctement le titre et la source de l\'article', (tester) async {
      const article = Article(
        id: 'test-1',
        title: 'Titre Actualite Test',
        description: 'Petite description pour le test',
        content: 'Contenu complet avec quelques mots pour tester le calcul de lecture.',
        source: 'Le Figaro Tech',
        url: 'https://example.com/test-1',
        categoryId: 'tech',
        imageUrl: '',
        publishedAt: '2026-10-12T00:00:00Z',
      );

      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: ArticleCard(
                article: article,
                onTap: () {},
              ),
            ),
          ),
        ),
      );

      expect(find.text('Titre Actualite Test'), findsOneWidget);
      expect(find.text('Le Figaro Tech'), findsOneWidget);
      expect(find.text('Petite description pour le test'), findsOneWidget);
    });
  });
}
