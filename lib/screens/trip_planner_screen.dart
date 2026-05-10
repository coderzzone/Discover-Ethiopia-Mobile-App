import 'package:flutter/material.dart';

import '../app.dart';
import '../data/sample_data.dart';
import '../models/app_models.dart';
import '../state/app_localization.dart';
import '../state/app_scope.dart';
import '../widgets/ui_components.dart';


class TripPlannerScreen extends StatefulWidget {
  const TripPlannerScreen({super.key});
  @override
  State<TripPlannerScreen> createState() => _TripPlannerScreenState();
}

class _TripPlannerScreenState extends State<TripPlannerScreen> {
  final Set<int> _expandedDays = {0};
  final Set<String> _packingDone = <String>{};

  static const _packingItems = <String>[
    'Passport / ID copy',
    'Power bank',
    'Offline map saved',
    'Cash (small bills)',
    'Comfortable walking shoes',
    'Light jacket',
  ];

  @override
  Widget build(BuildContext context) {
    final state = AppStateScope.watch(context);
    final plan = state.tripPlan;
    final completion = _packingDone.length / _packingItems.length;

    return ListView(
      padding: EdgeInsets.fromLTRB(20, MediaQuery.paddingOf(context).top + 84, 20, 40),
      children: [
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: EthioColors.primary,
            borderRadius: BorderRadius.circular(30),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      plan.name,
                      style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w800),
                    ),
                  ),
                  IconButton(
                    onPressed: () => _showCreateTripDialog(context),
                    icon: const Icon(Icons.edit_rounded, color: Colors.white),
                  ),
                ],
              ),
              Text(
                '${plan.totalDays} days | ${plan.startDate.day}/${plan.startDate.month} - ${plan.endDate.day}/${plan.endDate.month}',
                style: TextStyle(color: Colors.white.withValues(alpha: 0.84)),
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  Expanded(
                    child: FilledButton.icon(
                      onPressed: () => _showCreateTripDialog(context),
                      style: FilledButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: EthioColors.primary,
                      ),
                      icon: const Icon(Icons.add_rounded, size: 18),
                      label: Text(AppLocalization.tr(context, 'create_new_trip')),
                    ),
                  ),
                  const SizedBox(width: 10),
                  IconButton(
                    onPressed: () => AppStateScope.read(context).clearAllTrip(),
                    icon: const Icon(Icons.delete_outline_rounded, color: Colors.white),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        _readinessCard(completion),
        const SizedBox(height: 16),
        _costCard(context, state, plan),
        const SizedBox(height: 20),
        SectionHeader(title: AppLocalization.tr(context, 'timeline'), subtitle: 'Tap a day to manage stops and times'),
        const SizedBox(height: 14),
        if (plan.days.isEmpty)
          _emptyTripCard()
        else
          Column(
            children: List.generate(plan.days.length, (dayIdx) {
              final day = plan.days[dayIdx];
              final isExpanded = _expandedDays.contains(dayIdx);
              final dayStops = state.destinationsForDay(dayIdx);
              final date = plan.startDate.add(Duration(days: dayIdx));
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _DayCard(
                  dayIndex: dayIdx,
                  dateLabel: '${date.day}/${date.month}/${date.year}',
                  stops: dayStops,
                  stopData: day.stops,
                  notes: day.notes,
                  isExpanded: isExpanded,
                  onToggle: () => setState(() {
                    if (isExpanded) {
                      _expandedDays.remove(dayIdx);
                    } else {
                      _expandedDays.add(dayIdx);
                    }
                  }),
                  onAddStop: () => _showAddStopSheet(context, dayIdx),
                  onRemoveStop: (dest) => AppStateScope.read(context).removeDestinationFromDay(dayIdx, dest.id),
                  onMoveStop: (oldIndex, newIndex) => AppStateScope.read(context).moveStopInDay(dayIdx, oldIndex, newIndex),
                  onUpdateStopTime: (destinationId, arrival, departure) =>
                      AppStateScope.read(context).setStopTimeRange(dayIdx, destinationId, arrival, departure),
                  onNotesChanged: (notes) => AppStateScope.read(context).setDayNotes(dayIdx, notes),
                  onStopTap: (dest) => openDestinationDetails(context, dest),
                ),
              );
            }),
          ),
        const SizedBox(height: 20),
        SectionHeader(title: AppLocalization.tr(context, 'suggested_stops'), subtitle: 'Tap to add to Day 1'),
        const SizedBox(height: 12),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: sampleDestinations.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: 0.95,
          ),
          itemBuilder: (context, index) {
            final dest = sampleDestinations[index];
            final inTrip = state.isInTrip(dest.id);
            return GestureDetector(
              onTap: () {
                if (inTrip) {
                  AppStateScope.read(context).removeFromTrip(dest);
                } else {
                  AppStateScope.read(context).addToTrip(dest);
                }
              },
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(22),
                  border: Border.all(
                    color: inTrip ? EthioColors.secondary : EthioColors.outline.withValues(alpha: 0.10),
                    width: inTrip ? 2 : 1,
                  ),
                  color: EthioColors.surfaceContainerLowest,
                ),
                child: Column(
                  children: [
                    Expanded(
                      child: ClipRRect(
                        borderRadius: const BorderRadius.vertical(top: Radius.circular(21)),
                        child: Image.asset(
                          dest.imageUrl,
                          fit: BoxFit.cover,
                          width: double.infinity,
                          errorBuilder: (context, error, stackTrace) => Container(color: dest.accent.withValues(alpha: 0.15)),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(dest.name, style: const TextStyle(fontWeight: FontWeight.w800), maxLines: 1, overflow: TextOverflow.ellipsis),
                          const SizedBox(height: 3),
                          Text(dest.entryFee, style: const TextStyle(color: EthioColors.mutedInk, fontSize: 12)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _readinessCard(double completion) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: EthioColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: EthioColors.outline.withValues(alpha: 0.10)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              const Icon(Icons.checklist_rtl_rounded, color: EthioColors.secondary),
              const SizedBox(width: 8),
              const Expanded(child: Text('Trip Readiness', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16))),
              Text('${(completion * 100).round()}%', style: const TextStyle(fontWeight: FontWeight.w800)),
            ],
          ),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(99),
            child: LinearProgressIndicator(
              value: completion,
              minHeight: 8,
              color: EthioColors.secondary,
              backgroundColor: EthioColors.secondary.withValues(alpha: 0.15),
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _packingItems.map((item) {
              final done = _packingDone.contains(item);
              return FilterChip(
                selected: done,
                onSelected: (_) => setState(() {
                  if (done) {
                    _packingDone.remove(item);
                  } else {
                    _packingDone.add(item);
                  }
                }),
                label: Text(item),
                selectedColor: EthioColors.secondary.withValues(alpha: 0.16),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _costCard(BuildContext context, dynamic state, TripPlan plan) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: EthioColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(26),
        border: Border.all(color: EthioColors.outline.withValues(alpha: 0.10)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(AppLocalization.tr(context, 'estimated_cost')),
                    const SizedBox(height: 6),
                    Text('ETB ${state.estimatedTripCost.toStringAsFixed(0)}', style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w800)),
                    Text('${state.tripDestinations.length} stops', style: const TextStyle(fontSize: 12, color: EthioColors.mutedInk)),
                  ],
                ),
              ),
              if (plan.budget > 0)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    const Text('Budget'),
                    Text('ETB ${plan.budget}', style: const TextStyle(fontWeight: FontWeight.w700)),
                    Text(
                      state.estimatedTripCost > plan.budget ? 'Over budget' : 'On track',
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        color: state.estimatedTripCost > plan.budget ? EthioColors.error : EthioColors.secondary,
                      ),
                    ),
                  ],
                ),
            ],
          ),

        ],
      ),
    );
  }

  Widget _emptyTripCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: EthioColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(26),
        border: Border.all(color: EthioColors.outline.withValues(alpha: 0.10)),
      ),
      child: FilledButton.icon(
        onPressed: () => _showCreateTripDialog(context),
        icon: const Icon(Icons.add_rounded, size: 18),
        label: const Text('Create Trip'),
      ),
    );
  }

  Future<void> _showCreateTripDialog(BuildContext context) async {
    final state = AppStateScope.read(context);
    final nameCtrl = TextEditingController(text: state.tripPlan.name);
    final budgetCtrl = TextEditingController(text: state.tripPlan.budget > 0 ? state.tripPlan.budget.toString() : '');
    DateTime startDate = state.tripPlan.startDate;
    DateTime endDate = state.tripPlan.endDate;

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetCtx) => StatefulBuilder(
        builder: (ctx, setS) => Container(
          padding: EdgeInsets.fromLTRB(20, 8, 20, MediaQuery.viewInsetsOf(ctx).bottom + 30),
          decoration: const BoxDecoration(
            color: EthioColors.surfaceContainerLowest,
            borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
          ),
          child: SingleChildScrollView(
            child: Column(
              children: [
                TextField(controller: nameCtrl, decoration: const InputDecoration(labelText: 'Trip Name')),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _DatePickerField(
                        label: 'Start Date',
                        date: startDate,
                        onPick: (d) => setS(() {
                          startDate = d;
                          if (endDate.isBefore(d)) endDate = d.add(const Duration(days: 1));
                        }),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _DatePickerField(
                        label: 'End Date',
                        date: endDate,
                        onPick: (d) => setS(() => endDate = d),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: budgetCtrl,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: 'Budget (ETB)'),
                ),
                const SizedBox(height: 16),
                FilledButton(
                  onPressed: () {
                    state.createNewTrip(
                      name: nameCtrl.text,
                      startDate: startDate,
                      endDate: endDate,
                      budget: int.tryParse(budgetCtrl.text.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0,
                    );
                    Navigator.pop(sheetCtx);
                    setState(() {
                      _expandedDays
                        ..clear()
                        ..add(0);
                    });
                  },
                  child: const Text('Create Trip'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
    nameCtrl.dispose();
    budgetCtrl.dispose();
  }

  Future<void> _showAddStopSheet(BuildContext context, int dayIdx) async {
    final state = AppStateScope.read(context);
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
        height: MediaQuery.sizeOf(context).height * 0.65,
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 30),
        decoration: const BoxDecoration(
          color: EthioColors.surfaceContainerLowest,
          borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
        ),
        child: ListView.separated(
          itemCount: sampleDestinations.length,
          separatorBuilder: (context, index) => const SizedBox(height: 10),
          itemBuilder: (_, i) {
            final dest = sampleDestinations[i];
            final already = state.destinationsForDay(dayIdx).any((d) => d.id == dest.id);
            return ListTile(
              tileColor: already ? EthioColors.secondary.withValues(alpha: 0.08) : EthioColors.surfaceContainerLow,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
              title: Text(dest.name, style: const TextStyle(fontWeight: FontWeight.w800)),
              subtitle: Text(dest.region),
              trailing: Icon(already ? Icons.check_circle_rounded : Icons.add_circle_outline_rounded),
              onTap: () {
                if (!already) {
                  state.addDestinationToDay(dayIdx, dest);
                  Navigator.pop(context);
                }
              },
            );
          },
        ),
      ),
    );
  }
}

class _DayCard extends StatefulWidget {
  const _DayCard({
    required this.dayIndex,
    required this.dateLabel,
    required this.stops,
    required this.stopData,
    required this.notes,
    required this.isExpanded,
    required this.onToggle,
    required this.onAddStop,
    required this.onRemoveStop,
    required this.onMoveStop,
    required this.onUpdateStopTime,
    required this.onNotesChanged,
    required this.onStopTap,
  });

  final int dayIndex;
  final String dateLabel;
  final List<Destination> stops;
  final List<TripStop> stopData;
  final String notes;
  final bool isExpanded;
  final VoidCallback onToggle;
  final VoidCallback onAddStop;
  final void Function(Destination) onRemoveStop;
  final void Function(int oldIndex, int newIndex) onMoveStop;
  final void Function(String destinationId, String arrival, String departure) onUpdateStopTime;
  final void Function(String) onNotesChanged;
  final void Function(Destination) onStopTap;

  @override
  State<_DayCard> createState() => _DayCardState();
}

class _DayCardState extends State<_DayCard> {
  late final TextEditingController _notesCtrl;

  @override
  void initState() {
    super.initState();
    _notesCtrl = TextEditingController(text: widget.notes);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: EthioColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: widget.isExpanded ? EthioColors.primary.withValues(alpha: 0.3) : EthioColors.outline.withValues(alpha: 0.10)),
      ),
      child: Column(
        children: [
          ListTile(
            onTap: widget.onToggle,
            title: Text('Day ${widget.dayIndex + 1}', style: const TextStyle(fontWeight: FontWeight.w800)),
            subtitle: Text(widget.dateLabel),
            trailing: Text('${widget.stops.length} stops'),
          ),
          if (widget.isExpanded)
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                children: [
                  ...List.generate(widget.stops.length, (i) {
                    final dest = widget.stops[i];
                    final stop = widget.stopData.firstWhere(
                      (s) => s.destinationId == dest.id,
                      orElse: () => TripStop(destinationId: dest.id),
                    );
                    return Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(color: EthioColors.surfaceContainerLow, borderRadius: BorderRadius.circular(14)),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: GestureDetector(
                                  onTap: () => widget.onStopTap(dest),
                                  child: Text(dest.name, style: const TextStyle(fontWeight: FontWeight.w800)),
                                ),
                              ),
                              IconButton(
                                onPressed: i > 0 ? () => widget.onMoveStop(i, i - 1) : null,
                                icon: const Icon(Icons.arrow_upward_rounded, size: 18),
                              ),
                              IconButton(
                                onPressed: i < widget.stops.length - 1 ? () => widget.onMoveStop(i, i + 1) : null,
                                icon: const Icon(Icons.arrow_downward_rounded, size: 18),
                              ),
                              IconButton(
                                onPressed: () => widget.onRemoveStop(dest),
                                icon: const Icon(Icons.remove_circle_outline_rounded, color: EthioColors.error, size: 20),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Row(
                            children: [
                              Expanded(
                                child: _TimeChip(
                                  label: 'Arrive',
                                  value: stop.arrivalTime,
                                  onTap: (value) => widget.onUpdateStopTime(dest.id, value, stop.departureTime),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: _TimeChip(
                                  label: 'Leave',
                                  value: stop.departureTime,
                                  onTap: (value) => widget.onUpdateStopTime(dest.id, stop.arrivalTime, value),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    );
                  }),
                  OutlinedButton.icon(
                    onPressed: widget.onAddStop,
                    icon: const Icon(Icons.add_rounded),
                    label: const Text('Add Stop'),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: _notesCtrl,
                    maxLines: 2,
                    decoration: const InputDecoration(hintText: 'Day notes...'),
                    onChanged: widget.onNotesChanged,
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class _TimeChip extends StatelessWidget {
  const _TimeChip({required this.label, required this.value, required this.onTap});
  final String label;
  final String value;
  final void Function(String value) onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () async {
        final now = TimeOfDay.now();
        final parts = value.split(':');
        final initial = parts.length == 2
            ? TimeOfDay(hour: int.tryParse(parts[0]) ?? now.hour, minute: int.tryParse(parts[1]) ?? now.minute)
            : now;
        final picked = await showTimePicker(context: context, initialTime: initial);
        if (picked != null) {
          final h = picked.hour.toString().padLeft(2, '0');
          final m = picked.minute.toString().padLeft(2, '0');
          onTap('$h:$m');
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: EthioColors.outline.withValues(alpha: 0.2)),
        ),
        child: Row(
          children: [
            const Icon(Icons.schedule_rounded, size: 15, color: EthioColors.primary),
            const SizedBox(width: 6),
            Text('$label: $value', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700)),
          ],
        ),
      ),
    );
  }
}

class _DatePickerField extends StatelessWidget {
  const _DatePickerField({required this.label, required this.date, required this.onPick});
  final String label;
  final DateTime date;
  final void Function(DateTime) onPick;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        final picked = await showDatePicker(
          context: context,
          initialDate: date,
          firstDate: DateTime(2024),
          lastDate: DateTime(2030),
        );
        if (picked != null) onPick(picked);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
        decoration: BoxDecoration(
          color: EthioColors.surfaceContainerLow,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: EthioColors.outline.withValues(alpha: 0.12)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: const TextStyle(fontSize: 11, color: EthioColors.mutedInk, fontWeight: FontWeight.w700)),
            const SizedBox(height: 4),
            Text('${date.day}/${date.month}/${date.year}', style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
          ],
        ),
      ),
    );
  }
}
