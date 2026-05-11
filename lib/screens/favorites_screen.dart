import 'package:flutter/material.dart';

import '../app.dart';
import '../state/app_localization.dart';
import '../state/app_scope.dart';
import '../widgets/ui_components.dart';

class FavoritesScreen extends StatelessWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = AppStateScope.watch(context);
    final favorites = state.favorites;
    final scheme = Theme.of(context).colorScheme;

    return ListView(
      padding: EdgeInsets.fromLTRB(20, MediaQuery.paddingOf(context).top + 84, 20, 20),
      children: [
        Row(
          children: [
            Expanded(
              child: Text(AppLocalization.tr(context, 'saved_places'), style: Theme.of(context).textTheme.headlineMedium),
            ),
            OfflineChip(label: '${favorites.length} saved'),
          ],
        ),
        const SizedBox(height: 14),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: [
            CategoryPill(label: 'All', icon: Icons.filter_alt_outlined, color: Theme.of(context).colorScheme.primary, selected: true),
            CategoryPill(label: 'Destinations', icon: Icons.landscape_outlined, color: Theme.of(context).colorScheme.tertiary),
            CategoryPill(label: 'Hotels', icon: Icons.hotel_outlined, color: Theme.of(context).colorScheme.secondary),
            CategoryPill(label: 'Cultural Sites', icon: Icons.account_balance_outlined, color: Theme.of(context).colorScheme.primary),
          ],
        ),
        const SizedBox(height: 18),
        if (favorites.isEmpty)
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: scheme.surfaceContainerLowest,
              borderRadius: BorderRadius.circular(28),
              border: Border.all(color: scheme.outline.withValues(alpha: 0.2)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.bookmark_border_rounded, color: scheme.primary),
                const SizedBox(height: 12),
                Text(AppLocalization.tr(context, 'no_saved_places'), style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
                const SizedBox(height: 6),
                Text('Save a destination from its details page and it will appear here offline.'),
              ],
            ),
          )
        else
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: favorites.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 0.75,
            ),
            itemBuilder: (context, index) {
              final destination = favorites[index];
              return DestinationCard(
                destination: destination,
                compact: true,
                onTap: () => openDestinationDetails(context, destination),
              );
            },
          ),
        const SizedBox(height: 12),
      ],
    );
  }
}
