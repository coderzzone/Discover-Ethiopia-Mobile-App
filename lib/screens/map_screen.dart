import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import '../app.dart';
import '../data/sample_data.dart';
import '../models/app_models.dart';
import '../state/app_scope.dart';
import '../state/app_state.dart';
import '../widgets/ui_components.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  final MapController _mapController = MapController();
  final TextEditingController _searchCtrl = TextEditingController();
  Destination? _selectedDestination;
  bool _showSatellite = false;
  bool _showLegend = false;
  String _activeFilter = 'All';

  static const _center = LatLng(9.145, 40.489);
  static const _filters = ['All', 'Trip', 'Favorites', 'Nature', 'Culture', 'Historical', 'Cities'];

  @override
  void dispose() {
    _searchCtrl.dispose();
    _mapController.dispose();
    super.dispose();
  }

  List<Destination> _filteredDestinations(AppState state) {
    final q = _searchCtrl.text.trim().toLowerCase();
    return sampleDestinations.where((d) {
      final matchesQuery = q.isEmpty ||
          d.name.toLowerCase().contains(q) ||
          d.region.toLowerCase().contains(q) ||
          d.tags.any((t) => t.toLowerCase().contains(q));

      final matchesFilter = switch (_activeFilter) {
        'Trip' => state.isInTrip(d.id),
        'Favorites' => state.isFavorite(d.id),
        'Nature' => d.tags.contains('Nature'),
        'Culture' => d.tags.contains('Culture'),
        'Historical' => d.tags.contains('Historical'),
        'Cities' => d.tags.contains('Cities'),
        _ => true,
      };
      return matchesQuery && matchesFilter;
    }).toList(growable: false);
  }

  void _focusResults(List<Destination> results) {
    if (results.isEmpty) return;
    if (results.length == 1) {
      final d = results.first;
      setState(() => _selectedDestination = d);
      _mapController.move(LatLng(d.lat, d.lng), 9.0);
      return;
    }
    final avgLat = results.map((d) => d.lat).reduce((a, b) => a + b) / results.length;
    final avgLng = results.map((d) => d.lng).reduce((a, b) => a + b) / results.length;
    _mapController.move(LatLng(avgLat, avgLng), 6.2);
  }

  @override
  Widget build(BuildContext context) {
    final state = AppStateScope.watch(context);
    final filtered = _filteredDestinations(state);

    return Scaffold(
      backgroundColor: EthioColors.background,
      appBar: AppBar(
        leading: IconButton(
          onPressed: () => Navigator.of(context).maybePop(),
          icon: const Icon(Icons.arrow_back_rounded),
        ),
        title: const Text('Offline Map'),
        actions: [
          IconButton(
            onPressed: () => setState(() => _showSatellite = !_showSatellite),
            icon: Icon(_showSatellite ? Icons.map_rounded : Icons.satellite_alt_rounded),
            tooltip: 'Toggle map style',
          ),
          IconButton(
            onPressed: () => setState(() => _showLegend = !_showLegend),
            icon: Icon(_showLegend ? Icons.info_rounded : Icons.info_outline_rounded),
            tooltip: 'Legend',
          ),
        ],
      ),
      body: Stack(
        children: [
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: _center,
              initialZoom: 6.0,
              minZoom: 4.0,
              maxZoom: 16.0,
              onTap: (tapPosition, point) => setState(() => _selectedDestination = null),
              interactionOptions: const InteractionOptions(flags: InteractiveFlag.all),
            ),
            children: [
              TileLayer(
                urlTemplate: _showSatellite
                    ? 'https://server.arcgisonline.com/ArcGIS/rest/services/World_Imagery/MapServer/tile/{z}/{y}/{x}'
                    : 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.example.ethio_explore',
              ),
              MarkerLayer(
                markers: filtered.map((dest) {
                  final inTrip = state.isInTrip(dest.id);
                  final isFav = state.isFavorite(dest.id);
                  final isSelected = _selectedDestination?.id == dest.id;

                  return Marker(
                    point: LatLng(dest.lat, dest.lng),
                    width: isSelected ? 70 : 56,
                    height: isSelected ? 70 : 56,
                    child: GestureDetector(
                      onTap: () {
                        setState(() => _selectedDestination = dest);
                        _mapController.move(
                          LatLng(dest.lat, dest.lng),
                          _mapController.camera.zoom < 7 ? 7 : _mapController.camera.zoom,
                        );
                      },
                      child: AnimatedScale(
                        scale: isSelected ? 1.2 : 1.0,
                        duration: const Duration(milliseconds: 200),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: inTrip
                                    ? EthioColors.secondary
                                    : isFav
                                        ? EthioColors.error
                                        : dest.accent,
                                borderRadius: BorderRadius.circular(14),
                                border: isSelected ? Border.all(color: Colors.white, width: 2.5) : null,
                                boxShadow: [
                                  BoxShadow(
                                    color: dest.accent.withValues(alpha: 0.35),
                                    blurRadius: 14,
                                    offset: const Offset(0, 5),
                                  ),
                                ],
                              ),
                              child: Icon(
                                inTrip
                                    ? Icons.check_circle_rounded
                                    : isFav
                                        ? Icons.favorite_rounded
                                        : Icons.location_on_rounded,
                                color: Colors.white,
                                size: 20,
                              ),
                            ),
                            Container(width: 2, height: 8, color: dest.accent),
                          ],
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
          Positioned(
            left: 16,
            right: 16,
            top: 12,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Material(
                  borderRadius: BorderRadius.circular(22),
                  elevation: 4,
                  shadowColor: EthioColors.ink.withValues(alpha: 0.10),
                  child: TextField(
                    controller: _searchCtrl,
                    decoration: InputDecoration(
                      hintText: 'Search destinations, regions, tags...',
                      prefixIcon: const Icon(Icons.search_rounded),
                      suffixIcon: _searchCtrl.text.isEmpty
                          ? const SizedBox.shrink()
                          : IconButton(
                              onPressed: () => setState(() {
                                _searchCtrl.clear();
                                _selectedDestination = null;
                              }),
                              icon: const Icon(Icons.close_rounded),
                            ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(22),
                        borderSide: BorderSide.none,
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(22),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    onChanged: (_) => setState(() {}),
                    onSubmitted: (_) => _focusResults(filtered),
                  ),
                ),
                const SizedBox(height: 10),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      OfflineChip(
                        label: '${filtered.length} shown • ${state.tripDestinations.length} in trip',
                        color: EthioColors.secondary,
                      ),
                      const SizedBox(width: 8),
                      ..._filters.map(
                        (filter) => Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: ChoiceChip(
                            label: Text(filter),
                            selected: _activeFilter == filter,
                            onSelected: (_) => setState(() => _activeFilter = filter),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                if (_showLegend) ...[
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.96),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: EthioColors.outline.withValues(alpha: 0.15)),
                    ),
                    child: const Wrap(
                      spacing: 12,
                      runSpacing: 8,
                      children: [
                        _LegendItem(color: EthioColors.secondary, label: 'In Trip'),
                        _LegendItem(color: EthioColors.error, label: 'Favorite'),
                        _LegendItem(color: EthioColors.primary, label: 'Destination'),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
          Positioned(
            right: 16,
            bottom: _selectedDestination != null ? 300 : 120,
            child: Column(
              children: [
                _MapFab(
                  icon: Icons.filter_center_focus_rounded,
                  onTap: () => _focusResults(filtered),
                ),
                const SizedBox(height: 8),
                _MapFab(
                  icon: Icons.add_rounded,
                  onTap: () {
                    final cam = _mapController.camera;
                    _mapController.move(cam.center, cam.zoom + 1);
                  },
                ),
                const SizedBox(height: 8),
                _MapFab(
                  icon: Icons.remove_rounded,
                  onTap: () {
                    final cam = _mapController.camera;
                    _mapController.move(cam.center, cam.zoom - 1);
                  },
                ),
                const SizedBox(height: 8),
                _MapFab(
                  icon: Icons.my_location_rounded,
                  onTap: () => _mapController.move(_center, 6.0),
                ),
              ],
            ),
          ),
          if (filtered.isNotEmpty)
            Positioned(
              left: 16,
              right: 16,
              bottom: _selectedDestination != null ? 230 : 82,
              child: SizedBox(
                height: 86,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: filtered.length > 12 ? 12 : filtered.length,
                  separatorBuilder: (context, index) => const SizedBox(width: 8),
                  itemBuilder: (context, index) {
                    final d = filtered[index];
                    final selected = _selectedDestination?.id == d.id;
                    return GestureDetector(
                      onTap: () {
                        setState(() => _selectedDestination = d);
                        _mapController.move(LatLng(d.lat, d.lng), 8.0);
                      },
                      child: Container(
                        width: 180,
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: selected ? d.accent : Colors.white.withValues(alpha: 0.95),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: selected ? Colors.white : EthioColors.outline.withValues(alpha: 0.14),
                          ),
                        ),
                        child: Row(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(9),
                              child: SizedBox(
                                width: 42,
                                height: 42,
                                child: Image.asset(
                                  d.imageUrl,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) => Container(color: d.accent.withValues(alpha: 0.2)),
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    d.name,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      color: selected ? Colors.white : EthioColors.ink,
                                      fontWeight: FontWeight.w800,
                                      fontSize: 12.5,
                                    ),
                                  ),
                                  Text(
                                    d.region,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      color: selected ? Colors.white.withValues(alpha: 0.9) : EthioColors.mutedInk,
                                      fontSize: 11,
                                    ),
                                  ),
                                ],
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
          AnimatedPositioned(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOutCubic,
            left: 16,
            right: 16,
            bottom: _selectedDestination != null ? 16 : -300,
            child: _selectedDestination != null
                ? _DestinationMapCard(
                    destination: _selectedDestination!,
                    state: state,
                    onClose: () => setState(() => _selectedDestination = null),
                    onDetails: () => openDestinationDetails(context, _selectedDestination!),
                    onAddTrip: () {
                      AppStateScope.read(context).addToTrip(_selectedDestination!);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          behavior: SnackBarBehavior.floating,
                          margin: const EdgeInsets.fromLTRB(16, 0, 16, 100),
                          content: Text('${_selectedDestination!.name} added to trip'),
                        ),
                      );
                    },
                  )
                : const SizedBox.shrink(),
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              color: EthioColors.tertiaryContainer.withValues(alpha: 0.95),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.offline_bolt_rounded, size: 14, color: EthioColors.onTertiaryContainer),
                  SizedBox(width: 6),
                  Text(
                    'OFFLINE-FIRST VIEW | OSM MAP LAYER',
                    style: TextStyle(
                      color: EthioColors.onTertiaryContainer,
                      fontWeight: FontWeight.w800,
                      fontSize: 10,
                      letterSpacing: 0.8,
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

class _DestinationMapCard extends StatelessWidget {
  const _DestinationMapCard({
    required this.destination,
    required this.state,
    required this.onClose,
    required this.onDetails,
    required this.onAddTrip,
  });

  final Destination destination;
  final AppState state;
  final VoidCallback onClose;
  final VoidCallback onDetails;
  final VoidCallback onAddTrip;

  @override
  Widget build(BuildContext context) {
    final inTrip = state.isInTrip(destination.id);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: EthioColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: EthioColors.ink.withValues(alpha: 0.12),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(18),
                child: SizedBox(
                  width: 80,
                  height: 80,
                  child: Image.asset(
                    destination.imageUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(
                      color: destination.accent.withValues(alpha: 0.15),
                      child: Icon(Icons.landscape_rounded, color: destination.accent),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            destination.name,
                            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
                          ),
                        ),
                        GestureDetector(
                          onTap: onClose,
                          child: const Icon(Icons.close_rounded, color: EthioColors.mutedInk),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(Icons.location_on, size: 14, color: EthioColors.primary),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            destination.region,
                            style: const TextStyle(color: EthioColors.mutedInk, fontSize: 13),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Wrap(
                      spacing: 6,
                      children: destination.tags
                          .map(
                            (tag) => Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: destination.accent.withValues(alpha: 0.10),
                                borderRadius: BorderRadius.circular(99),
                              ),
                              child: Text(
                                tag,
                                style: TextStyle(
                                  color: destination.accent,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          )
                          .toList(),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: FilledButton.icon(
                  onPressed: onDetails,
                  style: FilledButton.styleFrom(
                    backgroundColor: destination.accent,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  icon: const Icon(Icons.info_outline_rounded, size: 18),
                  label: const Text('Details', style: TextStyle(fontWeight: FontWeight.w700)),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: inTrip ? null : onAddTrip,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: EthioColors.secondary,
                    side: BorderSide(color: inTrip ? EthioColors.secondary : EthioColors.outline.withValues(alpha: 0.3)),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    backgroundColor: inTrip ? EthioColors.secondary.withValues(alpha: 0.08) : null,
                  ),
                  icon: Icon(inTrip ? Icons.check_rounded : Icons.add_rounded, size: 18),
                  label: Text(inTrip ? 'In Trip' : 'Add Trip', style: const TextStyle(fontWeight: FontWeight.w700)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _LegendItem extends StatelessWidget {
  const _LegendItem({required this.color, required this.label});

  final Color color;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(99)),
        ),
        const SizedBox(width: 5),
        Text(label, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700)),
      ],
    );
  }
}

class _MapFab extends StatelessWidget {
  const _MapFab({required this.icon, required this.onTap});
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 46,
        height: 46,
        decoration: BoxDecoration(
          color: EthioColors.surfaceContainerLowest,
          shape: BoxShape.circle,
          border: Border.all(color: EthioColors.outline.withValues(alpha: 0.12)),
          boxShadow: [
            BoxShadow(
              color: EthioColors.ink.withValues(alpha: 0.08),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Icon(icon, color: EthioColors.ink, size: 20),
      ),
    );
  }
}
