import 'package:flutter/material.dart';

import '../models/app_models.dart';
import '../state/app_scope.dart';

class SavedPlansScreen extends StatelessWidget {
  const SavedPlansScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = AppStateScope.watch(context);
    final plans = state.savedAiPlans;
    final scheme = Theme.of(context).colorScheme;

    return ListView(
      padding: EdgeInsets.fromLTRB(20, MediaQuery.paddingOf(context).top + 84, 20, 24),
      children: [
        Text('Saved Plans', style: Theme.of(context).textTheme.headlineMedium),
        const SizedBox(height: 8),
        Text(
          'Reopen your AI itineraries and track progress as you travel.',
          style: TextStyle(color: scheme.onSurface.withValues(alpha: 0.7)),
        ),
        const SizedBox(height: 20),
        if (plans.isEmpty)
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: scheme.surfaceContainerLowest,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: scheme.outline.withValues(alpha: 0.2)),
            ),
            child: Column(
              children: [
                Icon(Icons.auto_awesome_rounded, size: 44, color: scheme.primary),
                const SizedBox(height: 12),
                const Text('No saved AI plans yet', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 17)),
                const SizedBox(height: 6),
                Text(
                  'Generate a trip in AI Planner and tap Save to keep it here.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: scheme.onSurface.withValues(alpha: 0.65)),
                ),
              ],
            ),
          )
        else
          ...plans.map((plan) => _SavedPlanCard(plan: plan)),
      ],
    );
  }
}

class _SavedPlanCard extends StatelessWidget {
  const _SavedPlanCard({required this.plan});

  final SavedAiTripPlan plan;

  @override
  Widget build(BuildContext context) {
    final state = AppStateScope.read(context);
    final scheme = Theme.of(context).colorScheme;
    final total = plan.tasks.length;
    final complete = plan.completedTasks;
    final progress = total == 0 ? 0.0 : complete / total;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: scheme.outline.withValues(alpha: 0.15)),
        boxShadow: [
          BoxShadow(
            color: scheme.onSurface.withValues(alpha: 0.05),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(plan.title, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 17)),
                    const SizedBox(height: 4),
                    Text(
                      '${plan.createdAt.day}/${plan.createdAt.month}/${plan.createdAt.year}  -  $complete/$total completed',
                      style: TextStyle(color: scheme.onSurface.withValues(alpha: 0.65), fontSize: 12),
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: () => state.deleteSavedPlan(plan.id),
                icon: Icon(Icons.delete_outline_rounded, color: scheme.error),
                tooltip: 'Delete plan',
              ),
            ],
          ),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(99),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 8,
              backgroundColor: scheme.surfaceContainerHigh,
            ),
          ),
          const SizedBox(height: 14),
          if (plan.tasks.isEmpty)
            Text(
              'No checklist items parsed. You can still review full sections below.',
              style: TextStyle(color: scheme.onSurface.withValues(alpha: 0.6), fontSize: 12),
            )
          else
            ...plan.tasks.map(
              (task) => CheckboxListTile(
                value: task.completed,
                controlAffinity: ListTileControlAffinity.leading,
                contentPadding: EdgeInsets.zero,
                dense: true,
                onChanged: (_) => state.toggleSavedPlanTask(planId: plan.id, taskId: task.id),
                title: AnimatedDefaultTextStyle(
                  duration: const Duration(milliseconds: 220),
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: task.completed
                        ? scheme.onSurface.withValues(alpha: 0.45)
                        : scheme.onSurface.withValues(alpha: 0.9),
                    decoration: task.completed ? TextDecoration.lineThrough : TextDecoration.none,
                    decorationThickness: 2.2,
                  ),
                  child: Text(task.label),
                ),
              ),
            ),
          const SizedBox(height: 10),
          ExpansionTile(
            tilePadding: EdgeInsets.zero,
            childrenPadding: EdgeInsets.zero,
            title: const Text('View full plan details', style: TextStyle(fontWeight: FontWeight.w700)),
            children: plan.sections
                .map(
                  (section) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(section.title, style: TextStyle(fontWeight: FontWeight.w800, color: scheme.primary)),
                        const SizedBox(height: 6),
                        Text(section.body, style: TextStyle(height: 1.45, color: scheme.onSurface.withValues(alpha: 0.82))),
                      ],
                    ),
                  ),
                )
                .toList(),
          ),
        ],
      ),
    );
  }
}
