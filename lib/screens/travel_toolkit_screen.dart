import 'package:flutter/material.dart';

import '../widgets/ui_components.dart';

class TravelToolkitScreen extends StatefulWidget {
  const TravelToolkitScreen({super.key});

  @override
  State<TravelToolkitScreen> createState() => _TravelToolkitScreenState();
}

class _TravelToolkitScreenState extends State<TravelToolkitScreen> {
  static const double _usdToEtb = 156.8;
  static const double _eurToEtb = 161.3;
  static const double _gbpToEtb = 171.2;
  static const String _ratesUpdated = 'May 21, 2026';

  final TextEditingController _currencyCtrl = TextEditingController(text: '100');
  final TextEditingController _expenseNameCtrl = TextEditingController();
  final TextEditingController _expenseAmountCtrl = TextEditingController();

  String _fromCurrency = 'USD';
  final List<_ExpenseItem> _expenses = [
    const _ExpenseItem(category: 'Transport', amount: 1800),
    const _ExpenseItem(category: 'Meals', amount: 950),
  ];

  @override
  void dispose() {
    _currencyCtrl.dispose();
    _expenseNameCtrl.dispose();
    _expenseAmountCtrl.dispose();
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
}

// ── Currency Card ─────────────────────────────────────────────────────────────
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
    final scheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: scheme.primary.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.currency_exchange_rounded, color: scheme.primary),
              const SizedBox(width: 8),
              const Text(
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
            style: TextStyle(fontSize: 12, color: scheme.onSurface.withValues(alpha: 0.55)),
          ),
        ],
      ),
    );
  }
}

// ── Expense Card ──────────────────────────────────────────────────────────────
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
    final scheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: scheme.secondary.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.receipt_long_rounded, color: scheme.secondary),
              const SizedBox(width: 8),
              const Text(
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
                icon: Icon(Icons.add_circle_rounded, color: scheme.secondary),
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

// ── Simple List Card ──────────────────────────────────────────────────────────
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
    final scheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerLowest,
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
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
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

// ── Expense Item Model ────────────────────────────────────────────────────────
class _ExpenseItem {
  const _ExpenseItem({required this.category, required this.amount});

  final String category;
  final double amount;
}
