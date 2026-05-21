import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';

enum TravelMode { walking, cycling, bus, driving }

class RouteResult {
  const RouteResult({
    required this.polyline,
    required this.distanceKm,
    required this.durationMins,
    required this.steps,
  });

  final List<LatLng> polyline;
  final double distanceKm;
  final int durationMins;
  final List<String> steps;
}

class RoutingService {
  static const String _baseUrl = 'https://router.project-osrm.org/route/v1';

  static Future<RouteResult> fetchRoute({
    required LatLng start,
    required LatLng end,
    required TravelMode mode,
  }) async {
    final String profile;
    switch (mode) {
      case TravelMode.walking:
        profile = 'foot';
        break;
      case TravelMode.cycling:
        profile = 'bike';
        break;
      case TravelMode.bus:
      case TravelMode.driving:
        profile = 'driving';
        break;
    }

    // OSRM expects coordinates in lon,lat format
    final startStr = '${start.longitude},${start.latitude}';
    final endStr = '${end.longitude},${end.latitude}';
    
    final uri = Uri.parse('$_baseUrl/$profile/$startStr;$endStr?geometries=geojson&steps=true&overview=full');

    final response = await http.get(
      uri,
      headers: {'User-Agent': 'EthioExploreApp/1.0 (Mobile App)'},
    ).timeout(const Duration(seconds: 15));

    if (response.statusCode != 200) {
      throw Exception('Routing API error: ${response.statusCode} ${response.reasonPhrase}');
    }

    final json = jsonDecode(response.body) as Map<String, dynamic>;
    final routes = json['routes'] as List?;
    if (routes == null || routes.isEmpty) {
      throw Exception('No route found');
    }

    final route = routes.first as Map<String, dynamic>;
    
    // Parse polyline from GeoJSON
    final geometry = route['geometry'] as Map<String, dynamic>;
    final coordinates = geometry['coordinates'] as List;
    final polyline = coordinates.map((c) {
      final point = c as List;
      return LatLng((point[1] as num).toDouble(), (point[0] as num).toDouble());
    }).toList();

    // Parse distance & duration
    final distanceMeters = (route['distance'] as num?)?.toDouble() ?? 0;
    final durationSeconds = (route['duration'] as num?)?.toDouble() ?? 0;
    
    // Parse steps
    final stepsList = <String>[];
    final legs = route['legs'] as List?;
    if (legs != null && legs.isNotEmpty) {
      final steps = (legs.first['steps'] as List?) ?? [];
      for (final step in steps) {
        final maneuver = step['maneuver'] as Map<String, dynamic>?;
        if (maneuver != null) {
          final instruction = maneuver['type'] as String?;
          final modifier = maneuver['modifier'] as String?;
          final name = step['name'] as String?;
          
          if (instruction != null) {
            var text = '$instruction';
            if (modifier != null) text += ' $modifier';
            if (name != null && name.isNotEmpty) text += ' onto $name';
            stepsList.add(text);
          }
        }
      }
    }

    if (stepsList.isEmpty) {
      stepsList.add('Proceed to destination.');
    }

    return RouteResult(
      polyline: polyline,
      distanceKm: distanceMeters / 1000.0,
      durationMins: (durationSeconds / 60.0).ceil(),
      steps: stepsList,
    );
  }
}
