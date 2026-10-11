# 📱 NewsPulse — Application Mobile Flutter (Full-Stack)

Application mobile d'actualités connectée à une API REST réelle, développée avec Flutter, Cloud Firestore, Firebase Authentication et un cache local SQLite offline-first.

---

## 🏆 Grille d'évaluation & Conformité aux exigences (Max 100 pts)

| Exigence du Cahier des Charges | Statut | Emplacement / Implémentation |
| :--- | :---: | :--- |
| **Authentification (login/register/logout)** |  **Conforme** | Firebase Authentication avec email/mot de passe ([`auth_controller.dart`](lib/features/auth/presentation/auth_controller.dart), [`auth_screen.dart`](lib/features/auth/presentation/auth_screen.dart)). |
| **Au moins 3 écrans de données API REST** |  **Conforme (5 écrans)** | 1. Flux d'actualités ([`news_list_screen.dart`](lib/features/news/presentation/news_list_screen.dart))<br>2. Recherche par mot-clé ([`search_screen.dart`](lib/features/search/presentation/search_screen.dart))<br>3. Catégories & filtrage ([`categories_screen.dart`](lib/features/categories/presentation/categories_screen.dart))<br>4. Détail d'article ([`article_detail_screen.dart`](lib/features/article_detail/presentation/article_detail_screen.dart))<br>5. Mes Favoris sécurisés ([`favorites_screen.dart`](lib/features/favorites/presentation/favorites_screen.dart)) |
| **Mise en cache locale des données** |  **Conforme** | Cache local SQLite persistant avec tables `articles`, `categories` et `favorites` ([`local_database.dart`](lib/core/cache/local_database.dart)). |
| **Mode hors-ligne** |  **Conforme** | Stratégie offline-first dans [`news_repository_impl.dart`](lib/features/news/data/news_repository_impl.dart). Si le réseau est indisponible, l'application bascule automatiquement sur les données locales et affiche un bandeau informatif. |
| **Gestion d'erreurs réseau & messages UI** |  **Conforme** | Exceptions typées ([`exceptions.dart`](lib/core/errors/exceptions.dart)), messages d'erreur explicites pour l'utilisateur, options de réessai et SnackBars réactives. |
| **Architecture Clean / Feature-First** |  **Conforme** | Découpage par fonctionnalités avec séparation stricte des couches `data`, `domain` et `presentation`. |
| **Repository Pattern** |  **Conforme** | Interfaces abstraites dans `domain/` et implémentations concrètes dans `data/` ([`news_repository.dart`](lib/features/news/domain/news_repository.dart)). |
| **Client HTTP Dio** |  **Conforme** | Client centralisé avec configuration de base, timeouts et gestion de flux ([`api_client.dart`](lib/core/network/api_client.dart)). |
| **Intercepteur d'authentification** |  **Conforme** | `InterceptorsWrapper` qui intercepte chaque requête sortante pour injecter l'en-tête `Authorization: Bearer <token>` ([`api_client.dart`](lib/core/network/api_client.dart)). |
| **Gestion du Refresh Token** |  **Conforme** | En cas d'erreur `401 Unauthorized`, l'intercepteur force le rafraîchissement du JWT via `user.getIdToken(true)` et rejoue la requête automatiquement. |
| **Au moins 3 tests unitaires (Repository)** |  **Conforme (6 tests)** | Tests complets avec mocks sur la couche repository et widgets dans [`news_repository_test.dart`](test/news_repository_test.dart) et [`widget_test.dart`](test/widget_test.dart). |

---

## 🏛️ Architecture du Projet

L'application suit une architecture **Feature-First** combinée aux principes de **Clean Architecture** :

```text
mobile/
├── lib/
│   ├── core/
│   │   ├── cache/
│   │   │   └── local_database.dart       # Singleton SQLite (sqflite) pour la persistance locale
│   │   ├── config/
│   │   │   └── app_config.dart           # Configuration des URLs (supporte --dart-define)
│   │   ├── errors/
│   │   │   └── exceptions.dart           # Hiérarchie des exceptions métier et réseau
│   │   ├── network/
│   │   │   └── api_client.dart           # Client Dio + Intercepteur Auth & Refresh Token
│   │   ├── theme/
│   │   │   └── app_theme.dart            # Thèmes Light / Dark et ThemeModeNotifier
│   │   ├── widgets/
│   │   │   └── shimmer_loading.dart      # Effets de chargement squelette (Shimmer)
│   │   └── providers.dart                # Providers Riverpod racine
│   │
│   ├── features/
│   │   ├── auth/                         # Authentification Firebase
│   │   │   └── presentation/
│   │   │       ├── auth_controller.dart  # Notifier de connexion / inscription / déconnexion
│   │   │       └── auth_screen.dart      # Formulaire moderne avec mode sombre & compte démo
│   │   ├── news/                         # Actualités principales
│   │   │   ├── data/
│   │   │   │   └── news_repository_impl.dart # Implémentation du Repository (API + Cache SQLite)
│   │   │   ├── domain/
│   │   │   │   ├── article.dart          # Modèle métier Article
│   │   │   │   └── news_repository.dart  # Interface du Repository
│   │   │   └── presentation/
│   │   │       ├── article_card.dart     # Carte d'article avec Hero animation, temps de lecture et like
│   │   │       └── news_list_screen.dart # Flux avec carrousel de catégories & article à la une
│   │   ├── categories/                   # Rubriques d'actualités
│   │   │   ├── data/category_repository.dart
│   │   │   ├── domain/category.dart
│   │   │   └── presentation/categories_screen.dart # Filtrage par rubriques avec icônes dédiées
│   │   ├── search/                       # Recherche plein texte
│   │   │   └── presentation/search_screen.dart     # Suggestions tendances, historique et résultats
│   │   ├── favorites/                    # Favoris privés synchronisés
│   │   │   ├── data/favorite_repository.dart
│   │   │   └── presentation/favorites_screen.dart  # Favoris avec glissement pour supprimer (Dismissible)
│   │   ├── article_detail/               # Page de lecture d'article
│   │   │   └── presentation/article_detail_screen.dart # Zoom de texte, partage, citation, lien source
│   │   └── home/                         # Navigation principale
│   │       └── presentation/home_screen.dart       # AppBar unifiée, bascule de thème, profil modal
│   │
│   ├── firebase_options.dart             # Configuration Firebase multiplateforme
│   └── main.dart                         # Initialisation et ProviderScope Riverpod
│
├── test/
│   ├── news_repository_test.dart         # Tests unitaires de la couche Repository avec Mocks
│   └── widget_test.dart                  # Tests de composants UI et du gestionnaire de thèmes
└── pubspec.yaml
```

---

## 🌐 Endpoints de l'API REST consommés

Le client mobile consomme les routes de l'API REST Flask (`/api/v1`) :

| Méthode | Endpoint | Authentifié | Description |
| :--- | :--- | :---: | :--- |
| `GET` | `/api/v1/health` | Non | Vérification de la disponibilité du serveur. |
| `GET` | `/api/v1/news` | Non | Récupération de tous les articles récents. |
| `GET` | `/api/v1/news/<id>` | Non | Détail complet d'un article par son identifiant. |
| `GET` | `/api/v1/categories` | Non | Liste des rubriques disponibles (Business, Tech, Science...). |
| `GET` | `/api/v1/categories/<id>/news` | Non | Articles filtrés par rubrique. |
| `GET` | `/api/v1/search?q=<query>` | Non | Recherche d'articles par mot-clé dans le titre et le contenu. |
| `GET` | `/api/v1/favorites` | **Oui** (Bearer) | Liste des articles favoris de l'utilisateur connecté. |
| `POST` | `/api/v1/favorites` | **Oui** (Bearer) | Ajout d'un article aux favoris (`{"article_id": "art-1"}`). |
| `DELETE` | `/api/v1/favorites/<id>` | **Oui** (Bearer) | Retrait d'un article des favoris. |

---

## 🔒 Authentification & Gestion des Tokens

1. **Connexion & Inscription** :
   L'authentification s'appuie sur **Firebase Authentication**. L'utilisateur obtient un jeton JWT sécurisé.
2. **Intercepteur Dio (`InterceptorsWrapper`)** :
   Chaque requête HTTP passe automatiquement par l'intercepteur dans [`api_client.dart`](lib/core/network/api_client.dart). Si un utilisateur est connecté, le token JWT est injecté dans le header :
   ```http
   Authorization: Bearer <ID_TOKEN_FIREBASE>
   ```
3. **Stratégie de rafraîchissement (Refresh Token)** :
   Si le backend renvoie un code d'erreur `401 Unauthorized` (token expiré), l'intercepteur intercepte l'erreur, appelle `user.getIdToken(true)` pour renouveler le JWT auprès des serveurs d'authentification, met à jour les en-têtes et rejoue la requête initiale en toute transparence pour l'utilisateur.

---

## 💾 Persistance locale & Mode Hors-ligne

La couche de données implémente une stratégie **Cache-then-Network avec fallback** :
- Lors d'une requête réseau réussie, les articles sont automatiquement insérés dans la base de données locale **SQLite** (`sqflite`).
- En cas de perte de connectivité (`SocketException`, timeout, mode avion), le repository intercepte l'erreur réseau et lit immédiatement les données enregistrées dans le cache SQLite local.
- L'interface affiche alors un indicateur distinctif : **« Mode hors ligne : données issues du cache local SQLite »**.

---

## 🛠️ Configuration & Lancement

### 1. Prérequis
- Flutter SDK (≥ 3.10.x / 3.38.x)
- Un appareil Android (ou émulateur) connecté
- Le backend Flask lancé

### 2. Démarrage du Backend
Dans le répertoire `Back/` :
```bash
source .venv/bin/activate
python run.py
```
*(Le serveur écoute par défaut sur le port 5000).*

### 3. Lancement de l'application Mobile

#### Sur appareil physique (ex: Samsung via câble USB)
1. Activer le redirection de port ADB :
   ```bash
   adb reverse tcp:5000 tcp:5000
   ```
2. Lancer l'application :
   ```bash
   flutter run --dart-define=API_BASE_URL=http://localhost:5000/api/v1
   ```

#### Sur Émulateur Android
```bash
flutter run --dart-define=API_BASE_URL=http://10.0.2.2:5000/api/v1
```

#### Sur le même réseau Wi-Fi
```bash
flutter run --dart-define=API_BASE_URL=http://<IP_LOCALE_DU_PC>:5000/api/v1
```

---

## 🧪 Tests Unitaires et de Composants

Exécutez la suite complète de tests avec :
```bash
flutter test
```

### Couverture des tests :
- **Succès réseau** : Vérifie la réception des données de l'API et l'alimentation synchrone du cache SQLite.
- **Mode hors-ligne** : Simule une coupure réseau totale et valide que le repository renvoie correctement les articles stockés en base SQLite avec le drapeau `isFromCache: true`.
- **Gestion des pannes** : Vérifie la propagation propre d'une exception `NetworkException` lorsque le cache est vide.
- **Gestionnaire de thèmes** : Valide le comportement du `ThemeModeNotifier` (bascule système, sombre et clair).
- **Rendu des composants** : Valide l'affichage des squelettes Shimmer et des éléments de la carte d'article.
