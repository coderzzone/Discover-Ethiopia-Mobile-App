import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import '../models/app_models.dart';
import '../widgets/ui_components.dart';

class InsightDetailScreen extends StatefulWidget {
  const InsightDetailScreen({super.key, required this.insight});

  final CulturalInsight insight;

  @override
  State<InsightDetailScreen> createState() => _InsightDetailScreenState();
}

class _InsightDetailScreenState extends State<InsightDetailScreen> {
  final PageController _pageController = PageController();
  final PageController _journalController = PageController(viewportFraction: 0.9);
  int _currentPage = 0;
  int _journalPage = 0;

  void _goToPage(int index, int total) {
    if (total <= 1) return;
    final clamped = index.clamp(0, total - 1);
    if (clamped == _currentPage) return;
    _pageController.animateToPage(
      clamped,
      duration: const Duration(milliseconds: 260),
      curve: Curves.easeOutCubic,
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    _journalController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final insight = widget.insight;
    final scheme = Theme.of(context).colorScheme;
    final photos = insight.imagePaths;
    final meta = _insightMeta(insight.id);

    return Scaffold(
      backgroundColor: scheme.surface,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          // ── Photo carousel SliverAppBar ──────────────────
          SliverAppBar(
            expandedHeight: 320,
            pinned: true,
            stretch: true,
            backgroundColor: insight.color,
            surfaceTintColor: Colors.transparent,
            leading: Padding(
              padding: const EdgeInsets.only(left: 12),
              child: _GlassCircleButton(
                icon: Icons.arrow_back_rounded,
                onTap: () => Navigator.of(context).maybePop(),
              ),
            ),
            flexibleSpace: FlexibleSpaceBar(
              stretchModes: const [StretchMode.zoomBackground],
              background: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onHorizontalDragEnd: (details) {
                  final velocity = details.primaryVelocity ?? 0;
                  if (velocity < -120) {
                    _goToPage(_currentPage + 1, photos.length);
                  } else if (velocity > 120) {
                    _goToPage(_currentPage - 1, photos.length);
                  }
                },
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    // Photo PageView
                    PageView.builder(
                      controller: _pageController,
                      physics: const PageScrollPhysics(),
                      allowImplicitScrolling: true,
                      itemCount: photos.isEmpty ? 1 : photos.length,
                      onPageChanged: (i) => setState(() => _currentPage = i),
                      itemBuilder: (context, index) {
                        if (photos.isEmpty) {
                          return _InsightHeroArt(insight: insight);
                        }
                        return Image.asset(
                          photos[index],
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) => _InsightHeroArt(insight: insight),
                        );
                      },
                    ),
                    // Gradient overlay
                    Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.black.withValues(alpha: 0.25),
                            Colors.transparent,
                            Colors.black.withValues(alpha: 0.55),
                          ],
                        ),
                      ),
                    ),
                    // Page dots
                    if (photos.length > 1)
                      Positioned(
                        bottom: 18,
                        left: 0,
                        right: 0,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: List.generate(photos.length, (i) {
                            return AnimatedContainer(
                              duration: const Duration(milliseconds: 250),
                              margin: const EdgeInsets.symmetric(horizontal: 4),
                              width: _currentPage == i ? 22 : 8,
                              height: 8,
                              decoration: BoxDecoration(
                                color: _currentPage == i
                                    ? Colors.white
                                    : Colors.white.withValues(alpha: 0.4),
                                borderRadius: BorderRadius.circular(99),
                              ),
                            );
                          }),
                        ),
                      ),
                    // Label badge
                    Positioned(
                      top: 16,
                      right: 16,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.18),
                          borderRadius: BorderRadius.circular(99),
                          border: Border.all(color: Colors.white.withValues(alpha: 0.3)),
                        ),
                        child: Text(
                          insight.label.toUpperCase(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 1.2,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // ── Content ──────────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 40),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header card
                  Transform.translate(
                    offset: const Offset(0, -20),
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(22),
                      decoration: BoxDecoration(
                        color: scheme.surfaceContainerLowest,
                        borderRadius: BorderRadius.circular(28),
                        boxShadow: [
                          BoxShadow(
                            color: scheme.shadow.withValues(alpha: 0.08),
                            blurRadius: 24,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: insight.color.withValues(alpha: 0.12),
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: Icon(insight.icon, color: insight.color, size: 26),
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      insight.title,
                                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                            fontWeight: FontWeight.w800,
                                          ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      insight.subtitle,
                                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                            color: scheme.onSurfaceVariant,
                                          ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Divider(height: 1, color: scheme.outlineVariant.withValues(alpha: 0.6)),
                          const SizedBox(height: 16),
                          Text(
                            insight.description,
                            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                  height: 1.6,
                                  color: scheme.onSurface.withValues(alpha: 0.88),
                                ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Info pills row
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        _InfoPill(icon: Icons.calendar_month_rounded, label: 'When', value: insight.when),
                        const SizedBox(width: 12),
                        _InfoPill(icon: Icons.location_on_rounded, label: 'Where', value: insight.where),
                        const SizedBox(width: 12),
                        _InfoPill(icon: Icons.confirmation_number_outlined, label: 'Entry', value: insight.entryFee),
                        const SizedBox(width: 12),
                        _InfoPill(icon: Icons.timelapse_rounded, label: 'Duration', value: insight.duration),
                      ],
                    ),
                  ),

                  const SizedBox(height: 28),

                  // History section
                  _DetailSection(
                    icon: Icons.history_edu_rounded,
                    title: 'History & Background',
                    color: insight.color,
                    content: insight.history,
                  ),

                  const SizedBox(height: 20),

                  // Tips section
                  _DetailSection(
                    icon: Icons.tips_and_updates_rounded,
                    title: 'Visitor Tips',
                    color: EthioColors.tertiary,
                    content: insight.tipText,
                  ),

                  const SizedBox(height: 22),
                  _SectionLabel(title: 'Quick Facts'),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: [
                      _MiniFact(icon: Icons.verified_rounded, title: 'Status', value: meta.status),
                      _MiniFact(icon: Icons.map_rounded, title: 'Access', value: meta.access),
                      _MiniFact(icon: Icons.people_alt_rounded, title: 'Best For', value: meta.bestFor),
                    ],
                  ),

                  const SizedBox(height: 22),
                  _SectionLabel(title: 'Photo Journal'),
                  const SizedBox(height: 12),
                  GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onHorizontalDragEnd: (details) {
                      final velocity = details.primaryVelocity ?? 0;
                      if (velocity < -120) {
                        final next = (_journalPage + 1).clamp(0, photos.length - 1);
                        _journalController.animateToPage(next, duration: const Duration(milliseconds: 260), curve: Curves.easeOutCubic);
                      } else if (velocity > 120) {
                        final prev = (_journalPage - 1).clamp(0, photos.length - 1);
                        _journalController.animateToPage(prev, duration: const Duration(milliseconds: 260), curve: Curves.easeOutCubic);
                      }
                    },
                    child: SizedBox(
                      height: 180,
                      child: PageView.builder(
                        controller: _journalController,
                        itemCount: photos.isEmpty ? 1 : photos.length,
                        onPageChanged: (i) => setState(() => _journalPage = i),
                        itemBuilder: (context, i) {
                          return Padding(
                            padding: const EdgeInsets.only(right: 10),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(20),
                              child: Stack(
                                fit: StackFit.expand,
                                children: [
                                  if (photos.isNotEmpty)
                                    Image.asset(
                                      photos[i],
                                      fit: BoxFit.cover,
                                      errorBuilder: (context, error, stackTrace) => _InsightHeroArt(insight: insight),
                                    )
                                  else
                                    _InsightHeroArt(insight: insight),
                                  Positioned(
                                    left: 12,
                                    bottom: 10,
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                      decoration: BoxDecoration(
                                        color: Colors.black.withValues(alpha: 0.45),
                                        borderRadius: BorderRadius.circular(99),
                                      ),
                                      child: Text('Frame ${i + 1}', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 12)),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                  if (photos.length > 1) ...[
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(photos.length, (i) {
                        return AnimatedContainer(
                          duration: const Duration(milliseconds: 180),
                          margin: const EdgeInsets.symmetric(horizontal: 3),
                          width: _journalPage == i ? 18 : 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: _journalPage == i ? insight.color : insight.color.withValues(alpha: 0.35),
                            borderRadius: BorderRadius.circular(20),
                          ),
                        );
                      }),
                    ),
                  ],

                  const SizedBox(height: 22),
                  _SectionLabel(title: 'Travel Essentials'),
                  const SizedBox(height: 10),
                  _InsightEssentials(meta: meta),

                  const SizedBox(height: 22),
                  _SectionLabel(title: 'Related Highlights'),
                  const SizedBox(height: 10),
                  ...meta.highlights.map((h) => Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: _HighlightRow(text: h, color: insight.color),
                      )),

                  const SizedBox(height: 28),

                  // Map section
                  _SectionLabel(title: 'Location'),
                  const SizedBox(height: 12),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(24),
                    child: SizedBox(
                      height: 260,
                      child: FlutterMap(
                        options: MapOptions(
                          initialCenter: LatLng(insight.lat, insight.lng),
                          initialZoom: 9,
                          interactionOptions: const InteractionOptions(
                            flags: InteractiveFlag.pinchZoom | InteractiveFlag.drag,
                          ),
                        ),
                        children: [
                          TileLayer(
                            urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                            userAgentPackageName: 'com.example.ethio_explore',
                          ),
                          MarkerLayer(
                            markers: [
                              Marker(
                                point: LatLng(insight.lat, insight.lng),
                                width: 56,
                                height: 56,
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(10),
                                      decoration: BoxDecoration(
                                        color: insight.color,
                                        borderRadius: BorderRadius.circular(14),
                                        boxShadow: [
                                          BoxShadow(
                                            color: insight.color.withValues(alpha: 0.4),
                                            blurRadius: 12,
                                            offset: const Offset(0, 4),
                                          ),
                                        ],
                                      ),
                                      child: Icon(insight.icon, color: Colors.white, size: 18),
                                    ),
                                    Container(width: 2, height: 8, color: insight.color),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Photo swipe hint (if multiple photos)
                  if (photos.length > 1)
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: insight.color.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(color: insight.color.withValues(alpha: 0.14)),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.swipe_rounded, color: insight.color, size: 22),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'Swipe the hero photo to see ${photos.length} images from this cultural experience.',
                              style: TextStyle(color: insight.color, fontWeight: FontWeight.w600, fontSize: 13),
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Fallback hero art when no image ─────────────────────────────────────────

class _InsightHeroArt extends StatelessWidget {
  const _InsightHeroArt({required this.insight});
  final CulturalInsight insight;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: insight.color.withValues(alpha: 0.15),
      child: Center(
        child: Icon(insight.icon, size: 80, color: insight.color.withValues(alpha: 0.5)),
      ),
    );
  }
}

// ── Detail section card ──────────────────────────────────────────────────────

class _DetailSection extends StatelessWidget {
  const _DetailSection({
    required this.icon,
    required this.title,
    required this.color,
    required this.content,
  });

  final IconData icon;
  final String title;
  final Color color;
  final String content;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: scheme.outlineVariant.withValues(alpha: 0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 20),
              const SizedBox(width: 10),
              Text(
                title,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            content,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  height: 1.7,
                  color: scheme.onSurface.withValues(alpha: 0.82),
                ),
          ),
        ],
      ),
    );
  }
}

// ── Info pill ────────────────────────────────────────────────────────────────

class _InfoPill extends StatelessWidget {
  const _InfoPill({required this.icon, required this.label, required this.value});
  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: scheme.outlineVariant.withValues(alpha: 0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 14, color: scheme.primary),
              const SizedBox(width: 6),
              Text(
                label.toUpperCase(),
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w800,
                  color: scheme.onSurfaceVariant,
                  letterSpacing: 0.8,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 200),
            child: Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Section label ────────────────────────────────────────────────────────────

class _SectionLabel extends StatelessWidget {
  const _SectionLabel({required this.title});
  final String title;

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
    );
  }
}

// ── Glass circle button ──────────────────────────────────────────────────────

class _GlassCircleButton extends StatelessWidget {
  const _GlassCircleButton({required this.icon, required this.onTap});
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 42,
        height: 42,
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.2),
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white.withValues(alpha: 0.3)),
        ),
        child: Icon(icon, color: Colors.white, size: 20),
      ),
    );
  }
}

class _MiniFact extends StatelessWidget {
  const _MiniFact({required this.icon, required this.title, required this.value});
  final IconData icon;
  final String title;
  final String value;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: scheme.outlineVariant.withValues(alpha: 0.5)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 15, color: scheme.primary),
          const SizedBox(width: 6),
          Text('$title: ', style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 12)),
          Text(value, style: const TextStyle(fontSize: 12)),
        ],
      ),
    );
  }
}

class _InsightEssentials extends StatelessWidget {
  const _InsightEssentials({required this.meta});
  final _InsightMeta meta;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final rows = <_EssentialRowData>[
      _EssentialRowData('Climate', meta.climate, Icons.wb_sunny_rounded),
      _EssentialRowData('Season', meta.season, Icons.event_rounded),
      _EssentialRowData('Transport', meta.transport, Icons.directions_bus_rounded),
      _EssentialRowData('Network', meta.network, Icons.network_cell_rounded),
    ];

    return Column(
      children: rows
          .map(
            (row) => Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: scheme.surfaceContainerLowest,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Icon(row.icon, size: 17, color: scheme.secondary),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text('${row.title}: ${row.value}', style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                  ),
                ],
              ),
            ),
          )
          .toList(),
    );
  }
}

class _HighlightRow extends StatelessWidget {
  const _HighlightRow({required this.text, required this.color});
  final String text;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(Icons.auto_awesome_rounded, size: 16, color: color),
          const SizedBox(width: 8),
          Expanded(child: Text(text, style: const TextStyle(fontWeight: FontWeight.w600))),
        ],
      ),
    );
  }
}

class _EssentialRowData {
  const _EssentialRowData(this.title, this.value, this.icon);
  final String title;
  final String value;
  final IconData icon;
}

class _InsightMeta {
  const _InsightMeta({
    required this.status,
    required this.access,
    required this.bestFor,
    required this.climate,
    required this.season,
    required this.transport,
    required this.network,
    required this.highlights,
  });

  final String status;
  final String access;
  final String bestFor;
  final String climate;
  final String season;
  final String transport;
  final String network;
  final List<String> highlights;
}

_InsightMeta _insightMeta(String id) {
  if (id == 'timkat') {
    return const _InsightMeta(
      status: 'UNESCO Intangible Heritage',
      access: 'Open public event',
      bestFor: 'Culture + photography',
      climate: 'Cool mornings in January',
      season: 'Jan 18-20',
      transport: 'Best by local taxi/walk',
      network: 'Strong in major cities',
      highlights: [
        'Dawn blessing ceremony draws massive local participation.',
        'White-robed processions create unique visual storytelling.',
        'Gondar and Lalibela offer the richest festival atmosphere.',
      ],
    );
  }

  return const _InsightMeta(
    status: 'Living Cultural Experience',
    access: 'Guided / local participation',
    bestFor: 'History + local immersion',
    climate: 'Varies by region',
    season: 'Oct-May recommended',
    transport: 'Domestic flight + road transfer',
    network: 'Urban strong, rural patchy',
    highlights: [
      'Authentic interaction with local communities.',
      'Strong historical context linked to place identity.',
      'Great pairing with nearby destination itineraries.',
    ],
  );
}
