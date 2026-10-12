// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for French (`fr`).
class AppLocalizationsFr extends AppLocalizations {
  AppLocalizationsFr([String locale = 'fr']) : super(locale);

  @override
  String get appTitle => 'NewsPulse';

  @override
  String get tabNews => 'Actualités';

  @override
  String get tabSearch => 'Recherche';

  @override
  String get tabCategories => 'Catégories';

  @override
  String get tabFavorites => 'Favoris';

  @override
  String get allCategories => 'Toutes';

  @override
  String readingTimeMinutes(int count) {
    return '$count min de lecture';
  }

  @override
  String publishedAgoMinutes(int count) {
    return 'Il y a $count min';
  }

  @override
  String publishedAgoHours(int count) {
    return 'Il y a $count h';
  }

  @override
  String publishedAgoDays(int count) {
    return 'Il y a $count j';
  }

  @override
  String get offlineModeBanner =>
      'Mode hors ligne : articles issus du cache SQLite local.';

  @override
  String get articleDetails => 'Détail de l\'article';

  @override
  String get fontSizeTooltip => 'Taille du texte';

  @override
  String get shareTooltip => 'Partager';

  @override
  String get addFavoriteTooltip => 'Ajouter aux favoris';

  @override
  String get removeFavoriteTooltip => 'Retirer des favoris';

  @override
  String get shareSuccessMessage =>
      'Lien de l\'article copié dans le presse-papier !';

  @override
  String get readSourceArticle => 'Lire l\'article complet à la source';

  @override
  String get searchHint => 'Rechercher un sujet ou mot-clé...';

  @override
  String get searchEmptyTitle => 'Explorez des milliers d\'actualités';

  @override
  String get searchEmptySubtitle =>
      'Entrez un mot-clé ou choisissez une suggestion ci-dessus pour lancer votre recherche.';

  @override
  String searchNoResults(String query) {
    return 'Aucun résultat pour \"$query\"';
  }

  @override
  String get noFavoritesTitle => 'Aucun article favori';

  @override
  String get noFavoritesSubtitle =>
      'Enregistrez vos articles préférés pour les retrouver rapidement même hors ligne.';

  @override
  String get exploreNews => 'Explorer les actualités';

  @override
  String get savedArticles => 'Articles sauvegardés';

  @override
  String get undo => 'Annuler';

  @override
  String get delete => 'Supprimer';

  @override
  String removedFromFavorites(String title) {
    return '\"$title\" retiré des favoris';
  }

  @override
  String get profileTitle => 'Profil & Paramètres';

  @override
  String get clearCache => 'Vider le cache local SQLite';

  @override
  String get clearCacheSubtitle =>
      'Libère l\'espace et force le rechargement API';

  @override
  String get cacheClearedMessage => 'Cache local vidé avec succès.';

  @override
  String get logout => 'Se déconnecter';

  @override
  String get login => 'Connexion';

  @override
  String get register => 'Inscription';

  @override
  String get loginTitle => 'Votre portail d\'actualités en temps réel';

  @override
  String get emailLabel => 'Adresse e-mail';

  @override
  String get passwordLabel => 'Mot de passe';

  @override
  String get fillDemo => 'Remplir identifiants de test';

  @override
  String get retry => 'Réessayer';

  @override
  String get lightMode => 'Mode clair';

  @override
  String get darkMode => 'Mode sombre';

  @override
  String get systemMode => 'Mode système';

  @override
  String get languageLabel => 'Langue (FR / EN)';

  @override
  String get languageSwitched => 'Langue changée';
}
