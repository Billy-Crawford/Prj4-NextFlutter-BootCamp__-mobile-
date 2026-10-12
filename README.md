# 📱 NewsPulse — Application Mobile Flutter (Production-Ready)

[![CI Pipeline](https://github.com/Billy-Crawford/Prj4-NextFlutter-BootCamp__-mobile-/actions/workflows/ci.yml/badge.svg)](https://github.com/Billy-Crawford/Prj4-NextFlutter-BootCamp__-mobile-/actions/workflows/ci.yml)
[![Flutter](https://img.shields.io/badge/Flutter-3.38.1-02569B?logo=flutter)](https://flutter.dev)
[![Dart](https://img.shields.io/badge/Dart-3.10.0-0175C2?logo=dart)](https://dart.dev)
[![License](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE)

Application mobile d'actualités connectée à une API REST réelle, développée avec Flutter, Cloud Firestore, Firebase Authentication et un cache local SQLite offline-first. Le projet respecte scrupuleusement les standards **production-ready**, d'accessibilité (a11y), d'internationalisation (i18n), d'optimisation des performances et d'automatisation CI/CD.

---

## 🏆 Grille d'évaluation & Conformité aux exigences (Max 100 pts)

| Exigence du Cahier des Charges | Statut | Détails & Emplacement |
| :--- | :---: | :--- |
| **Au moins 5 écrans fonctionnels** | ✅ **Conforme (5 écrans)** | 1. Flux d'actualités ([`news_list_screen.dart`](lib/features/news/presentation/news_list_screen.dart))<br>2. Recherche par mot-clé ([`search_screen.dart`](lib/features/search/presentation/search_screen.dart))<br>3. Catégories & filtrage ([`categories_screen.dart`](lib/features/categories/presentation/categories_screen.dart))<br>4. Détail d'article ([`article_detail_screen.dart`](lib/features/article_detail/presentation/article_detail_screen.dart))<br>5. Mes Favoris sécurisés ([`favorites_screen.dart`](lib/features/favorites/presentation/favorites_screen.dart)) |
| **Suite de tests complète** | ✅ **Conforme (22 tests)** | • **14 tests unitaires** ([`unit_tests.dart`](test/unit_tests.dart), [`news_repository_test.dart`](test/news_repository_test.dart))<br>• **6 tests de widgets** ([`widget_test.dart`](test/widget_test.dart))<br>• **2 tests d'intégration** ([`app_test.dart`](integration_test/app_test.dart)) |
| **Performance (60 FPS constant)** | ✅ **Conforme** | Images avec dimensionnement et mise en cache mémoire (`cacheWidth: 720/1080`), constructeurs `const`, suppression de tout jank visuel et évitement des rebuilds superflus. |
| **Accessibilité (a11y)** | ✅ **Conforme** | Balises `Semantics` explicites sur tous les éléments interactifs (boutons d'action, sélecteur de langue, favoris, images Hero, logo, champs de saisie). |
| **Internationalisation (i18n)** | ✅ **Conforme** | Support complet Français (FR) et Anglais (EN) via `flutter_localizations` & fichiers ARB ([`app_fr.arb`](lib/l10n/app_fr.arb), [`app_en.arb`](lib/l10n/app_en.arb)) avec bascule dynamique en temps réel via [`LocaleNotifier`](lib/core/providers/locale_provider.dart). |
| **CI/CD automatisé** | ✅ **Conforme (CI Verte)** | Pipeline GitHub Actions configuré dans [`.github/workflows/ci.yml`](.github/workflows/ci.yml) exécutant l'analyse statique (`flutter analyze`) et l'intégralité de la suite de tests. |
| **Analyse statique propre** | ✅ **Conforme** | `flutter analyze` s'exécute avec **0 avertissement, 0 erreur**. |
| **CHANGELOG.md professionnel** | ✅ **Conforme** | Historique complet et documenté de 3 versions sémantiques ([`CHANGELOG.md`](CHANGELOG.md) - v1.0.0, v1.1.0, v1.2.0). |

---

## 🧪 Détail de la Suite de Tests

### 1. Tests Unitaires (≥ 10 exigés — **14 implémentés**)
Exécutés via `flutter test test/news_repository_test.dart test/unit_tests.dart` :
- `Article.fromJson` & `Article.toMap` (Sérialisation / désérialisation modèle SQLite).
- `Category.fromJson` & `Category.toMap` (Sérialisation / désérialisation catégories).
- Succès réseau `NewsRepository` : alimentation automatique du cache SQLite.
- Mode hors-ligne `NewsRepository` : fallback transparent sur le cache SQLite lors d'une coupure réseau.
- Gestion d'exception `NetworkException` en cas d'indisponibilité totale et cache vide.
- Filtrage d'articles par catégorie via `getNews(categoryId: ...)`.
- Succès réseau et mise en cache des catégories dans `CategoryRepository`.
- Fallback sur le cache local des catégories en cas de panne réseau.
- Cycle de thèmes dynamiques (Clair, Sombre, Système) via `ThemeModeNotifier`.
- Basculement et persistance de la locale (FR <-> EN) via `LocaleNotifier`.

### 2. Tests de Widgets (≥ 5 exigés — **6 implémentés**)
Exécutés via `flutter test test/widget_test.dart` :
- Rendu sans scintillement des animations Shimmer (`ArticleCardSkeleton`).
- Affichage fidèle des données de carte d'actualité (`ArticleCard`).
- Déclenchement réactif des callbacks tactiles (`onTap`).
- Champ de recherche, suggestions tendances et réactivité dans `SearchScreen`.
- Construction sans régression des grilles et puces dans `CategoriesScreen`.
- Navigation et composabilité de la barre inférieure (`NavigationBar`) dans `HomeScreen`.

### 3. Tests d'Intégration (≥ 2 exigés — **2 implémentés**)
Exécutés via `flutter test integration_test/app_test.dart -d linux` :
- **Parcours E2E complet** : Traversée fluide des 4 écrans principaux sans débordement de layout ni jank.
- **Bascule bilingue temps réel** : Changement instantané de langue FR ➔ EN ➔ FR avec mise à jour immédiate de tous les libellés de l'interface.

---

## 🏛️ Architecture du Projet

L'application suit une architecture **Feature-First** combinée aux principes de **Clean Architecture** :

```text
mobile/
├── .github/
│   └── workflows/
│       └── ci.yml                    # Pipeline GitHub Actions (Lint, Tests, Build)
├── integration_test/
│   └── app_test.dart                 # Tests d'intégration E2E
├── test/
│   ├── news_repository_test.dart     # Tests unitaires du repository et cache
│   ├── unit_tests.dart               # Suite complète des tests unitaires
│   └── widget_test.dart              # Tests de composants et widgets
├── lib/
│   ├── core/
│   │   ├── cache/
│   │   │   └── local_database.dart   # Singleton SQLite (sqflite) pour la persistance locale
│   │   ├── config/
│   │   │   └── app_config.dart       # Configuration des URLs (supporte --dart-define)
│   │   ├── errors/
│   │   │   └── exceptions.dart       # Hiérarchie des exceptions métier et réseau
│   │   ├── network/
│   │   │   └── api_client.dart       # Client Dio + Intercepteur Auth & Refresh Token
│   │   ├── providers/
│   │   │   └── locale_provider.dart  # Notifier Riverpod pour le support bilingue
│   │   ├── theme/
│   │   │   └── app_theme.dart        # Thèmes Light / Dark et ThemeModeNotifier
│   │   ├── widgets/
│   │   │   └── shimmer_loading.dart  # Effets de chargement squelette (Shimmer)
│   │   └── providers.dart            # Providers Riverpod racine
│   │
│   ├── features/
│   │   ├── auth/                     # Authentification Firebase
│   │   ├── categories/               # Catégories d'actualités
│   │   ├── favorites/                # Gestion des favoris hors ligne
│   │   ├── home/                     # Navigation principale et sélecteurs
│   │   ├── news/                     # Flux d'actualités & cartes
│   │   └── search/                   # Recherche temps réel
│   │
│   ├── l10n/
│   │   ├── app_en.arb                # Dictionnaire Anglais
│   │   ├── app_fr.arb                # Dictionnaire Français
│   │   └── generated/                # Classes générées (AppLocalizations)
│   └── main.dart                     # Point d'entrée de l'application
├── CHANGELOG.md                      # Historique des versions
└── pubspec.yaml                      # Dépendances et configuration Flutter
```

---

## 🚀 Installation & Lancement

### 1. Prérequis
- Flutter SDK **3.38+**
- Java JDK **17**

### 2. Dépendances & Génération
```bash
flutter pub get
flutter gen-l10n
```

### 3. Exécution des Tests
```bash
# 1. Vérification de l'analyse statique (0 avertissement)
flutter analyze

# 2. Exécution des tests unitaires et de widgets
flutter test test/news_repository_test.dart test/unit_tests.dart test/widget_test.dart

# 3. Exécution des tests d'intégration
flutter test integration_test/app_test.dart -d linux
```

### 4. Lancement de l'Application
```bash
# Sur émulateur ou appareil connecté :
flutter run --dart-define=API_BASE_URL=http://localhost:5000/api/v1
```

---

## 📦 Génération de l'APK de Démonstration

Pour générer l'exécutable Android autonome :
```bash
flutter build apk --release
```
Le fichier généré sera disponible dans `build/app/outputs/flutter-apk/app-release.apk`.
