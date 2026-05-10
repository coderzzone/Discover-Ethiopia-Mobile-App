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
You are an expert, highly enthusiastic Ethiopia travel planner and local guide. Your goal is to craft an incredibly personalized, rich, and detailed itinerary that strictly follows the user's specific inputs and custom questions. Do not give generic advice—tailor everything!

TRIP PROFILE:
- Duration: $durationDays days
- Budget Limit: $budgetEtb ETB (strictly adhere to this budget)
- Core Interests: $interests
- Travel Style: $travelerStyle
- Season of Travel: $season
- CUSTOM REQUESTS / QUESTIONS: ${customQuestions.isEmpty ? 'None provided' : customQuestions}

CRITICAL RULES:
1. CUSTOM REQUESTS FIRST: You MUST explicitly address the user's "CUSTOM REQUESTS" throughout the plan. If they travel with kids, mention kid-friendly spots. If they want coffee, add coffee stops.
2. REALITY CHECK: Factor in Ethiopia's actual road conditions, realistic driving times between cities, and altitude acclimatization (e.g., Addis Ababa is at 2355m).
3. SEASONAL ACCURACY: 
   - Danakil Depression is dangerously hot and mostly closed from June to September.
   - Omo Valley roads can be impassable in the rainy season (July-August) but great otherwise.
4. EXACT OUTPUT FORMAT: You must organize your response using EXACTLY these headings (do not use markdown headers (#)(*)(**), just the exact text followed by a newline):
Route Summary
Day-by-Day Plan
Budget Breakdown
Packing Priorities
Risk & Safety Notes
Why This Plan Fits

Make the tone exciting, practical, and highly specific to Ethiopia. Let's build the perfect trip!
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
        'temperature': 0.85,
        'maxOutputTokens': 8001,
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
