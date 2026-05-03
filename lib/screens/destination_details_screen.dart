import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import '../models/app_models.dart';
import '../state/app_scope.dart';
import '../widgets/ui_components.dart';

class DestinationDetailsScreen extends StatefulWidget {
  const DestinationDetailsScreen({super.key, required this.destination});

  final Destination destination;

  @override
  State<DestinationDetailsScreen> createState() => _DestinationDetailsScreenState();
}

class _DestinationDetailsScreenState extends State<DestinationDetailsScreen> {
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

  void _goToJournalPage(int index, int total) {
    if (total <= 1) return;
    final clamped = index.clamp(0, total - 1);
    if (clamped == _journalPage) return;
    _journalController.animateToPage(
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
    final state = AppStateScope.watch(context);
    final inTrip = state.isInTrip(widget.destination.id);
    final saved = state.isFavorite(widget.destination.id);
    final photos = widget.destination.imagePaths.isNotEmpty
        ? widget.destination.imagePaths
        : [widget.destination.imageUrl];
    final meta = _destinationMeta(widget.destination.id);

    return Scaffold(
      backgroundColor: EthioColors.background,
      bottomNavigationBar: _BottomActionArea(
        destination: widget.destination,
        inTrip: inTrip,
        saved: saved,
        onTripToggle: () {
          if (inTrip) {
            state.removeFromTrip(widget.destination);
          } else {
            state.addToTrip(widget.destination);
          }
        },
        onFavoriteToggle: () => state.toggleFavorite(widget.destination),
      ),
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          SliverAppBar(
            pinned: true,
            stretch: true,
            expandedHeight: 340,
            backgroundColor: widget.destination.accent,
            surfaceTintColor: Colors.transparent,
            leadingWidth: 70,
            leading: Padding(
              padding: const EdgeInsets.only(left: 16),
              child: _GlassIconButton(
                onPressed: () => Navigator.of(context).maybePop(),
                icon: Icons.arrow_back_rounded,
              ),
            ),
            actions: [
              Padding(
                padding: const EdgeInsets.only(right: 16),
                child: _GlassIconButton(
                  onPressed: () => state.toggleFavorite(widget.destination),
                  icon: saved ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                  color: saved ? EthioColors.error : Colors.white,
                ),
              ),
            ],
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
                    PageView.builder(
                      controller: _pageController,
                      physics: const PageScrollPhysics(),
                      allowImplicitScrolling: true,
                      itemCount: photos.length,
                      onPageChanged: (i) => setState(() => _currentPage = i),
                      itemBuilder: (context, index) {
                        return Image.asset(
                          photos[index],
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) => Container(
                            color: widget.destination.accent.withValues(alpha: 0.15),
                            child: Icon(Icons.landscape_rounded, color: widget.destination.accent, size: 64),
                          ),
                        );
                      },
                    ),
                    Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.black.withValues(alpha: 0.3),
                            Colors.transparent,
                            Colors.black.withValues(alpha: 0.6),
                          ],
                        ),
                      ),
                    ),
                    if (photos.length > 1)
                      Positioned(
                        bottom: 30,
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
                  ],
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Transform.translate(
                    offset: const Offset(0, -20),
                    child: _HeaderCard(destination: widget.destination),
                  ),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        _InfoPill(
                          label: 'Entry fee',
                          value: widget.destination.entryFee,
                          icon: Icons.confirmation_number_outlined,
                        ),
                        const SizedBox(width: 12),
                        _InfoPill(
                          label: 'Best time',
                          value: widget.destination.bestTimeToVisit,
                          icon: Icons.wb_sunny_outlined,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),
                  const _SectionHeader(title: 'History'),
                  _ContentCard(text: widget.destination.history),
                  const SizedBox(height: 24),
                  const _SectionHeader(title: 'Travel tips'),
                  _ContentCard(text: widget.destination.tips),
                  const SizedBox(height: 24),
                  const _SectionHeader(title: 'Quick Facts'),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: [
                      _FactChip(icon: Icons.location_city_rounded, label: 'From Addis', value: meta.capitalDistance),
                      _FactChip(icon: Icons.verified_rounded, label: 'UNESCO', value: meta.unescoStatus),
                      _FactChip(icon: Icons.terrain_rounded, label: 'Altitude', value: meta.altitude),
                    ],
                  ),
                  const SizedBox(height: 24),
                  const _SectionHeader(title: 'Location'),
                  const SizedBox(height: 12),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(24),
                    child: SizedBox(
                      height: 230,
                      child: FlutterMap(
                        options: MapOptions(
                          initialCenter: LatLng(widget.destination.lat, widget.destination.lng),
                          initialZoom: 10,
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
                                point: LatLng(widget.destination.lat, widget.destination.lng),
                                width: 56,
                                height: 56,
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(10),
                                      decoration: BoxDecoration(
                                        color: widget.destination.accent,
                                        borderRadius: BorderRadius.circular(14),
                                        boxShadow: [
                                          BoxShadow(
                                            color: widget.destination.accent.withValues(alpha: 0.4),
                                            blurRadius: 12,
                                            offset: const Offset(0, 4),
                                          ),
                                        ],
                                      ),
                                      child: const Icon(Icons.location_on_rounded, color: Colors.white, size: 18),
                                    ),
                                    Container(width: 2, height: 8, color: widget.destination.accent),
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
                  const _SectionHeader(title: 'Photo Journal'),
                  const SizedBox(height: 12),
                  GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onHorizontalDragEnd: (details) {
                      final velocity = details.primaryVelocity ?? 0;
                      if (velocity < -120) {
                        _goToJournalPage(_journalPage + 1, photos.length);
                      } else if (velocity > 120) {
                        _goToJournalPage(_journalPage - 1, photos.length);
                      }
                    },
                    child: SizedBox(
                      height: 190,
                      child: PageView.builder(
                        controller: _journalController,
                        itemCount: photos.length,
                        onPageChanged: (i) => setState(() => _journalPage = i),
                        itemBuilder: (context, i) {
                          return Padding(
                            padding: const EdgeInsets.only(right: 10),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(22),
                              child: Stack(
                                fit: StackFit.expand,
                                children: [
                                  Image.asset(
                                    photos[i],
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) => Container(
                                      color: widget.destination.accent.withValues(alpha: 0.15),
                                      child: Icon(Icons.photo_library_rounded, color: widget.destination.accent, size: 36),
                                    ),
                                  ),
                                  Container(
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        begin: Alignment.topCenter,
                                        end: Alignment.bottomCenter,
                                        colors: [
                                          Colors.transparent,
                                          Colors.black.withValues(alpha: 0.5),
                                        ],
                                      ),
                                    ),
                                  ),
                                  Positioned(
                                    left: 14,
                                    bottom: 12,
                                    child: Text(
                                      'Moment ${i + 1}',
                                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800),
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
                          duration: const Duration(milliseconds: 200),
                          margin: const EdgeInsets.symmetric(horizontal: 3),
                          width: _journalPage == i ? 20 : 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: _journalPage == i ? widget.destination.accent : widget.destination.accent.withValues(alpha: 0.35),
                            borderRadius: BorderRadius.circular(20),
                          ),
                        );
                      }),
                    ),
                  ],
                  const SizedBox(height: 24),
                  const _SectionHeader(title: 'Travel Essentials'),
                  const SizedBox(height: 10),
                  _EssentialsGrid(meta: meta),
                  const SizedBox(height: 24),
                  const _SectionHeader(title: 'Nearby Hotels'),
                  const SizedBox(height: 10),
                  ...meta.nearbyHotels.map(
                    (hotel) => Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: _TravelNoteRow(
                        icon: Icons.hotel_rounded,
                        title: hotel,
                        color: EthioColors.secondary,
                      ),
                    ),
                  ),
                  const SizedBox(height: 18),
                  const _SectionHeader(title: 'Travel Notes'),
                  const SizedBox(height: 10),
                  ...meta.travelNotes.map(
                    (note) => Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: _TravelNoteRow(
                        icon: note.icon,
                        title: note.text,
                        color: widget.destination.accent,
                      ),
                    ),
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _FactChip extends StatelessWidget {
  const _FactChip({required this.icon, required this.label, required this.value});
  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: EthioColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: EthioColors.outline.withValues(alpha: 0.12)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: EthioColors.primary),
          const SizedBox(width: 8),
          Text('$label: ', style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 12)),
          Text(value, style: const TextStyle(fontSize: 12)),
        ],
      ),
    );
  }
}

class _EssentialsGrid extends StatelessWidget {
  const _EssentialsGrid({required this.meta});
  final _DestinationMeta meta;

  @override
  Widget build(BuildContext context) {
    final cards = <_EssentialData>[
      _EssentialData('Climate', meta.climate, Icons.wb_cloudy_rounded, EthioColors.tertiary),
      _EssentialData('Best Season', meta.bestSeason, Icons.event_available_rounded, EthioColors.secondary),
      _EssentialData('Transport', meta.transport, Icons.directions_bus_rounded, EthioColors.primary),
      _EssentialData('Stay', meta.stay, Icons.night_shelter_rounded, EthioColors.primary),
      _EssentialData('Network', meta.network, Icons.network_cell_rounded, EthioColors.secondary),
      _EssentialData('Security', meta.security, Icons.gpp_good_rounded, EthioColors.tertiary),
    ];

    return GridView.builder(
      itemCount: cards.length,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 10,
        crossAxisSpacing: 10,
        childAspectRatio: 1.75,
      ),
      itemBuilder: (context, index) {
        final item = cards[index];
        return Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: EthioColors.surfaceContainerLowest,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: EthioColors.outline.withValues(alpha: 0.1)),
          ),
          child: Row(
            children: [
              CircleAvatar(
                radius: 16,
                backgroundColor: item.color.withValues(alpha: 0.14),
                child: Icon(item.icon, size: 16, color: item.color),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(item.title, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: EthioColors.mutedInk)),
                    const SizedBox(height: 3),
                    Text(item.value, maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 12)),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _TravelNoteRow extends StatelessWidget {
  const _TravelNoteRow({required this.icon, required this.title, required this.color});
  final IconData icon;
  final String title;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: EthioColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Icon(icon, size: 18, color: color),
          const SizedBox(width: 10),
          Expanded(child: Text(title, style: const TextStyle(fontWeight: FontWeight.w600))),
        ],
      ),
    );
  }
}

class _EssentialData {
  const _EssentialData(this.title, this.value, this.icon, this.color);
  final String title;
  final String value;
  final IconData icon;
  final Color color;
}

class _TravelNote {
  const _TravelNote(this.icon, this.text);
  final IconData icon;
  final String text;
}

class _DestinationMeta {
  const _DestinationMeta({
    required this.capitalDistance,
    required this.unescoStatus,
    required this.altitude,
    required this.climate,
    required this.bestSeason,
    required this.transport,
    required this.stay,
    required this.network,
    required this.security,
    required this.nearbyHotels,
    required this.travelNotes,
  });

  final String capitalDistance;
  final String unescoStatus;
  final String altitude;
  final String climate;
  final String bestSeason;
  final String transport;
  final String stay;
  final String network;
  final String security;
  final List<String> nearbyHotels;
  final List<_TravelNote> travelNotes;
}

_DestinationMeta _destinationMeta(String id) {
  const defaults = _DestinationMeta(
    capitalDistance: '600-750 km',
    unescoStatus: 'Partially listed',
    altitude: '2,000-2,600 m',
    climate: 'Mild highland',
    bestSeason: 'Oct-May',
    transport: 'Road + domestic flight',
    stay: 'Hotels and guesthouses',
    network: '4G in towns, weak rural',
    security: 'Moderate, guide advised',
    nearbyHotels: ['Lali Hotel', 'Goha Hotel', 'Kuriftu Resort & Spa'],
    travelNotes: [
      _TravelNote(Icons.water_drop_rounded, 'Carry refillable water and sun protection.'),
      _TravelNote(Icons.hiking_rounded, 'Wear walking shoes with strong grip.'),
      _TravelNote(Icons.payments_rounded, 'Keep some cash for local fees and guides.'),
    ],
  );

  if (id == 'lalibela') {
    return const _DestinationMeta(
      capitalDistance: '645 km from Addis Ababa',
      unescoStatus: 'UNESCO World Heritage',
      altitude: '2,630 m',
      climate: 'Cool highland days',
      bestSeason: 'Oct-Mar',
      transport: 'Daily flights + road access',
      stay: 'Boutique hotels near churches',
      network: 'Good 4G in town center',
      security: 'High, tourist friendly',
      nearbyHotels: ['Lali Hotel', 'Jerusalem Hotel', 'Sora Lodge'],
      travelNotes: [
        _TravelNote(Icons.church_rounded, 'Early mornings are best for church visits.'),
        _TravelNote(Icons.camera_alt_rounded, 'Ask before photographing ceremonies.'),
        _TravelNote(Icons.air_rounded, 'Bring a light jacket for cool evenings.'),
      ],
    );
  }
  if (id == 'simien_mountains') {
    return const _DestinationMeta(
      capitalDistance: '780 km from Addis Ababa',
      unescoStatus: 'UNESCO World Heritage',
      altitude: '3,000-4,500 m',
      climate: 'Cold mornings, sunny afternoons',
      bestSeason: 'Oct-May',
      transport: 'Fly to Gondar + 4x4 transfer',
      stay: 'Mountain lodges and camps',
      network: 'Patchy beyond base camp',
      security: 'High with registered guides',
      nearbyHotels: ['Simien Lodge', 'Limalimo Lodge', 'Geech Camp'],
      travelNotes: [
        _TravelNote(Icons.health_and_safety_rounded, 'Acclimatize for altitude before trekking.'),
        _TravelNote(Icons.nightlight_rounded, 'Nights are very cold year-round.'),
        _TravelNote(Icons.pets_rounded, 'Best wildlife viewing is at dawn.'),
      ],
    );
  }

  return defaults;
}

class _HeaderCard extends StatelessWidget {
  const _HeaderCard({required this.destination});
  final Destination destination;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: EthioColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(32),
        boxShadow: [
          BoxShadow(
            color: EthioColors.ink.withValues(alpha: 0.1),
            blurRadius: 30,
            offset: const Offset(0, 15),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      destination.name,
                      style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            letterSpacing: -0.5,
                          ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(Icons.location_on, size: 18, color: EthioColors.primary),
                        const SizedBox(width: 4),
                        Text(
                          destination.region,
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: EthioColors.mutedInk,
                                fontWeight: FontWeight.w500,
                              ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              _RoundIconButton(
                icon: Icons.share_rounded,
                color: EthioColors.primary,
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(behavior: SnackBarBehavior.floating, content: Text('Link copied to clipboard')),
                  );
                },
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 20),
            child: Divider(height: 1, color: EthioColors.ink.withValues(alpha: 0.1)),
          ),
          Text(
            destination.description,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  height: 1.6,
                  color: EthioColors.ink.withValues(alpha: 0.8),
                ),
          ),
        ],
      ),
    );
  }
}

class _BottomActionArea extends StatelessWidget {
  const _BottomActionArea({
    required this.destination,
    required this.inTrip,
    required this.saved,
    required this.onTripToggle,
    required this.onFavoriteToggle,
  });

  final Destination destination;
  final bool inTrip;
  final bool saved;
  final VoidCallback onTripToggle;
  final VoidCallback onFavoriteToggle;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(20, 16, 20, MediaQuery.paddingOf(context).bottom + 16),
      decoration: BoxDecoration(
        color: EthioColors.background,
        border: Border(top: BorderSide(color: EthioColors.ink.withValues(alpha: 0.05))),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: FilledButton.icon(
              onPressed: onTripToggle,
              style: FilledButton.styleFrom(
                backgroundColor: inTrip ? EthioColors.secondary : EthioColors.primary,
                minimumSize: const Size.fromHeight(60),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                elevation: 0,
              ),
              icon: Icon(inTrip ? Icons.check_circle_rounded : Icons.add_circle_outline_rounded),
              label: Text(inTrip ? 'In Your Trip' : 'Add to Trip', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            ),
          ),
          const SizedBox(width: 12),
          Container(
            decoration: BoxDecoration(
              border: Border.all(color: EthioColors.primary.withValues(alpha: 0.2)),
              borderRadius: BorderRadius.circular(20),
            ),
            child: IconButton(
              onPressed: onFavoriteToggle,
              iconSize: 28,
              padding: const EdgeInsets.all(14),
              icon: Icon(
                saved ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                color: saved ? EthioColors.error : EthioColors.primary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12, left: 4),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
      ),
    );
  }
}

class _ContentCard extends StatelessWidget {
  final String text;
  const _ContentCard({required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: EthioColors.surfaceContainerLowest.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        text,
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(height: 1.7, color: EthioColors.ink),
      ),
    );
  }
}

class _GlassIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onPressed;
  final Color color;

  const _GlassIconButton({required this.icon, required this.onPressed, this.color = Colors.white});

  @override
  Widget build(BuildContext context) {
    return ClipOval(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.2),
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white.withValues(alpha: 0.3)),
          ),
          child: IconButton(
            onPressed: onPressed,
            icon: Icon(icon, color: color, size: 22),
          ),
        ),
      ),
    );
  }
}

class _RoundIconButton extends StatelessWidget {
  const _RoundIconButton({required this.icon, required this.color, required this.onTap});
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: color.withValues(alpha: 0.08),
      shape: const CircleBorder(),
      child: InkWell(
        onTap: onTap,
        customBorder: const CircleBorder(),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Icon(icon, color: color, size: 22),
        ),
      ),
    );
  }
}

class _InfoPill extends StatelessWidget {
  const _InfoPill({required this.label, required this.value, required this.icon});
  final String label;
  final String value;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: EthioColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: EthioColors.outline.withValues(alpha: 0.05)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircleAvatar(
            radius: 18,
            backgroundColor: EthioColors.primary.withValues(alpha: 0.1),
            child: Icon(icon, size: 18, color: EthioColors.primary),
          ),
          const SizedBox(width: 14),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: Theme.of(context).textTheme.labelSmall?.copyWith(color: EthioColors.mutedInk, letterSpacing: 0.5)),
              const SizedBox(height: 2),
              Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
            ],
          ),
        ],
      ),
    );
  }
}
