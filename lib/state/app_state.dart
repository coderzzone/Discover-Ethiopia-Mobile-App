import 'dart:convert';

import 'package:flutter/material.dart';

import '../data/local_store.dart';
import '../data/sample_data.dart';
import '../models/app_models.dart';

class AppState extends ChangeNotifier {
  AppState.fresh() : this._(LocalStore.memory());

  AppState._(this._store);

  static const _favoritesKey = 'favorites';
  static const _tripPlanKey = 'trip_plan_v2';
  static const _languageKey = 'language';
  static const _categoryKey = 'category';
  static const _queryKey = 'query';

  final LocalStore _store;

  bool _ready = false;
  String _searchQuery = '';
  String _selectedCategory = 'All';
  Set<String> _favoriteIds = <String>{};
  LanguageOption _language = LanguageOption.english;

  // Full trip plan
  TripPlan _tripPlan = TripPlan.defaultPlan();

  // ── Getters ────────────────────────────────────────────

  bool get ready => _ready;
  String get searchQuery => _searchQuery;
  String get selectedCategory => _selectedCategory;
  LanguageOption get language => _language;
  TripPlan get tripPlan => _tripPlan;
  String get activeTripName => _tripPlan.name;

  List<Destination> get destinations => sampleDestinations;
  Set<String> get favoriteIds => _favoriteIds;

  List<Destination> get favorites =>
      destinations.where((d) => _favoriteIds.contains(d.id)).toList(growable: false);

  // All destination IDs across all days
  List<String> get tripDestinationIds {
    final ids = <String>[];
    for (final day in _tripPlan.days) {
      for (final stop in day.stops) {
        if (!ids.contains(stop.destinationId)) ids.add(stop.destinationId);
      }
    }
    return ids;
  }

  List<Destination> get tripDestinations {
    final byId = {for (final d in destinations) d.id: d};
    return tripDestinationIds.map((id) => byId[id]).whereType<Destination>().toList();
  }

  int get estimatedTripCost {
    int total = _tripPlan.budget > 0 ? 0 : 1200;
    for (final d in tripDestinations) {
      total += _parseEtb(d.entryFee);
    }
    return total + 1200; // buffer for transport/accommodation
  }

  List<String> get categories => const ['All', 'Nature', 'Culture', 'Historical', 'Cities'];

  List<Destination> get filteredDestinations {
    return destinations.where((destination) {
      final matchesQuery = _searchQuery.isEmpty ||
          destination.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          destination.region.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          destination.summary.toLowerCase().contains(_searchQuery.toLowerCase());
      final matchesCategory = _selectedCategory == 'All' || destination.tags.contains(_selectedCategory);
      return matchesQuery && matchesCategory;
    }).toList(growable: false);
  }

  bool isFavorite(String destinationId) => _favoriteIds.contains(destinationId);

  bool isInTrip(String destinationId) => tripDestinationIds.contains(destinationId);

  Destination? destinationById(String id) {
    for (final d in destinations) {
      if (d.id == id) return d;
    }
    return null;
  }

  // ── Trip day helpers ────────────────────────────────────

  List<Destination> destinationsForDay(int dayIndex) {
    if (dayIndex >= _tripPlan.days.length) return [];
    final byId = {for (final d in destinations) d.id: d};
    return _tripPlan.days[dayIndex].stops
        .map((s) => byId[s.destinationId])
        .whereType<Destination>()
        .toList();
  }

  String notesForDay(int dayIndex) {
    if (dayIndex >= _tripPlan.days.length) return '';
    return _tripPlan.days[dayIndex].notes;
  }

  // ── Load ───────────────────────────────────────────────

  Future<void> load() async {
    _favoriteIds = _store.readStringList(_favoritesKey).toSet();
    _searchQuery = _store.readString(_queryKey, fallback: '');
    _selectedCategory = _store.readString(_categoryKey, fallback: 'All');
    _language = _store.readString(_languageKey, fallback: 'english') == 'amharic'
        ? LanguageOption.amharic
        : LanguageOption.english;

    final planJson = _store.readString(_tripPlanKey, fallback: '');
    if (planJson.isNotEmpty) {
      try {
        final decoded = jsonDecode(planJson) as Map<String, dynamic>;
        _tripPlan = TripPlan.fromJson(decoded);
      } catch (_) {
        _tripPlan = TripPlan.defaultPlan();
      }
    }
    _ready = true;
    notifyListeners();
  }

  // ── Search & Category ──────────────────────────────────

  void setSearchQuery(String value) {
    _searchQuery = value;
    _persistString(_queryKey, value);
    notifyListeners();
  }

  void setCategory(String value) {
    _selectedCategory = value;
    _persistString(_categoryKey, value);
    notifyListeners();
  }

  // ── Favorites ──────────────────────────────────────────

  void toggleFavorite(Destination destination) {
    if (_favoriteIds.contains(destination.id)) {
      _favoriteIds.remove(destination.id);
    } else {
      _favoriteIds.add(destination.id);
    }
    _persistStringList(_favoritesKey, _favoriteIds.toList(growable: false));
    notifyListeners();
  }

  // ── Trip — Simple adds (for destination detail screen) ─

  void addToTrip(Destination destination) {
    // Add to first day, or day 0 if no days
    if (_tripPlan.days.isEmpty) {
      _tripPlan.days.add(TripDayPlan(dayIndex: 0));
    }
    final day = _tripPlan.days[0];
    if (!day.stops.any((s) => s.destinationId == destination.id)) {
      day.stops.add(TripStop(destinationId: destination.id));
      _persistTripPlan();
      notifyListeners();
    }
  }

  void removeFromTrip(Destination destination) {
    for (final day in _tripPlan.days) {
      day.stops.removeWhere((s) => s.destinationId == destination.id);
    }
    _persistTripPlan();
    notifyListeners();
  }

  // ── Trip — Full plan management ────────────────────────

  void createNewTrip({
    required String name,
    required DateTime startDate,
    required DateTime endDate,
    int budget = 0,
    String notes = '',
  }) {
    final totalDays = endDate.difference(startDate).inDays + 1;
    final days = List.generate(
      totalDays,
      (i) => TripDayPlan(dayIndex: i),
    );
    _tripPlan = TripPlan(
      name: name.trim().isEmpty ? 'My Trip' : name.trim(),
      startDate: startDate,
      endDate: endDate,
      budget: budget,
      days: days,
      generalNotes: notes,
    );
    _persistTripPlan();
    notifyListeners();
  }

  void setTripName(String name) {
    _tripPlan.name = name.trim().isEmpty ? _tripPlan.name : name.trim();
    _persistTripPlan();
    notifyListeners();
  }

  void addDestinationToDay(int dayIndex, Destination destination) {
    while (_tripPlan.days.length <= dayIndex) {
      _tripPlan.days.add(TripDayPlan(dayIndex: _tripPlan.days.length));
    }
    final day = _tripPlan.days[dayIndex];
    if (!day.stops.any((s) => s.destinationId == destination.id)) {
      day.stops.add(TripStop(destinationId: destination.id));
      _persistTripPlan();
      notifyListeners();
    }
  }

  void removeDestinationFromDay(int dayIndex, String destinationId) {
    if (dayIndex >= _tripPlan.days.length) return;
    _tripPlan.days[dayIndex].stops.removeWhere((s) => s.destinationId == destinationId);
    _persistTripPlan();
    notifyListeners();
  }

  void setDayNotes(int dayIndex, String notes) {
    if (dayIndex >= _tripPlan.days.length) return;
    _tripPlan.days[dayIndex].notes = notes;
    _persistTripPlan();
    notifyListeners();
  }

  void moveStopInDay(int dayIndex, int oldIndex, int newIndex) {
    if (dayIndex >= _tripPlan.days.length) return;
    final stops = _tripPlan.days[dayIndex].stops;
    if (oldIndex < 0 || oldIndex >= stops.length || newIndex < 0 || newIndex >= stops.length) return;
    final item = stops.removeAt(oldIndex);
    stops.insert(newIndex, item);
    _persistTripPlan();
    notifyListeners();
  }

  void setStopTimeRange(int dayIndex, String destinationId, String arrival, String departure) {
    if (dayIndex >= _tripPlan.days.length) return;
    final stops = _tripPlan.days[dayIndex].stops;
    for (final stop in stops) {
      if (stop.destinationId == destinationId) {
        stop.arrivalTime = arrival;
        stop.departureTime = departure;
        _persistTripPlan();
        notifyListeners();
        return;
      }
    }
  }

  void setTripBudget(int budget) {
    _tripPlan.budget = budget;
    _persistTripPlan();
    notifyListeners();
  }

  void clearAllTrip() {
    _tripPlan = TripPlan.defaultPlan();
    _persistTripPlan();
    notifyListeners();
  }

  // ── Language ───────────────────────────────────────────

  void setLanguage(LanguageOption option) {
    _language = option;
    _persistString(_languageKey, option == LanguageOption.amharic ? 'amharic' : 'english');
    notifyListeners();
  }

  // ── Reset ──────────────────────────────────────────────

  Future<void> resetLocalData() async {
    _favoriteIds = <String>{};
    _tripPlan = TripPlan.defaultPlan();
    _searchQuery = '';
    _selectedCategory = 'All';
    _language = LanguageOption.english;
    await _store.remove(_favoritesKey);
    await _store.remove(_tripPlanKey);
    await _store.remove(_queryKey);
    await _store.remove(_categoryKey);
    await _store.remove(_languageKey);
    notifyListeners();
  }

  // ── Private helpers ────────────────────────────────────

  Future<void> _persistTripPlan() =>
      _store.writeString(_tripPlanKey, jsonEncode(_tripPlan.toJson()));

  Future<void> _persistStringList(String key, List<String> value) =>
      _store.writeStringList(key, value);

  Future<void> _persistString(String key, String value) =>
      _store.writeString(key, value);
}

Future<AppState> loadAppState() async {
  final store = await LocalStore.load();
  final state = AppState._(store);
  await state.load();
  return state;
}

int _parseEtb(String value) {
  final digits = value.replaceAll(RegExp(r'[^0-9]'), '');
  if (digits.isEmpty) return 0;
  return int.tryParse(digits) ?? 0;
}
