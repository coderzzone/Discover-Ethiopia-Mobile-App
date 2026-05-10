import 'dart:ui';
import 'package:flutter/material.dart';
import 'state/app_scope.dart';
import 'state/app_state.dart';
import 'screens/favorites_screen.dart';
import 'screens/home_screen.dart';
import 'screens/map_screen.dart';
import 'screens/directory_screen.dart';
import 'screens/splash_screen.dart';
import 'screens/trip_planner_screen.dart';
import 'screens/ai_trip_planner_screen.dart';
import 'screens/saved_plans_screen.dart';
import 'theme/app_theme.dart';
import 'models/app_models.dart';
import 'screens/destination_details_screen.dart';
import 'state/app_localization.dart';

class EthioExploreApp extends StatelessWidget {
  const EthioExploreApp({super.key, required this.state});

  final AppState state;

  @override
  Widget build(BuildContext context) {
    return AppStateScope(
      state: state,
      child: AnimatedBuilder(
        animation: state,
        builder: (context, _) => MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'Discover Ethiopia',
          theme: buildEthioExploreTheme(),
          darkTheme: buildEthioExploreDarkTheme(),
          themeMode: state.themeMode,
          scrollBehavior: const MaterialScrollBehavior().copyWith(
            dragDevices: {
              PointerDeviceKind.touch,
              PointerDeviceKind.mouse,
              PointerDeviceKind.trackpad,
              PointerDeviceKind.stylus,
              PointerDeviceKind.unknown,
            },
          ),
          home: const SplashScreen(),
          routes: {
            EthioExploreShell.routeName: (_) => const EthioExploreShell(),
          },
        ),
      ),
    );
  }
}

class EthioExploreShell extends StatefulWidget {
  const EthioExploreShell({super.key});

  static const routeName = '/app';

  @override
  State<EthioExploreShell> createState() => _EthioExploreShellState();
}

class _EthioExploreShellState extends State<EthioExploreShell> {
  int _selectedIndex = 0;

  final _pages = const [
    HomeScreen(),
    TripPlannerScreen(),
    AiTripPlannerScreen(),
    SavedPlansScreen(),
    FavoritesScreen(),
    DirectoryScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        centerTitle: false,
        elevation: 0,
        scrolledUnderElevation: 0,
        backgroundColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        flexibleSpace: ClipRect(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Container(
              color: Theme.of(context).colorScheme.surface.withValues(alpha: 0.8),
            ),
          ),
        ),
        titleSpacing: 24,
        title: Text(
          'Discover Ethiopia',
          style: TextStyle(
            color: Theme.of(context).colorScheme.primary,
            fontSize: 22,
            fontWeight: FontWeight.w900,
            letterSpacing: -0.5,
          ),
        ),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 16),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
              shape: BoxShape.circle,
            ),
            child: IconButton(
              tooltip: 'Toggle dark mode',
              onPressed: () => AppStateScope.read(context).toggleThemeMode(),
              icon: Icon(
                AppStateScope.watch(context).themeMode == ThemeMode.dark
                    ? Icons.dark_mode_rounded
                    : Icons.light_mode_rounded,
                size: 20,
              ),
            ),
          ),
        ],
      ),
      body: IndexedStack(index: _selectedIndex, children: _pages),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (index) => setState(() => _selectedIndex = index),
        backgroundColor: Theme.of(context).colorScheme.surfaceContainerLowest,
        indicatorColor: Theme.of(context).colorScheme.primaryContainer.withValues(alpha: 0.28),
        height: 76,
        destinations: [
          NavigationDestination(
            icon: const Icon(Icons.home_outlined),
            selectedIcon: const Icon(Icons.home),
            label: AppLocalization.tr(context, 'home'),
          ),
          NavigationDestination(
            icon: const Icon(Icons.route_outlined),
            selectedIcon: const Icon(Icons.route),
            label: AppLocalization.tr(context, 'trips'),
          ),
          const NavigationDestination(
            icon: Icon(Icons.auto_awesome_outlined),
            selectedIcon: Icon(Icons.auto_awesome),
            label: 'AI Planner',
          ),
          const NavigationDestination(
            icon: Icon(Icons.checklist_outlined),
            selectedIcon: Icon(Icons.checklist_rounded),
            label: 'Saved Plans',
          ),
          NavigationDestination(
            icon: const Icon(Icons.bookmark_outline),
            selectedIcon: const Icon(Icons.bookmark),
            label: AppLocalization.tr(context, 'favorites'),
          ),
          NavigationDestination(
            icon: const Icon(Icons.business_outlined),
            selectedIcon: const Icon(Icons.business),
            label: 'Directory',
          ),
        ],
      ),
    );
  }
}

void openDestinationDetails(BuildContext context, Destination destination) {
  Navigator.of(context).push(
    MaterialPageRoute<void>(
      builder: (_) => DestinationDetailsScreen(destination: destination),
    ),
  );
}

void openOfflineMap(BuildContext context) {
  Navigator.of(context).push(
    MaterialPageRoute<void>(builder: (_) => const MapScreen()),
  );
}
