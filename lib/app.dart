import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'state/app_scope.dart';
import 'state/app_state.dart';
import 'screens/favorites_screen.dart';
import 'screens/home_screen.dart';
import 'screens/map_screen.dart';
import 'screens/directory_screen.dart';
import 'screens/splash_screen.dart';
import 'screens/trip_planner_screen.dart';
import 'screens/ai_trip_planner_screen.dart';
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
    FavoritesScreen(),
    DirectoryScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        centerTitle: false,
        elevation: 0,
        scrolledUnderElevation: 0,
        backgroundColor: Theme.of(context).colorScheme.surface,
        surfaceTintColor: Colors.transparent,
        titleSpacing: 20,
        title: Text(
          'Discover Ethiopia',
          style: TextStyle(
            color: Theme.of(context).colorScheme.primary,
            fontSize: 24,
            fontWeight: FontWeight.w800,
            letterSpacing: -0.4,
          ),
        ),
        actions: [
          IconButton(
            tooltip: 'Toggle dark mode',
            onPressed: () => AppStateScope.read(context).toggleThemeMode(),
            icon: Icon(
              AppStateScope.watch(context).themeMode == ThemeMode.dark
                  ? Icons.dark_mode_rounded
                  : Icons.light_mode_rounded,
            ),
          ),
          const SizedBox(width: 8),
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
