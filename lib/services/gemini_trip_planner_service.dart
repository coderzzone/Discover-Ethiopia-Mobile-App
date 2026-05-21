import 'dart:convert';

import 'package:http/http.dart' as http;

class GeminiTripPlannerService {
  GeminiTripPlannerService({http.Client? client}) : _client = client ?? http.Client();

  final http.Client _client;

  static const _apiKey = String.fromEnvironment('GEMINI_API_KEY', defaultValue: '');
  static const List<String> _preferredModels = [
    'models/gemini-2.5-flash',
    'models/gemini-2.0-flash',
    'models/gemini-1.5-flash',
  ];

  bool get configured => _apiKey.isNotEmpty;

  Future<String> generatePlan({
    required int durationDays,
    required int budgetEtb,
    required String interests,
    required String travelerStyle,
    required String season,
    required String customQuestions,
  }) async {
    if (!configured) {
      throw Exception('Missing Gemini API key. Start app with --dart-define=GEMINI_API_KEY=YOUR_KEY');
    }

    final modelName = await _resolveModelName();
    final url = Uri.parse(
      'https://generativelanguage.googleapis.com/v1beta/$modelName:generateContent?key=$_apiKey',
    );

    final prompt = '''
You are a concise Ethiopia travel planner. Generate a SHORT, structured trip plan.

TRIP:
- Days: $durationDays | Budget: $budgetEtb ETB | Style: $travelerStyle
- Interests: $interests | Season: $season
${customQuestions.isNotEmpty ? '- Special requests: $customQuestions' : ''}

OUTPUT RULES (STRICT):
- Use EXACTLY these 4 section headers on their own line:
  Day-by-Day Tasks
  Budget Breakdown
  Packing Essentials
  Safety Tips

- Under "Day-by-Day Tasks": one bullet per activity using EXACTLY this format:
  • Day 1: Visit National Museum (2h, free entry)
  • Day 1: Lunch at Kategna restaurant (150 ETB)
  • Day 2: Drive to Lalibela (45 min flight, 3200 ETB)
  Keep each bullet SHORT — max 12 words. No paragraphs.

- Under "Budget Breakdown": 3-5 bullet lines only, e.g.:
  • Transport: 8,000 ETB
  • Accommodation: 4,500 ETB
  • Food: 2,000 ETB

- Under "Packing Essentials": 4-6 bullet items only, e.g.:
  • Sunscreen SPF 50+ (Danakil)
  • Warm layers for highlands

- Under "Safety Tips": 3-4 bullet lines only.

Be specific to Ethiopia. No markdown. No extra text outside the sections.
''';

    final body = jsonEncode({
      'contents': [
        {
          'parts': [
            {'text': prompt},
          ],
        },
      ],
      'generationConfig': {
        'temperature': 0.7,
        'maxOutputTokens': 1800,
      },
    });

    final response = await _client.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: body,
    );

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception('Planner request failed (${response.statusCode}): ${response.body}');
    }

    final json = jsonDecode(response.body) as Map<String, dynamic>;
    final candidates = (json['candidates'] as List?) ?? const [];
    if (candidates.isEmpty) {
      throw Exception('No plan returned by model.');
    }

    final content = (candidates.first as Map<String, dynamic>)['content'] as Map<String, dynamic>?;
    final parts = (content?['parts'] as List?) ?? const [];
    if (parts.isEmpty) {
      throw Exception('No text content returned by model.');
    }

    final text = (parts.first as Map<String, dynamic>)['text'] as String?;
    if (text?.trim().isNotEmpty != true) {
      throw Exception('Empty plan returned by model.');
    }
    return text!.trim();
  }

  Future<String> _resolveModelName() async {
    final listUrl = Uri.parse(
      'https://generativelanguage.googleapis.com/v1beta/models?key=$_apiKey',
    );
    final response = await _client.get(listUrl);
    if (response.statusCode < 200 || response.statusCode >= 300) {
      return _preferredModels.first;
    }

    final json = jsonDecode(response.body) as Map<String, dynamic>;
    final models = (json['models'] as List?) ?? const [];
    final supported = <String>{};
    for (final raw in models) {
      final model = raw as Map<String, dynamic>;
      final name = model['name'] as String?;
      final actions = (model['supportedGenerationMethods'] as List?)?.cast<String>() ?? const <String>[];
      if (name != null && actions.contains('generateContent')) {
        supported.add(name);
      }
    }

    for (final candidate in _preferredModels) {
      if (supported.contains(candidate)) return candidate;
    }
    if (supported.isNotEmpty) return supported.first;
    return _preferredModels.first;
  }
}
