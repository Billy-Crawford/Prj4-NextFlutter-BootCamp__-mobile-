# 📝 CHANGELOG

Toutes les modifications notables apportées au projet **NewsPulse (Client Flutter & Architecture Mobile)** sont documentées chronologiquement dans ce fichier.

Le format est basé sur [Keep a Changelog](https://keepachangelog.com/fr/1.0.0/) et respecte le versionnement sémantique [SemVer](https://semver.org/).

---

## [1.2.0] - 2026-10-12

### 🚀 Production-Ready, Performance, A11y & Tests (Jalon Final)
- **Suite de Tests Complète** :
  - **14 tests unitaires** (`test/news_repository_test.dart` & `test/unit_tests.dart`) couvrant la sérialisation des modèles, les dépôts de données, le fallback réseau/cache et les contrôleurs de state Riverpod (`ThemeModeNotifier`, `LocaleNotifier`).
  - **6 tests de widgets** (`test/widget_test.dart`) validant le squelette de chargement Shimmer, les cartes d'articles, les callbacks tactiles, le moteur de recherche et la barre de navigation.
  - **2 tests d'intégration E2E** (`integration_test/app_test.dart`) testant la traversée des 4 écrans principaux et le basculement bilingue instantané.
- **Accessibilité Universelle (a11y)** :
  - Intégration de balises `Semantics` avec descriptions explicites sur l'ensemble des éléments interactifs (boutons d'action, sélecteur de thème, changement de langue, boutons favoris, images Hero et logo).
- **Optimisation des Performances & Fluidité (60 FPS)** :
  - Lazy loading et limitation mémoire du cache d'images via `cacheWidth` (720px / 1080px).
  - Suppression des rebuilds superflus via granularité des widgets et constructeurs `const`.
  - Résolution des contraintes d'overflow via `SingleChildScrollView` sur les vues d'état vide/erreur.
- **Internationalisation Complète (i18n)** :
  - Prise en charge native du Français (FR) et de l'Anglais (EN) avec fichiers ARB (`app_fr.arb`, `app_en.arb`) et bascule dynamique en temps réel via `LocaleNotifier`.
- **Intégration Continue (CI/CD)** :
  - Mise en place du workflow GitHub Actions (`.github/workflows/ci.yml`) automatisant l'analyse statique sans warning (`flutter analyze`), l'exécution de la suite de tests et la compilation d'aperçu APK.

---

## [1.1.0] - 2026-10-11

### ✨ Architecture Feature-First & Persistance Hors-Ligne (Jalon 2)
- **Architecture & State Management** :
  - Restructuration propre en architecture Feature-First (`news`, `categories`, `favorites`, `search`, `auth`).
  - Migration vers **Riverpod** avec `FutureProvider` et `Notifier`.
- **Persistance Locale & Mode Hors-Ligne** :
  - Implémentation d'une base de données locale **SQLite** (`LocalDatabase`) avec tables `articles`, `categories` et `favorites`.
  - Cache automatique transparent lors des requêtes réseau réussies.
  - Mode hors-ligne automatique : affichage des données en cache avec notification visuelle (`offlineModeBanner`) si le réseau ou le backend est indisponible.
- **Sécurité & Authentification** :
  - Intégration de **Firebase Authentication** pour l'authentification des utilisateurs.
  - Client réseau **Dio** avec intercepteur JWT (`AuthInterceptor`) injectant dynamiquement le bearer token d'authentification sur chaque requête.
- **Nouveaux Écrans** :
  - Écran de Recherche dynamique avec chips de suggestions populaires.
  - Écran des Catégories avec filtrage en temps réel.
  - Écran de Détail d'article avec sélecteur de taille de police dynamique et calcul automatique du temps de lecture.

---

## [1.0.0] - 2026-10-10

### 🎉 Version Initiale (MVP)
- **Fondations de l'application** :
  - Création du projet Flutter de base.
  - Configuration du backend Flask / Python connecté à Firebase Firestore.
  - Écran initial de flux d'actualités avec cartes basiques.
  - Support du thème clair / sombre Material 3.
