import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import '../app.dart';
import '../data/sample_data.dart';
import '../models/app_models.dart';
import '../state/app_scope.dart';
import '../state/app_state.dart';
import '../widgets/ui_components.dart';

import '../services/routing_service.dart';
import 'package:geolocator/geolocator.dart';
import 'dart:async';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  final MapController _mapController = MapController();
  final TextEditingController _searchCtrl = TextEditingController();

  Destination? _selectedDestination;
  _LocalPoi? _selectedPoi;
  bool _showSatellite = false;
  bool _showLegend = false;
  String _activeFilter = 'All';
  TravelMode _routeMode = TravelMode.driving;
  LatLng _currentLocation = _center;
  List<LatLng> _activeRoute = const [];
  List<String> _turnByTurnSteps = const [];
  bool _isTracking = false;
  StreamSubscription<Position>? _positionStream;
  bool _isLoadingRoute = false;

  static const _center = LatLng(9.145, 40.489);
  static const _filters = [
    'All',
    'Trip',
    'Favorites',
    'Nature',
    'Culture',
    'Historical',
    'Cities',
  ];
  static final Distance _distance = const Distance();

  static const List<_LocalPoi> _offlinePois = [
    _LocalPoi(
      id: 'poi-1',
      name: 'Tomoca Coffee',
      category: 'Restaurant',
      region: 'Addis Ababa',
      lat: 9.037,
      lng: 38.751,
      icon: Icons.coffee_rounded,
      color: EthioColors.tertiary,
    ),
    _LocalPoi(
      id: 'poi-2',
      name: 'Yod Abyssinia',
      category: 'Restaurant',
      region: 'Addis Ababa',
      lat: 9.009,
      lng: 38.783,
      icon: Icons.restaurant_rounded,
      color: EthioColors.tertiary,
    ),
    _LocalPoi(
      id: 'poi-3',
      name: 'National Museum',
      category: 'Historical Site',
      region: 'Addis Ababa',
      lat: 9.047,
      lng: 38.761,
      icon: Icons.account_balance_rounded,
      color: EthioColors.primary,
    ),
    _LocalPoi(
      id: 'poi-4',
      name: 'Fasil Ghebbi',
      category: 'Historical Site',
      region: 'Gondar',
      lat: 12.608,
      lng: 37.469,
      icon: Icons.castle_rounded,
      color: EthioColors.primary,
    ),
    _LocalPoi(
      id: 'poi-5',
      name: 'Ben Abeba',
      category: 'Restaurant',
      region: 'Lalibela',
      lat: 12.038,
      lng: 39.047,
      icon: Icons.local_dining_rounded,
      color: EthioColors.tertiary,
    ),
    _LocalPoi(
      id: 'poi-6',
      name: 'Lalibela Market',
      category: 'Market',
      region: 'Lalibela',
      lat: 12.031,
      lng: 39.045,
      icon: Icons.storefront_rounded,
      color: EthioColors.secondary,
    ),
  ];

  @override
  void dispose() {
    _searchCtrl.dispose();
    _mapController.dispose();
    _positionStream?.cancel();
    super.dispose();
  }

  List<Destination> _filteredDestinations(AppState state) {
    final q = _searchCtrl.text.trim().toLowerCase();
    return sampleDestinations
        .where((d) {
          final matchesQuery =
              q.isEmpty ||
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
        })
        .toList(growable: false);
  }

  List<_LocalPoi> _filteredPois() {
    final q = _searchCtrl.text.trim().toLowerCase();
    if (q.isEmpty) return _offlinePois;

    final nearMeQuery = q.contains('near me');
    final restaurantQuery = q.contains('restaurant');
    final historicalQuery = q.contains('historical');

    var pois = _offlinePois
        .where((poi) {
          if (nearMeQuery) {
            final meters = _distance.as(
              LengthUnit.Meter,
              _currentLocation,
              LatLng(poi.lat, poi.lng),
            );
            return meters <= 250000;
          }
          if (restaurantQuery) {
            return poi.category.toLowerCase().contains('restaurant');
          }
          if (historicalQuery) {
            return poi.category.toLowerCase().contains('historical');
          }
          return poi.name.toLowerCase().contains(q) ||
              poi.region.toLowerCase().contains(q) ||
              poi.category.toLowerCase().contains(q);
        })
        .toList(growable: false);

    if (nearMeQuery && (restaurantQuery || historicalQuery)) {
      pois = pois
          .where((poi) {
            if (restaurantQuery) {
              return poi.category.toLowerCase().contains('restaurant');
            }
            return poi.category.toLowerCase().contains('historical');
          })
          .toList(growable: false);
    }

    return pois;
  }

  void _focusResults(List<Destination> results, List<_LocalPoi> pois) {
    final allPoints = <LatLng>[
      ...results.map((d) => LatLng(d.lat, d.lng)),
      ...pois.map((p) => LatLng(p.lat, p.lng)),
    ];
    if (allPoints.isEmpty) return;

    if (allPoints.length == 1) {
      _mapController.move(allPoints.first, 9.0);
      return;
    }

    final avgLat =
        allPoints.map((p) => p.latitude).reduce((a, b) => a + b) /
        allPoints.length;
    final avgLng =
        allPoints.map((p) => p.longitude).reduce((a, b) => a + b) /
        allPoints.length;
    _mapController.move(LatLng(avgLat, avgLng), 6.2);
  }

  Future<void> _startNavigationTo(LatLng target, String title) async {
    setState(() {
      _isLoadingRoute = true;
      _activeRoute = [];
      _turnByTurnSteps = ['Calculating route...'];
      _selectedPoi = null;
    });

    try {
      final route = await RoutingService.fetchRoute(
        start: _currentLocation,
        end: target,
        mode: _routeMode,
      );

      if (!mounted) return;
      setState(() {
        _activeRoute = route.polyline;
        _turnByTurnSteps = route.steps;
        _isLoadingRoute = false;
      });

      // Fit bounds to show the whole route
      if (_activeRoute.isNotEmpty) {
        final bounds = LatLngBounds.fromPoints(_activeRoute);
        _mapController.fitCamera(
          CameraFit.bounds(bounds: bounds, padding: const EdgeInsets.all(40)),
        );
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoadingRoute = false;
        _turnByTurnSteps = ['Error calculating route: $e'];
      });
    }
  }

  Future<void> _toggleTracking() async {
    if (_isTracking) {
      setState(() => _isTracking = false);
      _positionStream?.cancel();
      _positionStream = null;
      return;
    }

    // Request permissions
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Location permissions are denied')),
          );
        }
        return;
      }
    }
    
    if (permission == LocationPermission.deniedForever) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Location permissions are permanently denied, we cannot request permissions.')),
        );
      }
      return;
    }

    setState(() => _isTracking = true);
    
    // Get initial
    try {
      final pos = await Geolocator.getCurrentPosition(locationSettings: const LocationSettings(accuracy: LocationAccuracy.high));
      _updateLocationFromPosition(pos);
    } catch (_) {}

    // Stream
    _positionStream = Geolocator.getPositionStream(
      locationSettings: const LocationSettings(accuracy: LocationAccuracy.high, distanceFilter: 10),
    ).listen((Position? position) {
      if (position != null && mounted) {
        _updateLocationFromPosition(position);
      }
    });
  }

  void _updateLocationFromPosition(Position pos) {
    setState(() {
      _currentLocation = LatLng(pos.latitude, pos.longitude);
    });
    if (_isTracking) {
      _mapController.move(
        _currentLocation,
        _mapController.camera.zoom < 14 ? 14 : _mapController.camera.zoom,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = AppStateScope.watch(context);
    final scheme = Theme.of(context).colorScheme;
    final filtered = _filteredDestinations(state);
    final filteredPois = _filteredPois();

    return Scaffold(
      backgroundColor: scheme.surface,
      appBar: AppBar(
        leading: IconButton(
          onPressed: () => Navigator.of(context).maybePop(),
          icon: const Icon(Icons.arrow_back_rounded),
        ),
        title: const Text('Smart Offline Map'),
        actions: [
          IconButton(
            onPressed: () => setState(() => _showSatellite = !_showSatellite),
            icon: Icon(
              _showSatellite ? Icons.map_rounded : Icons.satellite_alt_rounded,
            ),
            tooltip: 'Toggle map style',
          ),
          IconButton(
            onPressed: () => setState(() => _showLegend = !_showLegend),
            icon: Icon(
              _showLegend ? Icons.info_rounded : Icons.info_outline_rounded,
            ),
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
              onTap: (tapPosition, point) => setState(() {
                _selectedDestination = null;
                _selectedPoi = null;
              }),
              interactionOptions: const InteractionOptions(
                flags: InteractiveFlag.all,
              ),
            ),
            children: [
              TileLayer(
                urlTemplate: _showSatellite
                    ? 'https://server.arcgisonline.com/ArcGIS/rest/services/World_Imagery/MapServer/tile/{z}/{y}/{x}'
                    : 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.example.ethio_explore',
              ),
              if (_activeRoute.isNotEmpty)
                PolylineLayer(
                  polylines: [
                    Polyline(
                      points: _activeRoute,
                      strokeWidth: 5,
                      color: switch (_routeMode) {
                        TravelMode.walking => EthioColors.secondary,
                        TravelMode.cycling => EthioColors.tertiary,
                        TravelMode.bus => EthioColors.primary,
                        TravelMode.driving => EthioColors.primary,
                      },
                    ),
                  ],
                ),
              MarkerLayer(
                markers: [
                  Marker(
                    point: _currentLocation,
                    width: 52,
                    height: 52,
                    child: Container(
                      decoration: BoxDecoration(
                        color: EthioColors.primary,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2.4),
                      ),
                      child: const Icon(
                        Icons.my_location_rounded,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                  ),
                  ...filtered.map((dest) {
                    final inTrip = state.isInTrip(dest.id);
                    final isFav = state.isFavorite(dest.id);
                    final isSelected = _selectedDestination?.id == dest.id;

                    return Marker(
                      point: LatLng(dest.lat, dest.lng),
                      width: isSelected ? 70 : 56,
                      height: isSelected ? 70 : 56,
                      child: GestureDetector(
                        onTap: () {
                          setState(() {
                            _selectedDestination = dest;
                            _selectedPoi = null;
                          });
                          _mapController.move(
                            LatLng(dest.lat, dest.lng),
                            _mapController.camera.zoom < 7
                                ? 7
                                : _mapController.camera.zoom,
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
                                  border: isSelected
                                      ? Border.all(
                                          color: Colors.white,
                                          width: 2.5,
                                        )
                                      : null,
                                  boxShadow: [
                                    BoxShadow(
                                      color: dest.accent.withValues(
                                        alpha: 0.35,
                                      ),
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
                              Container(
                                width: 2,
                                height: 8,
                                color: dest.accent,
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  }),
                  ...filteredPois.map((poi) {
                    final isSelected = _selectedPoi?.id == poi.id;
                    return Marker(
                      point: LatLng(poi.lat, poi.lng),
                      width: isSelected ? 56 : 46,
                      height: isSelected ? 56 : 46,
                      child: GestureDetector(
                        onTap: () {
                          setState(() {
                            _selectedPoi = poi;
                            _selectedDestination = null;
                          });
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            color: poi.color,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: Colors.white,
                              width: isSelected ? 2.5 : 1.7,
                            ),
                          ),
                          child: Icon(
                            poi.icon,
                            color: Colors.white,
                            size: isSelected ? 22 : 18,
                          ),
                        ),
                      ),
                    );
                  }),
                ],
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
                      hintText:
                          'Offline search: restaurants near me, historical sites...',
                      prefixIcon: const Icon(Icons.search_rounded),
                      suffixIcon: _searchCtrl.text.isEmpty
                          ? const SizedBox.shrink()
                          : IconButton(
                              onPressed: () => setState(() {
                                _searchCtrl.clear();
                                _selectedDestination = null;
                                _selectedPoi = null;
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
                    onSubmitted: (_) => _focusResults(filtered, filteredPois),
                  ),
                ),
                const SizedBox(height: 10),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      OfflineChip(
                        label:
                            '${filtered.length} destinations • ${filteredPois.length} local POIs',
                        color: EthioColors.secondary,
                      ),
                      const SizedBox(width: 8),
                      ..._filters.map(
                        (filter) => Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: ChoiceChip(
                            label: Text(filter),
                            selected: _activeFilter == filter,
                            onSelected: (_) =>
                                setState(() => _activeFilter = filter),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.95),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: EthioColors.outline.withValues(alpha: 0.12),
                    ),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.alt_route_rounded,
                        color: EthioColors.primary,
                        size: 18,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: SegmentedButton<TravelMode>(
                            segments: const [
                              ButtonSegment(
                                value: TravelMode.walking,
                                icon: Icon(Icons.directions_walk_rounded),
                                label: Text('Walk'),
                              ),
                              ButtonSegment(
                                value: TravelMode.cycling,
                                icon: Icon(Icons.directions_bike_rounded),
                                label: Text('Bike'),
                              ),
                              ButtonSegment(
                                value: TravelMode.bus,
                                icon: Icon(Icons.directions_bus_rounded),
                                label: Text('Bus'),
                              ),
                              ButtonSegment(
                                value: TravelMode.driving,
                                icon: Icon(Icons.directions_car_rounded),
                                label: Text('Car'),
                              ),
                            ],
                            selected: {_routeMode},
                            onSelectionChanged: (value) {
                              setState(() => _routeMode = value.first);
                              if (_selectedDestination != null) {
                                _startNavigationTo(LatLng(_selectedDestination!.lat, _selectedDestination!.lng), _selectedDestination!.name);
                              } else if (_selectedPoi != null) {
                                _startNavigationTo(LatLng(_selectedPoi!.lat, _selectedPoi!.lng), _selectedPoi!.name);
                              }
                            },
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
                      border: Border.all(
                        color: EthioColors.outline.withValues(alpha: 0.15),
                      ),
                    ),
                    child: const Wrap(
                      spacing: 12,
                      runSpacing: 8,
                      children: [
                        _LegendItem(color: EthioColors.primary, label: 'You'),
                        _LegendItem(
                          color: EthioColors.secondary,
                          label: 'In Trip',
                        ),
                        _LegendItem(
                          color: EthioColors.error,
                          label: 'Favorite',
                        ),
                        _LegendItem(
                          color: EthioColors.tertiary,
                          label: 'Food / POI',
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
          Positioned(
            right: 16,
            bottom: (_selectedDestination != null || _selectedPoi != null)
                ? 310
                : 138,
            child: Column(
              children: [
                _MapFab(
                  icon: Icons.filter_center_focus_rounded,
                  onTap: () => _focusResults(filtered, filteredPois),
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
                  icon: _isTracking ? Icons.explore_rounded : Icons.my_location_rounded,
                  color: _isTracking ? EthioColors.secondary : Colors.white,
                  iconColor: _isTracking ? Colors.white : EthioColors.primary,
                  onTap: _toggleTracking,
                ),
              ],
            ),
          ),
          if (_turnByTurnSteps.isNotEmpty || _isLoadingRoute)
            Positioned(
              left: 16,
              right: 16,
              bottom: (_selectedDestination != null || _selectedPoi != null)
                  ? 230
                  : 90,
              child: Container(
                constraints: const BoxConstraints(maxHeight: 140),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.97),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: EthioColors.outline.withValues(alpha: 0.15),
                  ),
                ),
                child: _isLoadingRoute 
                  ? const Center(child: Padding(padding: EdgeInsets.all(20), child: CircularProgressIndicator()))
                  : ListView.builder(
                      itemCount: _turnByTurnSteps.length,
                      itemBuilder: (context, i) => Padding(
                        padding: const EdgeInsets.only(bottom: 6),
                        child: Text(
                          '${i + 1}. ${_turnByTurnSteps[i]}',
                          style: const TextStyle(fontSize: 12.5),
                        ),
                      ),
                    ),
              ),
            ),
          AnimatedPositioned(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOutCubic,
            left: 16,
            right: 16,
            bottom: (_selectedDestination != null || _selectedPoi != null)
                ? 16
                : -300,
            child: _selectedDestination != null
                ? _DestinationMapCard(
                    destination: _selectedDestination!,
                    state: state,
                    onClose: () => setState(() => _selectedDestination = null),
                    onDetails: () =>
                        openDestinationDetails(context, _selectedDestination!),
                    onAddTrip: () {
                      AppStateScope.read(
                        context,
                      ).addToTrip(_selectedDestination!);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          behavior: SnackBarBehavior.floating,
                          margin: const EdgeInsets.fromLTRB(16, 0, 16, 100),
                          content: Text(
                            '${_selectedDestination!.name} added to trip',
                          ),
                        ),
                      );
                    },
                    onStartNavigation: () => _startNavigationTo(
                      LatLng(
                        _selectedDestination!.lat,
                        _selectedDestination!.lng,
                      ),
                      _selectedDestination!.name,
                    ),
                    onToggleFavorite: () => AppStateScope.read(
                      context,
                    ).toggleFavorite(_selectedDestination!),
                  )
                : _selectedPoi != null
                ? _PoiMapCard(
                    poi: _selectedPoi!,
                    onClose: () => setState(() => _selectedPoi = null),
                    onNavigate: () => _startNavigationTo(
                      LatLng(_selectedPoi!.lat, _selectedPoi!.lng),
                      _selectedPoi!.name,
                    ),
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
                  Icon(
                    Icons.offline_bolt_rounded,
                    size: 14,
                    color: EthioColors.onTertiaryContainer,
                  ),
                  SizedBox(width: 6),
                  Text(
                    'SMART OFFLINE NAVIGATION | LOCAL SEARCH + ROUTING',
                    style: TextStyle(
                      color: EthioColors.onTertiaryContainer,
                      fontWeight: FontWeight.w800,
                      fontSize: 10,
                      letterSpacing: 0.5,
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
    required this.onStartNavigation,
    required this.onToggleFavorite,
  });

  final Destination destination;
  final AppState state;
  final VoidCallback onClose;
  final VoidCallback onDetails;
  final VoidCallback onAddTrip;
  final VoidCallback onStartNavigation;
  final VoidCallback onToggleFavorite;

  @override
  Widget build(BuildContext context) {
    final inTrip = state.isInTrip(destination.id);
    final isFav = state.isFavorite(destination.id);

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
                      child: Icon(
                        Icons.landscape_rounded,
                        color: destination.accent,
                      ),
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
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                        GestureDetector(
                          onTap: onClose,
                          child: const Icon(
                            Icons.close_rounded,
                            color: EthioColors.mutedInk,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(
                          Icons.location_on,
                          size: 14,
                          color: EthioColors.primary,
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            destination.region,
                            style: const TextStyle(
                              color: EthioColors.mutedInk,
                              fontSize: 13,
                            ),
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
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: destination.accent.withValues(
                                  alpha: 0.10,
                                ),
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
                  onPressed: onStartNavigation,
                  style: FilledButton.styleFrom(
                    backgroundColor: destination.accent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  icon: const Icon(Icons.navigation_rounded, size: 18),
                  label: const Text(
                    'Navigate',
                    style: TextStyle(fontWeight: FontWeight.w700),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              IconButton(
                onPressed: onToggleFavorite,
                icon: Icon(
                  isFav
                      ? Icons.favorite_rounded
                      : Icons.favorite_border_rounded,
                  color: EthioColors.error,
                ),
                tooltip: 'Save favorite place',
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: FilledButton.icon(
                  onPressed: onDetails,
                  style: FilledButton.styleFrom(
                    backgroundColor: EthioColors.primary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  icon: const Icon(Icons.info_outline_rounded, size: 18),
                  label: const Text(
                    'Details',
                    style: TextStyle(fontWeight: FontWeight.w700),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: inTrip ? null : onAddTrip,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: EthioColors.secondary,
                    side: BorderSide(
                      color: inTrip
                          ? EthioColors.secondary
                          : EthioColors.outline.withValues(alpha: 0.3),
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    backgroundColor: inTrip
                        ? EthioColors.secondary.withValues(alpha: 0.08)
                        : null,
                  ),
                  icon: Icon(
                    inTrip ? Icons.check_rounded : Icons.add_rounded,
                    size: 18,
                  ),
                  label: Text(
                    inTrip ? 'In Trip' : 'Add Trip',
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _PoiMapCard extends StatelessWidget {
  const _PoiMapCard({
    required this.poi,
    required this.onClose,
    required this.onNavigate,
  });

  final _LocalPoi poi;
  final VoidCallback onClose;
  final VoidCallback onNavigate;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: EthioColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: poi.color.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                backgroundColor: poi.color,
                child: Icon(poi.icon, color: Colors.white),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      poi.name,
                      style: const TextStyle(fontWeight: FontWeight.w800),
                    ),
                    Text(
                      '${poi.category} • ${poi.region}',
                      style: const TextStyle(
                        color: EthioColors.mutedInk,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: onClose,
                icon: const Icon(Icons.close_rounded),
              ),
            ],
          ),
          const SizedBox(height: 10),
          FilledButton.icon(
            onPressed: onNavigate,
            icon: const Icon(Icons.navigation_rounded, size: 18),
            label: const Text('Start Offline Navigation'),
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
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(99),
          ),
        ),
        const SizedBox(width: 5),
        Text(
          label,
          style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700),
        ),
      ],
    );
  }
}

class _MapFab extends StatelessWidget {
  const _MapFab({
    required this.icon,
    required this.onTap,
    this.color = EthioColors.surfaceContainerLowest,
    this.iconColor = EthioColors.ink,
  });

  final IconData icon;
  final VoidCallback onTap;
  final Color color;
  final Color iconColor;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 46,
        height: 46,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          border: Border.all(
            color: EthioColors.outline.withValues(alpha: 0.12),
          ),
          boxShadow: [
            BoxShadow(
              color: EthioColors.ink.withValues(alpha: 0.08),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Icon(icon, color: iconColor, size: 20),
      ),
    );
  }
}

class _LocalPoi {
  const _LocalPoi({
    required this.id,
    required this.name,
    required this.category,
    required this.region,
    required this.lat,
    required this.lng,
    required this.icon,
    required this.color,
  });

  final String id;
  final String name;
  final String category;
  final String region;
  final double lat;
  final double lng;
  final IconData icon;
  final Color color;
}
