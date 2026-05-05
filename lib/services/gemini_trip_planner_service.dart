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
      return 'Missing Gemini API key. Start app with --dart-define=GEMINI_API_KEY=YOUR_KEY';
    }

    final modelName = await _resolveModelName();
    final url = Uri.parse(
      'https://generativelanguage.googleapis.com/v1beta/$modelName:generateContent?key=$_apiKey',
    );

    final prompt = '''
You are an expert Ethiopia travel planner.
Create a detailed itinerary.

Trip inputs:
- Duration: $durationDays days
- Budget: ETB $budgetEtb
- Interests: $interests
- Style: $travelerStyle
- Season: $season
- Custom traveler questions: ${customQuestions.isEmpty ? 'None provided' : customQuestions}

Rules:
1) Consider road conditions, realistic travel time, and altitude acclimatization.
2) Include seasonal guidance:
   - Avoid Danakil from June to September.
   - Omo Valley is most accessible June to September.
3) Output sections exactly:
   - Route Summary
   - Day-by-Day Plan
   - Budget Breakdown
   - Packing Priorities
   - Risk & Safety Notes
   - Why This Plan Fits
5) Under each section, answer the user's custom questions where relevant.
4) Keep it practical and specific to Ethiopia.
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
        'temperature': 0.35,
        'maxOutputTokens': 1200,
      },
    });

    final response = await _client.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: body,
    );

    if (response.statusCode < 200 || response.statusCode >= 300) {
      return 'Planner request failed (${response.statusCode}): ${response.body}';
    }

    final json = jsonDecode(response.body) as Map<String, dynamic>;
    final candidates = (json['candidates'] as List?) ?? const [];
    if (candidates.isEmpty) {
      return 'No plan returned by model.';
    }

    final content = (candidates.first as Map<String, dynamic>)['content'] as Map<String, dynamic>?;
    final parts = (content?['parts'] as List?) ?? const [];
    if (parts.isEmpty) {
      return 'No text content returned by model.';
    }

    final text = (parts.first as Map<String, dynamic>)['text'] as String?;
    return text?.trim().isNotEmpty == true ? text!.trim() : 'Empty plan returned by model.';
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
