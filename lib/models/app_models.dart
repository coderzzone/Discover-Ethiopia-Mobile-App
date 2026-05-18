import 'package:flutter/material.dart';
import '../widgets/ui_components.dart';

enum LanguageOption { english, amharic }

class Destination {
  const Destination({
    required this.id,
    required this.name,
    required this.region,
    required this.summary,
    required this.description,
    required this.history,
    required this.tips,
    required this.entryFee,
    required this.bestTimeToVisit,
    required this.imageUrl,
    required this.accent,
    required this.lat,
    required this.lng,
    this.imagePaths = const [],
    this.tags = const [],
    this.isSaved = false,
  });

  final String id;
  final String name;
  final String region;
  final String summary;
  final String description;
  final String history;
  final String tips;
  final String entryFee;
  final String bestTimeToVisit;
  final String imageUrl;
  final Color accent;
  final double lat;
  final double lng;
  final List<String> imagePaths;
  final List<String> tags;
  final bool isSaved;
}

abstract class DirectoryService {
  String get id;
  String get name;
  String get subtitle;
  String get location;
  String get description;
  double get rating;
  List<String> get imagePaths;
  List<String> get highlights;
  Color get brandColor;
  IconData get icon;
}

class Hotel implements DirectoryService {
  const Hotel({
    required this.id,
    required this.name,
    required this.destinationId,
    required this.rating,
    required this.pricePerNight,
    required this.imageUrl,
    required this.location,
    this.description = '',
    this.imagePaths = const [],
    this.highlights = const [],
  });

  @override
  final String id;
  @override
  final String name;
  final String destinationId;
  @override
  final double rating;
  final String pricePerNight;
  final String imageUrl;
  @override
  final String location;
  
  @override
  final String description;
  @override
  final List<String> imagePaths;
  @override
  final List<String> highlights;

  @override
  String get subtitle => pricePerNight;
  @override
  Color get brandColor => EthioColors.primary;
  @override
  IconData get icon => Icons.hotel_rounded;
}

class CarRental implements DirectoryService {
  const CarRental({
    required this.id,
    required this.name,
    required this.carType,
    required this.pricePerDay,
    required this.imageUrl,
    required this.rating,
    required this.location,
    this.description = '',
    this.imagePaths = const [],
    this.highlights = const [],
  });

  @override
  final String id;
  @override
  final String name;
  final String carType;
  final String pricePerDay;
  final String imageUrl;
  @override
  final double rating;
  @override
  final String location;

  @override
  final String description;
  @override
  final List<String> imagePaths;
  @override
  final List<String> highlights;

  @override
  String get subtitle => '$carType • $pricePerDay';
  @override
  Color get brandColor => EthioColors.secondary;
  @override
  IconData get icon => Icons.directions_car_rounded;
}

class TourAgency implements DirectoryService {
  const TourAgency({
    required this.id,
    required this.name,
    required this.specialty,
    required this.contact,
    required this.imageUrl,
    required this.rating,
    required this.location,
    this.description = '',
    this.imagePaths = const [],
    this.highlights = const [],
  });

  @override
  final String id;
  @override
  final String name;
  final String specialty;
  final String contact;
  final String imageUrl;
  @override
  final double rating;
  @override
  final String location;

  @override
  final String description;
  @override
  final List<String> imagePaths;
  @override
  final List<String> highlights;

  @override
  String get subtitle => specialty;
  @override
  Color get brandColor => EthioColors.tertiary;
  @override
  IconData get icon => Icons.tour_rounded;
}

class PlannerDay {
  const PlannerDay({
    required this.dayLabel,
    required this.title,
    required this.subtitle,
    required this.timeRange,
    required this.cost,
    required this.icon,
  });

  final String dayLabel;
  final String title;
  final String subtitle;
  final String timeRange;
  final String cost;
  final IconData icon;
}

class NearbyPlace {
  const NearbyPlace({
    required this.name,
    required this.distance,
    required this.icon,
    required this.color,
  });

  final String name;
  final String distance;
  final IconData icon;
  final Color color;
}

class MapPin {
  const MapPin({
    required this.name,
    required this.position,
    required this.icon,
    required this.color,
  });

  final String name;
  final Alignment position;
  final IconData icon;
  final Color color;
}

class FavoriteSection {
  const FavoriteSection({
    required this.title,
    required this.subtitle,
    required this.destination,
  });

  final String title;
  final String subtitle;
  final Destination destination;
}

// ── Cultural Insights ────────────────────────────────────────────────────────

class CulturalInsight {
  const CulturalInsight({
    required this.id,
    required this.label,
    required this.title,
    required this.subtitle,
    required this.description,
    required this.history,
    required this.tipText,
    required this.when,
    required this.where,
    required this.lat,
    required this.lng,
    required this.icon,
    required this.color,
    this.imagePaths = const [],
    this.entryFee = 'Free',
    this.duration = '1 day',
  });

  final String id;
  final String label;
  final String title;
  final String subtitle;
  final String description;
  final String history;
  final String tipText;
  final String when;
  final String where;
  final double lat;
  final double lng;
  final IconData icon;
  final Color color;
  final List<String> imagePaths;
  final String entryFee;
  final String duration;
}

// ── Full Trip Planner models ─────────────────────────────────────────────────

class TripStop {
  TripStop({
    required this.destinationId,
    this.notes = '',
    this.arrivalTime = '09:00',
    this.departureTime = '17:00',
  });

  final String destinationId;
  String notes;
  String arrivalTime;
  String departureTime;

  Map<String, dynamic> toJson() => {
    'destinationId': destinationId,
    'notes': notes,
    'arrivalTime': arrivalTime,
    'departureTime': departureTime,
  };

  factory TripStop.fromJson(Map<String, dynamic> json) => TripStop(
    destinationId: json['destinationId'] as String,
    notes: (json['notes'] as String?) ?? '',
    arrivalTime: (json['arrivalTime'] as String?) ?? '09:00',
    departureTime: (json['departureTime'] as String?) ?? '17:00',
  );
}

class TripDayPlan {
  TripDayPlan({
    required this.dayIndex,
    List<TripStop>? stops,
    this.notes = '',
  }) : stops = stops ?? [];

  final int dayIndex;
  List<TripStop> stops;
  String notes;

  String get label => dayIndex == 0 ? 'Day 1' : 'Day ${dayIndex + 1}';

  Map<String, dynamic> toJson() => {
    'dayIndex': dayIndex,
    'stops': stops.map((s) => s.toJson()).toList(),
    'notes': notes,
  };

  factory TripDayPlan.fromJson(Map<String, dynamic> json) => TripDayPlan(
    dayIndex: json['dayIndex'] as int,
    stops: ((json['stops'] as List?) ?? [])
        .map((s) => TripStop.fromJson(s as Map<String, dynamic>))
        .toList(),
    notes: (json['notes'] as String?) ?? '',
  );
}

class TripPlan {
  TripPlan({
    required this.name,
    required this.startDate,
    required this.endDate,
    this.budget = 0,
    List<TripDayPlan>? days,
    this.generalNotes = '',
  }) : days = days ?? [];

  String name;
  DateTime startDate;
  DateTime endDate;
  int budget;
  List<TripDayPlan> days;
  String generalNotes;

  int get totalDays => endDate.difference(startDate).inDays + 1;

  Map<String, dynamic> toJson() => {
    'name': name,
    'startDate': startDate.toIso8601String(),
    'endDate': endDate.toIso8601String(),
    'budget': budget,
    'days': days.map((d) => d.toJson()).toList(),
    'generalNotes': generalNotes,
  };

  factory TripPlan.fromJson(Map<String, dynamic> json) {
    final plan = TripPlan(
      name: (json['name'] as String?) ?? 'My Trip',
      startDate: DateTime.tryParse((json['startDate'] as String?) ?? '') ?? DateTime.now(),
      endDate: DateTime.tryParse((json['endDate'] as String?) ?? '') ?? DateTime.now().add(const Duration(days: 3)),
      budget: (json['budget'] as int?) ?? 0,
      generalNotes: (json['generalNotes'] as String?) ?? '',
    );
    plan.days = ((json['days'] as List?) ?? [])
        .map((d) => TripDayPlan.fromJson(d as Map<String, dynamic>))
        .toList();
    return plan;
  }

  static TripPlan defaultPlan() => TripPlan(
    name: 'Lalibela Weekend',
    startDate: DateTime.now(),
    endDate: DateTime.now().add(const Duration(days: 2)),
    budget: 5000,
    days: [TripDayPlan(dayIndex: 0), TripDayPlan(dayIndex: 1), TripDayPlan(dayIndex: 2)],
  );
}

class SavedPlanTask {
  SavedPlanTask({
    required this.id,
    required this.label,
    this.completed = false,
  });

  final String id;
  final String label;
  bool completed;

  Map<String, dynamic> toJson() => {
    'id': id,
    'label': label,
    'completed': completed,
  };

  factory SavedPlanTask.fromJson(Map<String, dynamic> json) => SavedPlanTask(
    id: (json['id'] as String?) ?? '',
    label: (json['label'] as String?) ?? '',
    completed: (json['completed'] as bool?) ?? false,
  );
}

class SavedAiTripPlan {
  SavedAiTripPlan({
    required this.id,
    required this.title,
    required this.createdAt,
    required this.sections,
    required this.tasks,
  });

  final String id;
  String title;
  final DateTime createdAt;
  final List<AiPlanSection> sections;
  final List<SavedPlanTask> tasks;

  int get completedTasks => tasks.where((task) => task.completed).length;

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'createdAt': createdAt.toIso8601String(),
    'sections': sections.map((section) => section.toJson()).toList(),
    'tasks': tasks.map((task) => task.toJson()).toList(),
  };

  factory SavedAiTripPlan.fromJson(Map<String, dynamic> json) => SavedAiTripPlan(
    id: (json['id'] as String?) ?? '',
    title: (json['title'] as String?) ?? 'Saved Plan',
    createdAt: DateTime.tryParse((json['createdAt'] as String?) ?? '') ?? DateTime.now(),
    sections: ((json['sections'] as List?) ?? [])
        .map((section) => AiPlanSection.fromJson(section as Map<String, dynamic>))
        .toList(),
    tasks: ((json['tasks'] as List?) ?? [])
        .map((task) => SavedPlanTask.fromJson(task as Map<String, dynamic>))
        .toList(),
  );
}

class AiPlanSection {
  const AiPlanSection({
    required this.title,
    required this.body,
  });

  final String title;
  final String body;

  Map<String, dynamic> toJson() => {
    'title': title,
    'body': body,
  };

  factory AiPlanSection.fromJson(Map<String, dynamic> json) => AiPlanSection(
    title: (json['title'] as String?) ?? 'Section',
    body: (json['body'] as String?) ?? '',
  );
}
