// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'NewsPulse';

  @override
  String get tabNews => 'News';

  @override
  String get tabSearch => 'Search';

  @override
  String get tabCategories => 'Categories';

  @override
  String get tabFavorites => 'Favorites';

  @override
  String get allCategories => 'All';

  @override
  String readingTimeMinutes(int count) {
    return '$count min read';
  }

  @override
  String publishedAgoMinutes(int count) {
    return '${count}m ago';
  }

  @override
  String publishedAgoHours(int count) {
    return '${count}h ago';
  }

  @override
  String publishedAgoDays(int count) {
    return '${count}d ago';
  }

  @override
  String get offlineModeBanner =>
      'Offline Mode: Data served from local SQLite cache.';

  @override
  String get articleDetails => 'Article Details';

  @override
  String get fontSizeTooltip => 'Font Size';

  @override
  String get shareTooltip => 'Share';

  @override
  String get addFavoriteTooltip => 'Add to favorites';

  @override
  String get removeFavoriteTooltip => 'Remove from favorites';

  @override
  String get shareSuccessMessage => 'Article link copied to clipboard!';

  @override
  String get readSourceArticle => 'Read full article at source';

  @override
  String get searchHint => 'Search for topics or keywords...';

  @override
  String get searchEmptyTitle => 'Explore thousands of headlines';

  @override
  String get searchEmptySubtitle =>
      'Type a keyword or choose a suggested topic above to start searching.';

  @override
  String searchNoResults(String query) {
    return 'No results for \"$query\"';
  }

  @override
  String get noFavoritesTitle => 'No favorite articles';

  @override
  String get noFavoritesSubtitle =>
      'Save your favorite stories to read them anytime, even offline.';

  @override
  String get exploreNews => 'Explore Headlines';

  @override
  String get savedArticles => 'Saved Articles';

  @override
  String get undo => 'Undo';

  @override
  String get delete => 'Delete';

  @override
  String removedFromFavorites(String title) {
    return '\"$title\" removed from favorites';
  }

  @override
  String get profileTitle => 'Profile & Settings';

  @override
  String get clearCache => 'Clear local SQLite cache';

  @override
  String get clearCacheSubtitle =>
      'Frees storage and forces fresh API fetching';

  @override
  String get cacheClearedMessage => 'Local cache cleared successfully.';

  @override
  String get logout => 'Log out';

  @override
  String get login => 'Log In';

  @override
  String get register => 'Sign Up';

  @override
  String get loginTitle => 'Your real-time news portal';

  @override
  String get emailLabel => 'Email address';

  @override
  String get passwordLabel => 'Password';

  @override
  String get fillDemo => 'Fill Demo Credentials';

  @override
  String get retry => 'Retry';

  @override
  String get lightMode => 'Light Mode';

  @override
  String get darkMode => 'Dark Mode';

  @override
  String get systemMode => 'System Mode';

  @override
  String get languageLabel => 'Language (FR / EN)';

  @override
  String get languageSwitched => 'Language changed';
}
