import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';

import '../data/travel_features_data.dart';
import '../models/travel_features_models.dart';
import '../services/bank_locator_service.dart';
import '../services/routing_service.dart';
import 'amharic_phrasebook_screen.dart';
import 'dart:async';

class SmartTravelFeaturesScreen extends StatefulWidget {
  const SmartTravelFeaturesScreen({super.key});

  @override
  State<SmartTravelFeaturesScreen> createState() => _SmartTravelFeaturesScreenState();
}

class _SmartTravelFeaturesScreenState extends State<SmartTravelFeaturesScreen> {
  final Set<String> _packingDone = <String>{};
  final TextEditingController _quizDaysCtrl = TextEditingController(text: '4');
  final MapController _bankMapController = MapController();

  String _region = 'Danakil';
  String _quizBudget = 'Medium';
  String _quizDifficulty = 'Medium';

  // ── Bank locator (live OSM data) ─────────────────────────────────────────
  Position? _userPosition;
  String? _locationError;
  bool _bankLoading = false;
  int _searchRadiusMeters = 3000;
  List<LiveBankBranch> _liveBranches = const [];
  bool _showBankMap = false;

  // ── Bank Routing ─────────────────────────────────────────────────────────
  TravelMode _travelMode = TravelMode.walking;
  List<LatLng> _activeRoute = const [];
  LiveBankBranch? _selectedBranch;
  StreamSubscription<Position>? _positionStream;
  bool _isNavigating = false;
  bool _isLoadingRoute = false;
  String? _turnByTurnText;

  @override
  void dispose() {
    _quizDaysCtrl.dispose();
    _positionStream?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final quizPick = _quizResult();
    final checklist = packingByRegion[_region] ?? const <PackingItem>[];

    return Scaffold(
      appBar: AppBar(title: const Text('Smart Travel Features')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
        children: [
          _section('Banks in Ethiopia & Nearby Branches'),
          _bankLocatorCard(),
          const SizedBox(height: 16),
          _section('Voice-Activated Amharic Phrasebook (Offline)'),
          _featureLaunchCard(
            title: 'Open Amharic Phrasebook',
            subtitle: 'Dedicated screen with category search and offline phrase actions.',
            icon: Icons.record_voice_over_rounded,
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute<void>(builder: (_) => const AmharicPhrasebookScreen()),
            ),
          ),
          const SizedBox(height: 16),
          _section('Packing List Generator'),
          _packingCard(checklist),
          const SizedBox(height: 16),
          _section('Destination Comparison Tool'),
          _comparisonCard(quizPick),
        ],
      ),
    );
  }

  Widget _section(String title) => Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Text(title, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
      );

  Widget _bankLocatorCard() {
    final scheme = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── Radius selector ────────────────────────────────────────────────
        Wrap(
          spacing: 6,
          runSpacing: 4,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            Text('Search radius:',
                style: TextStyle(
                    fontWeight: FontWeight.w700,
                    color: scheme.onSurface.withValues(alpha: 0.7))),
            ...{1000: '1 km', 3000: '3 km', 5000: '5 km', 10000: '10 km'}
                .entries
                .map((e) => ChoiceChip(
                      label: Text(e.value),
                      selected: _searchRadiusMeters == e.key,
                      onSelected: (_) =>
                          setState(() => _searchRadiusMeters = e.key),
                    )),
          ],
        ),
        const SizedBox(height: 12),

        // ── Scan button ────────────────────────────────────────────────────
        FilledButton.icon(
          onPressed: _bankLoading ? null : _detectLocation,
          icon: _bankLoading
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                      strokeWidth: 2, color: Colors.white))
              : const Icon(Icons.my_location_rounded, size: 18),
          label: Text(
              _bankLoading ? 'Searching...' : 'Find Real Nearby Banks'),
          style: FilledButton.styleFrom(
            minimumSize: const Size(double.infinity, 48),
          ),
        ),
        // GPS coordinate pill — below the button to avoid overflow
        if (_userPosition != null && !_bankLoading) ...[
          const SizedBox(height: 8),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.gps_fixed_rounded,
                  size: 13, color: scheme.primary),
              const SizedBox(width: 4),
              Text(
                '${_userPosition!.latitude.toStringAsFixed(4)}, '
                '${_userPosition!.longitude.toStringAsFixed(4)}',
                style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: scheme.primary),
              ),
            ],
          ),
        ],

        // ── Error ──────────────────────────────────────────────────────────
        if (_locationError != null) ...[
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: scheme.errorContainer.withValues(alpha: 0.35),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Icon(Icons.warning_amber_rounded,
                    size: 18, color: scheme.error),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(_locationError!,
                      style: TextStyle(
                          color: scheme.error, fontWeight: FontWeight.w600)),
                ),
              ],
            ),
          ),
        ],

        // ── Live map ───────────────────────────────────────────────────────
        if (_showBankMap && _userPosition != null) ...[
          const SizedBox(height: 16),
          // Route Mode Selector
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: SegmentedButton<TravelMode>(
              segments: const [
                ButtonSegment(value: TravelMode.walking, icon: Icon(Icons.directions_walk_rounded), label: Text('Walk')),
                ButtonSegment(value: TravelMode.cycling, icon: Icon(Icons.directions_bike_rounded), label: Text('Bike')),
                ButtonSegment(value: TravelMode.bus, icon: Icon(Icons.directions_bus_rounded), label: Text('Bus')),
                ButtonSegment(value: TravelMode.driving, icon: Icon(Icons.directions_car_rounded), label: Text('Car')),
              ],
              selected: {_travelMode},
              onSelectionChanged: (value) {
                setState(() => _travelMode = value.first);
                if (_selectedBranch != null) {
                  _calculateRouteToBranch(_selectedBranch!);
                }
              },
            ),
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: SizedBox(
              height: 300,
              child: FlutterMap(
                mapController: _bankMapController,
                options: MapOptions(
                  initialCenter: LatLng(
                      _userPosition!.latitude, _userPosition!.longitude),
                  initialZoom: _zoomForRadius(_searchRadiusMeters),
                  minZoom: 4.0,
                  maxZoom: 18.0,
                ),
                children: [
                  TileLayer(
                    urlTemplate:
                        'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                    userAgentPackageName: 'com.example.ethio_explore',
                  ),
                  if (_activeRoute.isNotEmpty)
                    PolylineLayer(
                      polylines: [
                        Polyline(
                          points: _activeRoute,
                          strokeWidth: 4,
                          color: scheme.primary,
                        ),
                      ],
                    ),
                  MarkerLayer(
                    markers: [
                      // You are here
                      Marker(
                        point: LatLng(_userPosition!.latitude,
                            _userPosition!.longitude),
                        width: 56,
                        height: 56,
                        child: Container(
                          margin: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: scheme.primary,
                            shape: BoxShape.circle,
                            border:
                                Border.all(color: Colors.white, width: 3),
                            boxShadow: [
                              BoxShadow(
                                  color:
                                      scheme.primary.withValues(alpha: 0.45),
                                  blurRadius: 14,
                                  spreadRadius: 3),
                            ],
                          ),
                          child: const Icon(
                              Icons.person_pin_circle_rounded,
                              color: Colors.white,
                              size: 22),
                        ),
                      ),
                      // Real branch markers from OSM
                      ..._liveBranches.map(
                        (b) {
                          final isSelected = _selectedBranch?.lat == b.lat && _selectedBranch?.lng == b.lng;
                          return Marker(
                            point: LatLng(b.lat, b.lng),
                            width: isSelected ? 60 : 48,
                            height: isSelected ? 60 : 48,
                            child: GestureDetector(
                              onTap: () => _calculateRouteToBranch(b),
                              child: Tooltip(
                                message: '${b.name}\n${b.displayAddress}',
                                preferBelow: false,
                                child: Container(
                                  margin: const EdgeInsets.all(4),
                                  decoration: BoxDecoration(
                                    color: isSelected ? scheme.error : scheme.secondary,
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                        color: Colors.white, width: isSelected ? 3 : 2),
                                    boxShadow: [
                                      BoxShadow(
                                          color: (isSelected ? scheme.error : scheme.secondary)
                                              .withValues(alpha: 0.4),
                                          blurRadius: 8,
                                          spreadRadius: 1),
                                    ],
                                  ),
                                  child: const Icon(
                                      Icons.account_balance_rounded,
                                      color: Colors.white,
                                      size: 20),
                                ),
                              ),
                            ),
                          );
                        }
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              _mapLegendDot(scheme.primary),
              const SizedBox(width: 5),
              const Text('You', style: TextStyle(fontSize: 12)),
              const SizedBox(width: 12),
              _mapLegendDot(scheme.secondary),
              const SizedBox(width: 5),
              Text('Banks found: ${_liveBranches.length}',
                  style: const TextStyle(fontSize: 12)),
            ],
          ),
          if (_isLoadingRoute)
            const Padding(
              padding: EdgeInsets.only(top: 8),
              child: Center(child: CircularProgressIndicator()),
            )
          else if (_turnByTurnText != null)
            Container(
              margin: const EdgeInsets.only(top: 12),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: scheme.primaryContainer,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Icon(Icons.directions, color: scheme.primary),
                  const SizedBox(width: 8),
                  Expanded(child: Text(_turnByTurnText!, style: TextStyle(color: scheme.onPrimaryContainer, fontWeight: FontWeight.w600))),
                ],
              ),
            ),
        ],

        // ── Live branch cards ──────────────────────────────────────────────
        if (_liveBranches.isNotEmpty) ...[
          const SizedBox(height: 16),
          Row(
            children: [
              Icon(Icons.account_balance_rounded,
                  size: 18, color: scheme.primary),
              const SizedBox(width: 8),
              Text(
                'Nearby banks — sorted by distance',
                style: const TextStyle(
                    fontWeight: FontWeight.w800, fontSize: 15),
              ),
            ],
          ),
          const SizedBox(height: 10),
          ..._liveBranches.asMap().entries.map((entry) {
            final i = entry.key;
            final branch = entry.value;
            final isNearest = i == 0;
            final dist = Geolocator.distanceBetween(
                  _userPosition!.latitude,
                  _userPosition!.longitude,
                  branch.lat,
                  branch.lng,
                ) /
                1000;

            return Container(
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: isNearest
                    ? scheme.primaryContainer.withValues(alpha: 0.25)
                    : scheme.surfaceContainerLowest,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isNearest
                      ? scheme.primary.withValues(alpha: 0.35)
                      : scheme.outline.withValues(alpha: 0.12),
                  width: isNearest ? 1.5 : 1,
                ),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: (isNearest
                              ? scheme.primary
                              : scheme.secondary)
                          .withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(Icons.account_balance_rounded,
                        color: isNearest
                            ? scheme.primary
                            : scheme.secondary,
                        size: 22),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(branch.name,
                                  style: const TextStyle(
                                      fontWeight: FontWeight.w800,
                                      fontSize: 14)),
                            ),
                            if (isNearest)
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 3),
                                decoration: BoxDecoration(
                                  color: scheme.primary,
                                  borderRadius: BorderRadius.circular(99),
                                ),
                                child: const Text('NEAREST',
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 9,
                                        fontWeight: FontWeight.w900,
                                        letterSpacing: 0.8)),
                              ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(branch.displayAddress,
                            style: TextStyle(
                                fontSize: 12,
                                color: scheme.onSurface
                                    .withValues(alpha: 0.65))),
                        if (branch.openingHours != null) ...[
                          const SizedBox(height: 3),
                          Row(children: [
                            Icon(Icons.access_time_rounded,
                                size: 12,
                                color: scheme.tertiary),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(branch.openingHours!,
                                  style: TextStyle(
                                      fontSize: 11,
                                      color: scheme.tertiary,
                                      fontWeight: FontWeight.w600)),
                            ),
                          ]),
                        ],
                        const SizedBox(height: 6),
                        Row(children: [
                          Icon(Icons.directions_walk_rounded,
                              size: 13, color: scheme.tertiary),
                          const SizedBox(width: 4),
                          Text('${dist.toStringAsFixed(2)} km away',
                              style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                  color: scheme.tertiary)),
                        ]),
                      ],
                    ),
                  ),
                ],
              ),
            );
          }),
        ],

        // ── Empty state ────────────────────────────────────────────────────
        if (!_bankLoading &&
            _userPosition != null &&
            _liveBranches.isEmpty &&
            _showBankMap) ...[
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: scheme.surfaceContainerLowest,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                  color: scheme.outline.withValues(alpha: 0.15)),
            ),
            child: Column(
              children: [
                Icon(Icons.search_off_rounded,
                    size: 36,
                    color: scheme.onSurface.withValues(alpha: 0.3)),
                const SizedBox(height: 8),
                Text(
                  'No banks found within ${_searchRadiusMeters ~/ 1000} km.\nTry increasing the search radius.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      color: scheme.onSurface.withValues(alpha: 0.55)),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  Widget _mapLegendDot(Color color) => Container(
        width: 12,
        height: 12,
        decoration: BoxDecoration(color: color, shape: BoxShape.circle),
      );

  double _zoomForRadius(int radiusMeters) {
    if (radiusMeters <= 1000) return 15.0;
    if (radiusMeters <= 3000) return 14.0;
    if (radiusMeters <= 5000) return 13.0;
    return 12.0;
  }

  Future<void> _calculateRouteToBranch(LiveBankBranch branch) async {
    if (_userPosition == null) return;
    setState(() {
      _selectedBranch = branch;
      _isLoadingRoute = true;
      _activeRoute = [];
      _turnByTurnText = 'Calculating route...';
    });
    
    try {
      final route = await RoutingService.fetchRoute(
        start: LatLng(_userPosition!.latitude, _userPosition!.longitude),
        end: LatLng(branch.lat, branch.lng),
        mode: _travelMode,
      );
      
      if (!mounted) return;
      
      setState(() {
        _activeRoute = route.polyline;
        _isLoadingRoute = false;
        
        final stepsText = route.steps.take(2).join(' then ');
        _turnByTurnText = '${route.distanceKm.toStringAsFixed(1)} km (${route.durationMins} min) — $stepsText';
      });
      
      if (_activeRoute.isNotEmpty) {
        final bounds = LatLngBounds.fromPoints(_activeRoute);
        _bankMapController.fitCamera(
          CameraFit.bounds(bounds: bounds, padding: const EdgeInsets.all(30)),
        );
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoadingRoute = false;
        _turnByTurnText = 'Failed to calculate route: $e';
      });
    }
  }

  Future<void> _detectLocation() async {
    setState(() {
      _locationError = null;
      _bankLoading = true;
    });

    try {
      // 1 — check location service
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        setState(() => _locationError =
            'Location service is disabled. Please turn it on.');
        return;
      }

      // 2 — check / request permission
      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        setState(() => _locationError =
            'Location permission denied. Enable it in Settings.');
        return;
      }

      // 3 — get GPS position
      final pos = await Geolocator.getCurrentPosition(
        locationSettings:
            const LocationSettings(accuracy: LocationAccuracy.high),
      );

      // 4 — fetch REAL banks from Overpass API (OpenStreetMap)
      final branches = await BankLocatorService.fetchNearby(
        lat: pos.latitude,
        lng: pos.longitude,
        radiusMeters: _searchRadiusMeters,
      );

      // Sort by distance
      branches.sort((a, b) {
        final da = Geolocator.distanceBetween(
            pos.latitude, pos.longitude, a.lat, a.lng);
        final db = Geolocator.distanceBetween(
            pos.latitude, pos.longitude, b.lat, b.lng);
        return da.compareTo(db);
      });

      setState(() {
        _userPosition = pos;
        _liveBranches = branches;
        _showBankMap = true;
      });

      // Start live sensor tracking
      _positionStream?.cancel();
      _positionStream = Geolocator.getPositionStream(
        locationSettings: const LocationSettings(accuracy: LocationAccuracy.high, distanceFilter: 10),
      ).listen((Position position) {
        if (mounted) {
          setState(() => _userPosition = position);
        }
      });

      // 5 — animate map to user position
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        _bankMapController.move(
          LatLng(pos.latitude, pos.longitude),
          _zoomForRadius(_searchRadiusMeters),
        );
      });
    } catch (e) {
      setState(() =>
          _locationError = 'Failed to fetch bank data: ${e.toString()}');
    } finally {
      if (mounted) setState(() => _bankLoading = false);
    }
  }

  Widget _featureLaunchCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    final scheme = Theme.of(context).colorScheme;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: scheme.surfaceContainerLowest,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: scheme.outline.withValues(alpha: 0.2)),
        ),
        child: Row(
          children: [
            CircleAvatar(
              backgroundColor: scheme.primaryContainer.withValues(alpha: 0.3),
              child: Icon(icon, color: scheme.primary),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(fontWeight: FontWeight.w700)),
                  const SizedBox(height: 2),
                  Text(subtitle, style: TextStyle(color: scheme.onSurface.withValues(alpha: 0.55), fontSize: 12)),
                ],
              ),
            ),
            Icon(Icons.arrow_forward_ios_rounded, size: 16, color: scheme.onSurface.withValues(alpha: 0.4)),
          ],
        ),
      ),
    );
  }

  Widget _packingCard(List<PackingItem> checklist) {
    final completion = checklist.isEmpty ? 0.0 : _packingDone.length / checklist.length;
    final scheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: scheme.outline.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          DropdownButtonFormField<String>(
            initialValue: _region,
            items: packingByRegion.keys.map((r) => DropdownMenuItem(value: r, child: Text(r))).toList(),
            onChanged: (v) => setState(() {
              _region = v ?? 'Danakil';
              _packingDone.clear();
            }),
            decoration: const InputDecoration(labelText: 'Region / visit type'),
          ),
          const SizedBox(height: 10),
          LinearProgressIndicator(value: completion),
          const SizedBox(height: 8),
          Text('Checklist completion: ${(completion * 100).round()}%'),
          const SizedBox(height: 8),
          ...checklist.map(
            (item) => CheckboxListTile(
              contentPadding: EdgeInsets.zero,
              value: _packingDone.contains(item.label),
              title: Text(item.label),
              subtitle: item.critical ? const Text('Critical item') : null,
              onChanged: (_) => setState(() {
                if (_packingDone.contains(item.label)) {
                  _packingDone.remove(item.label);
                } else {
                  _packingDone.add(item.label);
                }
              }),
            ),
          ),
        ],
      ),
    );
  }

  Widget _comparisonCard(DestinationCompare quizPick) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: scheme.outline.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Side-by-side comparison', style: TextStyle(fontWeight: FontWeight.w700)),
          const SizedBox(height: 8),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: DataTable(
              columns: const [
                DataColumn(label: Text('Destination')),
                DataColumn(label: Text('Difficulty')),
                DataColumn(label: Text('Cost')),
                DataColumn(label: Text('Best Season')),
                DataColumn(label: Text('Time Needed')),
                DataColumn(label: Text('Recommended')),
              ],
              rows: destinationComparisons
                  .map(
                    (d) => DataRow(cells: [
                      DataCell(Text(d.name)),
                      DataCell(Text(d.difficulty)),
                      DataCell(Text(d.cost)),
                      DataCell(Text(d.bestSeason)),
                      DataCell(Text(d.timeNeeded)),
                      DataCell(Text(d.recommendedDuration)),
                    ]),
                  )
                  .toList(),
            ),
          ),
          const Divider(height: 18),
          const Text('"Which is right for me?" quick quiz', style: TextStyle(fontWeight: FontWeight.w700)),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: DropdownButtonFormField<String>(
                  initialValue: _quizBudget,
                  items: const [
                    DropdownMenuItem(value: 'Low', child: Text('Low budget')),
                    DropdownMenuItem(value: 'Medium', child: Text('Medium budget')),
                    DropdownMenuItem(value: 'High', child: Text('High budget')),
                  ],
                  onChanged: (v) => setState(() => _quizBudget = v ?? 'Medium'),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: DropdownButtonFormField<String>(
                  initialValue: _quizDifficulty,
                  items: const [
                    DropdownMenuItem(value: 'Low', child: Text('Easy')),
                    DropdownMenuItem(value: 'Medium', child: Text('Moderate')),
                    DropdownMenuItem(value: 'High', child: Text('Hard')),
                  ],
                  onChanged: (v) => setState(() => _quizDifficulty = v ?? 'Medium'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _quizDaysCtrl,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(labelText: 'Available days'),
            onChanged: (_) => setState(() {}),
          ),
          const SizedBox(height: 10),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: scheme.secondaryContainer.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text('Best match: ${quizPick.name} | Recommended duration: ${quizPick.recommendedDuration}'),
          ),
        ],
      ),
    );
  }

  DestinationCompare _quizResult() {
    final days = int.tryParse(_quizDaysCtrl.text.trim()) ?? 4;
    final ranked = destinationComparisons.toList();

    ranked.sort((a, b) {
      int scoreA = 0;
      int scoreB = 0;

      if (_quizBudget == 'Low') {
        scoreA += a.cost.contains('Low') ? 3 : 0;
        scoreB += b.cost.contains('Low') ? 3 : 0;
      }
      if (_quizDifficulty == 'Low') {
        scoreA += a.difficulty.contains('Low') ? 2 : 0;
        scoreB += b.difficulty.contains('Low') ? 2 : 0;
      }

      final da = _durationDays(a.recommendedDuration);
      final db = _durationDays(b.recommendedDuration);
      scoreA += max(0, 4 - (da - days).abs());
      scoreB += max(0, 4 - (db - days).abs());
      return scoreB.compareTo(scoreA);
    });

    return ranked.first;
  }

  int _durationDays(String text) {
    final value = text.replaceAll(RegExp(r'[^0-9]'), '');
    return int.tryParse(value) ?? 3;
  }
}
