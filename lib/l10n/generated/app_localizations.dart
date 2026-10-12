import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_fr.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'generated/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('fr'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In fr, this message translates to:
  /// **'NewsPulse'**
  String get appTitle;

  /// No description provided for @tabNews.
  ///
  /// In fr, this message translates to:
  /// **'Actualités'**
  String get tabNews;

  /// No description provided for @tabSearch.
  ///
  /// In fr, this message translates to:
  /// **'Recherche'**
  String get tabSearch;

  /// No description provided for @tabCategories.
  ///
  /// In fr, this message translates to:
  /// **'Catégories'**
  String get tabCategories;

  /// No description provided for @tabFavorites.
  ///
  /// In fr, this message translates to:
  /// **'Favoris'**
  String get tabFavorites;

  /// No description provided for @allCategories.
  ///
  /// In fr, this message translates to:
  /// **'Toutes'**
  String get allCategories;

  /// No description provided for @readingTimeMinutes.
  ///
  /// In fr, this message translates to:
  /// **'{count} min de lecture'**
  String readingTimeMinutes(int count);

  /// No description provided for @publishedAgoMinutes.
  ///
  /// In fr, this message translates to:
  /// **'Il y a {count} min'**
  String publishedAgoMinutes(int count);

  /// No description provided for @publishedAgoHours.
  ///
  /// In fr, this message translates to:
  /// **'Il y a {count} h'**
  String publishedAgoHours(int count);

  /// No description provided for @publishedAgoDays.
  ///
  /// In fr, this message translates to:
  /// **'Il y a {count} j'**
  String publishedAgoDays(int count);

  /// No description provided for @offlineModeBanner.
  ///
  /// In fr, this message translates to:
  /// **'Mode hors ligne : articles issus du cache SQLite local.'**
  String get offlineModeBanner;

  /// No description provided for @articleDetails.
  ///
  /// In fr, this message translates to:
  /// **'Détail de l\'article'**
  String get articleDetails;

  /// No description provided for @fontSizeTooltip.
  ///
  /// In fr, this message translates to:
  /// **'Taille du texte'**
  String get fontSizeTooltip;

  /// No description provided for @shareTooltip.
  ///
  /// In fr, this message translates to:
  /// **'Partager'**
  String get shareTooltip;

  /// No description provided for @addFavoriteTooltip.
  ///
  /// In fr, this message translates to:
  /// **'Ajouter aux favoris'**
  String get addFavoriteTooltip;

  /// No description provided for @removeFavoriteTooltip.
  ///
  /// In fr, this message translates to:
  /// **'Retirer des favoris'**
  String get removeFavoriteTooltip;

  /// No description provided for @shareSuccessMessage.
  ///
  /// In fr, this message translates to:
  /// **'Lien de l\'article copié dans le presse-papier !'**
  String get shareSuccessMessage;

  /// No description provided for @readSourceArticle.
  ///
  /// In fr, this message translates to:
  /// **'Lire l\'article complet à la source'**
  String get readSourceArticle;

  /// No description provided for @searchHint.
  ///
  /// In fr, this message translates to:
  /// **'Rechercher un sujet ou mot-clé...'**
  String get searchHint;

  /// No description provided for @searchEmptyTitle.
  ///
  /// In fr, this message translates to:
  /// **'Explorez des milliers d\'actualités'**
  String get searchEmptyTitle;

  /// No description provided for @searchEmptySubtitle.
  ///
  /// In fr, this message translates to:
  /// **'Entrez un mot-clé ou choisissez une suggestion ci-dessus pour lancer votre recherche.'**
  String get searchEmptySubtitle;

  /// No description provided for @searchNoResults.
  ///
  /// In fr, this message translates to:
  /// **'Aucun résultat pour \"{query}\"'**
  String searchNoResults(String query);

  /// No description provided for @noFavoritesTitle.
  ///
  /// In fr, this message translates to:
  /// **'Aucun article favori'**
  String get noFavoritesTitle;

  /// No description provided for @noFavoritesSubtitle.
  ///
  /// In fr, this message translates to:
  /// **'Enregistrez vos articles préférés pour les retrouver rapidement même hors ligne.'**
  String get noFavoritesSubtitle;

  /// No description provided for @exploreNews.
  ///
  /// In fr, this message translates to:
  /// **'Explorer les actualités'**
  String get exploreNews;

  /// No description provided for @savedArticles.
  ///
  /// In fr, this message translates to:
  /// **'Articles sauvegardés'**
  String get savedArticles;

  /// No description provided for @undo.
  ///
  /// In fr, this message translates to:
  /// **'Annuler'**
  String get undo;

  /// No description provided for @delete.
  ///
  /// In fr, this message translates to:
  /// **'Supprimer'**
  String get delete;

  /// No description provided for @removedFromFavorites.
  ///
  /// In fr, this message translates to:
  /// **'\"{title}\" retiré des favoris'**
  String removedFromFavorites(String title);

  /// No description provided for @profileTitle.
  ///
  /// In fr, this message translates to:
  /// **'Profil & Paramètres'**
  String get profileTitle;

  /// No description provided for @clearCache.
  ///
  /// In fr, this message translates to:
  /// **'Vider le cache local SQLite'**
  String get clearCache;

  /// No description provided for @clearCacheSubtitle.
  ///
  /// In fr, this message translates to:
  /// **'Libère l\'espace et force le rechargement API'**
  String get clearCacheSubtitle;

  /// No description provided for @cacheClearedMessage.
  ///
  /// In fr, this message translates to:
  /// **'Cache local vidé avec succès.'**
  String get cacheClearedMessage;

  /// No description provided for @logout.
  ///
  /// In fr, this message translates to:
  /// **'Se déconnecter'**
  String get logout;

  /// No description provided for @login.
  ///
  /// In fr, this message translates to:
  /// **'Connexion'**
  String get login;

  /// No description provided for @register.
  ///
  /// In fr, this message translates to:
  /// **'Inscription'**
  String get register;

  /// No description provided for @loginTitle.
  ///
  /// In fr, this message translates to:
  /// **'Votre portail d\'actualités en temps réel'**
  String get loginTitle;

  /// No description provided for @emailLabel.
  ///
  /// In fr, this message translates to:
  /// **'Adresse e-mail'**
  String get emailLabel;

  /// No description provided for @passwordLabel.
  ///
  /// In fr, this message translates to:
  /// **'Mot de passe'**
  String get passwordLabel;

  /// No description provided for @fillDemo.
  ///
  /// In fr, this message translates to:
  /// **'Remplir identifiants de test'**
  String get fillDemo;

  /// No description provided for @retry.
  ///
  /// In fr, this message translates to:
  /// **'Réessayer'**
  String get retry;

  /// No description provided for @lightMode.
  ///
  /// In fr, this message translates to:
  /// **'Mode clair'**
  String get lightMode;

  /// No description provided for @darkMode.
  ///
  /// In fr, this message translates to:
  /// **'Mode sombre'**
  String get darkMode;

  /// No description provided for @systemMode.
  ///
  /// In fr, this message translates to:
  /// **'Mode système'**
  String get systemMode;

  /// No description provided for @languageLabel.
  ///
  /// In fr, this message translates to:
  /// **'Langue (FR / EN)'**
  String get languageLabel;

  /// No description provided for @languageSwitched.
  ///
  /// In fr, this message translates to:
  /// **'Langue changée'**
  String get languageSwitched;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'fr'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'fr':
      return AppLocalizationsFr();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
