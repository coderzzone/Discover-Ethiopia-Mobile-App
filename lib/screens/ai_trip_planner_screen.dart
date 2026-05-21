import 'dart:async';
import 'package:flutter/material.dart';

import '../models/app_models.dart';
import '../state/app_scope.dart';
import '../services/gemini_trip_planner_service.dart';

class AiTripPlannerScreen extends StatefulWidget {
  const AiTripPlannerScreen({super.key});

  @override
  State<AiTripPlannerScreen> createState() => _AiTripPlannerScreenState();
}

class _AiTripPlannerScreenState extends State<AiTripPlannerScreen> with TickerProviderStateMixin {
  final GeminiTripPlannerService _plannerService = GeminiTripPlannerService();
  String _customQuestions = '';

  double _days = 5;
  double _budget = 5000;
  String _interests = 'History & Culture';
  String _travelStyle = 'Balanced comfort';
  String _season = 'Dry Season';

  final List<String> _interestOptions = ['History & Culture', 'Adventure & Nature', 'Coffee & Culture', 'Mixed'];
  final List<String> _styleOptions = ['Budget', 'Balanced comfort', 'Premium'];
  final List<String> _seasonOptions = ['Dry Season', 'Wet Season'];

  bool _loading = false;
  List<AiPlanSection> _resultSections = [];

  // Animation controllers
  late final AnimationController _orbController;
  late final AnimationController _staggerController;

  // Text cycling
  final List<String> _loadingPhrases = [
    'Analyzing Ethiopian landscapes...',
    'Calculating optimal routes...',
    'Checking travel times...',
    'Drafting your perfect itinerary...',
  ];
  int _phraseIndex = 0;
  Timer? _phraseTimer;

  @override
  void initState() {
    super.initState();
    _orbController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat(reverse: true);

    _staggerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );
  }

  @override
  void dispose() {
    _orbController.dispose();
    _staggerController.dispose();
    _phraseTimer?.cancel();
    super.dispose();
  }

  Future<void> _generate() async {
    _phraseTimer?.cancel();
    _phraseTimer = null;
    setState(() {
      _loading = true;
      _resultSections = [];
      _phraseIndex = 0;
    });

    _phraseTimer = Timer.periodic(const Duration(seconds: 2), (timer) {
      if (!mounted) return;
      setState(() {
        _phraseIndex = (_phraseIndex + 1) % _loadingPhrases.length;
      });
    });

    try {
      final plan = await _plannerService.generatePlan(
        durationDays: _days.toInt(),
        budgetEtb: _budget.toInt(),
        interests: _interests,
        travelerStyle: _travelStyle,
        season: _season,
        customQuestions: _customQuestions.trim(),
      );

      if (!mounted) return;

      setState(() {
        _resultSections = _parseSections(plan);
        _loading = false;
      });
      _phraseTimer?.cancel();
      _phraseTimer = null;
      _staggerController.forward(from: 0);
    } catch (e, st) {
      if (!mounted) return;
      _phraseTimer?.cancel();
      _phraseTimer = null;
      setState(() {
        _loading = false;
        _resultSections = [
          AiPlanSection(title: 'Error', body: 'Failed to generate plan. Please try again.\n\nDetails: $e\n$st')
        ];
      });
      _staggerController.forward(from: 0);
    }
  }

  List<AiPlanSection> _parseSections(String text) {
    final titles = [
      'Day-by-Day Tasks',
      'Budget Breakdown',
      'Packing Essentials',
      'Safety Tips',
    ];

    final lines = text.split('\n');
    final sections = <AiPlanSection>[];
    String? currentTitle;
    final buffer = StringBuffer();

    for (final rawLine in lines) {
      final line = rawLine.trim().toLowerCase();
      // Remove common markdown formatting characters from start
      final cleanLine = line.replaceAll(RegExp(r'^[\#\*\-\s]+'), '').replaceAll(RegExp(r'[\*\#]+$'), '').trim();

      final matched = titles.firstWhere(
        (t) => cleanLine.startsWith(t.toLowerCase()),
        orElse: () => '',
      );

      if (matched.isNotEmpty) {
        if (currentTitle != null) {
          sections.add(AiPlanSection(title: currentTitle, body: buffer.toString().trim()));
          buffer.clear();
        }
        currentTitle = matched;
        continue;
      }
      buffer.writeln(rawLine);
    }

    if (currentTitle != null) {
      sections.add(AiPlanSection(title: currentTitle, body: buffer.toString().trim()));
    }
    
    if (sections.isEmpty) {
      sections.add(AiPlanSection(title: 'AI Response', body: text));
    }
    
    return sections;
  }

  @override
  Widget build(BuildContext context) {
    final viewIndex = _loading ? 1 : (_resultSections.isNotEmpty ? 2 : 0);
    return IndexedStack(
      index: viewIndex,
      children: [
        _buildInputView(context),
        _buildLoadingView(context),
        _buildResultView(context),
      ],
    );
  }

  Widget _buildInputView(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return ListView(
      padding: EdgeInsets.fromLTRB(20, MediaQuery.paddingOf(context).top + 84, 20, 40),
      children: [
        Text('AI Trip Planner', style: Theme.of(context).textTheme.headlineMedium),
        const SizedBox(height: 8),
        Text('Tell us your preferences and let our AI craft the perfect Ethiopian adventure for you.',
            style: TextStyle(color: scheme.onSurface.withValues(alpha: 0.7), height: 1.4, fontSize: 16)),
        const SizedBox(height: 30),

        if (!_plannerService.configured)
          Container(
            padding: const EdgeInsets.all(16),
            margin: const EdgeInsets.only(bottom: 24),
            decoration: BoxDecoration(
              color: scheme.error.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: scheme.error.withValues(alpha: 0.3)),
            ),
            child: Row(
              children: [
                Icon(Icons.warning_rounded, color: scheme.error),
                const SizedBox(width: 12),
                const Expanded(child: Text('API key missing. Use --dart-define=GEMINI_API_KEY=YOUR_KEY', style: TextStyle(fontWeight: FontWeight.bold))),
              ],
            ),
          ),

        _buildSectionTitle('Trip Duration', '${_days.toInt()} Days'),
        Slider(
          value: _days,
          min: 1,
          max: 14,
          divisions: 13,
          activeColor: scheme.primary,
          onChanged: (val) => setState(() => _days = val),
        ),
        const SizedBox(height: 20),

        _buildSectionTitle('Budget (ETB)', '${_budget.toInt()} ETB'),
        Slider(
          value: _budget,
          min: 5000,
          max: 100000,
          divisions: 19,
          activeColor: scheme.secondary,
          onChanged: (val) => setState(() => _budget = val),
        ),
        const SizedBox(height: 24),

        _buildSectionTitle('Main Interests', ''),
        const SizedBox(height: 12),
        _buildChipSelector(_interestOptions, _interests, (val) => setState(() => _interests = val)),
        const SizedBox(height: 28),

        _buildSectionTitle('Travel Style', ''),
        const SizedBox(height: 12),
        _buildChipSelector(_styleOptions, _travelStyle, (val) => setState(() => _travelStyle = val)),
        const SizedBox(height: 28),

        _buildSectionTitle('Season', ''),
        const SizedBox(height: 12),
        _buildChipSelector(_seasonOptions, _season, (val) => setState(() => _season = val)),
        const SizedBox(height: 28),

        _buildSectionTitle('Special Requests', ''),
        const SizedBox(height: 12),
        TextFormField(
          initialValue: _customQuestions,
          maxLines: 3,
          onChanged: (value) => _customQuestions = value,
          decoration: InputDecoration(
            hintText: 'E.g., I love spicy food, avoid long hikes, traveling with a toddler...',
            filled: true,
            fillColor: scheme.surfaceContainerHighest.withValues(alpha: 0.3),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(20), borderSide: BorderSide.none),
          ),
        ),
        const SizedBox(height: 40),

        GestureDetector(
          onTap: _plannerService.configured && !_loading ? _generate : null,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            height: 64,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: _plannerService.configured 
                    ? [scheme.primary, scheme.secondary] 
                    : [scheme.outline.withValues(alpha: 0.5), scheme.outline.withValues(alpha: 0.5)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(32),
              boxShadow: _plannerService.configured ? [
                BoxShadow(color: scheme.primary.withValues(alpha: 0.4), blurRadius: 20, offset: const Offset(0, 8)),
              ] : [],
            ),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.auto_awesome_rounded, color: Colors.white),
                SizedBox(width: 12),
                Text('Generate Magic Plan', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSectionTitle(String title, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 17)),
        if (value.isNotEmpty)
          Text(value, style: TextStyle(fontWeight: FontWeight.w800, color: Theme.of(context).colorScheme.primary, fontSize: 16)),
      ],
    );
  }

  Widget _buildChipSelector(List<String> options, String selected, ValueChanged<String> onSelect) {
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: options.map((opt) {
        final isSelected = opt == selected;
        final scheme = Theme.of(context).colorScheme;
        return GestureDetector(
          onTap: () => onSelect(opt),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
            decoration: BoxDecoration(
              color: isSelected ? scheme.primary : scheme.surfaceContainerHighest.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: isSelected ? scheme.primary : scheme.outline.withValues(alpha: 0.1)),
              boxShadow: isSelected
                  ? [BoxShadow(color: scheme.primary.withValues(alpha: 0.3), blurRadius: 12, offset: const Offset(0, 4))]
                  : [],
            ),
            child: Text(
              opt,
              style: TextStyle(
                color: isSelected ? Colors.white : scheme.onSurface,
                fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildLoadingView(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          AnimatedBuilder(
            animation: _orbController,
            builder: (context, child) {
              final scale = 0.8 + (_orbController.value * 0.4);
              final opacity = 0.5 + (_orbController.value * 0.5);
              return Transform.scale(
                scale: scale,
                child: Container(
                  width: 160,
                  height: 160,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        scheme.primary.withValues(alpha: opacity),
                        scheme.secondary.withValues(alpha: opacity * 0.6),
                        scheme.surface.withValues(alpha: 0),
                      ],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: scheme.primary.withValues(alpha: opacity * 0.4),
                        blurRadius: 60 * scale,
                        spreadRadius: 20 * scale,
                      ),
                    ],
                  ),
                  child: Center(
                    child: Icon(Icons.auto_awesome_rounded, color: Colors.white.withValues(alpha: 0.9), size: 50),
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 70),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 600),
            transitionBuilder: (child, animation) {
              return FadeTransition(
                opacity: animation,
                child: SlideTransition(
                  position: Tween<Offset>(begin: const Offset(0, 0.2), end: Offset.zero).animate(animation),
                  child: child,
                ),
              );
            },
            child: Text(
              _loadingPhrases[_phraseIndex],
              key: ValueKey<int>(_phraseIndex),
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: scheme.primary,
                letterSpacing: 0.5,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResultView(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return ListView(
      padding: EdgeInsets.fromLTRB(20, MediaQuery.paddingOf(context).top + 84, 20, 40),
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Your Magic Plan', style: Theme.of(context).textTheme.headlineMedium),
            Container(
              decoration: BoxDecoration(
                color: scheme.surfaceContainerHighest.withValues(alpha: 0.5),
                shape: BoxShape.circle,
              ),
              child: IconButton(
                icon: Icon(Icons.refresh_rounded, color: scheme.primary),
                onPressed: () => setState(() => _resultSections = []),
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),
        ...List.generate(_resultSections.length, (index) {
          final section = _resultSections[index];
          final animation = CurvedAnimation(
            parent: _staggerController,
            curve: Interval(
              (index / _resultSections.length) * 0.6,
              1.0,
              curve: Curves.easeOutCubic,
            ),
          );

          return AnimatedBuilder(
            animation: animation,
            builder: (context, child) {
              return Opacity(
                opacity: animation.value,
                child: Transform.translate(
                  offset: Offset(0, 40 * (1 - animation.value)),
                  child: child,
                ),
              );
            },
            child: Container(
              margin: const EdgeInsets.only(bottom: 20),
              padding: const EdgeInsets.all(22),
              decoration: BoxDecoration(
                color: scheme.surfaceContainerLowest,
                borderRadius: BorderRadius.circular(28),
                border: Border.all(color: scheme.outline.withValues(alpha: 0.12)),
                boxShadow: [
                  BoxShadow(color: scheme.onSurface.withValues(alpha: 0.04), blurRadius: 24, offset: const Offset(0, 8)),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: scheme.primary.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Icon(_getIconForSection(section.title), color: scheme.primary, size: 22),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Text(section.title, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 18, letterSpacing: -0.3)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),
                  Text(
                    section.body.isEmpty ? 'No details returned for this section.' : section.body,
                    style: TextStyle(color: scheme.onSurface.withValues(alpha: 0.8), height: 1.6, fontSize: 15),
                  ),
                ],
              ),
            ),
          );
        }),
        const SizedBox(height: 24),
        AnimatedBuilder(
          animation: _staggerController,
          builder: (context, child) {
            final btnAnimation = CurvedAnimation(
              parent: _staggerController,
              curve: const Interval(0.7, 1.0, curve: Curves.easeOutBack),
            );
            return Opacity(
              opacity: btnAnimation.value.clamp(0.0, 1.0),
              child: Transform.scale(
                scale: 0.9 + (btnAnimation.value * 0.1),
                child: child,
              ),
            );
          },
          child: FilledButton.icon(
            onPressed: () {
              AppStateScope.read(context).saveAiTripPlan(
                title: '${_days.toInt()}-Day $_interests Plan',
                sections: _resultSections,
              );
              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (!mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Plan saved to Saved Plans.')),
                );
              });
            },
            style: FilledButton.styleFrom(
              minimumSize: const Size.fromHeight(64),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
              backgroundColor: scheme.secondary,
            ),
            icon: const Icon(Icons.bookmark_added_rounded, size: 24),
            label: const Text('Save to My Trips', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
          ),
        ),
        const SizedBox(height: 20),
      ],
    );
  }

  IconData _getIconForSection(String title) {
    final lower = title.toLowerCase();
    if (lower.contains('route')) return Icons.map_rounded;
    if (lower.contains('day') || lower.contains('task')) return Icons.calendar_month_rounded;
    if (lower.contains('budget')) return Icons.account_balance_wallet_rounded;
    if (lower.contains('packing') || lower.contains('essential')) return Icons.backpack_rounded;
    if (lower.contains('risk') || lower.contains('safety')) return Icons.health_and_safety_rounded;
    return Icons.auto_awesome_rounded;
  }
}
