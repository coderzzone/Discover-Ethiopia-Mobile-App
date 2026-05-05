import 'package:flutter/material.dart';

import '../services/gemini_trip_planner_service.dart';
import '../widgets/ui_components.dart';

class AiTripPlannerScreen extends StatefulWidget {
  const AiTripPlannerScreen({super.key});

  @override
  State<AiTripPlannerScreen> createState() => _AiTripPlannerScreenState();
}

class _AiTripPlannerScreenState extends State<AiTripPlannerScreen> {
  final TextEditingController _daysCtrl = TextEditingController(text: '7');
  final TextEditingController _budgetCtrl = TextEditingController(text: '25000');
  final TextEditingController _questionsCtrl = TextEditingController();
  final GeminiTripPlannerService _plannerService = GeminiTripPlannerService();

  String _interests = 'History, Culture';
  String _travelStyle = 'Balanced comfort';
  String _season = 'Dry Season';
  bool _loading = false;
  String _result = 'Generate a live AI plan for a detailed Ethiopia itinerary.';

  @override
  void dispose() {
    _daysCtrl.dispose();
    _budgetCtrl.dispose();
    _questionsCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('AI Trip Planner')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
        children: [
          if (!_plannerService.configured)
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: EthioColors.error.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: EthioColors.error.withValues(alpha: 0.25)),
              ),
              child: const Text('API key missing. Use --dart-define=GEMINI_API_KEY=YOUR_KEY'),
            ),
          if (!_plannerService.configured) const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _daysCtrl,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: 'Duration (days)'),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: TextField(
                  controller: _budgetCtrl,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: 'Budget (ETB)'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          DropdownButtonFormField<String>(
            initialValue: _interests,
            decoration: const InputDecoration(labelText: 'Interests'),
            items: const [
              DropdownMenuItem(value: 'History, Culture', child: Text('History + Culture')),
              DropdownMenuItem(value: 'Adventure, Nature', child: Text('Adventure + Nature')),
              DropdownMenuItem(value: 'Coffee, Culture', child: Text('Coffee + Culture')),
              DropdownMenuItem(value: 'Mixed', child: Text('Mixed')),
            ],
            onChanged: (value) => setState(() => _interests = value ?? _interests),
          ),
          const SizedBox(height: 10),
          DropdownButtonFormField<String>(
            initialValue: _travelStyle,
            decoration: const InputDecoration(labelText: 'Travel style'),
            items: const [
              DropdownMenuItem(value: 'Budget', child: Text('Budget')),
              DropdownMenuItem(value: 'Balanced comfort', child: Text('Balanced comfort')),
              DropdownMenuItem(value: 'Premium', child: Text('Premium')),
            ],
            onChanged: (value) => setState(() => _travelStyle = value ?? _travelStyle),
          ),
          const SizedBox(height: 10),
          DropdownButtonFormField<String>(
            initialValue: _season,
            decoration: const InputDecoration(labelText: 'Season'),
            items: const [
              DropdownMenuItem(value: 'Dry Season', child: Text('Dry Season')),
              DropdownMenuItem(value: 'Wet Season', child: Text('Wet Season')),
            ],
            onChanged: (value) => setState(() => _season = value ?? _season),
          ),
          const SizedBox(height: 10),
          TextField(
            controller: _questionsCtrl,
            minLines: 2,
            maxLines: 4,
            decoration: const InputDecoration(
              labelText: 'Custom Questions',
              hintText: 'Example: I travel with kids, avoid long drives, need coffee-focused stops.',
            ),
          ),
          const SizedBox(height: 12),
          FilledButton.icon(
            onPressed: _loading ? null : _generate,
            icon: _loading
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                  )
                : const Icon(Icons.auto_awesome_rounded),
            label: Text(_loading ? 'Generating...' : 'Generate Live AI Plan'),
          ),
          const SizedBox(height: 14),
          ..._buildResultCards(_result),
        ],
      ),
    );
  }

  Future<void> _generate() async {
    final days = int.tryParse(_daysCtrl.text.trim()) ?? 5;
    final budget = int.tryParse(_budgetCtrl.text.trim()) ?? 15000;

    setState(() => _loading = true);
    final plan = await _plannerService.generatePlan(
      durationDays: days,
      budgetEtb: budget,
      interests: _interests,
      travelerStyle: _travelStyle,
      season: _season,
      customQuestions: _questionsCtrl.text.trim(),
    );
    if (!mounted) return;
    setState(() {
      _result = plan;
      _loading = false;
    });
  }

  List<Widget> _buildResultCards(String text) {
    final sections = _parseSections(text);
    if (sections.isEmpty) {
      return [
        _sectionCard('AI Response', text),
      ];
    }
    return sections.map((s) => _sectionCard(s.title, s.body)).toList();
  }

  List<_PlanSection> _parseSections(String text) {
    final titles = [
      'Route Summary',
      'Day-by-Day Plan',
      'Budget Breakdown',
      'Packing Priorities',
      'Risk & Safety Notes',
      'Why This Plan Fits',
    ];

    final lines = text.split('\n');
    final sections = <_PlanSection>[];
    String? currentTitle;
    final buffer = StringBuffer();

    for (final rawLine in lines) {
      final line = rawLine.trim();
      final matched = titles.firstWhere(
        (t) => line.toLowerCase().startsWith(t.toLowerCase()),
        orElse: () => '',
      );

      if (matched.isNotEmpty) {
        if (currentTitle != null) {
          sections.add(_PlanSection(currentTitle, buffer.toString().trim()));
          buffer.clear();
        }
        currentTitle = matched;
        continue;
      }
      buffer.writeln(rawLine);
    }

    if (currentTitle != null) {
      sections.add(_PlanSection(currentTitle, buffer.toString().trim()));
    }
    return sections;
  }

  Widget _sectionCard(String title, String body) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: EthioColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: EthioColors.outline.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
          const SizedBox(height: 8),
          SelectableText(body.isEmpty ? 'No details returned for this section.' : body),
        ],
      ),
    );
  }
}

class _PlanSection {
  const _PlanSection(this.title, this.body);
  final String title;
  final String body;
}
