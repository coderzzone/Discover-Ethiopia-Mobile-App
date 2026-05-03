import 'package:flutter/material.dart';

import '../app.dart';
import '../data/sample_data.dart';
import '../models/app_models.dart';
import '../screens/insight_detail_screen.dart';
import '../state/app_localization.dart';
import '../state/app_scope.dart';
import '../widgets/ui_components.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = AppStateScope.watch(context);

    if (_controller.text != state.searchQuery) {
      _controller.value = TextEditingValue(
        text: state.searchQuery,
        selection: TextSelection.collapsed(offset: state.searchQuery.length),
      );
    }

    final destinations = state.filteredDestinations;

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 20),
      children: [
        // 1. Search Bar
        TextField(
          controller: _controller,
          decoration: InputDecoration(
            hintText: AppLocalization.tr(context, 'search_destinations'),
            prefixIcon: const Icon(Icons.search_rounded),
            suffixIcon: Container(
              margin: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: EthioColors.primaryContainer.withValues(alpha: 0.30),
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Icon(Icons.tune_rounded, color: EthioColors.primary),
            ),
          ),
          onChanged: state.setSearchQuery,
        ),
        const SizedBox(height: 10),
        Align(
          alignment: Alignment.centerRight,
          child: OfflineChip(
            label: '${state.favorites.length} saved · ${state.tripDestinations.length} trip stops',
            color: EthioColors.secondary,
          ),
        ),
        const SizedBox(height: 26),

        // 2. Categories
        SectionHeader(title: AppLocalization.tr(context, 'categories')),
        const SizedBox(height: 14),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: state.categories.map((cat) => CategoryPill(
            label: cat,
            icon: _categoryIcon(cat),
            color: _categoryColor(cat),
            selected: state.selectedCategory == cat,
            onTap: () => state.setCategory(cat),
          )).toList(),
        ),
        const SizedBox(height: 28),

        // 3. Featured Destinations
        SectionHeader(
          title: AppLocalization.tr(context, 'featured_destinations'),
          actionLabel: AppLocalization.tr(context, 'map'),
          onAction: () => openOfflineMap(context),
        ),
        const SizedBox(height: 16),
        if (destinations.isEmpty)
          _buildEmptyState()
        else
          SizedBox(
            height: 360,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: destinations.length,
              clipBehavior: Clip.none,
              separatorBuilder: (context, index) => const SizedBox(width: 16),
              itemBuilder: (context, index) {
                final destination = destinations[index];
                return SizedBox(
                  width: 270,
                  child: DestinationCard(
                    destination: destination,
                    onTap: () => openDestinationDetails(context, destination),
                  ),
                );
              },
            ),
          ),
        const SizedBox(height: 32),

        // 4. Quick Insights — now interactive
        SectionHeader(
          title: AppLocalization.tr(context, 'quick_insights'),
          subtitle: 'Tap to explore Ethiopian culture',
        ),
        const SizedBox(height: 14),
        GridView.count(
          crossAxisCount: 2,
          crossAxisSpacing: 14,
          mainAxisSpacing: 14,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          childAspectRatio: 0.95,
          children: sampleInsights.map((insight) => _InsightCard(
            insight: insight,
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (_) => InsightDetailScreen(insight: insight),
              ),
            ),
          )).toList(),
        ),
        const SizedBox(height: 24),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 40),
      alignment: Alignment.center,
      child: Column(children: [
        Icon(Icons.search_off_rounded, size: 48, color: EthioColors.mutedInk.withValues(alpha: 0.5)),
        const SizedBox(height: 12),
        const Text('No matching destinations found',
            style: TextStyle(fontWeight: FontWeight.w700, color: EthioColors.mutedInk)),
      ]),
    );
  }

  IconData _categoryIcon(String category) {
    switch (category) {
      case 'Nature': return Icons.park_outlined;
      case 'Culture': return Icons.festival_outlined;
      case 'Historical': return Icons.account_balance_outlined;
      case 'Cities': return Icons.location_city_outlined;
      default: return Icons.travel_explore_outlined;
    }
  }

  Color _categoryColor(String category) {
    switch (category) {
      case 'Nature': return EthioColors.secondary;
      case 'Culture': return EthioColors.primary;
      case 'Historical': return EthioColors.tertiary;
      case 'Cities': return EthioColors.ink;
      default: return EthioColors.primary;
    }
  }
}

// ── Insight card — tappable, shows photo preview ─────────────────────────────

class _InsightCard extends StatelessWidget {
  const _InsightCard({required this.insight, required this.onTap});
  final CulturalInsight insight;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: insight.color.withValues(alpha: 0.14)),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: Stack(
            fit: StackFit.expand,
            children: [
              // Background image or color
              if (insight.imagePaths.isNotEmpty)
                Image.asset(insight.imagePaths.first, fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(color: insight.color.withValues(alpha: 0.10)))
              else
                Container(color: insight.color.withValues(alpha: 0.10)),
              // Dark gradient overlay
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Colors.black.withValues(alpha: 0.65),
                    ],
                  ),
                ),
              ),
              // Top icon badge
              Positioned(
                top: 12, left: 12,
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: insight.color.withValues(alpha: 0.85),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(insight.icon, color: Colors.white, size: 18),
                ),
              ),
              // Photo count badge
              if (insight.imagePaths.length > 1)
                Positioned(
                  top: 12, right: 12,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.45),
                      borderRadius: BorderRadius.circular(99),
                    ),
                    child: Row(mainAxisSize: MainAxisSize.min, children: [
                      const Icon(Icons.photo_library_outlined, color: Colors.white, size: 12),
                      const SizedBox(width: 4),
                      Text('${insight.imagePaths.length}',
                          style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w700)),
                    ]),
                  ),
                ),
              // Bottom text
              Positioned(
                left: 12, right: 12, bottom: 12,
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(insight.label.toUpperCase(),
                      style: TextStyle(color: Colors.white.withValues(alpha: 0.75), fontSize: 9,
                          fontWeight: FontWeight.w800, letterSpacing: 1.0)),
                  const SizedBox(height: 4),
                  Text(insight.title,
                      style: const TextStyle(color: Colors.white, fontSize: 14,
                          fontWeight: FontWeight.w800, height: 1.2),
                      maxLines: 2, overflow: TextOverflow.ellipsis),
                ]),
              ),
              // Tap ripple overlay
              Positioned.fill(
                child: Material(color: Colors.transparent,
                    child: InkWell(onTap: onTap, borderRadius: BorderRadius.circular(24))),
              ),
            ],
          ),
        ),
      ),
    );
  }
}