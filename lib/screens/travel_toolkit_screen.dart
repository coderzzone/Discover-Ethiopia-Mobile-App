import 'package:flutter/material.dart';

import 'smart_travel_features_screen.dart';
import '../widgets/ui_components.dart';

class TravelToolkitScreen extends StatefulWidget {
  const TravelToolkitScreen({super.key});

  @override
  State<TravelToolkitScreen> createState() => _TravelToolkitScreenState();
}

class _TravelToolkitScreenState extends State<TravelToolkitScreen> {
  static const double _usdToEtb = 56.8;
  static const double _eurToEtb = 61.3;
  static const double _gbpToEtb = 71.2;
  static const String _ratesUpdated = 'May 1, 2026';

  final TextEditingController _currencyCtrl = TextEditingController(
    text: '100',
  );
  final TextEditingController _expenseNameCtrl = TextEditingController();
  final TextEditingController _expenseAmountCtrl = TextEditingController();
  final TextEditingController _assistantCtrl = TextEditingController();

  String _fromCurrency = 'USD';
  final List<_ExpenseItem> _expenses = [
    const _ExpenseItem(category: 'Transport', amount: 1800),
    const _ExpenseItem(category: 'Meals', amount: 950),
  ];
  String _assistantAnswer =
      'Ask: "What is this place?", "Best time to visit?", or "I have 1 day in Addis."';

  @override
  void dispose() {
    _currencyCtrl.dispose();
    _expenseNameCtrl.dispose();
    _expenseAmountCtrl.dispose();
    _assistantCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final rate = _rateFor(_fromCurrency);
    final inputValue = double.tryParse(_currencyCtrl.text.trim()) ?? 0;
    final converted = inputValue * rate;
    final totalExpense = _expenses.fold<double>(
      0,
      (sum, item) => sum + item.amount,
    );

    return Scaffold(
      backgroundColor: scheme.surface,
      appBar: AppBar(
        title: const Text('Offline Tour Guide'),
        backgroundColor: scheme.surface,
        elevation: 0,
        scrolledUnderElevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
        children: [
          _sectionTitle('Toolkit Navigator'),
          _toolNavCard(
            title: 'Money Tools',
            subtitle: 'Open currency converter and expense tracker',
            icon: Icons.account_balance_wallet_rounded,
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (_) => Scaffold(
                  appBar: AppBar(title: const Text('Money Tools')),
                  body: ListView(
                    padding: const EdgeInsets.all(20),
                    children: [
                      _CurrencyCard(
                        amountController: _currencyCtrl,
                        fromCurrency: _fromCurrency,
                        convertedEtb: converted,
                        lastUpdated: _ratesUpdated,
                        onCurrencyChanged: (value) => setState(() => _fromCurrency = value),
                        onAmountChanged: (_) => setState(() {}),
                      ),
                      const SizedBox(height: 12),
                      _ExpenseCard(
                        expenses: _expenses,
                        totalExpense: totalExpense,
                        nameController: _expenseNameCtrl,
                        amountController: _expenseAmountCtrl,
                        onAddExpense: _addExpense,
                        onDeleteExpense: _removeExpense,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 10),
          _toolNavCard(
            title: 'Phrasebook & Smart Tools',
            subtitle: 'Open voice phrasebook and smart travel features',
            icon: Icons.record_voice_over_rounded,
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute<void>(builder: (_) => const SmartTravelFeaturesScreen()),
            ),
          ),
          const SizedBox(height: 10),
          _toolNavCard(
            title: 'Offline Assistant',
            subtitle: 'Ask travel questions in offline mode',
            icon: Icons.smart_toy_rounded,
            onTap: () => showModalBottomSheet<void>(
              context: context,
              isScrollControlled: true,
              builder: (_) => Padding(
                padding: EdgeInsets.fromLTRB(20, 20, 20, MediaQuery.of(context).viewInsets.bottom + 20),
                child: _AssistantCard(
                  controller: _assistantCtrl,
                  answer: _assistantAnswer,
                  onAsk: () {
                    _handleAssistantPrompt();
                    Navigator.pop(context);
                  },
                ),
              ),
            ),
          ),
          const SizedBox(height: 24),
          _sectionTitle('Money Tools'),
          _CurrencyCard(
            amountController: _currencyCtrl,
            fromCurrency: _fromCurrency,
            convertedEtb: converted,
            lastUpdated: _ratesUpdated,
            onCurrencyChanged: (value) => setState(() => _fromCurrency = value),
            onAmountChanged: (_) => setState(() {}),
          ),
          const SizedBox(height: 12),
          _ExpenseCard(
            expenses: _expenses,
            totalExpense: totalExpense,
            nameController: _expenseNameCtrl,
            amountController: _expenseAmountCtrl,
            onAddExpense: _addExpense,
            onDeleteExpense: _removeExpense,
          ),
          const SizedBox(height: 24),
          _sectionTitle('Local Knowledge'),
          const _SimpleListCard(
            icon: Icons.restaurant_rounded,
            title: 'Local Food Recommendations',
            color: EthioColors.tertiary,
            lines: [
              'Addis Ababa: Tibs, shiro, fasting platters, coffee ceremony.',
              'Lalibela: Honey wine (tej), lentil stews, local injera houses.',
              'Harar: Harari dishes, spicy sauces, street sambusa at sunset.',
            ],
          ),
          const SizedBox(height: 12),
          const _SimpleListCard(
            icon: Icons.shield_rounded,
            title: 'Safety Tips by Region',
            color: EthioColors.error,
            lines: [
              'Highlands: Carry layers; temperatures drop quickly after sunset.',
              'Danakil/Afar: Use guided tours only, hydrate aggressively.',
              'Cities: Keep copies of ID and use registered transport at night.',
            ],
          ),
          const SizedBox(height: 12),
          const _SimpleListCard(
            icon: Icons.volunteer_activism_rounded,
            title: 'Local Etiquette Tips',
            color: EthioColors.secondary,
            lines: [
              'Greet first: "Selam" before asking questions or prices.',
              'Accept coffee ceremony invitations when possible; it builds trust.',
              'Dress modestly in religious areas and ask before photos.',
            ],
          ),
          const SizedBox(height: 24),
          FilledButton.icon(
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => const SmartTravelFeaturesScreen(),
                ),
              );
            },
            icon: const Icon(Icons.auto_awesome_rounded),
            label: const Text('Open Smart Travel Features'),
          ),
          const SizedBox(height: 24),
          _sectionTitle('AI Travel Assistant (Offline Mode)'),
          _AssistantCard(
            controller: _assistantCtrl,
            answer: _assistantAnswer,
            onAsk: _handleAssistantPrompt,
          ),
          const SizedBox(height: 24),
          _sectionTitle('Stories & Culture'),
          const _StoryCard(
            title: 'Lalibela: Stone and Faith',
            subtitle: 'Short Story',
            body:
                'Local elders say Lalibela was carved with both human devotion and angelic help. Walking the sunken corridors at dawn, you feel how faith shaped not only churches, but an entire way of seeing time and community.',
          ),
          const SizedBox(height: 10),
          const _StoryCard(
            title: 'Harar Hyena Tradition',
            subtitle: 'Myth & Tradition',
            body:
                'In Harar, feeding hyenas is tied to stories of peace between town and wilderness. The ritual blends courage, humor, and respect for nature, and many families pass the role through generations.',
          ),
          const SizedBox(height: 10),
          const _StoryCard(
            title: 'Timkat and Meskel',
            subtitle: 'Festival Mini Documentary',
            body:
                'Timkat (January 19) and Meskel (September 27) transform cities into open-air stages of procession, drums, and white-robed pilgrims. Use destination galleries in this app as your photo-backed mini documentary archive.',
          ),
        ],
      ),
    );
  }

  Widget _sectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Text(
        title,
        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
      ),
    );
  }

  Widget _toolNavCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: EthioColors.surfaceContainerLowest,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: EthioColors.outline.withValues(alpha: 0.2)),
        ),
        child: Row(
          children: [
            CircleAvatar(
              backgroundColor: EthioColors.primaryContainer.withValues(alpha: 0.30),
              child: Icon(icon, color: EthioColors.primary),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(fontWeight: FontWeight.w700)),
                  Text(subtitle, style: const TextStyle(fontSize: 12, color: EthioColors.mutedInk)),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios_rounded, size: 14),
          ],
        ),
      ),
    );
  }

  double _rateFor(String code) {
    switch (code) {
      case 'EUR':
        return _eurToEtb;
      case 'GBP':
        return _gbpToEtb;
      default:
        return _usdToEtb;
    }
  }

  void _addExpense() {
    final name = _expenseNameCtrl.text.trim();
    final amount = double.tryParse(_expenseAmountCtrl.text.trim()) ?? 0;
    if (name.isEmpty || amount <= 0) return;

    setState(() {
      _expenses.add(_ExpenseItem(category: name, amount: amount));
      _expenseNameCtrl.clear();
      _expenseAmountCtrl.clear();
    });
  }

  void _removeExpense(int index) {
    setState(() {
      _expenses.removeAt(index);
    });
  }

  void _handleAssistantPrompt() {
    final q = _assistantCtrl.text.toLowerCase();
    String response;

    if (q.contains('best time')) {
      response =
          'Best overall season is October to March for clear skies and easier road trips.';
    } else if (q.contains('1 day') && q.contains('addis')) {
      response =
          '1-day Addis plan: National Museum, lunch at a traditional restaurant, Mercato walk, then evening coffee ceremony.';
    } else if (q.contains('what is this place') || q.contains('lalibela')) {
      response =
          'Lalibela is a 12th-13th century pilgrimage town known for monolithic churches carved into volcanic rock.';
    } else if (q.contains('safety')) {
      response =
          'Keep emergency contacts offline, avoid remote night travel, and use licensed guides in mountain/desert areas.';
    } else {
      response =
          'Try specific prompts like: "Best time to visit Simien?" or "I have 2 days in Gondar."';
    }

    setState(() => _assistantAnswer = response);
  }
}

class _CurrencyCard extends StatelessWidget {
  const _CurrencyCard({
    required this.amountController,
    required this.fromCurrency,
    required this.convertedEtb,
    required this.lastUpdated,
    required this.onCurrencyChanged,
    required this.onAmountChanged,
  });

  final TextEditingController amountController;
  final String fromCurrency;
  final double convertedEtb;
  final String lastUpdated;
  final ValueChanged<String> onCurrencyChanged;
  final ValueChanged<String> onAmountChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: EthioColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: EthioColors.primary.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.currency_exchange_rounded, color: EthioColors.primary),
              SizedBox(width: 8),
              Text(
                'Currency Converter (Offline)',
                style: TextStyle(fontWeight: FontWeight.w800),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: amountController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: 'Amount'),
                  onChanged: onAmountChanged,
                ),
              ),
              const SizedBox(width: 10),
              DropdownButton<String>(
                value: fromCurrency,
                items: const [
                  DropdownMenuItem(value: 'USD', child: Text('USD')),
                  DropdownMenuItem(value: 'EUR', child: Text('EUR')),
                  DropdownMenuItem(value: 'GBP', child: Text('GBP')),
                ],
                onChanged: (value) {
                  if (value != null) onCurrencyChanged(value);
                },
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            'ETB ${convertedEtb.toStringAsFixed(2)}',
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 4),
          Text(
            'Rates last updated: $lastUpdated',
            style: const TextStyle(fontSize: 12, color: EthioColors.mutedInk),
          ),
        ],
      ),
    );
  }
}

class _ExpenseCard extends StatelessWidget {
  const _ExpenseCard({
    required this.expenses,
    required this.totalExpense,
    required this.nameController,
    required this.amountController,
    required this.onAddExpense,
    required this.onDeleteExpense,
  });

  final List<_ExpenseItem> expenses;
  final double totalExpense;
  final TextEditingController nameController;
  final TextEditingController amountController;
  final VoidCallback onAddExpense;
  final void Function(int index) onDeleteExpense;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: EthioColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: EthioColors.secondary.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.receipt_long_rounded, color: EthioColors.secondary),
              SizedBox(width: 8),
              Text(
                'Expense Tracker',
                style: TextStyle(fontWeight: FontWeight.w800),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: nameController,
                  decoration: const InputDecoration(hintText: 'Category'),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: TextField(
                  controller: amountController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(hintText: 'Amount ETB'),
                ),
              ),
              const SizedBox(width: 8),
              IconButton(
                onPressed: onAddExpense,
                icon: const Icon(
                  Icons.add_circle_rounded,
                  color: EthioColors.secondary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          ...expenses.asMap().entries.map(
            (entry) => ListTile(
              dense: true,
              contentPadding: EdgeInsets.zero,
              title: Text(entry.value.category),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('ETB ${entry.value.amount.toStringAsFixed(0)}'),
                  IconButton(
                    onPressed: () => onDeleteExpense(entry.key),
                    icon: const Icon(Icons.close_rounded, size: 18),
                  ),
                ],
              ),
            ),
          ),
          const Divider(height: 18),
          Text(
            'Total: ETB ${totalExpense.toStringAsFixed(0)}',
            style: const TextStyle(fontWeight: FontWeight.w800),
          ),
        ],
      ),
    );
  }
}

class _AssistantCard extends StatelessWidget {
  const _AssistantCard({
    required this.controller,
    required this.answer,
    required this.onAsk,
  });

  final TextEditingController controller;
  final String answer;
  final VoidCallback onAsk;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: EthioColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: EthioColors.tertiary.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.smart_toy_rounded, color: EthioColors.tertiary),
              SizedBox(width: 8),
              Text(
                'Ask Offline Assistant',
                style: TextStyle(fontWeight: FontWeight.w800),
              ),
            ],
          ),
          const SizedBox(height: 10),
          TextField(
            controller: controller,
            decoration: const InputDecoration(
              hintText: 'Ask a travel question',
              suffixIcon: Icon(Icons.wifi_off_rounded),
            ),
          ),
          const SizedBox(height: 10),
          FilledButton.icon(
            onPressed: onAsk,
            icon: const Icon(Icons.auto_awesome_rounded, size: 18),
            label: const Text('Get Answer'),
          ),
          const SizedBox(height: 10),
          Text(answer),
        ],
      ),
    );
  }
}

class _SimpleListCard extends StatelessWidget {
  const _SimpleListCard({
    required this.icon,
    required this.title,
    required this.lines,
    required this.color,
  });

  final IconData icon;
  final String title;
  final List<String> lines;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: EthioColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          ...lines.map(
            (line) => Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Row(
                children: [
                  Icon(Icons.circle, size: 8, color: color),
                  const SizedBox(width: 8),
                  Expanded(child: Text(line)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StoryCard extends StatelessWidget {
  const _StoryCard({
    required this.title,
    required this.subtitle,
    required this.body,
  });

  final String title;
  final String subtitle;
  final String body;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: EthioColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: EthioColors.outline.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            subtitle,
            style: const TextStyle(
              fontSize: 12,
              color: EthioColors.mutedInk,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16),
          ),
          const SizedBox(height: 8),
          Text(body),
        ],
      ),
    );
  }
}

class _ExpenseItem {
  const _ExpenseItem({required this.category, required this.amount});

  final String category;
  final double amount;
}
