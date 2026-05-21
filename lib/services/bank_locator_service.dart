import 'dart:convert';

import 'package:http/http.dart' as http;

/// A branch returned from the Overpass API (real OpenStreetMap data).
class LiveBankBranch {
  const LiveBankBranch({
    required this.name,
    required this.bankName,
    required this.lat,
    required this.lng,
    this.address,
    this.openingHours,
    this.phone,
    this.operator,
  });

  final String name;
  final String bankName;
  final double lat;
  final double lng;
  final String? address;
  final String? openingHours;
  final String? phone;
  final String? operator;

  String get displayAddress {
    if (address != null && address!.isNotEmpty) return address!;
    return 'See on map';
  }
}

class BankLocatorService {
  // Use GET with query param — avoids the 406 that POST multipart triggers
  static const String _overpassBase = 'https://overpass-api.de/api/interpreter';

  static Future<List<LiveBankBranch>> fetchNearby({
    required double lat,
    required double lng,
    int radiusMeters = 5000,
    String? bankNameFilter,
  }) async {
    final query =
        '[out:json][timeout:20];(node["amenity"="bank"](around:$radiusMeters,$lat,$lng);way["amenity"="bank"](around:$radiusMeters,$lat,$lng););out center tags;';

    // Use GET + URL-encoded query param — fixes 406 Not Acceptable
    final uri = Uri.parse(_overpassBase)
        .replace(queryParameters: {'data': query});

    final response = await http.get(
      uri,
      headers: {
        'Accept': 'application/json',
        'User-Agent': 'EthioExploreApp/1.0 (Mobile App)',
      },
    ).timeout(const Duration(seconds: 30));

    if (response.statusCode != 200) {
      throw Exception(
          'Overpass API error: ${response.statusCode} ${response.reasonPhrase}');
    }

    final json = jsonDecode(response.body) as Map<String, dynamic>;
    final elements = (json['elements'] as List<dynamic>?) ?? [];

    final branches = <LiveBankBranch>[];

    for (final el in elements) {
      final tags = (el['tags'] as Map<String, dynamic>?) ?? {};

      double? elLat;
      double? elLng;
      if (el['type'] == 'node') {
        elLat = (el['lat'] as num?)?.toDouble();
        elLng = (el['lon'] as num?)?.toDouble();
      } else if (el['type'] == 'way' && el['center'] != null) {
        final center = el['center'] as Map<String, dynamic>;
        elLat = (center['lat'] as num?)?.toDouble();
        elLng = (center['lon'] as num?)?.toDouble();
      }
      if (elLat == null || elLng == null) continue;

      final rawName = (tags['name'] as String?) ??
          (tags['operator'] as String?) ??
          (tags['brand'] as String?) ??
          'Bank';

      if (bankNameFilter != null &&
          !rawName.toLowerCase().contains(bankNameFilter.toLowerCase())) {
        continue;
      }

      final addrParts = <String>[
        if (tags['addr:street'] != null) tags['addr:street'] as String,
        if (tags['addr:suburb'] != null) tags['addr:suburb'] as String,
        if (tags['addr:city'] != null) tags['addr:city'] as String,
      ];

      branches.add(LiveBankBranch(
        name: rawName,
        bankName: (tags['operator'] as String?) ??
            (tags['brand'] as String?) ??
            rawName,
        lat: elLat,
        lng: elLng,
        address: addrParts.isNotEmpty ? addrParts.join(', ') : null,
        openingHours: tags['opening_hours'] as String?,
        phone: tags['phone'] as String?,
        operator: tags['operator'] as String?,
      ));
    }

    return branches;
  }
}
