import 'package:flutter/material.dart';

import '../data/travel_features_data.dart';
import '../models/travel_features_models.dart';
import '../widgets/ui_components.dart';

class AmharicPhrasebookScreen extends StatefulWidget {
  const AmharicPhrasebookScreen({super.key});

  @override
  State<AmharicPhrasebookScreen> createState() => _AmharicPhrasebookScreenState();
}

class _AmharicPhrasebookScreenState extends State<AmharicPhrasebookScreen> {
  String _activeCategory = 'Greetings';
  String _query = '';
  final Set<String> _savedPhrases = <String>{};

  @override
  Widget build(BuildContext context) {
    final categories = const ['Greetings', 'Bargaining', 'Emergencies', 'Directions'];
    final filtered = _filteredPhrases();

    return Scaffold(
      appBar: AppBar(title: const Text('Amharic Phrasebook')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
        children: [
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(18),
              gradient: LinearGradient(
                colors: [
                  Theme.of(context).colorScheme.secondary.withValues(alpha: 0.92),
                  Theme.of(context).colorScheme.primary.withValues(alpha: 0.88),
                ],
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Offline Voice Phrasebook', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w800)),
                const SizedBox(height: 6),
                Text('${_filteredPhrases().length} phrases in $_activeCategory', style: const TextStyle(color: Colors.white70, fontWeight: FontWeight.w600)),
              ],
            ),
          ),
          const SizedBox(height: 12),
          const OfflineChip(label: 'Offline Ready', color: EthioColors.secondary),
          const SizedBox(height: 12),
          TextField(
            decoration: const InputDecoration(
              hintText: 'Search phrase in Amharic or English',
              prefixIcon: Icon(Icons.search_rounded),
            ),
            onChanged: (value) => setState(() => _query = value.trim().toLowerCase()),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: categories
                .map(
                  (category) => ChoiceChip(
                    label: Text(category),
                    selected: _activeCategory == category,
                    onSelected: (_) => setState(() => _activeCategory = category),
                  ),
                )
                .toList(),
          ),
          const SizedBox(height: 12),
          OutlinedButton.icon(
            onPressed: () {
              _simulateVoiceIntent();
            },
            icon: const Icon(Icons.mic_rounded),
            label: const Text('Voice Smart Category'),
          ),
          const SizedBox(height: 8),
          if (_savedPhrases.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Text('Saved phrases: ${_savedPhrases.length}', style: const TextStyle(fontWeight: FontWeight.w700)),
            ),
          ...filtered.map(_phraseTile),
        ],
      ),
    );
  }

  List<PhraseItem> _filteredPhrases() {
    return samplePhrases.where((phrase) {
      final categoryMatch = phrase.category == _activeCategory;
      final queryMatch =
          _query.isEmpty || phrase.amharic.toLowerCase().contains(_query) || phrase.english.toLowerCase().contains(_query);
      return categoryMatch && queryMatch;
    }).toList(growable: false);
  }

  Widget _phraseTile(PhraseItem phrase) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: EthioColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: EthioColors.outline.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(phrase.amharic, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 18)),
              ),
              IconButton(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Pronunciation: ${phrase.pronunciation}')),
                  );
                },
                icon: const Icon(Icons.volume_up_rounded),
              ),
              IconButton(
                onPressed: () {
                  setState(() {
                    if (_savedPhrases.contains(phrase.amharic)) {
                      _savedPhrases.remove(phrase.amharic);
                    } else {
                      _savedPhrases.add(phrase.amharic);
                    }
                  });
                },
                icon: Icon(_savedPhrases.contains(phrase.amharic) ? Icons.bookmark_rounded : Icons.bookmark_border_rounded),
              ),
            ],
          ),
          Text(phrase.english, style: const TextStyle(fontSize: 15)),
          const SizedBox(height: 4),
          Text(
            'Pronunciation: ${phrase.pronunciation}',
            style: const TextStyle(color: EthioColors.mutedInk, fontSize: 12),
          ),
          const SizedBox(height: 6),
          Wrap(
            spacing: 8,
            children: [
              ActionChip(
                avatar: const Icon(Icons.copy_rounded, size: 16),
                label: const Text('Copy'),
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Copied: ${phrase.amharic}')),
                  );
                },
              ),
              ActionChip(
                avatar: const Icon(Icons.translate_rounded, size: 16),
                label: const Text('Meaning'),
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('${phrase.amharic} = ${phrase.english}')),
                  );
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _simulateVoiceIntent() {
    final q = _query.toLowerCase();
    String category = _activeCategory;
    if (q.contains('help') || q.contains('hospital') || q.contains('police')) {
      category = 'Emergencies';
    } else if (q.contains('price') || q.contains('much') || q.contains('cheap')) {
      category = 'Bargaining';
    } else if (q.contains('where') || q.contains('road') || q.contains('taxi')) {
      category = 'Directions';
    } else {
      category = 'Greetings';
    }
    setState(() => _activeCategory = category);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Voice intent matched: $category')),
    );
  }
}
