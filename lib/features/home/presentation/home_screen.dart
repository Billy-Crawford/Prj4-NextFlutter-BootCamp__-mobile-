import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/providers.dart';
import '../../../core/theme/app_theme.dart';
import '../../auth/presentation/auth_controller.dart';
import '../../categories/presentation/categories_screen.dart';
import '../../favorites/presentation/favorites_screen.dart';
import '../../news/presentation/news_list_screen.dart';
import '../../search/presentation/search_screen.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  int _currentIndex = 0;

  final List<String> _tabTitles = const [
    'À la une',
    'Recherche',
    'Catégories',
    'Favoris',
  ];

  void _showProfileDialog(BuildContext context) {
    final user = ref.read(authStateProvider).value;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade400,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  CircleAvatar(
                    radius: 26,
                    backgroundColor: theme.primaryColor.withValues(alpha: 0.15),
                    child: Icon(Icons.person_rounded,
                        size: 30, color: theme.primaryColor),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          user?.email ?? 'Utilisateur connecté',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),
                        Row(
                          children: [
                            const Icon(Icons.verified,
                                size: 14, color: Colors.green),
                            const SizedBox(width: 4),
                            Text(
                              'Compte Firebase actif',
                              style: TextStyle(
                                fontSize: 12,
                                color: isDark ? Colors.white60 : Colors.black54,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              const Divider(),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.cleaning_services_outlined),
                title: const Text('Vider le cache local SQLite'),
                subtitle: const Text('Libère l\'espace et force le rechargement API'),
                onTap: () async {
                  final db = ref.read(localDatabaseProvider);
                  await db.clearAllCache();
                  if (ctx.mounted) {
                    Navigator.pop(ctx);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Cache local vidé avec succès.')),
                    );
                    ref.invalidate(feedNewsProvider);
                  }
                },
              ),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.logout, color: Colors.redAccent),
                title: const Text('Se déconnecter',
                    style: TextStyle(color: Colors.redAccent)),
                onTap: () {
                  Navigator.pop(ctx);
                  ref.read(authControllerProvider.notifier).signOut();
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final screens = [
      const NewsListScreen(),
      const SearchScreen(),
      const CategoriesScreen(),
      FavoritesScreen(
        onExplore: () {
          setState(() {
            _currentIndex = 0;
          });
        },
      ),
    ];

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.newspaper, color: Colors.white, size: 20),
            ),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'NewsPulse',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                Text(
                  _tabTitles[_currentIndex],
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.normal,
                    color: isDark ? Colors.white60 : Colors.black45,
                  ),
                ),
              ],
            ),
          ],
        ),
        actions: [
          // Theme Switcher (Dark / Light)
          IconButton(
            icon: Icon(
              isDark ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
            ),
            tooltip: isDark ? 'Mode clair' : 'Mode sombre',
            onPressed: () {
              ref.read(themeModeProvider.notifier).toggle();
            },
          ),
          // User Profile & Settings
          IconButton(
            icon: const Icon(Icons.account_circle_outlined),
            tooltip: 'Profil',
            onPressed: () => _showProfileDialog(context),
          ),
        ],
      ),
      body: IndexedStack(
        index: _currentIndex,
        children: screens,
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.newspaper_outlined),
            selectedIcon: Icon(Icons.newspaper),
            label: 'Actualités',
          ),
          NavigationDestination(
            icon: Icon(Icons.search_rounded),
            selectedIcon: Icon(Icons.saved_search_rounded),
            label: 'Recherche',
          ),
          NavigationDestination(
            icon: Icon(Icons.category_outlined),
            selectedIcon: Icon(Icons.category),
            label: 'Catégories',
          ),
          NavigationDestination(
            icon: Icon(Icons.favorite_border_rounded),
            selectedIcon: Icon(Icons.favorite_rounded),
            label: 'Favoris',
          ),
        ],
      ),
    );
  }
}
